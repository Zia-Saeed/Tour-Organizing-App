import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:trip_app/constss/firebase_auth.dart';
import 'package:trip_app/screens/home_screen.dart';

class GoogleLogin extends StatelessWidget {
  GoogleLogin({super.key});

  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<void> _googleLogin(context) async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // User canceled the sign-in
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await authInstance.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Sign in successful, Welcome ${user.displayName}')),
        );
        Navigator.of(context)
            .pushReplacement(MaterialPageRoute(builder: (BuildContext context) {
          return const HomeScreen();
        }));
        // Navigate to another screen, or handle sign-in success
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sign in failed: ${e.message}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {},
        label: const Icon(
          FontAwesomeIcons.google,
          color: Color.fromARGB(255, 95, 35, 35),
        ),
        icon: const Text(
          "Login With Google",
          style: TextStyle(
            fontFamily: "Roboto",
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
      ),
    );
  }
}
