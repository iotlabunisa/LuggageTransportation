import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sm_iot_lab/constants/colors.dart';
import 'package:sm_iot_lab/mqtt/mqtt_service.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewPage extends StatefulWidget {
  final String url;
  final String name;
  final int position;

  const WebViewPage({
    super.key,
    required this.url,
    required this.name,
    required this.position,
  });

  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _error = false;
  late StreamSubscription<CubeScannedMessage> _cubeScannedStreamSubscription;
  String _qrCodeMessage = "";

  @override
  void initState() {
    super.initState();

    _cubeScannedStreamSubscription = MQTTService.currentQRcodeScanned.stream
        .asBroadcastStream()
        .listen((event) {
      if (event.cubeScanner != widget.position) return;
      setState(() {
        _qrCodeMessage = event.message;
      });
    });

    _controller = WebViewController()
      ..setNavigationDelegate(NavigationDelegate(
        onPageFinished: (url) {
          setState(() {
            _isLoading = false;
          });
        },
        onWebResourceError: (error) {
          setState(() {
            _error = true;
          });
        },
      ))
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(
        Uri.parse(widget.url),
      );
  }

  @override
  void dispose() {
    _cubeScannedStreamSubscription.cancel();
    super.dispose();
  }

  Widget _buildView() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_error) return const Center(child: Text("error"));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: [
        ConstrainedBox(
          constraints: BoxConstraints.loose(const Size(400, 300)),
          child: WebViewWidget(controller: _controller),
        ),
        if (_qrCodeMessage != "") _payloadView(_qrCodeMessage),
      ],
    );
  }

  Widget _payloadView(String payload) {
    var p = jsonDecode(payload);

    return Column(
      children: [
        Container(
          margin: EdgeInsets.only(
            bottom: ScreenUtil().setHeight(20),
            top: ScreenUtil().setHeight(20),
          ),
          child: Text(
            "Last QRCode content:",
            style: TextStyle(
              fontSize: ScreenUtil().setSp(30),
            ),
          ),
        ),
        Text(
          p["payload"],
          style: TextStyle(
            fontSize: ScreenUtil().setSp(40),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // title: Text(widget.name),
        title: Text("Cube Scanner 1"),
        elevation: 0,
        // automaticallyImplyLeading: false,
        backgroundColor: AppColors.bgGray,
        bottomOpacity: 1,
        scrolledUnderElevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
        child: _buildView(),
      ),
    );
  }
}
