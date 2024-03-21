import db from "../../db/db";

const updateIpAddress = async (pickupPointPosition: number, ipAddress: string) => {
  try {
    const pickupPoint = await db.pickup_point.findFirst({
      where: {
        position: pickupPointPosition,
      },
    });

    if (pickupPoint == null) {
      console.log("no pickup point found in position " + pickupPointPosition);
      return;
    }

    await db.cube_scanner.updateMany({
      data: {
        ip_address: ipAddress,
      },
      where: {
        id_pickup_point: pickupPoint.id,
      },
    });
  } catch (error) {
    console.log(error);
  }
};

const cubeScanner = {
  updateIpAddress,
};

export default cubeScanner;
