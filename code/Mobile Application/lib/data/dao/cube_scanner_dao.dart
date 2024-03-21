import 'package:sm_iot_lab/api/api.dart';
import 'package:sm_iot_lab/data/model/cube_scanner.dart';

class CubeScannerDAO {
  static Future<List<CubeScanner>?> getAll() async {
    var res = await Api.getCubeScanners();

    if (res != null) {
      return List.generate(res.body["data"].length, (i) {
        return CubeScanner.fromMap(res.body["data"][i]);
      });
    }

    return null;
  }
}
