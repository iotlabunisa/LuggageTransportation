import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sm_iot_lab/constants/colors.dart';
import 'package:sm_iot_lab/home.dart';
import 'package:sm_iot_lab/mqtt/mqtt_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  MQTTService.setup();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      builder: (BuildContext context, Widget? child) {
        return MaterialApp(
          title: 'SM IoT Lab',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: AppColors.purple),
            useMaterial3: true,
          ),
          home: const HomePage(title: 'Home'),
        );
      },
    );
  }
}
