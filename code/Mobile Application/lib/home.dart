import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sm_iot_lab/constants/colors.dart';
import 'package:sm_iot_lab/screens/map/screens/route_map.dart';
import 'package:sm_iot_lab/screens/scan/screens/cube_scanner_list.dart';
import 'package:sm_iot_lab/screens/stats/screens/stats.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 1;
  late List<Widget> _widgetOptions;
  late PageController _pageController;

  @override
  void initState() {
    _widgetOptions = <Widget>[
      const RouteMap(),
      const Stats(),
      const CubeScannerList(),
    ];
    _pageController = PageController(initialPage: _selectedIndex);

    super.initState();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _pageController.jumpToPage(_selectedIndex);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.grey[300],
        toolbarHeight: 0,
      ),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: _widgetOptions,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          // color: _getBackgroundColor(),
          border: Border(
            top: BorderSide(
              color: AppColors.purple,
              width: 1.5,
            ),
          ),
        ),
        child: BottomNavigationBar(
          items: [
            BottomNavigationBarItem(
              icon: Container(
                width: 30,
                height: 30,
                margin: const EdgeInsets.only(bottom: 5.0, top: 8.0),
                child: SvgPicture.asset(
                  _selectedIndex == 0
                      ? "assets/navigation_bar/map_selected.svg"
                      : "assets/navigation_bar/map.svg",
                ),
              ),
              label: "Map",
            ),
            BottomNavigationBarItem(
              icon: Container(
                width: 30,
                height: 30,
                margin: const EdgeInsets.only(bottom: 5.0, top: 8.0),
                child: SvgPicture.asset(
                  _selectedIndex == 1
                      ? "assets/navigation_bar/stats_selected.svg"
                      : "assets/navigation_bar/stats.svg",
                ),
              ),
              label: "Stats",
            ),
            BottomNavigationBarItem(
              icon: Container(
                width: 30,
                height: 30,
                margin: const EdgeInsets.only(bottom: 5.0, top: 8.0),
                child: SvgPicture.asset(
                  _selectedIndex == 2
                      ? "assets/navigation_bar/scan_selected.svg"
                      : "assets/navigation_bar/scan.svg",
                ),
              ),
              label: "Scan",
            ),
          ],
          backgroundColor: Colors.white,
          elevation: 0,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          selectedItemColor: AppColors.purple,
          unselectedItemColor: Colors.black,
          selectedLabelStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
