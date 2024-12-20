import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:trip_app/auth/login.dart';
import 'package:trip_app/constss/firebase_auth.dart';
import 'package:trip_app/constss/global_methods.dart';
import 'package:trip_app/screens/fetch_screen.dart';

class RegistrationForm extends StatefulWidget {
  const RegistrationForm({super.key});

  @override
  State<RegistrationForm> createState() => _RegistrationFormState();
}

class _RegistrationFormState extends State<RegistrationForm> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _userName = TextEditingController();
  final TextEditingController _contactNumber = TextEditingController();

  bool _hidePassword = true;
  final _formKey = GlobalKey<FormState>();
  final _userNameFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  bool _isValidNumber = false;
  String contactNumber = "";
  String countryCode = "";
  String countryISOCode = "";
  bool _isLoading = false;
  bool emailVarified = false;
  bool resendEmail = false;

  void _submiyForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _isLoading = true;
      });
      try {
        // Create the user account
        UserCredential userCredential =
            await authInstance.createUserWithEmailAndPassword(
          email: _email.text.toLowerCase().trim(),
          password: _password.text.trim(),
        );

        // Send the email verification
        await userCredential.user?.sendEmailVerification();
        Fluttertoast.showToast(
          msg: "Verification email sent. Please check your inbox.",
          backgroundColor: Colors.teal.shade300,
          gravity: ToastGravity.TOP,
          fontSize: 16,
          timeInSecForIosWeb: 4000000,
        );

        User? user = authInstance.currentUser;

        // Wait for email verification
        bool isVerified = false;
        while (!isVerified) {
          await Future.delayed(const Duration(
              seconds: 3)); // Wait 3 seconds before checking again
          await user
              ?.reload(); // Reload user data to get the latest emailVerified status
          user = authInstance.currentUser; // Refresh the user object
          if (user != null && user.emailVerified) {
            isVerified = true; // Exit the loop when the email is verified
          }
          Fluttertoast.showToast(
            msg: "Verification email sent. Please check your inbox.",
            backgroundColor: Colors.teal.shade300,
            gravity: ToastGravity.TOP,
            fontSize: 16,
            timeInSecForIosWeb: 4000000,
          );
        }

        // Proceed with user creation in Firestore if email is verified
        Fluttertoast.showToast(
          msg: "Email Verified!",
          backgroundColor: Colors.teal.shade300,
          gravity: ToastGravity.TOP,
          fontSize: 16,
          timeInSecForIosWeb: 4000000,
        );

        final _uuid = user!.uid;

        await FirebaseFirestore.instance.collection('users').doc(_uuid).set({
          "id": _uuid,
          "contactNumber": "$countryCode $contactNumber",
          "countryISOCode": countryISOCode,
          "fullName": _userName.text.trim(),
          "email": _email.text.toLowerCase().trim(),
          "createdAt": Timestamp.now(),
          "bookedTrips": [],
          "savedTrips": [],
          "tripHistory": [],
          "tripsCreated": [],
        });

        await FirebaseFirestore.instance.collection("Ratings").doc(_uuid).set({
          "raterId": [],
          "rating": [],
        });

        setState(() {
          _isLoading = false;
        });

        if (!mounted) return;

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  const FetchScreen()), // Navigate to the next screen
          (Route<dynamic> route) => false, // Remove all previous routes
        );
      } on FirebaseAuthException catch (error) {
        showError(
          context: context,
          title: error.message!,
        );
        setState(() {
          _isLoading = false;
        });
      } catch (e) {
        showError(context: context, title: e.toString());
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _userNameFocusNode.dispose();
    _email.dispose();
    _password.dispose();
    _contactNumber.dispose();
    _userNameFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Image.asset(
            "assets/images/registration_page.jpg",
            fit: BoxFit.cover,
            height: double.infinity,
            width: double.infinity,
          ),
          SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    elevation: 8,
                    shadowColor: const Color.fromARGB(255, 29, 29, 29),
                    color: Colors.transparent,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Form(
                        key: _formKey,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const SizedBox(
                                  height: 60,
                                ),
                                const Text(
                                  "Welcome To Trip Fiesta",
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontFamily: "Roboto",
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                                const SizedBox(
                                  height: 30,
                                ),
                                Image.network(
                                  "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTmDYhWr8PWtxhS-Z_BnaWXY8gX-d47ehK80Q&s",
                                  height: 100,
                                  width: 100,
                                ),
                                const SizedBox(
                                  height: 40,
                                ),
                                TextFormField(
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return "Enter Name";
                                    } else if (value.trim().length < 6) {
                                      return "Name Should atleast of 5 characters";
                                    } else {
                                      return null;
                                    }
                                  },
                                  focusNode: _userNameFocusNode,
                                  textInputAction: TextInputAction.next,
                                  style: const TextStyle(
                                    color: Colors.white,
                                  ),
                                  decoration: InputDecoration(
                                    hintStyle: TextStyle(
                                      foreground: Paint()
                                        ..color = Colors.white70,
                                    ),
                                    hintText: "Full Name",
                                  ),
                                  controller: _userName,
                                ),
                                const SizedBox(
                                  height: 40,
                                ),
                                TextFormField(
                                  keyboardType: TextInputType.emailAddress,
                                  focusNode: _emailFocusNode,
                                  textInputAction: TextInputAction.next,
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return "Please Enter Your Email";
                                    } else if (!value.contains("@")) {
                                      return "Please Enter a valid Email";
                                    } else {
                                      return null;
                                    }
                                  },
                                  style: const TextStyle(
                                    color: Colors.white,
                                  ),
                                  decoration: const InputDecoration(
                                      hintText: "Email",
                                      hintStyle: TextStyle(
                                        color: Colors.white70,
                                      )),
                                  controller: _email,
                                ),
                                const SizedBox(
                                  height: 40,
                                ),
                                TextFormField(
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return "Enter password";
                                    } else if (value.trim().length < 6) {
                                      return "Password should be at least 6 characters";
                                    } else {
                                      return null;
                                    }
                                  },
                                  focusNode: _passwordFocusNode,
                                  textInputAction: TextInputAction.next,
                                  style: const TextStyle(
                                    color: Colors.white,
                                  ),
                                  obscureText: _hidePassword,
                                  decoration: InputDecoration(
                                    hintStyle: TextStyle(
                                      foreground: Paint()
                                        ..color = Colors.white70,
                                    ),
                                    hintText: "Password",
                                    suffixIcon: IconButton(
                                      onPressed: () {
                                        setState(() {
                                          _hidePassword = !_hidePassword;
                                        });
                                      },
                                      icon: Icon(
                                        _hidePassword
                                            ? Icons.visibility_off
                                            : Icons.visibility,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  controller: _password,
                                ),
                                const SizedBox(
                                  height: 40,
                                ),
                                IntlPhoneField(
                                  decoration: const InputDecoration(
                                    labelText: "Phone Number",
                                    border: UnderlineInputBorder(
                                      borderSide: BorderSide(),
                                    ),
                                  ),
                                  initialCountryCode:
                                      'US', // Set the default country code
                                  onChanged: (phone) {
                                    setState(() {
                                      contactNumber = phone.number;
                                      countryCode = phone.countryCode;
                                      countryISOCode = phone.countryISOCode;
                                      _isValidNumber = phone.isValidNumber();
                                    });
                                  },
                                ),
                                const SizedBox(
                                  height: 40,
                                ),
                                SizedBox(
                                  height: 40,
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      _submiyForm();
                                    },
                                    label: const Icon(
                                      Icons.run_circle_sharp,
                                      color: Color.fromARGB(255, 50, 56, 61),
                                    ),
                                    icon: _isLoading
                                        ? const CircularProgressIndicator()
                                        : Text(
                                            resendEmail
                                                ? "Resend varification Code"
                                                : "Register User",
                                            style: const TextStyle(
                                              fontFamily: "Roboto",
                                              fontWeight: FontWeight.bold,
                                              fontSize: 17,
                                            ),
                                          ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text(
                                      "Already Have Account ? ",
                                      style: TextStyle(
                                        fontFamily: "Roboto",
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Colors.white70,
                                      ),
                                    ),
                                    TextButton(
                                      child: Text(
                                        "Login ",
                                        style: TextStyle(
                                          color: Colors.blue.shade400,
                                          fontFamily: "Roboto",
                                          fontWeight: FontWeight.bold,
                                          fontSize: 17,
                                        ),
                                      ),
                                      onPressed: () {
                                        Navigator.of(context).pushReplacement(
                                          MaterialPageRoute(
                                            builder: (BuildContext context) {
                                              return const LoginScreen();
                                            },
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
