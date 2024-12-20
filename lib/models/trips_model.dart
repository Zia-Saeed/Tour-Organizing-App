import 'package:flutter/material.dart';

class TripsModel with ChangeNotifier {
  TripsModel({
    required this.category,
    required this.city,
    required this.country,
    required this.description,
    required this.destination,
    required this.endDate,
    required this.id,
    required this.importancInfo,
    required this.name,
    required this.startdate,
    required this.imageUrl,
    required this.state,
    required this.userid,
    required this.totalseats,
    required this.price,
    required this.createdByUser,
    required this.salePrice,
    required this.onSale,
  });
  final String category;
  final String city;
  final String country;
  final String description;
  final String destination;
  final String endDate;
  final String id;
  final String importancInfo;
  final String name;
  final String startdate;
  final String imageUrl;
  final String state;
  final String userid;
  final String createdByUser;
  final int totalseats;
  final double price;
  final double salePrice;
  final bool onSale;
}
