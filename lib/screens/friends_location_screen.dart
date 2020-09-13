import 'dart:async';
import 'dart:typed_data';

import 'package:Whereabouts/helpers/app_localizations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import './chat_screen.dart';
import './profile_screen.dart';

class FriendsLocationScreen extends StatefulWidget {
  static const routeName = '/friends-location-screen';

  @override
  _FriendsLocationScreenState createState() => _FriendsLocationScreenState();
}

class _FriendsLocationScreenState extends State<FriendsLocationScreen> {
  StreamSubscription<QuerySnapshot> _dataStream;
  Position _currentPosition;
  Firestore firestore = Firestore.instance;
  FirebaseUser _user;
  CameraPosition _currentCameraPosition;
  Uint8List _imageData;
  Set<Marker> _markers = {};
  Set<Circle> _circles = {};
  bool _changeMap = true;

  @override
  void initState() {
    super.initState();
    _getCurrentPosition();
    _getCircles();
    _subscribeData();
  }

  Future<void> _getCurrentPosition() async {
    Position position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _currentPosition = position;
    });

    _currentCameraPosition = CameraPosition(
      target: LatLng(position.latitude, position.longitude),
      tilt: 0,
      zoom: 16,
    );
  }

  Future<void> _getCircles() async {
    _user = await FirebaseAuth.instance.currentUser();
    QuerySnapshot circleDocs = await Firestore.instance
        .collection('circles')
        .where("userId", isEqualTo: _user.uid)
        .getDocuments();
    circleDocs.documents.forEach((element) {
      LatLng centerOfCircle = LatLng(
        element.data['latitude'],
        element.data['longitude'],
      );
      setState(() {
        _circles.add(
          Circle(
              circleId: CircleId(element.data['name']),
              radius: element.data['radius'],
              zIndex: 1,
              strokeColor: Colors.green,
              center: centerOfCircle,
              consumeTapEvents: true,
              fillColor: Colors.green.withAlpha(70),
              onTap: () {
                showModalBottomSheet<void>(
                    backgroundColor: Colors.transparent,
                    barrierColor: Colors.black.withOpacity(0.01),
                    context: context,
                    builder: (BuildContext context) {
                      return Container(
                        height: 100,
                        child: Card(
                          margin: EdgeInsets.zero,
                          color: Theme.of(context).accentColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                            ),
                          ),
                          child: Container(
                            margin: EdgeInsets.only(
                              top: 10,
                            ),
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  child: Container(
                                    margin: EdgeInsets.only(
                                      left: 15,
                                      right: 25,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          AppLocalizations.of(context)
                                              .translate(
                                                  'friends_location_screen',
                                                  'placeAdded'),
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Container(
                                          margin: EdgeInsets.only(
                                            top: 10,
                                          ),
                                          child: Text(
                                            element.data['name'],
                                            style: TextStyle(
                                              color: Theme.of(context)
                                                  .backgroundColor,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.only(
                                    right: 25,
                                  ),
                                  child: IconButton(
                                      iconSize: 35,
                                      icon: Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      onPressed: () {
                                        _deleteCircle(
                                          element.data['circleId'],
                                          element.data['name'],
                                        );
                                        Navigator.of(context).pop();
                                      }),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    });
              }),
        );
      });
    });
  }

  Future<void> _deleteCircle(String circleId, String name) async {
    await Firestore.instance.collection('circles').document(circleId).delete();
    await Firestore.instance
        .collection('circles')
        .document(circleId)
        .collection('trackedUsers')
        .getDocuments()
        .then((snapshot) {
      for (DocumentSnapshot ds in snapshot.documents) {
        ds.reference.delete();
      }
    });

    setState(() {
      _circles.add(
        Circle(
          circleId: CircleId(name),
          radius: 0,
        ),
      );
    });
  }

  Future<void> _subscribeData() async {
    _user = await FirebaseAuth.instance.currentUser();

    //stream all locations
    _dataStream = firestore
        .collection('locations')
        .snapshots()
        .listen((QuerySnapshot querySnapshot) async {
      querySnapshot.documentChanges.forEach((element) async {
        //check if document of friendship exists
        DocumentSnapshot isFriend = await Firestore.instance
            .collection('users')
            .document(_user.uid)
            .collection('friends')
            .document(element.document.data['userId'])
            .get();

        //if document exists pin marker on the map
        //only friends are visible on map
        if (isFriend.data != null ||
            element.document.data['userId'] == _user.uid) {
          double distance;
          DocumentSnapshot userData = await Firestore.instance
              .collection('users')
              .document(element.document.data['userId'])
              .get();

          var userMarkerId = element.document.data['userId'];
          var longitudeChange = element.document.data['longitude'];
          var latitudeChange = element.document.data['latitude'];
          print(
              'change has been made by: $userMarkerId longitude: $longitudeChange latitude: $latitudeChange');

          //if marker is your set it to red otherwise set it to orange fetch your location to calculate distance between markers
          if (_user.uid == element.document.data['userId']) {
            ByteData byteData = await DefaultAssetBundle.of(context)
                .load("assets/arrow_you.png");
            _imageData = byteData.buffer.asUint8List();
          } else {
            ByteData byteData =
                await DefaultAssetBundle.of(context).load("assets/arrow.png");
            _imageData = byteData.buffer.asUint8List();
            DocumentSnapshot myCurrentData = await Firestore.instance
                .collection('locations')
                .document(_user.uid)
                .get();
            distance = await Geolocator().distanceBetween(
                element.document.data['latitude'],
                element.document.data['longitude'],
                myCurrentData['latitude'],
                myCurrentData['longitude']);
          }
          LatLng latLng = LatLng(
            element.document.data['latitude'],
            element.document.data['longitude'],
          );

          setState(() {
            _markers.add(
              Marker(
                markerId: MarkerId(element.document.data['userId']),
                position: latLng,
                rotation: element.document.data['heading'],
                draggable: false,
                zIndex: 2,
                flat: true,
                anchor: Offset(0.5, 0.5),
                icon: BitmapDescriptor.fromBytes(_imageData),
                onTap: () {
                  showModalBottomSheet<void>(
                      backgroundColor: Colors.transparent,
                      barrierColor: Colors.black.withOpacity(0.01),
                      context: context,
                      builder: (BuildContext context) {
                        return Container(
                          height: 120,
                          child: Card(
                            margin: EdgeInsets.zero,
                            color: Theme.of(context).accentColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(20),
                                topRight: Radius.circular(20),
                              ),
                            ),
                            child: Row(
                              children: <Widget>[
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      margin: EdgeInsets.only(
                                        left: 15,
                                        right: 25,
                                      ),
                                      child: ClipOval(
                                        child: Container(
                                          color:
                                              Theme.of(context).backgroundColor,
                                          child: CachedNetworkImage(
                                            fit: BoxFit.cover,
                                            height: 50,
                                            width: 50,
                                            imageUrl: userData['image_url'],
                                            placeholder: (context, url) =>
                                                CircularProgressIndicator(),
                                            errorWidget:
                                                (context, url, error) =>
                                                    Icon(Icons.error),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      margin: EdgeInsets.only(
                                        bottom: 10,
                                      ),
                                      child: Text(
                                        element.document.data['userId'] ==
                                                _user.uid
                                            ? AppLocalizations.of(context)
                                                .translate(
                                                    'friends_location_screen',
                                                    'you')
                                            : element.document.data['userName'],
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color:
                                              Theme.of(context).backgroundColor,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        element.document.data['userId'] ==
                                                _user.uid
                                            ? Container()
                                            : Container(
                                                height: 30,
                                                width: 80,
                                                margin: EdgeInsets.only(
                                                  left: 5,
                                                ),
                                                child: RaisedButton(
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.all(
                                                      Radius.circular(20),
                                                    ),
                                                  ),
                                                  color: Theme.of(context)
                                                      .backgroundColor,
                                                  onPressed: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            ProfileScreen(
                                                          element.document
                                                              .data['userId'],
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                  child: Text(
                                                    AppLocalizations.of(context)
                                                        .translate(
                                                            'friends_location_screen',
                                                            'profile'),
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                        element.document.data['userId'] ==
                                                _user.uid
                                            ? Container()
                                            : IconButton(
                                                icon: Icon(
                                                  Icons.message,
                                                  color: Theme.of(context)
                                                      .backgroundColor,
                                                ),
                                                onPressed: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          ChatScreen(
                                                        element.document
                                                            .data['userId'],
                                                        _user,
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                      ],
                                    ),
                                  ],
                                ),
                                element.document.data['userId'] == _user.uid
                                    ? Container()
                                    : Container(
                                        margin: EdgeInsets.only(
                                          left: 30,
                                          top: 25,
                                          bottom: 15,
                                          right: 10,
                                        ),
                                        child: Column(
                                          children: [
                                            Text(
                                              AppLocalizations.of(context)
                                                  .translate(
                                                      'friends_location_screen',
                                                      'distance'),
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: Theme.of(context)
                                                    .backgroundColor,
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Container(
                                              margin: EdgeInsets.only(
                                                top: 10,
                                              ),
                                              child: Text(
                                                distance.toStringAsFixed(0) +
                                                    ' m',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                              ],
                            ),
                          ),
                        );
                      });
                },
              ),
            );
            _circles.add(
              Circle(
                circleId: CircleId(element.document.data['userId']),
                radius: element.document.data['accuracy'],
                zIndex: 1,
                strokeColor: Colors.blue,
                center: latLng,
                fillColor: Colors.blue.withAlpha(70),
              ),
            );
          });
        }
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    if (_dataStream != null) {
      _dataStream.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(
            color: Theme.of(context).backgroundColor,
          ),
          brightness: Brightness.dark,
          backgroundColor: Theme.of(context).accentColor,
          title: Text(
            AppLocalizations.of(context)
                .translate('friends_location_screen', 'locationFriends'),
            style: TextStyle(
              color: Theme.of(context).backgroundColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: _currentPosition == null || _currentCameraPosition == null
            ? Container(
                color: Theme.of(context).accentColor,
                height: double.infinity,
                width: double.infinity,
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).backgroundColor),
                  ),
                ),
              )
            : Stack(
                children: [
                  GoogleMap(
                    mapType: _changeMap ? MapType.normal : MapType.hybrid,
                    initialCameraPosition: _currentCameraPosition,
                    markers: _markers == null ? [] : _markers,
                    circles: _circles == null ? [] : _circles,
                  ),
                  Positioned(
                    top: 15,
                    right: 15,
                    child: Container(
                      color: Theme.of(context).accentColor,
                      padding: EdgeInsets.only(bottom: 5, right: 5),
                      child: IconButton(
                          icon: Icon(Icons.map,
                              size: 40,
                              color: Theme.of(context).backgroundColor),
                          onPressed: () {
                            setState(() {
                              _changeMap = !_changeMap;
                            });
                          }),
                    ),
                  )
                ],
              ));
  }
}
