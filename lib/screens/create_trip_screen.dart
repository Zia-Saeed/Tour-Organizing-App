import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csc_picker/csc_picker.dart';
import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:trip_app/constss/firebase_auth.dart';
import 'package:trip_app/constss/global_methods.dart';
import 'package:trip_app/models/trips_model.dart';
import 'package:trip_app/providers/trips_provider.dart';
import 'package:trip_app/providers/user_provider.dart';
import 'package:trip_app/screens/add_member_to_trip.dart';
import 'package:trip_app/screens/show_bookings.dart';
import 'package:trip_app/screens/trips_list_screen.dart';
import 'package:uuid/uuid.dart';

class CreateTripScreen extends StatefulWidget {
  const CreateTripScreen({
    super.key,
    this.name,
    this.seats,
    this.startDate,
    this.endDate,
    this.selectCategory,
    this.price,
    this.description,
    this.importantInfo,
    this.imageUrl,
    this.country,
    this.state,
    this.city,
    this.editTrip = false,
    this.salePrice = 0.0,
    this.onSale = false,
    this.tripId,
  });

  final String? name;
  final int? seats;
  final String? startDate;
  final String? endDate;
  final String? selectCategory;
  final double? price;
  final String? description;
  final String? importantInfo;
  final String? imageUrl;
  final String? country;
  final String? state;
  final String? city;
  final bool onSale;
  final double salePrice;
  final bool editTrip;
  final String? tripId;

  @override
  State<CreateTripScreen> createState() => _CreateTripScreenState();
}

class _CreateTripScreenState extends State<CreateTripScreen> {
  // File? image;
  bool imagePicked = false;
  String? selectedItem = "Luxury";

  DateTime? startDate;
  DateTime? endDate;
  String? countryValue;
  String? stateValue;
  String? cityValue;
  String address = "";
  bool startPicked = false;
  bool endPicked = false;
  bool isLoading = false;
  bool onSalecheckBox = false;
  Color dottedContainerColor = Colors.black;

