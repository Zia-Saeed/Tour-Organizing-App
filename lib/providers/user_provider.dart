import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:trip_app/constss/firebase_auth.dart';
import 'package:trip_app/models/trips_model.dart';
import 'package:trip_app/providers/trips_provider.dart';

import 'package:uuid/uuid.dart';

class UserProvider with ChangeNotifier {
  final List<TripsModel> userCreatedTrips = [];
  String _userName = "";
  String _contacntNumber = "";

  Future<void> updateTripsCreated({
    required String category,
    required String city,
    required String country,
    required String description,
    required String destination,
    required endDate,
    required String tripId,
    required String importancInfo,
    required String name,
    required startDate,
    required String imageUrl,
    required String state,
    required String userid,
    required int totalseats,
    required double price,
    required double salePrice,
    required bool onSale,
  }) async {
    try {
      final User? user = authInstance.currentUser;
      final userRef =
          FirebaseFirestore.instance.collection("users").doc(user!.uid);
      DocumentSnapshot userDoc = await userRef.get();
      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        List<dynamic> currentTrips = userData["tripsCreated"] ?? [];
        currentTrips.add({
          "category": category,
          "city": city,
          "country": country,
          "description": description,
          "endDate":
              DateTime(endDate!.year, endDate!.month, endDate!.day).toString(),
          "startDate":
              DateTime(startDate!.year, startDate!.month, startDate!.day)
                  .toString(),
          "id": tripId,
          "importantInfo": importancInfo,
          "name": name,
          "imageUrl": imageUrl,
          "state": state,
          "userId": userid,
          "totalseats": totalseats,
          "price": price,
          "destination": destination,
          "salePrice": salePrice,
          "onSale": onSale,
        });
        await userRef.update(
          {
            "tripsCreated": currentTrips,
          },
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Error adding trip to user trips: $e",
        gravity: ToastGravity.TOP,
        timeInSecForIosWeb: 4,
      );
    }
    await TripsProvider().fetchTrips();
    notifyListeners();
  }

  Future<void> userCreatedTrip({
    required String countryValue,
    required String cityValue,
    required String stateValue,
    required startDate,
    required endDate,
    required String name,
    required int seats,
    required String cat,
    required double price,
    required String description,
    required String importantInfo,
    required double salePrice,
    required bool onSale,
    imageUrl = "",
  }) async {
    try {
      final User? user = authInstance.currentUser;
      final collectionRef = FirebaseFirestore.instance.collection('Trips');
      final tripId = const Uuid().v4();
      final documentRef = collectionRef.doc(tripId);

      await userNameById(userId: user!.uid);

      await documentRef.set({
        "userId": user.uid,
        "id": tripId,
        "country": countryValue,
        "city": cityValue,
        "state": stateValue,
        "startDate": DateTime(startDate!.year, startDate!.month, startDate!.day)
            .toString(),
        "endDate":
            DateTime(endDate!.year, endDate!.month, endDate!.day).toString(),
        "name": name,
        "totalseats": (seats),
        "category": cat,
        "price": price,
        "description": description,
        "importantInfo": importantInfo,
        "imageUrl": imageUrl,
        "destination": "$countryValue: $stateValue: $cityValue",
        "createdByUser": getuserName,
        "bookings": [],
        "onSale": onSale,
        "salePrice": salePrice,
      });
      await updateTripsCreated(
        category: cat,
        city: cityValue,
        country: countryValue,
        description: description,
        destination: "$countryValue: $stateValue: $cityValue",
        endDate: endDate,
        tripId: tripId,
        importancInfo: importantInfo,
        name: name,
        startDate: startDate,
        imageUrl: imageUrl,
        state: stateValue,
        userid: user.uid,
        totalseats: seats,
        price: price,
        salePrice: salePrice,
        onSale: onSale,
      );
    } catch (e) {
      throw ("unable to create trip due to : $e");
    }

    await TripsProvider().fetchTrips();
    await fetchUserTrips();
    notifyListeners();
  }

  List<TripsModel> get getuserTrips {
    return userCreatedTrips;
  }

