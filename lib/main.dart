import 'package:lit_firebase_auth/lit_firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:pipo/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized(); // Needed for Firebase core
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // Create the initilization Future outside of `build`:
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    // Before Lit Auth can be used, Firebase needs to be initialized and the
    // initialization needs to finish.
    return FutureBuilder(
      future: _initialization,
      builder: (context, snapshot) {
        // Check for errors
        if (snapshot.hasError) {
          return Center(child: Text('Something went wrong'));
        }
        // Once complete, show your application
        if (snapshot.connectionState == ConnectionState.done) {
          // Initialize Lit Firebase Auth. Needs to be called before
          // `MaterialApp`, to ensure all of the child widget, even when
          // navigating to a new route, has access to the Lit auth methods
          return LitAuthInit(
            authProviders: const AuthProviders(
              emailAndPassword: true, // enabled by default
              google: false,
              apple: false,
              anonymous: true,
              github: false,
              twitter: false,
            ),
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'Pipo',
              theme: ThemeData(
                  inputDecorationTheme: InputDecorationTheme(
                      labelStyle: TextStyle(color: Colors.white)),
                  accentColor: Colors.white,
                  buttonTheme: ButtonThemeData(
                    minWidth: 100,
                    height: 45,
                    buttonColor: Colors.purple[600],
                    textTheme: ButtonTextTheme.accent,
                  ),
                  dialogBackgroundColor: Colors.purple[600],
                  textTheme: Theme.of(context).textTheme.apply(
                      fontFamily: "Poppins",
                      bodyColor: Colors.white,
                      displayColor: Colors.white),
                  visualDensity: VisualDensity.adaptivePlatformDensity,
                  fontFamily: "Poppins"),
              home: SplashScreen(),
            ),
          );
        }

        // Otherwise, show something whilst waiting for initialization to complete
        return Center(child: CircularProgressIndicator());
      },
    );
  }
}