  @override
  void initState() {
    super.initState();
    _priceController.text = widget.editTrip ? widget.price!.toString() : "";
    _descriptionController.text = widget.editTrip ? widget.description! : "";
    _importantInformationController.text =
        widget.editTrip ? widget.importantInfo! : "";
    _seatsController.text = widget.editTrip ? "${widget.seats!}" : "";
    _nameController.text = widget.editTrip ? widget.name! : "";
    countryValue = widget.editTrip ? widget.country : "pakistan";
    stateValue = widget.editTrip ? widget.state : "punjab";
    cityValue = widget.editTrip ? widget.city : "lahore";
    _salePriceController.text = widget.salePrice.toString();
    endDate = widget.editTrip ? DateTime.parse(widget.endDate!) : null;
    startDate = widget.editTrip ? DateTime.parse(widget.startDate!) : null;
    onSalecheckBox = widget.editTrip ? widget.onSale : false;
  }

  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _seatsController = TextEditingController();
  final TextEditingController _importantInformationController =
      TextEditingController();
  final TextEditingController _salePriceController = TextEditingController();
  final GlobalKey<CSCPickerState> _cscPickerKey = GlobalKey();
  final GlobalKey<FormState> _formKey = GlobalKey();
  String _price = "";
  String userName = "";
  List<String> tripsCategories = [
    "Luxury",
    "Adventure",
    "Family Friendly",
    "Cultural",
    "Road",
    "City Break",
  ];
  File? _image;
  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
    );

    if (image != null) {
      imagePicked = true;
      setState(() {
        _image = File(image.path);
      });
      // print("this is image path ${image.path}");
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime currentDate = DateTime.now();
    final DateTime initialDate = endDate ?? currentDate;

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null && pickedDate != endDate) {
      setState(() {
        endPicked = true;
        endDate = pickedDate;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime currentDate = DateTime.now();
    final DateTime initialDate = startDate ?? currentDate;

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null && pickedDate != startDate) {
      setState(() {
        startPicked = true;
        startDate = pickedDate;
      });
    }
  }

  Future<void> fetchUserData() async {
    try {
      final DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection("users")
          .doc(authInstance.currentUser!.uid)
          .get();
      userName = userDoc.get("fullName");
      setState(() {});
    } catch (e) {
      throw Exception("Unable to fetch user data due to : $e");
    }
  }

  void createTrip(context) async {
    final userProvider = Provider.of<UserProvider>(
      context,
      listen: false,
    );
    final tripsProvider = Provider.of<TripsProvider>(context, listen: false);
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      if (!imagePicked && !widget.editTrip) {
        setState(() {
          dottedContainerColor = Colors.red;
        });
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please select an image.')));
      }
      if (countryValue != null &&
          cityValue != null &&
          stateValue != null &&
          startDate != null &&
          endDate != null) {
        try {
          setState(() {
            isLoading = true;
          });
          if (widget.editTrip) {
            await fetchUserData();
            String? imageUrl;
            if (!imagePicked) {
              imageUrl = widget.imageUrl;
            } else {
              final _uuid = const Uuid().v4();
              final ref = FirebaseStorage.instance
                  .ref()
                  .child("TripImages")
                  .child("$_uuid.jpg");
              await ref.putFile(_image!);
              imageUrl = await ref.getDownloadURL();
            }

            double _discountPrice = onSalecheckBox
                ? double.parse(_priceController.text) -
                    double.parse(_salePriceController.text)
                : double.parse(_priceController.text);
            tripsProvider.editTrip(
                tripId: widget.tripId!,
                trip: TripsModel(
                  category: selectedItem!,
                  city: cityValue!,
                  country: countryValue!,
                  description: _descriptionController.text,
                  destination: '$countryValue: $stateValue: $cityValue',
                  endDate: endDate.toString(),
                  id: widget.tripId.toString(),
                  importancInfo: _importantInformationController.text,
                  name: _nameController.text,
                  startdate: startDate.toString(),
                  imageUrl: imageUrl!,
                  state: stateValue!,
                  userid: authInstance.currentUser!.uid,
                  totalseats: int.parse(_seatsController.text),
                  price: _discountPrice,
                  createdByUser: userName,
                  salePrice: onSalecheckBox
                      ? double.parse(_salePriceController.text)
                      : 0.0,
                  onSale: onSalecheckBox,
                ));
            await userProvider.updateUserCreatedTrips(
                tripId: widget.tripId!,
                tripDateToUpdate: TripsModel(
                  category: selectedItem!,
                  city: cityValue!,
                  country: countryValue!,
                  description: _descriptionController.text,
                  destination: '$countryValue: $stateValue: $cityValue',
                  endDate: endDate.toString(),
                  id: widget.tripId.toString(),
                  importancInfo: _importantInformationController.text,
                  name: _nameController.text,
                  startdate: startDate.toString(),
                  imageUrl: imageUrl,
                  state: stateValue!,
                  userid: authInstance.currentUser!.uid,
                  totalseats: int.parse(_seatsController.text),
                  price: _discountPrice,
                  createdByUser: userName,
                  salePrice: onSalecheckBox
                      ? double.parse(_salePriceController.text)
                      : 0.0,
                  onSale: onSalecheckBox,
                ));
          } else {
            final _uuid = const Uuid().v4();
            final ref = FirebaseStorage.instance
                .ref()
                .child("TripImages")
                .child("$_uuid.jpg");
            await ref.putFile(_image!);
            String imageUrl = await ref.getDownloadURL();

            await userProvider.userCreatedTrip(
              countryValue: countryValue!,
              cityValue: cityValue!,
              stateValue: stateValue!,
              startDate: startDate,
              endDate: endDate,
              name: _nameController.text,
              seats: int.parse(_seatsController.text),
              cat: selectedItem!,
              price: double.parse(_priceController.text),
              description: _descriptionController.text,
              importantInfo: _importantInformationController.text,
              salePrice: widget.salePrice,
              onSale: widget.onSale,
              imageUrl: imageUrl,
            );
            _formKey.currentState?.reset();
          }

          Fluttertoast.showToast(
            msg: (widget.editTrip)
                ? "Trip Edited Successfully"
                : "Trip Created Successfully",
            backgroundColor: Colors.teal.shade300,
            gravity: ToastGravity.TOP,
            fontSize: 16,
            timeInSecForIosWeb: 4000000,
          );
        } catch (error) {
          setState(() {
            isLoading = false;
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("$error"),
              ),
            );
          }
        } finally {
          setState(() {
            isLoading = false;
          });
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please fill all the fields'),
          ),
        );
      }
    }
  }

  void updatePrice(String value) {
    setState(() {
      _price = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    Size screensize = MediaQuery.of(context).size;
    return Scaffold(
      // backgroundColor: Colors.transparent,
      floatingActionButtonLocation:
          widget.editTrip ? FloatingActionButtonLocation.endTop : null,
      floatingActionButtonAnimator:
          widget.editTrip ? FloatingActionButtonAnimator.scaling : null,
      floatingActionButton: widget.editTrip
          ? ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 146, 149, 151)),
              icon: const Icon(
                Icons.book_online_sharp,
                color: Color.fromARGB(255, 117, 99, 91),
              ),
              label: const Text(
                "Add New Booking",
                style: TextStyle(color: Colors.white54),
              ),
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) =>
                        AddMemberToTrip(tripId: widget.tripId!)));
              },
            )
          : null,
      appBar: AppBar(
        title: const Text("Create a New Trip "),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    SizedBox(
                      width: screensize.width - 160,
                      child: TextFormField(
                        controller: _nameController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a valid name';
                          }
                        },
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: "Name of trip",
                          labelStyle: TextStyle(
                            fontFamily: "Roboto",
                            fontWeight: FontWeight.bold,
                          ),
                          labelText: "Name of Trip",
                          hintStyle: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontFamily: "Roboto",
                          ),
                        ),
                      ),
                    ),
                    const Spacer(),
                    SizedBox(
                      width: screensize.width - 300,
                      child: TextFormField(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a valid Price';
                          }
                          try {
                            int.parse(value);
                          } catch (e) {
                            return 'Please enter a valid Price';
                          }
                        },
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'^\d*\.?\d{0,2}'))
                        ],
                        controller: _seatsController,
                        decoration: const InputDecoration(
                          border: UnderlineInputBorder(),
                          hintText: "Total Seats",
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 20,
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: () => _selectDate(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal.shade100,
                              foregroundColor: Colors.black87,
                            ),
                            child: Text(
                              widget.editTrip
                                  ? "Edit Start Date"
                                  : (startPicked
                                      ? "Start Date"
                                      : 'Select Start Date'),
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          if (startDate != null)
                            Text(
                              startDate!.toLocal().toString().split(' ')[0],
                            )
                          else if (widget.editTrip)
                            Text(widget.endDate!.split(" ")[0]),
                          const SizedBox(
                            width: 10,
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: () => _selectEndDate(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.brown.shade100,
                              foregroundColor: Colors.black87,
                            ),
                            child: Text(
                              widget.editTrip
                                  ? "Edit End Date"
                                  : (endPicked ? "EndDate" : 'Select End Date'),
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          if (endDate != null)
                            Text(
                              endDate!.toLocal().toString().split(' ')[0],
                              // style: const TextStyle(fontSize: ),
                            )
                          else if (widget.editTrip)
                            (Text(widget.endDate!.split(" ")[0])),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  left: 24.0,
                  top: 10.0,
                  bottom: 10.0,
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 150,
                      child: DropdownButton<String>(
                        value: selectedItem,
                        hint: const Text('Select Category'),
                        items: tripsCategories.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedItem = newValue;
                          });
                        },
                        icon: const Icon(Icons.arrow_drop_down),
                        iconSize: 30,
                        isExpanded: true,
                        underline: Container(
                          height: 2,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                    const Spacer(),
                    SizedBox(
                      width: screensize.width - 250,
                      child: TextFormField(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a valid Price';
                          }
                          try {
                            double.parse(value);
                          } catch (e) {
                            return 'Please enter a valid Price';
                          }
                        },
                        controller: _priceController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.elliptical(10, 10),
                            ),
                          ),
                          label: Text(
                            "Enter Price",
                          ),
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(
                              r'^\d*\.?\d{0,2}')), // Allow only digits and decimal point
                        ],
                        onChanged: updatePrice,
                      ),
                    ),
                    const SizedBox(
                      width: 20,
                    )
                  ],
                ),
              ),
              if (widget.editTrip)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: CheckboxListTile(
                            title: const Text(
                              "Put Discount.",
                            ),
                            value: onSalecheckBox,
                            onChanged: (value) {
                              _salePriceController.text =
                                  widget.salePrice.toString();
                              // print("this is sale price ${widget.salePrice}");
                              setState(() {
                                onSalecheckBox = value!;
                              });
                            }),
                      ),
                      // Spacer(),
                      if (onSalecheckBox)
                        SizedBox(
                          width: screensize.width - 240,
                          child: TextFormField(
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(
                                  r'[0-9.]')), // Allow only digits and decimal point
                            ],
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.elliptical(10, 10),
                                ),
                              ),
                              label: Text(
                                "Sale percentage",
                              ),
                            ),
                            controller: _salePriceController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Please enter a value of discount if donot want to put discount enter a 0.0";
                              }
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: _descriptionController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Enter a valid Description";
                    }
                  },
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText:
                          "Enter the description like this\n1.The trip include staking, hiking etc.",
                      labelText: "Decription of Trip",
                      labelStyle: TextStyle(
                        fontFamily: "Roboto",
                        fontWeight: FontWeight.bold,
                      )),
                  maxLines: 14,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: _importantInformationController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Enter a valid Information";
                    }
                  },
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText:
                          "Enter the Important Information like this\n1.The trip include staking, hiking etc.",
                      labelText: "Important Information",
                      labelStyle: TextStyle(
                        fontFamily: "Roboto",
                        fontWeight: FontWeight.bold,
                      )),
                  maxLines: 14,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: InkWell(
                  onTap: _pickImage,
                  child: DottedBorder(
                    color: dottedContainerColor,
                    child: Container(
                      height: 250,
                      width: screensize.width - 25,
                      child: imagePicked
                          ? Image.file(
                              _image!,
                              fit: BoxFit.cover,
                            )
                          : (widget.editTrip
                              ? Image.network(
                                  widget.imageUrl!,
                                  fit: BoxFit.cover,
                                )
                              : Center(
                                  child: ElevatedButton.icon(
                                    onPressed: _pickImage,
                                    label: const Text(
                                      "Select a Image",
                                    ),
                                    icon: const Icon(
                                      Icons.photo_size_select_actual_rounded,
                                    ),
                                  ),
                                )),
                    ),
                  ),
                ),
              ),
              // widget.editTrip
              Padding(
                key: _cscPickerKey,
                padding: const EdgeInsets.all(8.0),
                child: CSCPicker(
                  // currentCity: "Lahore",
                  currentCountry:
                      widget.editTrip ? (widget.country ?? "") : "Pakistan",
                  currentCity: widget.editTrip ? (widget.city ?? "") : "Lahore",
                  currentState:
                      widget.editTrip ? (widget.state ?? "") : "Punjab",
                  showCities: true,
                  showStates: true,
                  flagState: CountryFlag.ENABLE,
                  dropdownDecoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    border: Border.all(
                      color: Colors.grey.shade100,
                    ),
                  ),
                  disabledDropdownDecoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                    color: Colors.grey.shade300,
                    border: Border.all(color: Colors.grey.shade300, width: 1),
                  ),
                  countrySearchPlaceholder: "Country",
                  stateSearchPlaceholder: "State",
                  citySearchPlaceholder: "City",
                  onCountryChanged: (value) {
                    setState(() {
                      countryValue = value;
                    });
                  },
                  onStateChanged: (value) {
                    setState(() {
                      stateValue = value;
                    });
                  },
                  onCityChanged: (value) {
                    setState(() {
                      cityValue = value;
                    });
                  },
                ),
              ),
              SizedBox(
                width: screensize.width - 20,
                child: ElevatedButton.icon(
                  onPressed: () {
                    createTrip(
                      context,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                  ),
                  label: isLoading
                      ? const Text("")
                      : Text(
                          widget.editTrip ? "Edit" : "Create",
                          style: const TextStyle(
                            color: Colors.black87,
                          ),
                        ),
                  icon: isLoading
                      ? const CircularProgressIndicator(
                          // backgroundColor: Colors.brown.shade100,
                          strokeWidth: 2,
                          strokeAlign: 0.5,
                          strokeCap: StrokeCap.butt,
                          color: Colors.white,
                        )
                      : Icon(
                          Icons.create_sharp,
                          color: Theme.of(context).canvasColor,
                        ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              if (widget.editTrip)
                SizedBox(
                  width: screensize.width - 20,
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueGrey.shade400),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                ShowBookingsScreen(tripId: widget.tripId!),
                          ),
                        );
                      },
                      child: const Text(
                        "check Bookings",
                        style: TextStyle(color: Colors.black54),
                      )),
                ),
              const SizedBox(
                height: 20,
              ),
              if (widget.editTrip)
                SizedBox(
                  width: screensize.width - 20,
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 193, 111, 107)),
                      onPressed: () {
                        showMessageDialog(
                            title: "Delete Trip",
                            ctx: context,
                            content:
                                "Are you sure you want to delete this trip and you won't be able to recover this trip again",
                            ontapok: () async {
                              final tripProvider = Provider.of<TripsProvider>(
                                context,
                                listen: false,
                              );
                              await tripProvider.deleteTrip(
                                tripId: widget.tripId,
                              );
                              if (mounted) {
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                    builder: (context) => const TripListScreen(
                                      title: "Trips Created",
                                      tripCreated: true,
                                    ),
                                  ),
                                );
                              }
                            });
                      },
                      child: const Text(
                        "Delete Trip",
                        style: TextStyle(color: Colors.black54),
                      )),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
