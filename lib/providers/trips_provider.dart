import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:trip_app/constss/firebase_auth.dart';
import 'package:trip_app/models/trips_model.dart';
import 'package:trip_app/providers/user_provider.dart';

class TripsProvider with ChangeNotifier {
  static List<TripsModel> _trips = [];
  final List<TripsModel> _tripCategory = [];
  List<dynamic> _totalbookings = [];
  final UserProvider userProvider = UserProvider();

  Future<void> fetchTrips() async {
    try {
      QuerySnapshot tripsData =
          await FirebaseFirestore.instance.collection("Trips").get();

      _trips.clear();

      for (var element in tripsData.docs) {
        _trips.add(
          TripsModel(
              category: element.get("category"),
              city: element.get("city"),
              country: element.get("country"),
              description: element.get("description"),
              destination: element.get("destination"),
              endDate: element.get("endDate"),
              id: element.get("id"),
              importancInfo: element.get("importantInfo"),
              name: element.get("name"),
              startdate: element.get("startDate"),
              imageUrl: element.get("imageUrl"),
              state: element.get("state"),
              userid: element.get("userId"),
              totalseats: element.get("totalseats"),
              price: (element.get("price")),
              createdByUser: element.get("createdByUser"),
              onSale: element.get("onSale"),
              salePrice: element.get("salePrice")),
        );
      }
    } catch (e) {
      throw "unable to fetch triplist from database due to : $e";
    }
    notifyListeners();
  }

  List<TripsModel> get getTrips {
    return _trips;
  }

  List<TripsModel> tripByCategory({required String category}) {
    _tripCategory.clear();
    for (var element in _trips) {
      if (element.category == category.trim()) {
        _tripCategory.add(element);
      }
    }
    return _tripCategory;
  }

  Future<void> editTrip(
      {required String tripId, required TripsModel trip}) async {
    final tripRef = FirebaseFirestore.instance.collection("Trips").doc(tripId);
    final tripDoc = await tripRef.get();
    if (tripDoc.exists) {
      await tripRef.update({
        "category": trip.category,
        "city": trip.city,
        "country": trip.country,
        "description": trip.description,
        "destination": trip.destination,
        "endDate": trip.endDate,
        "id": trip.id,
        "importantInfo": trip.importancInfo,
        "name": trip.name,
        "startDate": trip.startdate,
        "imageUrl": trip.imageUrl,
        "state": trip.state,
        "userid": trip.userid,
        "totalseats": trip.totalseats,
        "price": trip.price,
        "createdByUser": trip.createdByUser,
        "onSale": trip.onSale,
        "salePrice": trip.salePrice,
      });
    }
    fetchTrips();
    notifyListeners();
  }

  Future<void> bookingUser({
    required String tripId,
    required String name,
    required String email,
    required double amount,
    required String date,
    required String phoneNumber,
    required String bookingId,
  }) async {
    try {
      final tripRef =
          FirebaseFirestore.instance.collection("Trips").doc(tripId);
      DocumentSnapshot tripDoc = await tripRef.get();
      final usertripRef = FirebaseFirestore.instance
          .collection("users")
          .doc(authInstance.currentUser!.uid);

      DocumentSnapshot userTripDoc = await usertripRef.get();
      if (tripDoc.exists) {
        Map<String, dynamic> tripData = tripDoc.data() as Map<String, dynamic>;
        Map<String, dynamic> userTripData =
            userTripDoc.data() as Map<String, dynamic>;
        List<dynamic> bookings = tripData["bookings"] ?? [];
        List<dynamic> tripsCreated = userTripData["tripsCreated"] ?? [];

        if (bookings.length > tripData["totalseats"]) {
          return;
        }
        if (tripDoc.exists && userTripDoc.exists) {
          bookings.add({
            "name": name,
            "email": email,
            "amount": amount,
            "date": date,
            "bookedId": bookingId,
            "phoneNumber": phoneNumber,
          });
          await tripRef.update({
            "bookings": bookings,
            "totalseats": tripData["totalseats"] - 1,
          });
          for (var trip in tripsCreated) {
            if (trip["id"] == tripId) {
              trip["totalseats"] = trip["totalseats"] - 1;
              break;
            }
          }
          await usertripRef.update({
            "tripsCreated": tripsCreated,
          });
        }
        userProvider.fetchUserTrips();
        fetchTrips();
        notifyListeners();
      }
    } catch (e) {
      throw "Unble to add booking due to $e";
    }
  }

