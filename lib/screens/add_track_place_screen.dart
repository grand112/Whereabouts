import 'dart:math';

import 'package:Whereabouts/helpers/app_localizations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../screens/users_screen.dart';
import '../helpers/location_helper.dart';
import '../screens/pick_circle_screen.dart';

class AddTrackPlaceScreen extends StatefulWidget {
  static const routeName = '/add-track-place';
  @override
  _AddTrackPlaceScreenState createState() => _AddTrackPlaceScreenState();
}

class _AddTrackPlaceScreenState extends State<AddTrackPlaceScreen> {
  String _enteredTitle;
  String _previewImageUrl;
  String _readableAddress;
  String _circleId;
  double _radius;
  bool _isLoading = false;
  double _pickedLatitude;
  double _pickedLongitude;
  FirebaseUser _user;
  List<String> _pickedUsers = [];

  @override
  void initState() {
    super.initState();
    _getUserInfo();
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

  Future<void> _getUserInfo() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    setState(() {
      _user = user;
    });
  }

  double _round(double val, int places) {
    double mod = pow(10.0, places);
    return ((val * mod).round().toDouble() / mod);
  }

  Future<void> _sendData() async {
    setState(() {
      _isLoading = true;
    });

    await Firestore.instance.collection('circles').document(_circleId).setData({
      'userId': _user.uid,
      'createdAt': Timestamp.now(),
      'name': _enteredTitle,
      'radius': _round(_radius, 2),
      'latitude': _pickedLatitude,
      'longitude': _pickedLongitude,
      'address': _readableAddress,
      'mapUrl': _previewImageUrl,
      'circleId': _circleId,
    });

    _pickedUsers.forEach((element) async {
      await Firestore.instance
          .collection('circles')
          .document(_circleId)
          .collection('trackedUsers')
          .document(element)
          .setData({
        'userId': element,
      });
    });

    setState(() {
      _isLoading = false;
    });
    return;
  }

