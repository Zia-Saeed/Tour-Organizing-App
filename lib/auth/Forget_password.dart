import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:trip_app/auth/login.dart';
import 'package:trip_app/constss/firebase_auth.dart';
import 'package:trip_app/constss/global_methods.dart';

class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({super.key});

  @override
  State<ForgetPasswordScreen> createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  final TextEditingController _email = TextEditingController();
  final FocusNode _emailFocusNode = FocusNode();
  bool _isLoading = false;

  void _generateNewPassword() async {
    if (_email.text == null ||
        _email.text.isEmpty ||
        !_email.text.trim().contains("@")) {
      showError(context: context, title: "Enter a valid Email address");
    } else {
      setState(() {
        _isLoading = true;
      });
      try {
        await authInstance.sendPasswordResetEmail(
            email: _email.text.toLowerCase());
        Fluttertoast.showToast(
          msg: "An email has been sent to your email address",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.grey.shade600,
          textColor: Colors.white,
          fontSize: 16.0,
        );
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("New Password Generation"),
            content: const Text("An Email has been sent to your email Address"),
            actions: [
              TextButton(
                onPressed: () {
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                          builder: (context) => const LoginScreen()),
                    );
                  }
                },
                child: const Text("Ok"),
              ),
            ],
          ),
        );
      } on FirebaseException catch (error) {
        if (!mounted) {
          return;
        }
        setState(() {
          _isLoading = false;
        });
        showError(context: context, title: "${error.message}");
      } catch (e) {
        setState(() {
          _isLoading = false;
        });

        if (!mounted) {
          return;
        }
        showError(context: context, title: e.toString());
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _email.dispose();
    _emailFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvoked: (bool value) {
        Navigator.canPop(context);
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Forget Password"),
        ),
        body: Container(
          margin: const EdgeInsets.only(
            top: 30,
          ),
          child: Stack(
            children: [
              Image.asset(
                "assets/images/forget_password_page.webp",
                fit: BoxFit.cover,
                height: double.infinity,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      textInputAction: TextInputAction.go,
                      focusNode: _emailFocusNode,
                      controller: _email,
                      onSubmitted: (value) {
                        _generateNewPassword();
                      },
                      decoration: const InputDecoration(
                        hintText: "Enter Email Address",
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 50,
                  ),
                  _isLoading
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey),
                          onPressed: () {
                            _generateNewPassword();
                          },
                          child: const Text(
                            "Generate New Passord",
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
