import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:trip_app/constss/firebase_auth.dart';
import 'package:trip_app/models/wishList_model.dart';

class WishListProvider with ChangeNotifier {
  List<WishlistModel> userWishList = [];
  List<WishlistModel> get getUserWishList {
    return userWishList;
  }

  Future<void> fetchWishList() async {
    userWishList = [];
    try {
      final User? user = authInstance.currentUser;
      DocumentSnapshot docRef = await FirebaseFirestore.instance
          .collection("users")
          .doc(user!.uid)
          .get();
      if (docRef.exists) {
        Map<String, dynamic> userData = docRef.data() as Map<String, dynamic>;
        List<dynamic> wishList = userData["savedTrips"] ?? [];
        for (var trip in wishList) {
          userWishList.add(WishlistModel(
              category: trip["category"] ?? "category",
              city: trip["city"] ?? "city",
              country: trip["country"] ?? "country",
              description: trip["description"] ?? "description",
              destination: trip["destination"] ?? "destination",
              endDate: trip["endDate"] ?? "endDate",
              tripId: trip["id"] ?? "id",
              importantInfo: trip["importancInfo"] ?? "importancInfo",
              name: trip["name"] ?? "name",
              startDate: trip["startdate"] ?? "startdate",
              imageUrl: trip["imageUrl"] ?? "imageUrl",
              state: trip["state"] ?? "state",
              userid: trip["userid"] ?? "userid",
              totalseats: trip["totalseats"] ?? "totalseats",
              createdBy: trip["createdByUser"] ?? "user",
              price: trip["price"] ?? "price"));
        }
      }
    } catch (e) {
      throw "Unable to fetch Wishlist of user due to $e";
    }
    notifyListeners();
  }

  Future<void> removeTripFromWishList({required String tripId}) async {
    try {
      final User? user = authInstance.currentUser;
      final userRef =
          FirebaseFirestore.instance.collection("users").doc(user!.uid);
      DocumentSnapshot userDoc = await userRef.get();
      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        List<dynamic> wishlist = userData["savedTrips"] ?? [];
        for (var element in wishlist) {
          if (element["id"] == tripId) {
            wishlist.remove(element);
            break;
          }
        }

        await userRef.update({"savedTrips": wishlist});
      }
    } catch (e) {
      throw "Unable to remove trip from wishlist due to : $e";
    } finally {
      await fetchWishList();
      notifyListeners();
    }
  }

  Future<void> addTripToWishList({
    required tripId,
  }) async {
    try {
      final User? user = authInstance.currentUser;
      final tripRef = await FirebaseFirestore.instance
          .collection("Trips")
          .doc(tripId)
          .get();
      if (tripRef.exists) {
        final tripdata = tripRef.data() as Map<String, dynamic>;
        final userRef =
            FirebaseFirestore.instance.collection("users").doc(user!.uid);
        DocumentSnapshot userDoc = await userRef.get();
        if (userDoc.exists) {
          Map<String, dynamic> userData =
              userDoc.data() as Map<String, dynamic>;
          List<dynamic> wishlist = userData["savedTrips"] ?? [];

          for (var element in wishlist) {
            if (element["id"] == tripdata["id"]) {
              return;
            }
          }
          wishlist.add({
            "category": tripdata["category"],
            "city": tripdata["city"],
            "country": tripdata["country"],
            "description": tripdata["description"],
            "endDate": tripdata["endDate"],
            "startDate": tripdata["startDate"],
            "id": tripdata["id"],
            "importantInfo": tripdata["importantInfo"],
            "name": tripdata["name"],
            "imageUrl": tripdata["imageUrl"],
            "state": tripdata["state"],
            "userid": tripdata["userId"],
            "totalseats": tripdata["totalseats"],
            "price": tripdata["price"],
            "createdByUser": tripdata["createdByUser"],
          });

          await userRef.update({
            "savedTrips": wishlist,
          });
        }
      }
    } catch (e) {
      throw "Unable to add Trip to wishlist due to : $e";
    }
    await fetchWishList();
    notifyListeners();
  }

  bool tripAllReadyInWishlist({required String tripId}) {
    for (var element in userWishList) {
      if (element.tripId == tripId) {
        return true;
      }
    }
    return false;
  }

  Future<void> clearWishlist() async {
    final User? user = authInstance.currentUser;
    final userRef =
        FirebaseFirestore.instance.collection("users").doc(user!.uid);
    DocumentSnapshot userDoc = await userRef.get();
    if (userDoc.exists) {
      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
      userWishList.clear();
      await userRef.update({"savedTrips": []});
    }
    notifyListeners();
  }
}
