// ignore_for_file: unnecessary_string_interpolations
import 'package:flutter/material.dart';
import 'package:trip_app/trips_data.dart';
import 'package:trip_app/screens/trips_list_screen.dart';

class TripsCategoriesScreen extends StatefulWidget {
  const TripsCategoriesScreen({super.key});

  @override
  State<TripsCategoriesScreen> createState() => _TripsCategoriesScreenState();
}

class _TripsCategoriesScreenState extends State<TripsCategoriesScreen> {
  final List<String> imagesPath = [
    "assets/images/category_images/adventure_trip.jpg",
    "assets/images/category_images/city_break_trip.jpg",
    "assets/images/category_images/cultural_trip.jpg",
    "assets/images/category_images/family_friendly_trip.jpg",
    "assets/images/category_images/road_trip.jpg",
    "assets/images/category_images/luxury_trip.webp",
    "assets/images/category_images/married_trip.webp",
  ];

  // @override
  // void initState() {
  //   super.initState();
  //   // TODO: implement initState
  //   // for (var imagePath in imagesPath) {
  //   //   precacheImage(AssetImage(imagePath), context);
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            "Trips Categories",
          ),
        ),
        body: CustomScrollView(
          slivers: [
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => TripListScreen(
                            title: '${tripsData[index]["category"]}',
                            selectedCategory: tripsData[index]["category"],
                            categorySelected: true,
                          ),
                        ),
                      );
                    },
                    child: Stack(
                      children: [
                        Card(
                          key: ValueKey(imagesPath[index]),
                          elevation: 5,
                          shape: const RoundedRectangleBorder(
                            borderRadius:
                                BorderRadiusDirectional.all(Radius.zero),
                          ),
                          shadowColor: Colors.black,
                          surfaceTintColor: Colors.teal,
                          child: SizedBox(
                            height: 180,
                            width: double.infinity,
                            child: Image.asset(
                              imagesPath[index],
                              fit: BoxFit.cover,
                              height: 180,
                              width: double.infinity,
                            ),
                          ),
                        ),
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 10,
                          child: Center(
                            child: Text(
                              style: const TextStyle(
                                fontFamily: "Roboto",
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: Colors.white,
                              ),
                              "${tripsData[index]["category"]}",
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                childCount: imagesPath.length,
              ),
            ),
          ],
        ));
  }
}
