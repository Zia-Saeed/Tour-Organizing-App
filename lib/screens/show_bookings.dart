// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:provider/provider.dart';
import 'package:trip_app/providers/trips_provider.dart';

class ShowBookingsScreen extends StatefulWidget {
  const ShowBookingsScreen({
    super.key,
    required this.tripId,
  });
  final String tripId;

  @override
  State<ShowBookingsScreen> createState() => _ShowBookingsScreenState();
}

class _ShowBookingsScreenState extends State<ShowBookingsScreen> {
  @override
  void initState() {
    final tripProvider = Provider.of<TripsProvider>(context, listen: false);
    tripProvider.fetchBooking(tripId: widget.tripId);
    super.initState();
  }

  List<dynamic> totalBooking = [];

  @override
  Widget build(BuildContext context) {
    final tripProvider = Provider.of<TripsProvider>(context);
    totalBooking = tripProvider.getbookings;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Total Bookings",
        ),
      ),
      body: ListView.builder(
        itemBuilder: (context, index) => Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListTile(
            leading: Text(
              totalBooking[index]["name"].toString(),
              style: const TextStyle(
                  color: Color.fromARGB(255, 58, 107, 60), fontSize: 15),
            ),
            title: Text(
              "paid ${totalBooking[index]["amount"]}\$",
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: const TextStyle(
                color: Color.fromARGB(255, 129, 119, 30),
                fontWeight: FontWeight.bold,
                fontSize: 16,
                fontFamily: "Roboto",
              ),
            ),
            onTap: () {},
            subtitle: Text(
              totalBooking[index]["email"],
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: const TextStyle(
                color: Color.fromARGB(255, 18, 45, 66),
                fontFamily: "Roboto",
              ),
            ),
            trailing: Column(
              children: [
                Text(
                  totalBooking[index]["phoneNumber"],
                  style: TextStyle(
                    fontFamily: "Roboto",
                    fontWeight: FontWeight.bold,
                    overflow: TextOverflow.ellipsis,
                    color: Colors.brown.shade500,
                  ),
                  maxLines: 1,
                ),
                Text(
                  totalBooking[index]["date"].split(" ")[0],
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
                          title: const Text("Press yes to remove booking"),
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
                                tripProvider.removeBooking(
                                    tripId: widget.tripId,
                                    bookedId: totalBooking[index]["bookedId"]);
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
        itemCount: totalBooking.length,
      ),
    );
  }
}
