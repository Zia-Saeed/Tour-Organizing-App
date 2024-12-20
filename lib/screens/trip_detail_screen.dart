import 'dart:io';

import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:trip_app/constss/firebase_auth.dart';
import 'package:trip_app/constss/global_methods.dart';
import 'package:trip_app/providers/rating_provider.dart';
import 'package:trip_app/providers/user_provider.dart';
import 'package:trip_app/widgets/heart_button.dart';
import 'package:url_launcher/url_launcher.dart';

class TripDetailScren extends StatefulWidget {
  const TripDetailScren({
    super.key,
    // required this.imagePath,
    required this.heroID,
    required this.name,
    required this.category,
    required this.destination,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.tripId,
    this.imageUrl =
        "https://tse2.mm.bing.net/th?id=OIP.g6fYBg1__RcGkqhxydKxDAHaE2&pid=Api&P=0&h=220",
    required this.importantInfo,
    required this.price,
    required this.totalseats,
    required this.userId,
    required this.createdByUser,
  });

  final String imageUrl,
      name,
      category,
      destination,
      description,
      startDate,
      endDate,
      tripId,
      importantInfo,
      userId,
      createdByUser;
  final int heroID, totalseats;
  final double price;

  @override
  State<TripDetailScren> createState() => _TripDetailScrenState();
}

class _TripDetailScrenState extends State<TripDetailScren> {
  @override
  void initState() {
    Future.delayed(
        const Duration(
          microseconds: 3,
        ), () async {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final ratingProvider =
          Provider.of<RatingProvider>(context, listen: false);

      await ratingProvider.fetchUserRatings(
        userId: widget.userId,
      );
      await ratingProvider.hasUserRated(
        raterId: authInstance.currentUser!.uid,
        userId: widget.userId,
      );
      await userProvider.userNameById(userId: widget.userId);
    });
    super.initState();
  }