  Future<void> _pickOnMap() async {
    final Circle circle = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => PickCircleScreen(),
      ),
    );
    if (circle == null) {
      return;
    }
    _circleId = circle.circleId.value;
    _pickedLatitude = circle.center.latitude;
    _pickedLongitude = circle.center.longitude;
    _getLocationMapImage(circle.center.latitude, circle.center.longitude);
    final String address = await LocationHelper.getPlaceAddress(
      circle.center.latitude,
      circle.center.longitude,
    );
    setState(() {
      _radius = circle.radius;
      _readableAddress = address;
    });
  }

  void _validate(BuildContext context) {
    if (_enteredTitle == null || _enteredTitle.length < 3) {
      Scaffold.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)
                .translate('add_track_place_screen', 'provideName'),
          ),
          backgroundColor: Theme.of(context).errorColor,
        ),
      );
      return;
    } else if (_previewImageUrl == null) {
      Scaffold.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)
                .translate('add_track_place_screen', 'pickPlaceTrack'),
          ),
          backgroundColor: Theme.of(context).errorColor,
        ),
      );
      return;
    } else if (_pickedUsers.length == 0) {
      Scaffold.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)
                .translate('add_track_place_screen', 'pickFriend'),
          ),
          backgroundColor: Theme.of(context).errorColor,
        ),
      );
      return;
    } else {
      _sendData().then((_) {
        Navigator.of(context).pop();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Builder(
        builder: (ctx) => Container(
          width: double.infinity,
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
                        AppLocalizations.of(context)
                            .translate('add_track_place_screen', 'addPlace'),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      AppLocalizations.of(context).translate(
                          'add_track_place_screen', 'provideCustomName'),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(
                        left: 30,
                        right: 30,
                      ),
                      child: TextField(
                        maxLength: 30,
                        textCapitalization: TextCapitalization.words,
                        autocorrect: true,
                        enableSuggestions: true,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context)
                              .translate('add_track_place_screen', 'addName'),
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
                    SizedBox(height: 10),
                    Divider(
                      color: Colors.grey[400],
                    ),
                    SizedBox(height: 10),
                    Text(
                      AppLocalizations.of(context)
                          .translate('add_track_place_screen', 'pickPlaceMap'),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    RaisedButton.icon(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(20),
                        ),
                      ),
                      onPressed: () {
                        _pickOnMap();
                      },
                      icon: Icon(Icons.map),
                      label: Text(
                        AppLocalizations.of(context)
                            .translate('add_track_place_screen', 'pickPlace'),
                      ),
                    ),
                    _previewImageUrl == null
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
                              SizedBox(
                                height: 20,
                              ),
                              Text(
                                _radius == null
                                    ? ''
                                    : AppLocalizations.of(context).translate(
                                            'add_track_place_screen',
                                            'radius') +
                                        _round(_radius, 2).toString() +
                                        ' m',
                              ),
                            ],
                          ),
                    SizedBox(height: 10),
                    Divider(
                      color: Colors.grey[400],
                    ),
                    SizedBox(height: 20),
                    Text(
                      AppLocalizations.of(context).translate(
                          'add_track_place_screen', 'pickFriendTrack'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    _user == null
                        ? Container()
                        : Container(
                            width: double.infinity,
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(20),
                                ),
                              ),
                              margin: EdgeInsets.only(
                                top: 15,
                                bottom: 15,
                                left: 10,
                                right: 10,
                              ),
                              color: Theme.of(context).accentColor,
                              child: Container(
                                padding: EdgeInsets.only(
                                  top: 10,
                                  bottom: 10,
                                ),
                                child: StreamBuilder(
                                  stream: Firestore.instance
                                      .collection('users')
                                      .document(_user.uid)
                                      .collection('friends')
                                      .where("accepted", isEqualTo: "yes")
                                      .snapshots(),
                                  builder: (ctx, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    }
                                    if (snapshot.connectionState ==
                                        ConnectionState.none) {
                                      return Center(
                                        child: Icon(Icons.error),
                                      );
                                    }
                                    final docs = snapshot.data.documents;
                                    return docs.length == 0
                                        ? Container(
                                            margin: EdgeInsets.only(
                                              top: 15,
                                              bottom: 15,
                                            ),
                                            child: Column(
                                              children: [
                                                Text(
                                                  AppLocalizations.of(context)
                                                      .translate(
                                                          'add_track_place_screen',
                                                          'noFriends'),
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 15,
                                                    color: Colors.white,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                                Container(
                                                  margin: EdgeInsets.only(
                                                    top: 10,
                                                  ),
                                                  child: RaisedButton.icon(
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.all(
                                                        Radius.circular(20),
                                                      ),
                                                    ),
                                                    color: Theme.of(context)
                                                        .backgroundColor,
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pushNamed(UsersScreen
                                                              .routeName);
                                                    },
                                                    icon: Icon(Icons.add),
                                                    label: Text(
                                                      AppLocalizations.of(
                                                              context)
                                                          .translate(
                                                              'add_track_place_screen',
                                                              'addFriends'),
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                        : ListView.builder(
                                            scrollDirection: Axis.vertical,
                                            shrinkWrap: true,
                                            itemBuilder: (ctx, index) {
                                              return docs[index]['userId'] ==
                                                      _user.uid
                                                  ? Container()
                                                  : Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment.end,
                                                      children: <Widget>[
                                                        Container(
                                                          margin:
                                                              EdgeInsets.only(
                                                                  left: 10),
                                                          child: ClipOval(
                                                            child: Container(
                                                              color: Theme.of(
                                                                      context)
                                                                  .backgroundColor,
                                                              child:
                                                                  CachedNetworkImage(
                                                                fit: BoxFit
                                                                    .cover,
                                                                height: 50,
                                                                width: 50,
                                                                imageUrl: docs[
                                                                        index][
                                                                    'sentBy_imageUrl'],
                                                                placeholder: (context,
                                                                        url) =>
                                                                    CircularProgressIndicator(),
                                                                errorWidget: (context,
                                                                        url,
                                                                        error) =>
                                                                    Icon(Icons
                                                                        .error),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        Expanded(
                                                          child: Container(
                                                            margin:
                                                                EdgeInsets.only(
                                                              top: 25,
                                                              bottom: 25,
                                                              left: 20,
                                                            ),
                                                            child: Text(
                                                              docs[index][
                                                                  'sentBy_username'],
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: 17,
                                                                  color: Colors
                                                                      .white),
                                                            ),
                                                          ),
                                                        ),
                                                        _pickedUsers.contains(
                                                                docs[index]
                                                                    ['sentBy'])
                                                            ? Container(
                                                                margin:
                                                                    EdgeInsets
                                                                        .only(
                                                                  right: 15,
                                                                ),
                                                                child: Text(
                                                                  AppLocalizations.of(
                                                                          context)
                                                                      .translate(
                                                                          'add_track_place_screen',
                                                                          'userAdded'),
                                                                  style: TextStyle(
                                                                      color: Theme.of(
                                                                              context)
                                                                          .backgroundColor),
                                                                ),
                                                              )
                                                            : Container(
                                                                margin:
                                                                    EdgeInsets
                                                                        .only(
                                                                  right: 15,
                                                                ),
                                                                child:
                                                                    IconButton(
                                                                        color: Theme.of(context)
                                                                            .backgroundColor,
                                                                        icon: Icon(Icons
                                                                            .add),
                                                                        onPressed:
                                                                            () {
                                                                          setState(
                                                                              () {
                                                                            _pickedUsers.add(docs[index]['sentBy']);
                                                                          });
                                                                        }),
                                                              ),
                                                      ],
                                                    );
                                            },
                                            itemCount: docs.length,
                                          );
                                  },
                                ),
                              ),
                            ),
                          ),
                    SizedBox(
                      height: 30,
                    ),
                    _isLoading
                        ? CircularProgressIndicator()
                        : RaisedButton(
                            onPressed: () => _validate(ctx),
                            child: Text(
                              AppLocalizations.of(context)
                                  .translate('add_track_place_screen', 'add'),
                            ),
                          ),
                    SizedBox(
                      height: 30,
                    ),
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
