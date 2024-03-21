import mqtt from "mqtt";
import { BROKER_ADDRESS } from "../constants/constants";
import cube from "../model/cube/cube";
import CubeReleased from "./messages/cubeReleased.interface";
import CubeByPerson from "./messages/cubeByPerson.interface";
import cubeScanner from "../model/cubeScanner/cubeScanner";
import CubeScannerIpPublish from "./messages/cubeScannerIpPublish";
import CubeScanned from "./messages/cubeScanned.interface";
import CubeInsertResponse from "./messages/cubeInsertResponse.interface";

const client = mqtt.connect(BROKER_ADDRESS);

client.on("connect", () => {
  console.log("connected");
  const os = require("os");

  let networkInterfaces = os.networkInterfaces();

  let nonLocalInterfaces = {};
  for (let inet in networkInterfaces) {
    let addresses = networkInterfaces[inet];
    for (let i = 0; i < addresses.length; i++) {
      let address = addresses[i];
      if (!address.internal) {
        if (!nonLocalInterfaces[inet]) {
          nonLocalInterfaces[inet] = [];
        }
        nonLocalInterfaces[inet].push(address);
      }
    }
  }

  const ip = nonLocalInterfaces["en0"][1]["address"];
  console.log(`server ip ${ip}`);
  client.publish("sm_iot_lab/server/ip", ip, { retain: true, qos: 1 });
  client.subscribe("sm_iot_lab/#");
});

client.on("message", async (topic, payload) => {
  let jsonPayload;

  if (topic.endsWith("cube/scanned")) {
    // a new cube has been scanned
    console.log("cube scanned");
    jsonPayload = JSON.parse(payload.toString()) as CubeScanned;

    await cube.markAsScanned(jsonPayload.payload);

    // now we need to send an insert_request to the pickup point
    // specified in the payload
    client.publish(
      "sm_iot_lab/pickup_point/" + jsonPayload.pickupPointN + "/cube/insert/request",
      jsonPayload.payload
    );
    return;
  }

  if (topic.endsWith("insert/response")) {
    // a new cube has been inserted in a pickup point
    console.log("cube insert response");
    jsonPayload = JSON.parse(payload.toString()) as CubeInsertResponse;

    console.log(jsonPayload);

    if (jsonPayload.status == "inserted") {
      console.log("cube inserted");
      // now we need to save where this cube has been inserted
      await cube.markAsInserted(
        jsonPayload.cubeId,
        jsonPayload.pickupPointN,
        jsonPayload.cubeDropperN
      );
      return;
    }

    if (jsonPayload.status == "all full") {
      console.log("all full");
      client.publish(
        "sm_iot_lab/pickup_point/" + (jsonPayload.pickupPointN + 1) + "/cube/insert/request",
        jsonPayload.cubeId
      );
      return;
    }
  }

  if (topic.endsWith("release/response")) {
    // a cube has been released from a pickup point
    console.log("cube released");
    jsonPayload = JSON.parse(payload.toString()) as CubeReleased;
    await cube.markAsReleased(jsonPayload.cubeDropperN, jsonPayload.pickupPointN);
    return;
  }

  if (topic.endsWith("person/cubes/get")) {
    // a cube has been released from a pickup point
    console.log("request for cubes for person");
    jsonPayload = JSON.parse(payload.toString()) as CubeByPerson;

    const result = await cube.getByPerson(jsonPayload.person);
    client.publish("sm_iot_lab/person/cubes/info", result != null ? JSON.stringify(result) : "");
    return;
  }

  if (topic.endsWith("ip/post")) {
    jsonPayload = JSON.parse(payload.toString()) as CubeScannerIpPublish;
    console.log("a cube scanner has posted its ip address");

    await cubeScanner.updateIpAddress(jsonPayload.pickupPointN, jsonPayload.ipAddress);
    return;
  }
});
