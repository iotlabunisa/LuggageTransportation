import db from "../../db/db";

const addCube = async (idPerson: number, uuid: string) => {
  try {
    await db.cube.create({
      data: {
        scanned_at: new Date().toISOString(),
        id_person: idPerson,
        uuid: uuid,
      },
    });
  } catch (error) {
    console.log(error);
  }
};

const markCubeAsScanned = async (uuid: string) => {
  try {
    await db.cube.update({
      data: {
        scanned_at: new Date().toISOString(),
      },
      where: {
        uuid: uuid,
      },
    });
  } catch (error) {
    console.log(error);
  }
};

const markCubeAsInserted = async (uuid: string, pickupPointN: number, cubeDropperN: number) => {
  let cubeDropper;
  try {
    cubeDropper = await db.cube_dropper.findFirst({
      where: {
        position: cubeDropperN,
        pickup_point: {
          position: pickupPointN,
        },
      },
    });
  } catch (error) {
    console.log(error);
  }

  if (cubeDropper == null) return;

  try {
    await db.cube.update({
      data: {
        id_cube_dropper: cubeDropper.id,
      },
      where: {
        uuid: uuid,
      },
    });
  } catch (error) {
    console.log(error);
  }
};

const markCubeAsReleased = async (pickupPointN: number, cubeDropperN: number) => {
  let cubeDropper;
  try {
    cubeDropper = await db.cube_dropper.findFirst({
      where: {
        position: cubeDropperN,
        pickup_point: {
          position: pickupPointN,
        },
      },
    });
  } catch (error) {
    console.log(error);
  }

  if (cubeDropper == null) return;

  try {
    await db.cube.updateMany({
      data: {
        released_at: new Date().toISOString(),
        id_cube_dropper: null,
      },
      where: {
        id_cube_dropper: cubeDropper.id,
        released_at: null,
      },
    });
  } catch (error) {
    console.log(error);
  }
};

const getCubesByPerson = async (idPerson: number) => {
  let result;

  try {
    result = await db.cube.findMany({
      select: {
        id: true,
        // cube_dropper: {
        //   select: {
        //     position: true,
        //     pickup_point: {
        //       select: {
        //         position: true,
        //       },
        //     },
        //   },
        // },
      },
      where: {
        AND: [
          {
            id_person: idPerson,
          },
          {
            NOT: [{ id_cube_dropper: null }],
          },
        ],
      },
    });
  } catch (error) {
    console.log(error);
  }

  return result;
};

const cube = {
  add: addCube,
  markAsReleased: markCubeAsReleased,
  markAsInserted: markCubeAsInserted,
  getByPerson: getCubesByPerson,
  markAsScanned: markCubeAsScanned,
};

export default cube;