  void openWhatsAppChat(String phoneNumber) async {
    final whatsappURlAndroid =
        'whatsapp://send?phone="$phoneNumber"&text=Hy I want to talk about booking of trip :> ${widget.name}';
    if (Platform.isAndroid) {
      await launchUrl(
        Uri.parse(whatsappURlAndroid),
      );
    } else {
      Fluttertoast.showToast(
        msg: 'Unable to connect to whatsapp',
        backgroundColor: Colors.teal.shade300,
        gravity: ToastGravity.TOP,
        fontSize: 16,
        timeInSecForIosWeb: 4000000,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double averageRating = 0.0;
    bool hasUserRated = false;
    final screenSize = MediaQuery.of(context).size;
    final ratingProvider = Provider.of<RatingProvider>(context);
    averageRating = ratingProvider.getTotalrating;
    hasUserRated = ratingProvider.hasUserAlreadyRated;
    print("has user rated or not is : $hasUserRated");
    //
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndFloat,
      floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
      floatingActionButton: ElevatedButton.icon(
        onPressed: () async {
          final userProvider =
              Provider.of<UserProvider>(context, listen: false);
          final contactNumber = userProvider.getContactNumber;
          openWhatsAppChat(contactNumber);
        },
        label: const Text("Contact for booking"),
        icon: const Icon(
          Icons.chat,
        ),
      ),
      appBar: AppBar(
        title: Text(widget.name),
      ),
      body: Stack(
        children: [
          // Scrollable content behind the image
          SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // Empty space to offset the image
                const SizedBox(height: 300),
                const SizedBox(
                  height: 7,
                ),
                Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        Text(
                          "Location : ${widget.destination}",
                          style: const TextStyle(
                            fontFamily: "Roboto",
                            color: Colors.black54,
                          ),
                        ),
                        // Spacer(),
                        const SizedBox(
                          width: 40,
                        ),
                        Text(
                          "From: ${(widget.startDate.split(" "))[0]} To: ${(widget.endDate.split(" "))[0]}",
                          style: const TextStyle(
                            fontFamily: "Roboto",
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    widget.name,
                    style: const TextStyle(
                      fontFamily: "Roboto",
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                const Text(
                  "Description",
                  style: TextStyle(
                    fontFamily: "Roboto",
                    fontWeight: FontWeight.bold,
                    fontSize: 19,
                    color: Colors.brown,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: Text(
                    widget.description,
                    style: const TextStyle(
                      fontFamily: "Roboto",
                      fontSize: 15,
                      height: 1.5,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const Text(
                  "Important Information",
                  style: TextStyle(
                    fontFamily: "Roboto",
                    fontSize: 19,
                    // height: 1.5,
                    color: Colors.brown,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: Text(
                    widget.importantInfo,
                    style: const TextStyle(
                      height: 1.5,
                      fontFamily: "Roboto",
                      color: Colors.black87,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Organized BY : ${widget.createdByUser}",
                    style: const TextStyle(
                      color: Colors.brown,
                      fontFamily: "Roboto",
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (hasUserRated)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                          "${widget.createdByUser} rating: ${averageRating.toStringAsFixed(2)}"),
                      RatingBar.builder(
                        initialRating:
                            averageRating, // Set the user's rating value
                        minRating: 0, // Minimum rating value
                        direction: Axis.horizontal,
                        allowHalfRating:
                            true, // Allow half-star ratings if applicable
                        itemCount: 5, // Number of stars
                        itemSize: 40.0, // Size of the stars
                        itemBuilder: (context, _) => const Icon(
                          Icons.star,
                          color: Colors.amber,
                        ),
                        onRatingUpdate: (rating) {
                          // No action needed here for read-only, but required by RatingBar.builder
                        },
                        ignoreGestures: true, // Makes the RatingBar read-only
                      ),
                    ],
                  ),
                if (!hasUserRated)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Give Rating"),
                      SizedBox(
                        width: screenSize.width - 150,
                        child: RatingBar.builder(
                          initialRating: averageRating,
                          minRating: 1,
                          direction: Axis.horizontal,
                          allowHalfRating: true,
                          itemCount: 5,
                          itemPadding:
                              const EdgeInsets.symmetric(horizontal: 2.0),
                          itemBuilder: (context, _) => const Icon(
                            Icons.star,
                            color: Colors.yellow,
                          ),
                          onRatingUpdate: (rating) {
                            showMessageDialog(
                                title: "Rating",
                                ctx: context,
                                content:
                                    "Are you sure you want to give this rating",
                                ontapok: () {
                                  ratingProvider.addUserRating(
                                    userId: widget.userId,
                                    raterId: authInstance.currentUser!.uid,
                                    rating: rating,
                                  );
                                  setState(() {});
                                });
                          },
                        ),
                      ),
                    ],
                  ),

                const SizedBox(
                  height: 50,
                ),
              ],
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SizedBox(
              width: double.infinity,
              height: 300,
              child: Hero(
                tag: widget.heroID,
                child: Material(
                  borderRadius: const BorderRadius.only(
                    bottomLeft:
                        Radius.circular(30.0), // Rounded bottom left corner
                    bottomRight:
                        Radius.circular(30.0), // Rounded bottom right corner
                  ),
                  elevation: 20,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      bottomLeft:
                          Radius.circular(30.0), // Rounded bottom left corner
                      bottomRight:
                          Radius.circular(30.0), // Rounded bottom right corner
                    ),
                    child: FancyShimmerImage(
                      imageUrl: widget.imageUrl,
                      boxFit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
          ),
          HeartButton(tripId: widget.tripId),
          Positioned(
            top: 10,
            right: 10,
            child: SizedBox(
              child: Container(
                height: 20,
                width: 100,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topRight: Radius.elliptical(
                      50,
                      50,
                    ),
                    bottomLeft: Radius.elliptical(
                      50,
                      50,
                    ),
                  ),
                  gradient: LinearGradient(
                    colors: [
                      Color.fromARGB(255, 88, 83, 83),
                      Color.fromARGB(255, 219, 156, 134),
                    ],
                  ),
                ),
                child: Center(
                  child: Text(
                    "Seats Left: ${widget.totalseats}",
                    style: const TextStyle(
                      fontFamily: "Roboto",
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
