import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:trip_app/screens/categories_screen.dart';
import 'package:trip_app/screens/create_trip_screen.dart';
import 'package:trip_app/screens/home_screen.dart';
import 'package:trip_app/screens/trip_wislist.dart';

class BottomScreens extends StatefulWidget {
  const BottomScreens({
    super.key,
  });

  @override
  State<BottomScreens> createState() => _BottomScreensState();
}

class _BottomScreensState extends State<BottomScreens> {
  int currentScreen = 0;
  final List<Widget> _screenList = [
    const HomeScreen(),
    const TripsCategoriesScreen(),
    const TripWislistScreen(),
    const CreateTripScreen(),
  ];
  final GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screenList[currentScreen],
      bottomNavigationBar: CurvedNavigationBar(
        key: _bottomNavigationKey,
        backgroundColor: Colors.transparent,
        animationCurve: Curves.easeInOut,
        color: Colors.grey.shade500,
        // color: Colors.transparent,
        animationDuration: const Duration(
          milliseconds: 600,
        ),
        onTap: (value) {
          setState(() {
            currentScreen = value;
          });
        },
        items: const <Widget>[
          Icon(
            // semanticLabel: "Home",
            IconlyLight.home,
          ),
          Icon(
            IconlyLight.category,
          ),
          Icon(
            IconlyLight.bookmark,
          ),
          Icon(
            IconlyLight.edit_square,
          ),
        ],
      ),
    );
  }
}
