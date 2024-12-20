import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trip_app/models/trips_model.dart';
import 'package:trip_app/providers/trips_provider.dart';
import 'package:trip_app/providers/user_provider.dart';
import 'package:trip_app/screens/create_trip_screen.dart';
import 'package:trip_app/screens/empty_screen.dart';
import 'package:trip_app/screens/trip_detail_screen.dart';
import 'package:trip_app/trips_data.dart';
import 'package:trip_app/widgets/3d_home_card.dart';

class TripListScreen extends StatefulWidget {
  const TripListScreen({
    super.key,
    required this.title,
    this.tripCreated = false,
    this.categorySelected = false,
    this.selectTripsBySale = false,
    this.selectedCategory = "",
  });
  final String title;
  final bool tripCreated;
  final bool categorySelected;
  final String selectedCategory;
  final bool selectTripsBySale;
  @override
  State<TripListScreen> createState() => TripListScreenState();
}

class TripListScreenState extends State<TripListScreen> {
  final TextEditingController _searchBar = TextEditingController();

  bool catfilteredTrips = true;
  bool userfilteredTrips = true;
  List<TripsModel> userCreatedTrips = [];
  List<TripsModel> categoryTrips = [];
  List<TripsModel> filteredUserTrips = [];
  List<TripsModel> allTrips = [];
  List<TripsModel> onSaleTrips = [];
  List<TripsModel> catFilteredTripsList = [];

  void _categoryfilteredTrips(String query) {
    catfilteredTrips = true;
    catFilteredTripsList = categoryTrips
        .where(
          (element) => element.name.toLowerCase().contains(
                query.toLowerCase().trim(),
              ),
        )
        .toList();
    setState(() {});
  }

