import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:provider/provider.dart';
import 'package:trip_app/models/wishList_model.dart';
import 'package:trip_app/providers/wishlist_provider.dart';
import 'package:trip_app/screens/bottom_screen.dart';
import 'package:trip_app/screens/empty_screen.dart';
import 'package:trip_app/screens/trip_detail_screen.dart';

class TripWislistScreen extends StatefulWidget {
  const TripWislistScreen({super.key});

  @override
  State<TripWislistScreen> createState() => _TripWislistScreenState();
}

class _TripWislistScreenState extends State<TripWislistScreen> {
  int? removeItemIndex;
  WishlistModel? removedItem;

  void _restoreItem({required item, required index}) {
    userWislist.insert(index, item);
    removeItemIndex = null;
    removedItem = null;
    setState(() {});
  }

  void moveToHomeScreen() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const BottomScreens(),
      ),
    );
    return;
  }

  List<WishlistModel> userWislist = [];

  @override
  Widget build(BuildContext context) {
    final wishListProvider = Provider.of<WishListProvider>(context);

    userWislist = wishListProvider.getUserWishList;

    return Scaffold(
      appBar: AppBar(
        title: Text("Your Wishlist(${userWislist.length})"),
        actions: [
          if (userWislist.isNotEmpty)
            ElevatedButton.icon(
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                          title:
                              const Text("Are you sure to clear the WishList"),
                          actions: [
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                iconColor:
                                    const Color.fromARGB(255, 223, 81, 71),
                                foregroundColor:
                                    const Color.fromARGB(255, 223, 81, 71),
                              ),
                              onPressed: () {
                                if (Navigator.of(context).canPop()) {
                                  Navigator.of(context).pop();
                                }
                              },
                              label: const Text("cancel"),
                              icon: const Icon(Icons.cancel),
                            ),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.green,
                                iconColor: Colors.green,
                              ),
                              onPressed: () {
                                if (Navigator.canPop(context)) {
                                  wishListProvider.clearWishlist();
                                  // userWislist.clear();
                                  Navigator.of(context).pop();
                                }
                              },
                              label: const Text("Ok"),
                              icon: const Icon(Icons.done),
                            ),
                          ],
                        ));
              },
              label: const Text(
                "Clear Wishlist",
                style: TextStyle(color: Color.fromARGB(255, 161, 150, 51)),
              ),
              icon: const Icon(
                IconlyBold.delete,
                color: Color.fromARGB(255, 94, 26, 21),
              ),
            ),
        ],
      ),
      body: userWislist.isEmpty
          ? EmptyScreen(
              text: "Opps! No items in WishList",
              subTitle: "CLick To Check Some Trips or Tours",
              navigatorFunc: moveToHomeScreen,
              icon: const Icon(
                IconlyLight.bag_2,
                size: 100,
                color: Colors.blue,
              ),
            )
          : ListView.separated(
              itemBuilder: (context, index) => Dismissible(
                    direction: DismissDirection.startToEnd,
                    onDismissed: (direction) async {
                      removeItemIndex = index;
                      removedItem = userWislist[index];
                      userWislist.removeAt(index);
                      setState(() {});

                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text("Remove Trip From Wishlist"),
                          actions: [
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                iconColor:
                                    const Color.fromARGB(255, 223, 81, 71),
                                foregroundColor:
                                    const Color.fromARGB(255, 223, 81, 71),
                              ),
                              onPressed: () {
                                if (Navigator.of(context).canPop()) {
                                  _restoreItem(
                                      item: removedItem,
                                      index: removeItemIndex);
                                  setState(() {});
                                  Navigator.of(context).pop();
                                }
                              },
                              label: const Text("cancel"),
                              icon: const Icon(Icons.cancel),
                            ),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.green,
                                iconColor: Colors.green,
                              ),
                              onPressed: () {
                                if (Navigator.canPop(context)) {
                                  userWislist.insert(
                                      removeItemIndex!, removedItem!);
                                  wishListProvider.removeTripFromWishList(
                                      tripId: userWislist[index].tripId);
                                  userWislist.removeAt(removeItemIndex!);
                                  Navigator.of(context).pop();
                                  // setState(() {});
                                  // if()
                                }
                              },
                              label: const Text("Ok"),
                              icon: const Icon(Icons.done),
                            ),
                          ],
                        ),
                      );
                    },
                    key: Key(
                      userWislist[index].tripId.toString(),
                    ),
                    background: Container(
                      color: Colors.red,
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        radius: 50.0,
                        // backgroundImage: ,
                        foregroundImage:
                            NetworkImage(userWislist[index].imageUrl),
                      ),
                      title: Text(
                        userWislist[index].name ?? "name",
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: const TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          fontFamily: "Roboto",
                        ),
                      ),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => TripDetailScren(
                              heroID: userWislist[index].totalseats,
                              name: userWislist[index].name,
                              category: userWislist[index].category,
                              destination: userWislist[index].destination,
                              description: userWislist[index].description,
                              startDate: userWislist[index].startDate,
                              endDate: userWislist[index].endDate,
                              tripId: userWislist[index].tripId,
                              importantInfo: userWislist[index].importantInfo,
                              price: userWislist[index].price,
                              totalseats: userWislist[index].totalseats,
                              userId: userWislist[index].userid,
                              createdByUser: userWislist[index].createdBy,
                              imageUrl: userWislist[index].imageUrl,
                            ),
                          ),
                        );
                      },
                      subtitle: Text(
                        userWislist[index].description,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: const TextStyle(
                          color: Colors.black54,
                          fontFamily: "Roboto",
                        ),
                      ),
                      trailing: Column(
                        children: [
                          Text(
                            userWislist[index].destination,
                            style: TextStyle(
                              fontFamily: "Roboto",
                              fontWeight: FontWeight.bold,
                              overflow: TextOverflow.ellipsis,
                              color: Colors.brown.shade500,
                            ),
                            maxLines: 1,
                          ),
                          Text(
                            "\$${userWislist[index].price.toString()}",
                            style: TextStyle(
                              color: Colors.green.shade700,
                              fontWeight: FontWeight.bold,
                              overflow: TextOverflow.ellipsis,
                              fontFamily: "Roboto",
                            ),
                          ),
                          Flexible(
                            child: IconButton(
                              onPressed: () async {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title:
                                        const Text("Remove Trip From Wishlist"),
                                    actions: [
                                      ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                          iconColor: const Color.fromARGB(
                                              255, 223, 81, 71),
                                          foregroundColor: const Color.fromARGB(
                                              255, 223, 81, 71),
                                        ),
                                        onPressed: () {
                                          if (Navigator.of(context).canPop()) {
                                            Navigator.of(context).pop();
                                            setState(() {});
                                          }
                                        },
                                        label: const Text("cancel"),
                                        icon: const Icon(Icons.cancel),
                                      ),
                                      ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                          foregroundColor: Colors.green,
                                          iconColor: Colors.green,
                                        ),
                                        onPressed: () {
                                          wishListProvider
                                              .removeTripFromWishList(
                                                  tripId: userWislist[index]
                                                      .tripId);

                                          if (Navigator.canPop(context)) {
                                            Navigator.of(context).pop();
                                          }
                                        },
                                        label: const Text("Ok"),
                                        icon: const Icon(Icons.done),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              icon: const Icon(
                                IconlyBold.delete,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              separatorBuilder: (context, index) =>
                  const Divider(color: Colors.black54, thickness: 1),
              itemCount: userWislist.length),
    );
  }
}