  void removeBooking({required String tripId, required String bookedId}) async {
    try {
      final tripRef =
          FirebaseFirestore.instance.collection("Trips").doc(tripId);
      DocumentSnapshot tripDoc = await tripRef.get();
      final usertripRef = FirebaseFirestore.instance
          .collection("users")
          .doc(authInstance.currentUser!.uid);

      DocumentSnapshot userTripDoc = await usertripRef.get();
      if (tripDoc.exists && userTripDoc.exists) {
        Map<String, dynamic> userTripData =
            userTripDoc.data() as Map<String, dynamic>;
        Map<String, dynamic> tripData = tripDoc.data() as Map<String, dynamic>;
        List<dynamic> bookings = tripData["bookings"] ?? [];
        List<dynamic> tripsCreated = userTripData["tripsCreated"] ?? [];
        if (bookings.isNotEmpty) {
          for (var booking in bookings) {
            if (booking["bookedId"] == bookedId) {
              bookings.remove(booking);
              break;
            }
          }
        }
        await tripRef.update({
          "bookings": bookings,
          "totalseats": tripData["totalseats"] + 1,
        });
        for (var trip in tripsCreated) {
          if (trip["id"] == tripId) {
            trip["totalseats"] = trip["totalseats"] + 1;
            break;
          }
        }
        await usertripRef.update({
          "tripsCreated": tripsCreated,
        });
      }
      fetchBooking(tripId: tripId);
      userProvider.fetchUserTrips();
      notifyListeners();
    } catch (e) {
      throw "unable to cancel the booking due to $e";
    }
  }

  List<TripsModel> get getOnSaleTrips {
    return _trips.where((element) => element.onSale).toList();
  }

  Future<void> fetchBooking({required String tripId}) async {
    _totalbookings.clear();
    try {
      final tripRef =
          FirebaseFirestore.instance.collection("Trips").doc(tripId);
      DocumentSnapshot tripDoc = await tripRef.get();
      if (tripDoc.exists) {
        Map<String, dynamic> tripData = tripDoc.data() as Map<String, dynamic>;
        List<dynamic> bookings = tripData["bookings"] ?? [];
        _totalbookings = bookings;
      }
      notifyListeners();
    } catch (e) {
      throw "Unable to fetch booking due to $e";
    }
  }

  List<dynamic> get getbookings {
    return _totalbookings;
  }

  List<TripsModel> getTripByName({required String name}) {
    return _trips
        .where((element) => element.name == name.toLowerCase().trim())
        .toList();
  }

  Future<void> deleteTrip({
    required tripId,
  }) async {
    try {
      final User? user = authInstance.currentUser;
      final userRef =
          FirebaseFirestore.instance.collection("users").doc(user!.uid);
      DocumentSnapshot userDoc = await userRef.get();
      if (userDoc.exists) {
        await FirebaseFirestore.instance
            .collection("Trips")
            .doc(tripId)
            .delete();
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        List<dynamic> wishlist = userData["tripsCreated"] ?? [];
        for (var element in wishlist) {
          if (element["id"] == tripId) {
            wishlist.remove(element);
            break;
          }
        }

        await userRef.update({"tripsCreated": wishlist});
        Fluttertoast.showToast(
          msg: "Trip Deleted Successfully",
          backgroundColor: Colors.teal.shade300,
          gravity: ToastGravity.TOP,
          fontSize: 16,
          timeInSecForIosWeb: 4000000,
        );
        // Provider.of(context)
        await fetchTrips();
        await UserProvider().fetchUserTrips();
        notifyListeners();
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Unable to delete the trip due to $e",
        backgroundColor: Colors.teal.shade300,
        gravity: ToastGravity.TOP,
        fontSize: 16,
        timeInSecForIosWeb: 4000000,
      );
    }
  }
}
