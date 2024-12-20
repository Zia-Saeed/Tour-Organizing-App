import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:trip_app/auth/login.dart';
import 'package:trip_app/constss/firebase_auth.dart';
import 'package:trip_app/providers/trips_provider.dart';
import 'package:trip_app/providers/user_provider.dart';
import 'package:trip_app/providers/wishlist_provider.dart';
import 'package:trip_app/screens/bottom_screen.dart';

class FetchScreen extends StatefulWidget {
  const FetchScreen({super.key});

  @override
  State<FetchScreen> createState() => _FetchScreenState();
}

class _FetchScreenState extends State<FetchScreen> {
  @override
  void initState() {
    final tripProvider = Provider.of<TripsProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final wishLishProvider = Provider.of<WishListProvider>(
      context,
      listen: false,
    );

    Future.delayed(const Duration(microseconds: 1), () async {
      if (authInstance.currentUser != null) {
        await tripProvider.fetchTrips();
        await userProvider.fetchUserTrips();
        await wishLishProvider.fetchWishList();
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const BottomScreens(),
            ),
          );
        }
      } else {
        if (mounted) {
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const LoginScreen()));
        }
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Image.asset(
            "assets/images/drawer_image.jpg",
            fit: BoxFit.cover,
            height: double.infinity,
          ),
          Container(
            color: Colors.black.withOpacity(0.7),
          ),
          const Center(
            child: SpinKitFadingFour(
              color: Colors.white,
            ),
          )
        ],
      ),
    );
  }
}
