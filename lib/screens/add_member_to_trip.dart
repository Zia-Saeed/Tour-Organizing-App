import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:trip_app/providers/trips_provider.dart';
import 'package:uuid/uuid.dart';

class AddMemberToTrip extends StatefulWidget {
  const AddMemberToTrip({
    super.key,
    required this.tripId,
  });
  final String tripId;

  @override
  State<AddMemberToTrip> createState() => _AddMemberToTripState();
}

class _AddMemberToTripState extends State<AddMemberToTrip> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  DateTime? date;
  bool datePicked = false;
  bool loading = false;
  Future<void> _selectDate(BuildContext context) async {
    final DateTime currentDate = DateTime.now();
    final DateTime initialDate = currentDate;

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      setState(() {
        datePicked = true;
        date = pickedDate;
      });
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      if (date == null) {
        Fluttertoast.showToast(
            msg: "Please select a date",
            backgroundColor: const Color.fromARGB(255, 73, 123, 130));
      }
      if (date != null) {
        try {
          setState(() {});
          loading = true;
          final tripProvider =
              Provider.of<TripsProvider>(context, listen: false);
          final uuid = const Uuid().v4();
          await tripProvider.bookingUser(
            tripId: widget.tripId,
            name: _nameController.text,
            email: _emailController.text,
            amount: double.parse(_priceController.text),
            date: date.toString(),
            phoneNumber: _phoneController.text,
            bookingId: uuid,
          );
          Fluttertoast.showToast(
            gravity: ToastGravity.TOP,
            msg: "Booked Successfully",
            backgroundColor: const Color.fromARGB(255, 61, 90, 104),
          );
        } catch (e) {
          Fluttertoast.showToast(
            msg: "Unable to add new booking due to $e",
            backgroundColor: const Color.fromARGB(255, 61, 90, 104),
          );
        } finally {
          loading = false;
          _formKey.currentState?.reset();
          _nameController.clear();
          _emailController.clear();
          _phoneController.clear();
          _priceController.clear();
          setState(() {});
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Book a new Memeber"),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 30,
                ),
                TextFormField(
                  controller: _nameController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a valid name';
                    }
                  },
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Member Name",
                    labelStyle: TextStyle(
                      fontFamily: "Roboto",
                      fontWeight: FontWeight.bold,
                    ),
                    labelText: "Member Name",
                    hintStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: "Roboto",
                    ),
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                TextFormField(
                  controller: _emailController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a valid Email address';
                    }
                  },
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Email Address",
                    labelStyle: TextStyle(
                      fontFamily: "Roboto",
                      fontWeight: FontWeight.bold,
                    ),
                    labelText: "Email Address",
                    hintStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: "Roboto",
                    ),
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                TextFormField(
                  controller: _phoneController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a phoneNumber';
                    }
                  },
                  keyboardType: const TextInputType.numberWithOptions(),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Phone Number",
                    labelStyle: TextStyle(
                      fontFamily: "Roboto",
                      fontWeight: FontWeight.bold,
                    ),
                    labelText: "Phone Number",
                    hintStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: "Roboto",
                    ),
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(
                      width: screenSize.width - 260,
                      child: TextFormField(
                        controller: _priceController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a valid amount';
                          }
                          try {
                            double.parse(value);
                          } catch (e) {
                            return 'Please enter a valid amount';
                          }
                        },
                        keyboardType: const TextInputType.numberWithOptions(),
                        decoration: const InputDecoration(
                          border: UnderlineInputBorder(),
                          hintText: "Total Amount",
                        ),
                      ),
                    ),
                    // Spacer(),
                    ElevatedButton(
                      onPressed: () => _selectDate(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.brown.shade100,
                        foregroundColor: Colors.black87,
                      ),
                      child: Text(
                        datePicked
                            ? date!.toLocal().toString().split(' ')[0]
                            : "Select Date",
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 40,
                ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    label: const Text(
                      "Done Booking",
                      style: TextStyle(
                        color: Colors.black87,
                      ),
                    ),
                    icon: loading
                        ? SizedBox(
                            child: CircularProgressIndicator(
                              backgroundColor: Colors.brown.shade100,
                              strokeWidth: 2,
                              strokeAlign: 0.5,
                              strokeCap: StrokeCap.butt,
                            ),
                          )
                        : const Icon(Icons.bookmark_add),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade400),
                    onPressed: () async {
                      _submitForm();
                    },
                  ),
                )
                // TextFormField(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
