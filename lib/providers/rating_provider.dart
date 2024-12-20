import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class RatingProvider with ChangeNotifier {
  double totalRating = 0.0;
  bool hasUserAlreadyRated = false;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Adds a rating for a user
  Future<void> addUserRating({
    required String userId, // The ID of the user being rated
    required String raterId, // The ID of the user giving the rating
    required double rating, // The rating value (e.g., 4.5)
  }) async {
    try {
      final docRef = _firestore.collection('UsersRatings').doc(userId);

      // Fetch the document for the user being rated
      final docSnapshot = await docRef.get();

      if (docSnapshot.exists) {
        // User document exists
        final data = docSnapshot.data() as Map<String, dynamic>;
        List<dynamic> ratings = data['ratings'] ?? [];
        List<dynamic> raterIds = data['raterIds'] ?? [];

        // Check if the rater has already rated (optional)
        if (raterIds.contains(raterId)) {
          Fluttertoast.showToast(
            msg: "You have already rated this user.",
            backgroundColor: Colors.teal.shade300,
            gravity: ToastGravity.TOP,
            fontSize: 16,
            timeInSecForIosWeb: 4000000,
          );
        }

        // Add the new rating and raterId
        ratings.add(rating);
        raterIds.add(raterId);

        // Calculate the new average rating
        double averageRating = ratings.reduce((a, b) => a + b) / ratings.length;

        // Update the user document
        await docRef.update({
          'ratings': ratings,
          'raterIds': raterIds,
          'averageRating': averageRating,
        });
      } else {
        // Create a new document if the user doesn't exist
        await docRef.set({
          'userId': userId,
          'ratings': [rating],
          'raterIds': [raterId],
          'averageRating': rating,
        });
      }

      Fluttertoast.showToast(
        msg: "Ratings Given SuccessFully",
        backgroundColor: Colors.teal.shade300,
        gravity: ToastGravity.TOP,
        fontSize: 16,
        timeInSecForIosWeb: 4000000,
      );
      notifyListeners();
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Error adding user rating: $e",
        backgroundColor: Colors.teal.shade300,
        gravity: ToastGravity.TOP,
        fontSize: 16,
        timeInSecForIosWeb: 4000000,
      );
      rethrow;
    }
  }

  Future<void> hasUserRated({
    required String raterId,
    required String userId,
  }) async {
    try {
      final FirebaseFirestore _firestore = FirebaseFirestore.instance;
      final docRef = _firestore.collection('UsersRatings').doc(userId);

      // Fetch the document for the user being rated
      final docSnapshot = await docRef.get();

      if (docSnapshot.exists) {
        // User document exists
        final data = docSnapshot.data() as Map<String, dynamic>;
        List<dynamic> ratings = data['ratings'] ?? [];
        List<dynamic> raterIds = data['raterIds'] ?? [];

        // Check if the rater has already rated (optional)
        if (raterIds.contains(raterId)) {
          hasUserAlreadyRated = true;
          notifyListeners();
        } else {
          hasUserAlreadyRated = false;
          notifyListeners();
          return;
        }
      }
    } catch (e) {
      throw "Unable to check wheather User has rated or not due to $e";
    }
  }

  /// Fetches the ratings and average rating for a user
  Future<void> fetchUserRatings({
    required String userId, // ID of the user being fetched
  }) async {
    try {
      final docRef = _firestore.collection('UsersRatings').doc(userId);

      // Get the document snapshot
      final docSnapshot = await docRef.get();

      if (docSnapshot.exists) {
        // Return the document's data
        final ratingsDoc = docSnapshot.data() as Map<String, dynamic>;
        totalRating = ratingsDoc["averageRating"] ?? 0.0;
        notifyListeners();
        return;
      } else {
        return;
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Error fetching user ratings: $e",
        backgroundColor: Colors.teal.shade300,
        gravity: ToastGravity.TOP,
        fontSize: 16,
        timeInSecForIosWeb: 4000000,
      );
      rethrow;
    }
  }

  double get getTotalrating {
    return totalRating;
  }

  bool get getHasUserRated {
    return hasUserAlreadyRated;
  }
}
