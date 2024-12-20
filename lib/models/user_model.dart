import 'package:flutter/material.dart';

class UserModel with ChangeNotifier {
  UserModel({
    required this.name,
    required this.bookedTrips,
    required this.contactNumber,
    required this.fullName,
    required this.email,
    required this.savedTrips,
    required this.tripHistory,
    required this.tripsCreated,
  });
  String name, contactNumber, email, fullName;
  List savedTrips, tripHistory, tripsCreated, bookedTrips;
}
