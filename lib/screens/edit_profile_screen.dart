import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileScreen extends StatefulWidget {
  static const routeName = '/edit-profile-screen';

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  String _backgroundUrl;
  String _imageUrl;
  String _username;
  String _enteredHobby;
  String _enteredAbout;
  String _enteredNick;
  File _pickedAvatar;
  File _pickedBackground;
  bool _isLoading = false;
  String _defaultBackground =
      'https://firebasestorage.googleapis.com/v0/b/whereabouts-b22a6.appspot.com/o/logo%2Flogo_title_white.png?alt=media&token=87e02392-c602-49c0-837d-cb401fab2111';

  @override
  void initState() {
    super.initState();
    _getUserData();
  }

  Future<void> _sendData() async {
    setState(() {
      _isLoading = true;
    });
    dynamic urlBackground;
    dynamic urlAvatar;
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    if (_pickedAvatar != null) {
      final refAvatar = FirebaseStorage.instance
          .ref()
          .child('user_image')
          .child(user.uid + '.jpg');
      await refAvatar.putFile(_pickedAvatar).onComplete;
      urlAvatar = await refAvatar.getDownloadURL();
    }
    if (_pickedBackground != null) {
      final refBackground = FirebaseStorage.instance
          .ref()
          .child('background_images')
          .child(user.uid + '.jpg');
      await refBackground.putFile(_pickedBackground).onComplete;
      urlBackground = await refBackground.getDownloadURL();
    }

    await Firestore.instance.collection('users').document(user.uid).updateData({
      if (_enteredNick != null) 'username': _enteredNick,
      if (_pickedBackground != null) 'background': urlBackground,
      if (_pickedAvatar != null) 'image_url': urlAvatar,
      if (_enteredAbout != null) 'about': _enteredAbout,
      if (_enteredHobby != null) 'hobby': _enteredHobby,
    });

    setState(() {
      _isLoading = false;
    });
    Navigator.of(context).pop(context);
  }

  Future<void> _getUserData() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    DocumentSnapshot userData =
        await Firestore.instance.collection('users').document(user.uid).get();
    setState(() {
      _backgroundUrl = userData.data['background'];
      _imageUrl = userData.data['image_url'];
      _username = userData.data['username'];
    });
  }

  @override
  Widget build(BuildContext context) {
    final double heightOfScreen = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Stack(
                children: <Widget>[
                  Container(
                    color: Theme.of(context).accentColor,
                    height: heightOfScreen * 0.4,
                    child: _pickedBackground == null
                        ? CachedNetworkImage(
                            fit: _backgroundUrl == _defaultBackground
                                ? BoxFit.contain
                                : BoxFit.cover,
                            height: 40,
                            width: 40,
                            imageUrl:
                                _backgroundUrl == null ? '' : _backgroundUrl,
                            placeholder: (context, url) =>
                                Center(child: CircularProgressIndicator()),
                            errorWidget: (context, url, error) =>
                                Icon(Icons.error),
                          )
                        : Image.file(
                            _pickedBackground,
                            fit: BoxFit.cover,
                          ),
                    width: double.infinity,
                  ),
                  Positioned(
                    left: -4.0,
                    right: -4.0,
                    bottom: -4.0,
                    child: Container(
                      height: 30,
                      width: double.infinity,
                      child: Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Text(
                'Change your background image',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                ),
              ),
              SizedBox(
                height: 15,
              ),
              RaisedButton.icon(
                icon: Icon(Icons.image),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(20),
                  ),
                ),
                color: Theme.of(context).backgroundColor,
                onPressed: () async {
                  File pickedImage = await ImagePicker.pickImage(
                      imageQuality: 50, source: ImageSource.gallery);
                  setState(() {
                    _pickedBackground = pickedImage;
                  });
                },
                label: Text('Image form gallery'),
              ),
              SizedBox(
                height: 10,
              ),
              Text('OR'),
              SizedBox(
                height: 10,
              ),
              RaisedButton.icon(
                icon: Icon(Icons.photo_camera),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(20),
                  ),
                ),
                color: Theme.of(context).backgroundColor,
                onPressed: () async {
                  File pickedImage = await ImagePicker.pickImage(
                      imageQuality: 50, source: ImageSource.camera);
                  setState(() {
                    _pickedBackground = pickedImage;
                  });
                },
                label: Text('Take a photo'),
              ),
              SizedBox(height: 10),
              Divider(
                color: Colors.grey[400],
              ),
              SizedBox(height: 10),
              Text(
                'Change your profile image',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                ),
              ),
              SizedBox(
                height: 15,
              ),
              Container(
                margin: EdgeInsets.only(
                  left: 15,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    ClipOval(
                      child: Container(
                          height: 90,
                          width: 90,
                          color: Theme.of(context).backgroundColor,
                          child: _pickedAvatar == null
                              ? CachedNetworkImage(
                                  fit: BoxFit.cover,
                                  imageUrl: _imageUrl == null ? '' : _imageUrl,
                                  placeholder: (context, url) => Center(
                                      child: CircularProgressIndicator()),
                                  errorWidget: (context, url, error) =>
                                      Icon(Icons.error),
                                )
                              : Image.file(_pickedAvatar, fit: BoxFit.cover)),
                    ),
                    Container(
                      margin: EdgeInsets.only(
                        left: 15,
                      ),
                      child: Column(
                        children: [
                          RaisedButton.icon(
                            icon: Icon(Icons.image),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(20),
                              ),
                            ),
                            color: Theme.of(context).backgroundColor,
                            onPressed: () async {
                              File pickedImage = await ImagePicker.pickImage(
                                  imageQuality: 50,
                                  source: ImageSource.gallery);
                              setState(() {
                                _pickedAvatar = pickedImage;
                              });
                            },
                            label: Text('Image form gallery'),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text('OR'),
                          SizedBox(
                            height: 10,
                          ),
                          RaisedButton.icon(
                            icon: Icon(Icons.photo_camera),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(20),
                              ),
                            ),
                            color: Theme.of(context).backgroundColor,
                            onPressed: () async {
                              File pickedImage = await ImagePicker.pickImage(
                                  imageQuality: 50, source: ImageSource.camera);
                              setState(() {
                                _pickedAvatar = pickedImage;
                              });
                            },
                            label: Text('Take a photo'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              Divider(
                color: Colors.grey[400],
              ),
              SizedBox(height: 10),
              Text(
                'Change your username',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                ),
              ),
              SizedBox(
                height: 15,
              ),
              Container(
                margin: EdgeInsets.only(
                  left: 30,
                  right: 30,
                ),
                child: TextField(
                  maxLength: 25,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    labelText: _username,
                    labelStyle: TextStyle(color: Theme.of(context).accentColor),
                  ),
                  onChanged: (value) {
                    _enteredNick = value;
                  },
                ),
              ),
              SizedBox(height: 10),
              Divider(
                color: Colors.grey[400],
              ),
              SizedBox(height: 10),
              Text(
                'Provide your hobby or proffesion',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                ),
              ),
              SizedBox(
                height: 15,
              ),
              Container(
                margin: EdgeInsets.only(
                  left: 30,
                  right: 30,
                ),
                child: TextField(
                  maxLength: 30,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    labelText: 'Hobby/Proffesion',
                    labelStyle: TextStyle(color: Theme.of(context).accentColor),
                  ),
                  onChanged: (value) {
                    _enteredHobby = value;
                  },
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Say something about you:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                ),
              ),
              SizedBox(
                height: 15,
              ),
              Container(
                margin: EdgeInsets.only(
                  left: 30,
                  right: 30,
                ),
                child: TextField(
                  keyboardType: TextInputType.multiline,
                  textCapitalization: TextCapitalization.sentences,
                  autocorrect: true,
                  enableSuggestions: true,
                  maxLength: 300,
                  decoration: InputDecoration(
                    labelText: 'About you',
                    labelStyle: TextStyle(color: Theme.of(context).accentColor),
                  ),
                  onChanged: (value) {
                    _enteredAbout = value;
                  },
                ),
              ),
              SizedBox(
                height: 30,
              ),
              _isLoading
                  ? CircularProgressIndicator()
                  : RaisedButton(
                      onPressed: () {
                        _sendData();
                      },
                      child: Text('Save changes'),
                    ),
              SizedBox(
                height: 30,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