  void _filterUserTrips(String query) {
    userfilteredTrips = true;
    filteredUserTrips = userCreatedTrips
        .where((element) => element.name.contains(query.toLowerCase().trim()))
        .toList();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final tripsProvider = Provider.of<TripsProvider>(context);
    userCreatedTrips = userProvider.getuserTrips;
    categoryTrips =
        tripsProvider.tripByCategory(category: widget.selectedCategory);

    onSaleTrips = tripsProvider.getOnSaleTrips;
    allTrips = tripsProvider.getTrips;
    Widget displayWidget = ListView.builder(
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.all(8.0),
        child: GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => TripDetailScren(
                  name: allTrips[index].name,
                  description: allTrips[index].description,
                  destination: allTrips[index].destination,
                  endDate: allTrips[index].endDate,
                  startDate: allTrips[index].startdate,
                  category: allTrips[index].category,
                  tripId: allTrips[index].id,
                  userId: allTrips[index].userid,
                  importantInfo: allTrips[index].importancInfo,
                  price: allTrips[index].price,
                  totalseats: allTrips[index].totalseats,
                  createdByUser: allTrips[index].createdByUser,
                  imageUrl: allTrips[index].imageUrl,
                  heroID: index,
                ),
              ),
            );
          },
          // },
          child: HomeCard3D(
            tripId: allTrips[index].id,
            title: allTrips[index].name,
            description: allTrips[index].description,
            destination: allTrips[index].destination,
            price: allTrips[index].price,
            totalSeats: allTrips[index].totalseats,
            imageUrl: allTrips[index].imageUrl,
            heroID: index,
          ),
        ),
      ),
      itemCount: tripsData.length,
    );
    if (widget.selectTripsBySale) {
      displayWidget = onSaleTrips.isEmpty
          ? EmptyScreen(
              text:
                  "Opps! no Trip have discount or Sale\n                come check later.",
              icon: const Icon(Icons.hourglass_empty_sharp),
              subTitle: "Opps No Trips Created",
              navigatorFunc: () {
                Navigator.of(context).pop();
              })
          : ListView.builder(
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => TripDetailScren(
                          heroID: index,
                          name: onSaleTrips[index].name,
                          category: onSaleTrips[index].category,
                          destination: onSaleTrips[index].destination,
                          description: onSaleTrips[index].description,
                          startDate: onSaleTrips[index].startdate,
                          endDate: onSaleTrips[index].endDate,
                          tripId: onSaleTrips[index].id,
                          importantInfo: onSaleTrips[index].importancInfo,
                          price: onSaleTrips[index].price,
                          totalseats: onSaleTrips[index].totalseats,
                          userId: onSaleTrips[index].userid,
                          createdByUser: onSaleTrips[index].createdByUser,
                          imageUrl: onSaleTrips[index].imageUrl,
                        ),
                      ),
                    );
                  },
                  child: HomeCard3D(
                    tripId: onSaleTrips[index].id,
                    imageUrl: onSaleTrips[index].imageUrl,
                    heroID: index,
                    title: onSaleTrips[index].name,
                    price: onSaleTrips[index].price,
                    destination: onSaleTrips[index].destination,
                    description: onSaleTrips[index].description,
                    totalSeats: onSaleTrips[index].totalseats,
                  ),
                ),
              ),
              itemCount: onSaleTrips.length,
            );
    }
    if (widget.tripCreated) {
      displayWidget = userCreatedTrips.isEmpty
          ? EmptyScreen(
              text: "You haven't created any trips yet!",
              icon: const Icon(Icons.hourglass_empty_sharp),
              subTitle: "Opps No Trips Created",
              navigatorFunc: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => const CreateTripScreen(),
                  ),
                );
              })
          : (filteredUserTrips.isNotEmpty
              ? ListView.builder(
                  itemBuilder: (context, index) => Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => CreateTripScreen(
                              tripId: filteredUserTrips[index].id,
                              name: filteredUserTrips[index].name,
                              seats: filteredUserTrips[index].totalseats,
                              startDate: filteredUserTrips[index].startdate,
                              endDate: filteredUserTrips[index].endDate,
                              selectCategory: filteredUserTrips[index].category,
                              price: filteredUserTrips[index].price,
                              description: filteredUserTrips[index].description,
                              importantInfo:
                                  filteredUserTrips[index].importancInfo,
                              country: filteredUserTrips[index].country,
                              state: filteredUserTrips[index].state,
                              city: filteredUserTrips[index].city,
                              editTrip: true,
                              salePrice: filteredUserTrips[index].salePrice,
                              onSale: filteredUserTrips[index].onSale,
                              imageUrl: filteredUserTrips[index].imageUrl,
                            ),
                          ),
                        );
                      },
                      child: HomeCard3D(
                        tripId: filteredUserTrips[index].id,
                        imageUrl: filteredUserTrips[index].imageUrl,
                        heroID: index,
                        title: filteredUserTrips[index].name,
                        price: filteredUserTrips[index].price,
                        destination: filteredUserTrips[index].destination,
                        description: filteredUserTrips[index].description,
                        totalSeats: filteredUserTrips[index].totalseats,
                      ),
                    ),
                  ),
                  itemCount: userCreatedTrips.length,
                )
              : ListView.builder(
                  itemBuilder: (context, index) => Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => CreateTripScreen(
                              tripId: userCreatedTrips[index].id,
                              name: userCreatedTrips[index].name,
                              seats: userCreatedTrips[index].totalseats,
                              startDate: userCreatedTrips[index].startdate,
                              endDate: userCreatedTrips[index].endDate,
                              selectCategory: userCreatedTrips[index].category,
                              price: userCreatedTrips[index].price,
                              description: userCreatedTrips[index].description,
                              importantInfo:
                                  userCreatedTrips[index].importancInfo,
                              country: userCreatedTrips[index].country,
                              state: userCreatedTrips[index].state,
                              city: userCreatedTrips[index].city,
                              editTrip: true,
                              salePrice: userCreatedTrips[index].salePrice,
                              onSale: userCreatedTrips[index].onSale,
                              imageUrl: userCreatedTrips[index].imageUrl,
                            ),
                          ),
                        );
                      },
                      child: HomeCard3D(
                        tripId: userCreatedTrips[index].id,
                        imageUrl: userCreatedTrips[index].imageUrl,
                        heroID: index,
                        title: userCreatedTrips[index].name,
                        price: userCreatedTrips[index].price,
                        destination: userCreatedTrips[index].destination,
                        description: userCreatedTrips[index].description,
                        totalSeats: userCreatedTrips[index].totalseats,
                      ),
                    ),
                  ),
                  itemCount: userCreatedTrips.length,
                ));
    } else if (widget.categorySelected) {
      displayWidget = categoryTrips.isEmpty
          ? EmptyScreen(
              text: "Opps! No Trips Available for this Category",
              icon: const Icon(Icons.hourglass_empty_outlined),
              subTitle: "Explore More Categories",
              navigatorFunc: () {
                Navigator.of(context).pop();
              })
          : (categoryTrips.isNotEmpty && catFilteredTripsList.isNotEmpty
              ? (catFilteredTripsList.isEmpty
                  ? EmptyScreen(
                      text: "Opps! No Trips Available for this Category",
                      icon: const Icon(Icons.hourglass_empty_outlined),
                      subTitle: "Explore More Categories",
                      navigatorFunc: () {
                        Navigator.of(context).pop();
                      })
                  : ListView.builder(
                      itemBuilder: (context, index) => Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => TripDetailScren(
                                    name: catFilteredTripsList[index].name,
                                    description:
                                        catFilteredTripsList[index].description,
                                    destination:
                                        catFilteredTripsList[index].destination,
                                    endDate:
                                        catFilteredTripsList[index].endDate,
                                    startDate:
                                        catFilteredTripsList[index].startdate,
                                    category:
                                        catFilteredTripsList[index].category,
                                    tripId: catFilteredTripsList[index].id,
                                    userId: catFilteredTripsList[index].userid,
                                    importantInfo: catFilteredTripsList[index]
                                        .importancInfo,
                                    price: catFilteredTripsList[index].price,
                                    totalseats:
                                        catFilteredTripsList[index].totalseats,
                                    createdByUser: catFilteredTripsList[index]
                                        .createdByUser,
                                    imageUrl:
                                        catFilteredTripsList[index].imageUrl,
                                    heroID: index,
                                  ),
                                ),
                              );
                            },
                            child: HomeCard3D(
                              tripId: catFilteredTripsList[index].id,
                              imageUrl: catFilteredTripsList[index].imageUrl,
                              heroID: index,
                              title: catFilteredTripsList[index].name,
                              price: catFilteredTripsList[index].price,
                              destination:
                                  catFilteredTripsList[index].destination,
                              description:
                                  catFilteredTripsList[index].description,
                              totalSeats:
                                  catFilteredTripsList[index].totalseats,
                            )),
                      ),
                      itemCount: catFilteredTripsList.length,
                    ))
              : ListView.builder(
                  itemBuilder: (context, index) => Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => TripDetailScren(
                                name: categoryTrips[index].name,
                                description: categoryTrips[index].description,
                                destination: categoryTrips[index].destination,
                                endDate: categoryTrips[index].endDate,
                                startDate: categoryTrips[index].startdate,
                                category: categoryTrips[index].category,
                                tripId: categoryTrips[index].id,
                                userId: categoryTrips[index].userid,
                                importantInfo:
                                    categoryTrips[index].importancInfo,
                                price: categoryTrips[index].price,
                                totalseats: categoryTrips[index].totalseats,
                                createdByUser:
                                    categoryTrips[index].createdByUser,
                                imageUrl: categoryTrips[index].imageUrl,
                                heroID: index,
                              ),
                            ),
                          );
                        },
                        child: HomeCard3D(
                          tripId: categoryTrips[index].id,
                          imageUrl: categoryTrips[index].imageUrl,
                          heroID: index,
                          title: categoryTrips[index].name,
                          price: categoryTrips[index].price,
                          destination: categoryTrips[index].destination,
                          description: categoryTrips[index].description,
                          totalSeats: categoryTrips[index].totalseats,
                        )),
                  ),
                  itemCount: categoryTrips.length,
                ));
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: widget.tripCreated || widget.selectTripsBySale
                ? const SizedBox()
                : TextField(
                    controller: _searchBar,
                    onChanged: _categoryfilteredTrips,
                    decoration: InputDecoration(
                      hintText: "Search Trip By Name",
                      enabledBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.elliptical(15, 15),
                          ),
                          borderSide: BorderSide(
                            color: Colors.grey,
                          )),
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.elliptical(15, 15),
                        ),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.grey,
                        ),
                        borderRadius: BorderRadius.all(
                          Radius.elliptical(15, 15),
                        ),
                      ),
                      suffixIcon: IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.search,
                        ),
                      ),
                    ),
                  ),
          ),
          Expanded(
            child: displayWidget,
          ),
        ],
      ),
    );
  }
}
