import 'package:flutter/material.dart';
import 'package:sm_iot_lab/data/dao/cube_scanner_dao.dart';
import 'package:sm_iot_lab/data/model/cube_scanner.dart';
import 'package:sm_iot_lab/screens/scan/widgets/cube_scanner_item.dart';
import 'package:sm_iot_lab/screens/scan/widgets/webview_page.dart';

class CubeScannerList extends StatefulWidget {
  const CubeScannerList({super.key});

  @override
  State<CubeScannerList> createState() => _CubeScannerListState();
}

class _CubeScannerListState extends State<CubeScannerList> {
  List<CubeScanner>? _cubeScanners;
  @override
  void initState() {
    _retrieveCompletedLaps();
    super.initState();
  }

  Future<void> _retrieveCompletedLaps() async {
    var cubeScanners = await CubeScannerDAO.getAll();

    if (cubeScanners != null) {
      setState(() {
        _cubeScanners = cubeScanners;
      });
    }
  }

  Widget _buildView() {
    if (_cubeScanners == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView.builder(
      itemCount: _cubeScanners!.length,
      itemBuilder: (context, index) {
        if (index > 0) return Container();
        final item = _cubeScanners![index];
        return CubeScannerItem(
          name:
              "Cube Scanner ${item.id} ${item.ipAddress != "" ? "" : "(not connected)"}",
          underline: true,
          onTap: () {
            if (item.ipAddress == "") return;
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return WebViewPage(
                    name: "Cube Scanner ${item.position}",
                    url: "http://${item.ipAddress}",
                    position: item.position,
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        // backgroundColor: Theme.of(context).colorScheme.background,
        toolbarHeight: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0),
        child: Flex(
          direction: Axis.horizontal,
          children: [
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(top: 10),
                child: _buildView(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
