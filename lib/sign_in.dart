import 'package:flutter/material.dart';
import 'package:lit_firebase_auth/lit_firebase_auth.dart';

/// A custom Sign-in widget built with Lit Firebase components
class CustomSignInWidget extends StatelessWidget {
  const CustomSignInWidget({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          height: MediaQuery.of(context).size.height,
          width: double.maxFinite,
          decoration: BoxDecoration(
              gradient:
                  LinearGradient(colors: [Colors.purple[800], Colors.pink])),
          child: Container(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('pipo',
                      style: TextStyle(fontFamily: "Fredoka", fontSize: 32.0)),
                  Text(
                    "",
                    style: Theme.of(context).textTheme.bodyText1,
                  ),

                  // You need to wrap the custom sign-in widgets with a [SignInForm].
                  // This is used to validate the email and password
                  SignInForm(
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width > 1200
                          ? MediaQuery.of(context).size.width / 3
                          : MediaQuery.of(context).size.width,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'Sign in or create an account',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.headline5,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: EmailTextFormField(
                              decoration: InputDecoration(labelText: 'Email'),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: PasswordTextFormField(
                              decoration:
                                  InputDecoration(labelText: 'Password'),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              RaisedButton(
                                onPressed: () {
                                  context.signInWithEmailAndPassword();
                                },
                                child: Text('Sign In'),
                              ),
                              SizedBox(
                                width: 5.0,
                              ),
                              RaisedButton(
                                onPressed: () {
                                  context.registerWithEmailAndPassword();
                                },
                                child: Text('Register'),
                              ),
                              SizedBox(
                                width: 5.0,
                              ),
                              RaisedButton(
                                onPressed: () {
                                  context.signInAnonymously();
                                },
                                child: Text('Sign In (Anonymous)'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
