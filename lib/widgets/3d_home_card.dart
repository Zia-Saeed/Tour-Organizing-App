import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trip_app/providers/wishlist_provider.dart';
import 'package:trip_app/widgets/heart_button.dart';

class HomeCard3D extends StatefulWidget {
  const HomeCard3D(
      {super.key,
      required this.imageUrl,
      required this.heroID,
      required this.title,
      required this.price,
      required this.destination,
      required this.description,
      required this.totalSeats,
      required this.tripId});
  final String imageUrl;
  final int heroID;
  final String title, destination, description;
  final double price;
  final int totalSeats;
  final String tripId;

  @override
  State<HomeCard3D> createState() => _HomeCard3DState();
}

class _HomeCard3DState extends State<HomeCard3D>
    with SingleTickerProviderStateMixin {
  Offset location = Offset.zero;
  late AnimationController _controller;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5), // Adjust animation duration
    )
      ..repeat()
      ..addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<dynamic> userWishList = [];
  @override
  Widget build(BuildContext context) {
    final wishLishProvider =
        Provider.of<WishListProvider>(context, listen: false);
    Size screenSize = MediaQuery.of(context).size;

    return Stack(
      children: [
        Transform(
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.002) // perspective
            ..rotateX(0.001 * location.dy)
            ..rotateY(-0.001 * location.dx),
          alignment: FractionalOffset.center,
          child: GestureDetector(
            onPanUpdate: (details) {
              location += details.delta;
              setState(() {});
            },
            onPanEnd: (details) {
              location = Offset.zero;
              setState(() {});
            },
            child: SizedBox(
              height: 200,
              child: Hero(
                tag: widget.heroID,
                child: FancyShimmerImage(
                  imageUrl: widget.imageUrl,
                  boxFit: BoxFit.cover,
                  height: 130,
                  width: double.infinity,
                ),
              ),
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          top: 8,
          child: Center(
            child: Container(
              height: 20,
              width: 200,
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
                  widget.title,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                    overflow: TextOverflow.ellipsis,
                    fontFamily: "Roboto",
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                ),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 60,
          child: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Row(
              children: [
                const Text(
                  "Price: ",
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: "Roboto",
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "\$${widget.price}",
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          left: 0,
          bottom: 40,
          child: Padding(
            padding: const EdgeInsets.only(
              top: 20,
              left: 8.0,
            ),
            child: Row(
              children: [
                SizedBox(
                  width: screenSize.width - 160,
                  child: Text(
                    "Destination: ${widget.destination}",
                    style: const TextStyle(
                      fontFamily: "Roboto",
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                Container(
                  height: 20,
                  width: 120,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                        colors: [Colors.grey, Colors.brown.shade300]),
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.elliptical(
                        50,
                        50,
                      ),
                      bottomLeft: Radius.elliptical(
                        50,
                        50,
                      ),
                    ),
                    color: Colors.white,
                  ),
                  child: Center(
                    child: Text(
                      "Booking left: ${widget.totalSeats}",
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontFamily: "Roboto",
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
        Positioned(
          bottom: 20,
          child: Padding(
            padding: const EdgeInsets.only(
              top: 20,
              left: 8.0,
            ),
            child: Row(
              children: [
                const Text(
                  "Description: ",
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: "Roboto",
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  width: screenSize.width - 110,
                  child: Text(
                    widget.description,
                    style: const TextStyle(
                      fontFamily: "Roboto",
                      color: Colors.white70,
                      overflow: TextOverflow.ellipsis,
                    ),
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
        HeartButton(tripId: widget.tripId),
      ],
    );
  }
}
