import 'package:sm_iot_lab/data/model/pickup_point.dart';

class CubeScanner {
  int id;
  String? ipAddress;
  int position;
  PickupPoint? pickupPoint;

  CubeScanner({
    required this.id,
    required this.ipAddress,
    required this.position,
    this.pickupPoint,
  });

  static CubeScanner fromMap(Map<String, dynamic> data) {
    return CubeScanner(
      id: data['id'],
      ipAddress: data['ip_address'],
      position: data['pickup_point']["position"],
    );
  }
}
