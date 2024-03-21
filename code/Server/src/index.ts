import express, { Request, Response } from "express";
import db from "./db/db";
import "./mqtt/mqtt";

const app = express();
const port = process.env.PORT || 3000;

app.get("/api/cube-scanner", async (_: Request, res: Response) => {
  console.log("request for cube scanners");

  try {
    const result = await db.cube_scanner.findMany({
      include: {
        pickup_point: {
          select: {
            position: true,
          },
        },
      },
    });
    const response = {
      message: "ok",
      data: result,
    };

    res.json(response);
  } catch (error) {
    res.status(500).json({
      message: "error",
    });
  }
});

app.get("/api/person/:uuid/cubes", async (req: Request, res: Response) => {
  console.log("request for cube");

  var uuid = req.params.uuid;

  try {
    const person = await db.person.findFirst({
      where: {
        uuid: uuid,
      },
    });

    if (person == null) return;

    const result = await db.cube.findMany({
      where: {
        AND: [
          {
            id_person: person.id,
          },
          {
            NOT: [{ id_cube_dropper: null }],
          },
        ],
      },
      include: {
        cube_dropper: {
          include: {
            pickup_point: {
              select: {
                position: true,
              },
            },
          },
        },
      },
    });

    res.json(result);
  } catch (error) {
    res.status(500).json({
      message: "error",
    });
  }
});

app.listen(port, () => {
  console.log(`HTTP Server listening on port ${port}`);
});
