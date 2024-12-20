import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:iconly/iconly.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart';
import 'package:provider/provider.dart';
import 'package:trip_app/auth/login.dart';
import 'package:trip_app/constss/firebase_auth.dart';
import 'package:trip_app/constss/global_methods.dart';
import 'package:trip_app/models/trips_model.dart';
import 'package:trip_app/providers/trips_provider.dart';
import 'package:trip_app/screens/empty_screen.dart';
import 'package:trip_app/screens/trip_detail_screen.dart';
import 'package:trip_app/screens/trip_wislist.dart';
import 'package:trip_app/screens/trips_list_screen.dart';
import 'package:trip_app/trips_data.dart';
import 'package:trip_app/widgets/3d_home_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool chipSelected = false;
  bool catSelected = false;
  bool filteredTrips = false;
  final TextEditingController _phoneNumber =
      TextEditingController(text: "+92 XXXXXXXXXX");
  String _userName = "user";
  String _emailAddress = "bot12@gmail.com";
  final user = authInstance.currentUser;
  final TextEditingController _searchBar = TextEditingController();
  List<TripsModel> _tripsList = [];
  List<TripsModel> _tripsCat = [];
  List<TripsModel> _tripsByName = [];
  String contactNumber = "";
  String countryISOCode = "";
  String countryCode = "";
  bool _isValidContact = false;

  final imageList = [
    "https://tse3.mm.bing.net/th?id=OIP.YYEEyRAyn7Rj5Y64yOVmMQHaEo&pid=Api&P=0&h=220",
    "https://wallpapercave.com/wp/wp4782909.jpg",
    "https://tse3.mm.bing.net/th?id=OIP.J7tiGkkZ4Iw16OAwfdUWIgHaE7&pid=Api&P=0&h=220",
    "https://thumbs.dreamstime.com/z/city-hall-tours-france-tours-france-may-city-hall-hotel-de-ville-built-architect-victor-laloux-128280235.jpg",
  ];

  Future<void> fetchUserData() async {
    try {
      final DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection("users")
          .doc(user!.uid)
          .get();
      _emailAddress = userDoc.get("email");
      _userName = userDoc.get("fullName");
      _phoneNumber.text =
          (userDoc.get("contactNumber").toString()).split(" ")[1];

      countryISOCode = userDoc.get("countryISOCode");

      setState(() {});
    } catch (e) {
      throw Exception("Unable to fetch user data due to : $e");
    }
  }

  @override
  void initState() {
    fetchUserData();
    super.initState();
  }

  void _updatePhoneNumber() async {
    try {
      final _uuid = user!.uid;
      await FirebaseFirestore.instance.collection("users").doc(_uuid).update(
        {
          "contactNumber": "$countryCode $contactNumber",
          "countryISOCode": countryISOCode,
        },
      );
      Fluttertoast.showToast(
        msg: "Contact Number Updated Successfully",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        timeInSecForIosWeb: 1,
        backgroundColor: const Color.fromARGB(255, 122, 157, 123),
        textColor: Colors.white,
        fontSize: 16.0,
      );
      setState(() {});
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Error Updating Phone Number : $e",
        gravity: ToastGravity.TOP,
        fontSize: 16,
        timeInSecForIosWeb: 1,
        backgroundColor: const Color.fromARGB(255, 122, 157, 123),
        textColor: Colors.white,
      );
    }
  }

  void _filteredTrips(String query) {
    filteredTrips = true;
    _tripsByName = TripsProvider()
        .getTrips
        .where(
          (element) => element.name.toLowerCase().contains(
                query.toLowerCase().trim(),
              ),
        )
        .toList();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final tripProvider = Provider.of<TripsProvider>(
      context,
    );
    List<TripsModel> _tripsList = tripProvider.getTrips;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Welcome to Tourista"),
      ),
      drawer: Drawer(
        child: ListView(
          children: <Widget>[
            _createHeader(),
            _createDrawerItem(
              text: _emailAddress,
              icon: Icons.email,
            ),
            _createDrawerItem(
                text: "Whislist Trips",
                icon: Icons.bookmark_added_outlined,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const TripWislistScreen(),
                    ),
                  );
                }),
            _createDrawerItem(
              text: "Trips Created",
              icon: Icons.create,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const TripListScreen(
                      title: "Trips Created",
                      tripCreated: true,
                    ),
                  ),
                );
              },
            ),
            ListTile(
              title: Row(
                children: [
                  Expanded(
                    child: IntlPhoneField(
                      initialValue: _phoneNumber.text,
                      // initialCountryCode: ,
                      decoration: const InputDecoration(
                        labelText: "Phone Number",
                        border: UnderlineInputBorder(
                          borderSide: BorderSide(),
                        ),
                      ),
                      initialCountryCode:
                          countryISOCode, // Set the default country code
                      onChanged: (phone) {
                        setState(() {
                          contactNumber =
                              phone.number; // Extract the phone number
                          // phone.countryCode = countryCode;
                          countryCode = phone.countryCode;
                          countryISOCode = phone.countryISOCode;
                          _isValidContact =
                              phone.isValidNumber(); // Extract the country code
                        });
                      },
                    ),
                  ),
                  if (_isValidContact)
                    IconButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (contest) => AlertDialog(
                            title: const Text("Update Contact Number"),
                            content: const Text(
                                "Do you want to update the contact number?"),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text("cancel"),
                              ),
                              TextButton(
                                onPressed: () {
                                  _updatePhoneNumber();
                                  Navigator.of(context).pop();
                                },
                                child: const Text("Ok"),
                              ),
                            ],
                          ),
                        );
                      },
                      icon: const Icon(
                        IconlyLight.send,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(
              height: 100,
            ),
            _createDrawerItem(
                text: "Logout",
                icon: Icons.logout,
                onTap: () {
                  showMessageDialog(
                      title: "Sign Out",
                      ctx: context,
                      content: "Do you want to Sign out?",
                      ontapok: () async {
                        await authInstance.signOut();
                        if (!mounted) {
                          return;
                        }
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (BuildContext context) =>
                                const LoginScreen(),
                          ),
                        );
                      });
                }),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(
              top: 8.0,
              bottom: 8.0,
              left: 3.0,
              right: 3.0,
            ),
            child: TextField(
              controller: _searchBar,
              onChanged: _filteredTrips,
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
          Stack(
            children: [
              InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (ctx) => const TripListScreen(
                          selectTripsBySale: true,
                          title: "Hot And Discounted Trips"),
                    ),
                  );
                },
                child: CarouselSlider(
                  disableGesture: true,
                  options: CarouselOptions(
                    pauseAutoPlayOnTouch: true,
                    enableInfiniteScroll: true,
                    autoPlay: true,
                    autoPlayCurve: Curves.linear,
                  ),
                  items: imageList
                      .map(
                        (item) => Image.network(
                          item,
                          fit: BoxFit.cover,
                        ),
                      )
                      .toList(),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                // top: 10,
                child: Container(
                  // width: 200,
                  height: 30,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFF6A82FB),
                        Color(0xFFFC5C7D),
                      ],
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      "Hot & Dicounted Trips",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontFamily: "Roboto",
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(
              top: 8.0,
              bottom: 8.0,
            ),
            child: SizedBox(
              height: 50,
              child: CustomScrollView(
                scrollDirection: Axis.horizontal,
                slivers: [
                  SliverList(
                      delegate: SliverChildBuilderDelegate(
                    childCount: tripsData.length,
                    (context, index) => Padding(
                      padding: const EdgeInsets.only(
                        left: 8.0,
                        right: 8.0,
                      ),
                      child: InputChip(
                        backgroundColor:
                            const Color.fromARGB(255, 201, 198, 224),
                        pressElevation: 6,
                        selectedColor: tripsData[index]["selected"]
                            ? const Color.fromARGB(255, 109, 154, 111)
                            : Colors.grey,
                        selected: tripsData[index]["selected"],
                        elevation: 4,
                        shadowColor: Colors.black,
                        label: Text(tripsData[index]["category"]),
                        onSelected: (value) {
                          setState(() {});
                          tripsData[index]["selected"] = value;
                          catSelected = value;
                          _tripsCat.clear();
                          _tripsCat = TripsProvider().tripByCategory(
                            category: tripsData[index]["category"],
                          );
                          for (int i = 0; i < tripsData.length; i++) {
                            if (i != index) {
                              tripsData[i]["selected"] = false;
                            }
                          }
                        },
                      ),
                    ),
                  ))
                ],
                // child: ListView.builder(
                //   shrinkWrap: true,
                //   scrollDirection: Axis.horizontal,
                //   itemCount: tripsData.length,
                //   itemBuilder:
                // ),
              ),
            ),
          ),
          Expanded(
            child: (catSelected)
                ? ((_tripsCat.isEmpty)
                    ? EmptyScreen(
                        navigatorFunc: () {},
                        text: "Opps No trips Available",
                        icon: const Icon(
                          Icons.hourglass_empty_outlined,
                        ),
                        subTitle: "Come back after someTime to explore Trips")
                    : CustomScrollView(
                        slivers: [
                          SliverList(
                              delegate: SliverChildBuilderDelegate(
                            childCount: _tripsCat.length,
                            (context, index) => InkWell(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        TripDetailScren(
                                      name: _tripsCat[index].name,
                                      tripId: _tripsCat[index].id,
                                      description: _tripsCat[index].description,
                                      destination: _tripsCat[index].destination,
                                      category: _tripsCat[index].category,
                                      startDate: _tripsCat[index].startdate,
                                      endDate: _tripsCat[index].endDate,
                                      userId: _tripsCat[index].userid,
                                      importantInfo:
                                          _tripsCat[index].importancInfo,
                                      price: _tripsCat[index].price,
                                      totalseats: _tripsCat[index].totalseats,
                                      createdByUser:
                                          _tripsCat[index].createdByUser,
                                      imageUrl: _tripsCat[index].imageUrl,
                                      heroID: index,
                                    ),
                                  ),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: HomeCard3D(
                                    tripId: _tripsCat[index].id,
                                    title: _tripsCat[index].name,
                                    description: _tripsCat[index].description,
                                    destination: _tripsCat[index].destination,
                                    totalSeats: _tripsCat[index].totalseats,
                                    price: _tripsCat[index].price,
                                    imageUrl: _tripsCat[index].imageUrl,
                                    heroID: index),
                              ),
                            ),
                          ))
                        ],
                      ))
                : _tripsList.isEmpty
                    ? EmptyScreen(
                        navigatorFunc: () {},
                        text: "Opps No trips Available",
                        icon: const Icon(
                          Icons.hourglass_empty_outlined,
                        ),
                        subTitle: "Come back after someTime to explore Trips")
                    : (filteredTrips
                        ? _tripsByName.isEmpty
                            ? EmptyScreen(
                                navigatorFunc: () {},
                                text: "Opps No trips Available",
                                icon: const Icon(
                                  Icons.hourglass_empty_outlined,
                                ),
                                subTitle:
                                    "Come back after someTime to explore Trips")
                            : CustomScrollView(
                                slivers: [
                                  SliverList(
                                      delegate: SliverChildBuilderDelegate(
                                    childCount: _tripsByName.length,
                                    (context, index) => InkWell(
                                      onTap: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (BuildContext context) =>
                                                TripDetailScren(
                                              name: _tripsByName[index].name,
                                              tripId: _tripsByName[index].id,
                                              description: _tripsByName[index]
                                                  .description,
                                              destination: _tripsByName[index]
                                                  .destination,
                                              category:
                                                  _tripsByName[index].category,
                                              startDate:
                                                  _tripsByName[index].startdate,
                                              endDate:
                                                  _tripsByName[index].endDate,
                                              userId:
                                                  _tripsByName[index].userid,
                                              importantInfo: _tripsByName[index]
                                                  .importancInfo,
                                              price: _tripsByName[index].price,
                                              totalseats: _tripsByName[index]
                                                  .totalseats,
                                              createdByUser: _tripsByName[index]
                                                  .createdByUser,
                                              imageUrl:
                                                  _tripsByName[index].imageUrl,
                                              heroID: index,
                                            ),
                                          ),
                                        );
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: HomeCard3D(
                                            tripId: _tripsByName[index].id,
                                            title: _tripsByName[index].name,
                                            description:
                                                _tripsByName[index].description,
                                            destination:
                                                _tripsByName[index].destination,
                                            totalSeats:
                                                _tripsByName[index].totalseats,
                                            price: _tripsByName[index].price,
                                            imageUrl:
                                                _tripsByName[index].imageUrl,
                                            heroID: index),
                                      ),
                                    ),
                                  ))
                                ],
                                // child: ListView.builder(
                                //
                                //     itemBuilder:
                                //   ),
                              )
                        : CustomScrollView(
                            slivers: [
                              SliverList(
                                  delegate: SliverChildBuilderDelegate(
                                childCount: _tripsList.length,
                                (context, index) => InkWell(
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (BuildContext context) =>
                                            TripDetailScren(
                                          name: _tripsList[index].name,
                                          tripId: _tripsList[index].id,
                                          description:
                                              _tripsList[index].description,
                                          destination:
                                              _tripsList[index].destination,
                                          category: _tripsList[index].category,
                                          startDate:
                                              _tripsList[index].startdate,
                                          endDate: _tripsList[index].endDate,
                                          userId: _tripsList[index].userid,
                                          importantInfo:
                                              _tripsList[index].importancInfo,
                                          price: _tripsList[index].price,
                                          totalseats:
                                              _tripsList[index].totalseats,
                                          createdByUser:
                                              _tripsList[index].createdByUser,
                                          imageUrl: _tripsList[index].imageUrl,
                                          heroID: index,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: HomeCard3D(
                                        tripId: _tripsList[index].id,
                                        title: _tripsList[index].name,
                                        description:
                                            _tripsList[index].description,
                                        destination:
                                            _tripsList[index].destination,
                                        totalSeats:
                                            _tripsList[index].totalseats,
                                        price: _tripsList[index].price,
                                        imageUrl: _tripsList[index].imageUrl,
                                        heroID: index),
                                  ),
                                ),
                              ))
                            ],
                          )),
          ),
        ],
      ),
    );
  }

  Widget _createHeader() {
    return DrawerHeader(
      decoration: BoxDecoration(
        color: Colors.green.shade200,
        image: const DecorationImage(
          fit: BoxFit.cover,
          image: AssetImage(
              'assets/images/drawer_image.jpg'), // Add a background image
        ),
      ),
      child: Stack(
        children: <Widget>[
          Align(
            alignment: Alignment.center,
            child: Text(
              'Welcome, $_userName',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _createDrawerItem(
      {IconData? icon, String? text, GestureTapCallback? onTap}) {
    return ListTile(
      title: Row(
        children: <Widget>[
          Icon(icon),
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Text(text!),
          )
        ],
      ),
      onTap: onTap,
    );
  }
}
