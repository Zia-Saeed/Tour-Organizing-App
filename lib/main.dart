import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:trip_app/constss/theme_data.dart';
import 'package:trip_app/providers/rating_provider.dart';
import 'package:trip_app/providers/trips_provider.dart';
import 'package:trip_app/providers/user_provider.dart';
import 'package:trip_app/providers/wishlist_provider.dart';
import 'package:trip_app/screens/fetch_screen.dart';
// import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: "assets/.env");
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: "${dotenv.env['apiKey']}",
      appId: "${dotenv.env['appId']}",
      messagingSenderId: "${dotenv.env['messagingSenderId']}",
      projectId: "${dotenv.env['projectId']}",
      storageBucket: "${dotenv.env['storageBucket']}",
    ),
  );
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) {
    runApp(MainScreen());
  });
}

class MainScreen extends StatelessWidget {
  MainScreen({super.key});

  final Future<FirebaseApp> _firebaseInitialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _firebaseInitialization,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return MaterialApp(
            theme: Styles().themeData(context),
            home: const Scaffold(
              body: CircularProgressIndicator(),
            ),
          );
        } else if (snapshot.hasError) {
          MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              body: Center(
                child: Text("An Error occured${snapshot.error}"),
              ),
            ),
          );
        }
        return MultiProvider(
          providers: [
            ChangeNotifierProvider(
              create: (_) => TripsProvider(),
            ),
            ChangeNotifierProvider(
              create: (_) => UserProvider(),
            ),
            ChangeNotifierProvider(
              create: (_) => WishListProvider(),
            ),
            ChangeNotifierProvider(
              create: (_) => RatingProvider(),
            )
          ],
          child: const MaterialApp(
            debugShowCheckedModeBanner: false,
            title: "Winter Is Comming",
            home: FetchScreen(),
          ),
        );
      },
    );
  }
}