  Future<void> updateUserCreatedTrips({
    required String tripId,
    required TripsModel tripDateToUpdate,
  }) async {
    try {
      final User? user = authInstance.currentUser;
      final docRef =
          FirebaseFirestore.instance.collection("users").doc(user!.uid);
      DocumentSnapshot document = await docRef.get();
      if (document.exists) {
        List<dynamic> userCreatedTrips =
            document.get("tripsCreated") as List<dynamic>;
        for (var trip in userCreatedTrips) {
          if (trip["id"] == tripId) {
            trip["category"] = tripDateToUpdate.category;
            trip["city"] = tripDateToUpdate.city;
            trip["country"] = tripDateToUpdate.country;
            trip["description"] = tripDateToUpdate.description;
            trip["destination"] = tripDateToUpdate.destination;
            trip["endDate"] = tripDateToUpdate.endDate;
            trip["id"] = tripDateToUpdate.id;
            trip["importantInfo"] = tripDateToUpdate.importancInfo;
            trip["name"] = tripDateToUpdate.name;
            trip["startDate"] = tripDateToUpdate.startdate;
            trip["imageUrl"] = tripDateToUpdate.imageUrl;
            trip["state"] = tripDateToUpdate.state;
            trip["userid"] = tripDateToUpdate.userid;
            trip["totalseats"] = tripDateToUpdate.totalseats;
            trip["price"] = tripDateToUpdate.price;
            trip["salePrice"] = tripDateToUpdate.salePrice;
            trip["onSale"] = tripDateToUpdate.onSale;
            trip["createdByUser"] = tripDateToUpdate.createdByUser;
            trip["userId"] = user.uid;
          }
        }
        await docRef.update({
          "tripsCreated": userCreatedTrips,
        });
        await fetchUserTrips();
      }
    } catch (e) {
      throw ("unable to update user craeted trip in user doc due to :$e");
    }
  }

  Future<void> fetchUserTrips() async {
    userCreatedTrips.clear();
    try {
      final User? user = authInstance.currentUser;

      CollectionReference collectionReference =
          FirebaseFirestore.instance.collection("users");
      DocumentSnapshot document =
          await collectionReference.doc(user!.uid).get();
      if (document.exists) {
        Map<String, dynamic> userData = document.data() as Map<String, dynamic>;
        List<dynamic> tripsCreated = userData["tripsCreated"] ?? [];
        for (var trip in tripsCreated) {
          userCreatedTrips.add(
            TripsModel(
                category: trip["category"] ?? "cat",
                city: trip["city"] ?? "city",
                country: trip["country"] ?? "country",
                description: trip["description"] ?? "description",
                destination: trip["destination"] ?? "city",
                endDate: trip["endDate"] ?? "endDate",
                id: trip["id"] ?? "id",
                importancInfo: trip["importantInfo"] ?? "tripInfo",
                name: trip["name"] ?? "name",
                startdate: trip["startDate"] ?? "startDate",
                imageUrl: trip["imageUrl"] ?? "imageUrl",
                state: trip["state"] ?? "state",
                userid: trip["userid"] ?? "userid",
                totalseats: trip["totalseats"] ?? 0,
                price: trip["price"] ?? 0.0,
                salePrice: trip["salePrice"] ?? 0.0,
                onSale: trip["onSale"] ?? false,
                createdByUser: trip["createdByUser"] ?? "UserBot12@"),
          );
        }
      }
    } catch (e) {
      throw ("Unable to fetch User trips due to : $e");
    }
  }

  String get getuserName {
    return _userName;
  }

  String get getContactNumber {
    return _contacntNumber;
  }

  Future<void> userNameById({required String userId}) async {
    try {
      CollectionReference collectionReference =
          FirebaseFirestore.instance.collection("users");
      DocumentSnapshot document = await collectionReference.doc(userId).get();
      if (document.exists) {
        Map<String, dynamic> userData = document.data() as Map<String, dynamic>;
        _userName = userData["fullName"] ?? "name";
        _contacntNumber = userData["contactNumber"] ?? "contact Number";
      }
    } catch (e) {
      throw "Unable to get the user name due to $e";
    }
    notifyListeners();
  }
}
