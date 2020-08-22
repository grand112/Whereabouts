import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';

import '../helpers/location_helper.dart';
import '../screens/pick_on_map_screen.dart';

class AddPlaceScreen extends StatefulWidget {
  static const routeName = '/add-place-screen';

  @override
  _AddPlaceScreenState createState() => _AddPlaceScreenState();
}

class _AddPlaceScreenState extends State<AddPlaceScreen> {
  File _pickedImageFile;
  String _previewImageUrl;
  String _readableAddress;
  String _enteredMessage;
  String _enteredTitle;
  LatLng _selectedLocation;
  bool _isLoading = false;

  Future<void> _sendData() async {
    setState(() {
      _isLoading = true;
    });
    FirebaseUser _user = await FirebaseAuth.instance.currentUser();
    final refPhoto = FirebaseStorage.instance.ref().child('place_images').child(
        _user.uid +
            ',' +
            _selectedLocation.latitude.toString() +
            ',' +
            _selectedLocation.longitude.toString() +
            'place_photo.jpg');
    await refPhoto.putFile(_pickedImageFile).onComplete;
    final urlPhoto = await refPhoto.getDownloadURL();

    await Firestore.instance
        .collection('users')
        .document(_user.uid)
        .collection('places')
        .document()
        .setData({
      'userId': _user.uid,
      'createdAt': Timestamp.now(),
      'name': _enteredTitle,
      'latitude': _selectedLocation.latitude,
      'longitude': _selectedLocation.longitude,
      'info': _enteredMessage,
      'address': _readableAddress,
      'mapUrl': _previewImageUrl,
      'imageUrl': urlPhoto,
    });

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _getCurrentLocation() async {
    Position position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    _getLocationMapImage(position.latitude, position.longitude);
    final String address = await LocationHelper.getPlaceAddress(
      position.latitude,
      position.longitude,
    );
    _selectedLocation = LatLng(position.latitude, position.longitude);
    setState(() {
      _readableAddress = address;
    });
  }

  Future<void> _getLocationMapImage(double latitude, double longitude) async {
    final staticMapImageUrl = LocationHelper.generateLocationPreviewImage(
      latitude: latitude,
      longitude: longitude,
    );
    setState(() {
      _previewImageUrl = staticMapImageUrl;
    });
  }

  Future<void> _selectOnMap() async {
    final LatLng selectedLocation = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => PickOnMapScreen(),
      ),
    );
    if (selectedLocation == null) {
      return;
    }
    _selectedLocation = selectedLocation;
    _getLocationMapImage(selectedLocation.latitude, selectedLocation.longitude);
    final String address = await LocationHelper.getPlaceAddress(
      selectedLocation.latitude,
      selectedLocation.longitude,
    );
    setState(() {
      _readableAddress = address;
    });
  }

  Future<void> _validate(BuildContext context) async {
    if (_pickedImageFile == null) {
      Scaffold.of(context).showSnackBar(
        SnackBar(
          content: Text('Please provide a photo of the place.'),
          backgroundColor: Theme.of(context).errorColor,
        ),
      );
      return;
    } else if (_selectedLocation == null) {
      Scaffold.of(context).showSnackBar(
        SnackBar(
          content: Text('Please pick the location of the place.'),
          backgroundColor: Theme.of(context).errorColor,
        ),
      );
      return;
    } else if (_enteredTitle == null) {
      Scaffold.of(context).showSnackBar(
        SnackBar(
          content: Text('Please pick the name of the place.'),
          backgroundColor: Theme.of(context).errorColor,
        ),
      );
      return;
    } else {
      await _sendData();
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Builder(
        builder: (ctx) => Container(
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                Colors.amber[500],
                Colors.amber[800],
              ],
            ),
          ),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(
                        top: 10,
                        bottom: 30,
                      ),
                      child: Text(
                        'ADD PLACE',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(
                        bottom: 15,
                      ),
                      child: Text(
                        'Provide photo of the place:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                      ),
                    ),
                    _pickedImageFile == null
                        ? Container()
                        : Container(
                            height: 200,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: FileImage(_pickedImageFile),
                              ),
                            ),
                          ),
                    RaisedButton.icon(
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
                          _pickedImageFile = pickedImage;
                        });
                      },
                      icon: Icon(Icons.camera_alt),
                      label: Text(
                        'Take a photo',
                      ),
                    ),
                    SizedBox(height: 10),
                    Center(
                      child: Text(
                        "OR",
                        style: TextStyle(color: Colors.grey[400]),
                      ),
                    ),
                    SizedBox(height: 10),
                    RaisedButton.icon(
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
                          _pickedImageFile = pickedImage;
                        });
                      },
                      icon: Icon(Icons.image),
                      label: Text(
                        'Pick a photo from gallery',
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Divider(
                      color: Colors.grey[400],
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Text(
                      'Provide location of the place:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(
                        top: 10,
                        bottom: 10,
                      ),
                      alignment: Alignment.center,
                      child: _previewImageUrl == null
                          ? Container()
                          : Column(
                              children: <Widget>[
                                Container(
                                  height: 200,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: NetworkImage(
                                        _previewImageUrl,
                                      ),
                                    ),
                                  ),
                                ),
                                Text(_readableAddress == null
                                    ? ''
                                    : _readableAddress),
                              ],
                            ),
                    ),
                    RaisedButton.icon(
                      onPressed: _getCurrentLocation,
                      icon: Icon(
                        Icons.location_on,
                      ),
                      label: Text(
                        ' Use current location',
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(20),
                        ),
                      ),
                      color: Theme.of(context).backgroundColor,
                    ),
                    SizedBox(height: 10),
                    Center(
                      child: Text(
                        "OR",
                        style: TextStyle(color: Colors.grey[400]),
                      ),
                    ),
                    SizedBox(height: 10),
                    RaisedButton.icon(
                      onPressed: _selectOnMap,
                      icon: Icon(
                        Icons.map,
                      ),
                      label: Text(
                        'Select location on  the Map',
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(20),
                        ),
                      ),
                      color: Theme.of(context).backgroundColor,
                    ),
                    SizedBox(height: 20),
                    Container(
                      margin: EdgeInsets.only(
                        right: 30,
                        left: 30,
                      ),
                      child: TextField(
                        maxLength: 30,
                        textCapitalization: TextCapitalization.words,
                        autocorrect: true,
                        enableSuggestions: true,
                        decoration: InputDecoration(
                          labelText: 'Add the name of the place',
                          labelStyle:
                              TextStyle(color: Theme.of(context).accentColor),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _enteredTitle = value;
                          });
                        },
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(
                        right: 30,
                        left: 30,
                      ),
                      child: TextField(
                        keyboardType: TextInputType.multiline,
                        textCapitalization: TextCapitalization.sentences,
                        autocorrect: true,
                        enableSuggestions: true,
                        maxLength: 150,
                        decoration: InputDecoration(
                          labelText: 'Description of the place',
                          labelStyle:
                              TextStyle(color: Theme.of(context).accentColor),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _enteredMessage = value;
                          });
                        },
                      ),
                    ),
                    SizedBox(height: 30),
                    _isLoading
                        ? CircularProgressIndicator()
                        : RaisedButton(
                            onPressed: () => _validate(ctx),
                            child: Text('ADD'),
                          )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
