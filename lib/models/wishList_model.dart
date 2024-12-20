import 'package:flutter/foundation.dart';

class WishlistModel with ChangeNotifier {
  WishlistModel({
    required this.category,
    required this.city,
    required this.country,
    required this.description,
    required this.endDate,
    required this.startDate,
    required this.tripId,
    required this.importantInfo,
    required this.name,
    required this.imageUrl,
    required this.userid,
    required this.totalseats,
    required this.price,
    required this.state,
    required this.destination,
    required this.createdBy,
  });
  final String category,
      city,
      country,
      description,
      endDate,
      tripId,
      importantInfo,
      name,
      imageUrl,
      userid,
      state,
      destination,
      startDate;
  String createdBy;
  final double price;
  final int totalseats;
}
