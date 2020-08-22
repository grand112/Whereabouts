import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';

class UserImagePicker extends StatefulWidget {
  UserImagePicker(this.imagePickFn);
  final Function(File pickedImage) imagePickFn;

  @override
  _UserImagePickerState createState() => _UserImagePickerState();
}

class _UserImagePickerState extends State<UserImagePicker> {
  File pickedImageFile;
  File _pickedImage;

  void initState() {
    super.initState();
    _getDefaultAvatar();
  }

  void _getDefaultAvatar() async {
    pickedImageFile = await getImageFileFromAssets('default_avatar.png');
    widget.imagePickFn(pickedImageFile);
  }

  Future<File> getImageFileFromAssets(String path) async {
    final byteData = await rootBundle.load('assets/$path');

    final file = File('${(await getTemporaryDirectory()).path}/$path');
    await file.writeAsBytes(byteData.buffer
        .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
    return file;
  }

  void _pickImage(BuildContext context) {
    final double heightOfScreen = MediaQuery.of(context).size.height;
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Container(
              height: heightOfScreen * 0.4,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: <Widget>[
                    Text(
                      'Choose your profile image:',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                    ),
                    SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Column(
                          children: <Widget>[
                            FlatButton(
                              onPressed: () async {
                                pickedImageFile = await ImagePicker.pickImage(
                                    imageQuality: 50,
                                    maxWidth: 300,
                                    source: ImageSource.camera);
                                setState(() {
                                  _pickedImage = pickedImageFile;
                                });
                                Navigator.of(context).pop();
                                widget.imagePickFn(pickedImageFile);
                              },
                              child: Icon(
                                Icons.camera_alt,
                                color: Theme.of(context).backgroundColor,
                                size: 50,
                              ),
                            ),
                            Text('Camera')
                          ],
                        ),
                        Column(
                          children: <Widget>[
                            FlatButton(
                              onPressed: () async {
                                pickedImageFile = await ImagePicker.pickImage(
                                    imageQuality: 50,
                                    maxWidth: 300,
                                    source: ImageSource.gallery);
                                setState(() {
                                  _pickedImage = pickedImageFile;
                                });
                                Navigator.of(context).pop();
                                widget.imagePickFn(pickedImageFile);
                              },
                              child: Icon(
                                Icons.image,
                                color: Theme.of(context).backgroundColor,
                                size: 50,
                              ),
                            ),
                            Text('Gallery')
                          ],
                        ),
                      ],
                    ),
                    Container(
                      margin: EdgeInsets.only(
                        top: 10,
                        bottom: 10,
                      ),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Divider(
                              color: Colors.grey[700],
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(
                              left: 10,
                              right: 10,
                            ),
                            child: Text(
                              "OR",
                              style: TextStyle(color: Colors.grey[700]),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Column(
                          children: <Widget>[
                            FlatButton(
                              onPressed: () async {
                                pickedImageFile = await getImageFileFromAssets(
                                    'default_avatar.png');
                                Navigator.of(context).pop();
                                widget.imagePickFn(pickedImageFile);
                              },
                              child: CircleAvatar(
                                radius: 30,
                                backgroundColor:
                                    Theme.of(context).backgroundColor,
                                backgroundImage:
                                    AssetImage('assets/default_avatar.png'),
                              ),
                            ),
                            SizedBox(height: 3),
                            Text('Default')
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        SizedBox(height: 5),
        CircleAvatar(
          radius: 40,
          backgroundColor: Theme.of(context).backgroundColor,
          backgroundImage: _pickedImage == null
              ? AssetImage('assets/default_avatar.png')
              : FileImage(_pickedImage),
        ),
        SizedBox(height: 5),
        FlatButton.icon(
          textColor: Colors.black,
          onPressed: () => _pickImage(context),
          icon: Icon(Icons.image),
          label: Text('Choose your\nprofile image'),
        ),
      ],
    );
  }
}
