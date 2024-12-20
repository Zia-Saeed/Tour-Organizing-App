import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:provider/provider.dart';
import 'package:trip_app/providers/wishlist_provider.dart';

class HeartButton extends StatefulWidget {
  const HeartButton({super.key, required this.tripId});
  final String tripId;

  @override
  State<HeartButton> createState() => _HeartButtonState();
}

class _HeartButtonState extends State<HeartButton> {
  bool _loading = false;
  @override
  Widget build(BuildContext context) {
    final wishListProvider = Provider.of<WishListProvider>(context);
    return IconButton(
      onPressed: () async {
        _loading = true;
        if (wishListProvider.tripAllReadyInWishlist(tripId: widget.tripId)) {
          await wishListProvider.removeTripFromWishList(tripId: widget.tripId);
          _loading = false;
        } else if (!wishListProvider.tripAllReadyInWishlist(
            tripId: widget.tripId)) {
          await wishListProvider.addTripToWishList(tripId: widget.tripId);
          _loading = false;
        }
      },
      icon: _loading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(),
            )
          : Icon(
              // _isAdded
              !wishListProvider.tripAllReadyInWishlist(tripId: widget.tripId)
                  ? IconlyLight.heart
                  : IconlyBold.heart,
            ),
    );
  }
}
