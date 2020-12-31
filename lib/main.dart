import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:lit_firebase_auth/lit_firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase/firebase.dart' as fb;

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
              anonymous: false,
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

            /// Standard
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
            //         labelText: 'Your Email',
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

/// An example widget. This can be anything that you want to show after
/// succesful authentication
class YourAuthenticatedWidget extends StatefulWidget {
  const YourAuthenticatedWidget({
    Key key,
  }) : super(key: key);

  @override
  _YourAuthenticatedWidgetState createState() =>
      _YourAuthenticatedWidgetState();
}

class _YourAuthenticatedWidgetState extends State<YourAuthenticatedWidget> {
  LitUser user;

  Future<Uri> uploadFile(Uint8List file, BuildContext context,
      {String fileName}) async {
    final litUser = context.getSignedInUser();
    litUser.when((user) async {
      final storageRef = fb.storage().ref("${user.uid}/$fileName");
      final task = await storageRef.put(file).future;

      Uri imageUri = await task.ref.getDownloadURL();
      print(imageUri);
      Navigator.of(context).pop();
      setState(() {});
      (() {});
      return imageUri;
    }, empty: () {}, initializing: () {});
  }

  @override
  void initState() {
    user = context.getSignedInUser();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
          gradient: LinearGradient(colors: [Colors.purple[800], Colors.pink])),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("pipo",
                        style:
                            TextStyle(fontFamily: "Fredoka", fontSize: 32.0)),
                    SizedBox(width: 5.0),
                    RaisedButton.icon(
                      icon: Icon(Icons.lock_outline),
                      onPressed: () {
                        context.signOut();
                      },
                      label: Text("Sign out"),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 10.0,
              ),
              RaisedButton.icon(
                icon: Icon(Icons.upload_file),
                onPressed: () async {
                  FilePicker.platform.pickFiles().then((result) async {
                    showDialog(
                        context: context,
                        builder: (context) => SimpleDialog(
                              title: Text("Uploading file..."),
                              children: [
                                Center(child: CircularProgressIndicator())
                              ],
                            ));
                    print(result.files.single.bytes.length);
                    await uploadFile(result.files.single.bytes, context,
                        fileName: result.files.single.name);
                  });
                },
                label: Text("Upload a file"),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height,
                child: FutureBuilder(
                  future: fb
                      .storage()
                      .ref(user.when((user) => user.uid,
                          empty: () {}, initializing: () {}))
                      .listAll(),
                  builder: (context, list) {
                    switch (list.connectionState) {
                      case ConnectionState.waiting:
                        return Center(child: CircularProgressIndicator());
                        break;
                      case ConnectionState.done:
                        print(list.data.items.length);
                        return GridView.builder(
                          gridDelegate:
                              SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 200.0),
                          itemCount: list.data.items.length,
                          itemBuilder: (context, itemCount) {
                            return GridTile(
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                      child: Icon(
                                    Icons.file_present,
                                    color: Colors.white,
                                  )),
                                  Text(
                                    list.data.items[itemCount].name,
                                    textAlign: TextAlign.center,
                                  ),
                                  RaisedButton.icon(
                                    icon: Icon(Icons.copy_rounded),
                                    label: Text("Copy link"),
                                    onPressed: () async {
                                      Uri url = await list.data.items[itemCount]
                                          .getDownloadURL();
                                      Clipboard.setData(
                                          ClipboardData(text: url.toString()));
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                        break;
                      default:
                        return CircularProgressIndicator();
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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
