import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lit_firebase_auth/lit_firebase_auth.dart';
import 'package:firebase/firebase.dart' as fb;

/* Rates:
Store: 0.05 / GB
Download: 0.20 / GB
Upload: 0.10 / 10k
Download operation: 0.008 / 10k
*/
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
  List<Uri> urls = List<Uri>();

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
    return null;
  }

  getImages() async {
    fb.ListResult list = await fb
        .storage()
        .ref(user.when((user) => user.uid, empty: () {}, initializing: () {}))
        .listAll();

    list.items.forEach((item) async {
      Uri url = await item.getDownloadURL();
      urls.add(url);
    });

    setState(() {});
  }

  @override
  void initState() {
    user = context.getSignedInUser();
    getImages();
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
                        barrierDismissible: false,
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
                height: 10.0,
              ),
              RaisedButton.icon(
                icon: Icon(Icons.folder),
                onPressed: () async {
                  FilePicker.platform.pickFiles().then((result) async {
                    showDialog(
                        barrierDismissible: false,
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
                label: Text("Create a folder"),
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
                              SliverGridDelegateWithMaxCrossAxisExtent(
                                  maxCrossAxisExtent: 200.0),
                          itemCount: list.data.items.length,
                          itemBuilder: (context, itemCount) {
                            final file = list.data.items[itemCount];

                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: GridTile(
                                child: FutureBuilder(
                                  future: file.getDownloadURL(),
                                  builder: (context,
                                      AsyncSnapshot<dynamic> snapshot) {
                                    switch (snapshot.connectionState) {
                                      case ConnectionState.done:
                                        String extension =
                                            file.name.split(".")[1];
                                        if (extension == "jpg" ||
                                            extension == "png" ||
                                            extension == "gif" ||
                                            extension == "webp" ||
                                            extension == "bpm" ||
                                            extension == "wbpm") {
                                          return Container(
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(8.0)),
                                              shape: BoxShape.rectangle,
                                            ),
                                            child: Image.network(
                                              snapshot.data.toString(),
                                              fit: BoxFit.contain,
                                            ),
                                          );
                                        } else if (extension == "wav" ||
                                            extension == "mp3" ||
                                            extension == "ogg") {
                                          return Center(
                                              child: Icon(
                                            Icons.audiotrack,
                                            color: Colors.white,
                                          ));
                                        } else if (extension == "exe") {
                                          return Center(
                                              child: Icon(
                                            Icons.padding,
                                            color: Colors.white,
                                          ));
                                        } else if (extension == "mp4") {
                                          return Center(
                                              child: Icon(
                                            Icons.movie,
                                            color: Colors.white,
                                          ));
                                        } else {
                                          return Center(
                                              child: Icon(
                                            Icons.file_present,
                                            color: Colors.white,
                                          ));
                                        }
                                        break;
                                      case ConnectionState.waiting:
                                        return Center(
                                          child: CircularProgressIndicator(),
                                        );
                                        break;
                                      default:
                                        return Expanded(
                                            child: Icon(
                                          Icons.error,
                                          color: Colors.white,
                                        ));
                                        break;
                                    }
                                  },
                                ),
                                header: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: Colors.purple[800],
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(8.0)),
                                        shape: BoxShape.rectangle,
                                        border: Border.all(
                                            color: Colors.black, width: 2.0)),
                                    child: Text(
                                      file.name.length > 25
                                          ? file.name.substring(0, 25)
                                          : file.name,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                                footer: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.center,
                                  children: [
                                    Tooltip(
                                      message: "Copy link",
                                      child: IconButton(
                                        color: Colors.white,
                                        icon: Icon(Icons.copy_rounded),
                                        //label: Text(""),
                                        onPressed: () async {
                                          Uri url = await file.getDownloadURL();
                                          Clipboard.setData(ClipboardData(
                                              text: url.toString()));
                                        },
                                      ),
                                    ),
                                    Tooltip(
                                      message: "Delete",
                                      child: IconButton(
                                        color: Colors.white,
                                        icon: Icon(Icons.delete),
                                        //label: Text(""),
                                        onPressed: () async {
                                          await file.delete();
                                          setState(() {
                                            
                                          });
                                        },
                                      ),
                                    ),
                                  ],
                                ),
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
