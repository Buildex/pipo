import 'package:flutter/material.dart';
import 'package:lit_firebase_auth/lit_firebase_auth.dart';
import 'package:pipo/sign_in.dart';

import 'authenticated.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: LitAuthState(
            authenticated: YourAuthenticatedWidget(),

            // Standard
            // unauthenticated: LitAuth(
            //   config: AuthConfig(
            //     title: Text(
            //       'pipo',
            //       textAlign: TextAlign.center,
            //       style: Theme.of(context).textTheme.headline4,
            //     ),
            //     googleButton: GoogleButtonConfig.light(),
            //     appleButton: AppleButtonConfig.dark(),
            //     emailTextField: TextFieldConfig(
            //       style: TextStyle(fontSize: 18, color: Colors.red),
            //       inputDecoration: InputDecoration(
            //         labelStyle: TextStyle(color: Colors.black),
            //         labelText: 'Email',
            //       ),
            //     ),
            //   ),
            // ),

            // USE THIS FOR A CUSTOM SIGN IN WIDGET
            /// Custom
            unauthenticated: LitAuth.custom(
              child: CustomSignInWidget(),
            ),
          ),
        ),
      ),
    );
  }
}
