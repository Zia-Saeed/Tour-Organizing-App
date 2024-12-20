import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:trip_app/auth/Forget_password.dart';
import 'package:trip_app/auth/registration.dart';
import 'package:trip_app/constss/firebase_auth.dart';
import 'package:trip_app/constss/global_methods.dart';
import 'package:trip_app/screens/fetch_screen.dart';
import 'package:trip_app/widgets/google_login.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController _email = TextEditingController();
  TextEditingController _password = TextEditingController();
  bool _hidePassword = true;
  final _formKey = GlobalKey<FormState>();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  bool _isLoading = false;

  void _submiyForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      try {
        setState(() {
          _isLoading = true;
        });
        await authInstance.signInWithEmailAndPassword(
            email: _email.text, password: _password.text);

        if (!mounted) {
          return;
        }
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const FetchScreen(),
          ), // The new screen to push
          (Route<dynamic> route) => false, // Remove all previous routes
        );
      } on FirebaseException catch (error) {
        showError(context: context, title: error.message!);
        setState(() {
          _isLoading = false;
        });
      } catch (e) {
        _isLoading = false;
      } finally {
        _isLoading = false;
      }
    }
    return null;
  }

  @override
  void dispose() {
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Image.asset(
            "assets/images/login_page.jpg",
            fit: BoxFit.cover,
            height: double.infinity,
            width: double.infinity,
          ),
          SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const SizedBox(
                  height: 80,
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
                                  height: 90,
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
                                  keyboardType: TextInputType.emailAddress,
                                  focusNode: _emailFocusNode,
                                  textInputAction: TextInputAction.next,
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return "Please Enter Your Name";
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
                                      )
                                      // border: InputBorder.none,
                                      ),
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
                                  textInputAction: TextInputAction.done,
                                  onFieldSubmitted: (value) {
                                    _submiyForm();
                                  },
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
                                  height: 60,
                                ),
                                _isLoading
                                    ? const SizedBox(
                                        width: 40,
                                        child: CircularProgressIndicator())
                                    : SizedBox(
                                        height: 40,
                                        width: double.infinity,
                                        child: ElevatedButton.icon(
                                          onPressed: () {
                                            _submiyForm();
                                          },
                                          label: const Icon(
                                            Icons.run_circle,
                                            color:
                                                Color.fromARGB(255, 50, 56, 61),
                                          ),
                                          icon: const Text(
                                            "Login",
                                            style: TextStyle(
                                              fontFamily: "Roboto",
                                              fontWeight: FontWeight.bold,
                                              fontSize: 17,
                                            ),
                                          ),
                                        ),
                                      ),
                                const SizedBox(
                                  height: 30,
                                ),
                                GoogleLogin(),
                                const SizedBox(
                                  height: 20,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text(
                                      "Donot Have Account ? ",
                                      style: TextStyle(
                                        fontFamily: "Roboto",
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Colors.white70,
                                      ),
                                    ),
                                    TextButton(
                                      child: Text(
                                        "Sign Up",
                                        style: TextStyle(
                                          color: Colors.blue.shade400,
                                          fontFamily: "Roboto",
                                          fontWeight: FontWeight.bold,
                                          fontSize: 17,
                                        ),
                                      ),
                                      onPressed: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (BuildContext context) {
                                              return const RegistrationForm();
                                            },
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (BuildContext context) {
                                          return const ForgetPasswordScreen();
                                        },
                                      ),
                                    );
                                  },
                                  child: Text(
                                    "Forget Password",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontFamily: "Roboto",
                                      fontWeight: FontWeight.bold,
                                      color: Colors.amber.shade400,
                                    ),
                                  ),
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
