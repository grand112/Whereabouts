import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:workmanager/workmanager.dart';
import 'package:geolocator/geolocator.dart';

import '../screens/select_chat_screen.dart';
import '../screens/home_screen.dart';
import '../screens/friends_screen.dart';
import '../screens/places_list_screen.dart';

const fetchBackground = "fetchBackground";

// backgorund fetching location if app is in background or terminated
void callbackDispatcher() {
  Workmanager.executeTask((task, inputData) async {
    switch (task) {
      case fetchBackground:
        print('location has been fetched in background');
        Position position = await Geolocator()
            .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
        FirebaseUser user = await FirebaseAuth.instance.currentUser();
        DocumentSnapshot userData = await Firestore.instance
            .collection('users')
            .document(user.uid)
            .get();
        await Firestore.instance
            .collection('locations')
            .document(user.uid)
            .setData({
          'userId': user.uid,
          'createdAt': Timestamp.now(),
          'latitude': position.latitude,
          'longitude': position.longitude,
          'accuracy': position.accuracy,
          'heading': position.heading,
          'userName': userData['username'],
          'madeBy': 'backgroundFetch',
        });
        break;
    }
    return Future.value(true);
  });
}

class ControlScreen extends StatefulWidget {
  static const routeName = '/contorl-screen';
  @override
  _ControlScreenState createState() => _ControlScreenState();
}

class _ControlScreenState extends State<ControlScreen>
    with WidgetsBindingObserver {
  Timer timer;
  int _selectedPageIndex = 0;
  StreamSubscription<Position> _positionStream;
  FirebaseMessaging _fcm = FirebaseMessaging();

  //options to get location
  var _locationOptions = LocationOptions(
    accuracy: LocationAccuracy.high,
    distanceFilter: 5,
  );

  @override
  void initState() {
    super.initState();
    _checkInternetConnection();
    WidgetsBinding.instance.addObserver(this);

    // register background function
    Workmanager.initialize(
      callbackDispatcher,
      isInDebugMode: true,
    );
    Workmanager.registerPeriodicTask(
      "1",
      fetchBackground,
      frequency: Duration(minutes: 15),
      constraints: Constraints(
        networkType: NetworkType.not_required,
        requiresBatteryNotLow: false,
        requiresCharging: false,
        requiresDeviceIdle: false,
        requiresStorageNotLow: false,
      ),
    );

    //subscribe to push notifications
    _fcm.configure(onMessage: (msg) {
      print(msg);
      final snackbar = SnackBar(
        content: Text(
          msg.toString(),
        ),
        action: SnackBarAction(label: 'Go', onPressed: () {}),
      );
      Scaffold.of(context).showSnackBar(snackbar);
      return;
    }, onLaunch: (msg) {
      print(msg);
      return;
    }, onResume: (msg) {
      //Navigator.of(context).pushNamed(WelcomeScreen.routeName);
      print('resume from message');
      print(msg);
      return;
    });
    _fcm.subscribeToTopic('chat');

    _saveDeviceToken();
    _subscribePosition();
  }

  final List<Widget> _pages = [
    HomeScreen(),
    SelectChatScreen(),
    FriendsScreen(),
    PlacesListScreen(),
  ];

  Future<void> _checkInternetConnection() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      showDialog(
        context: context,
        child: AlertDialog(
          backgroundColor: Theme.of(context).accentColor,
          title: Text(
            "You are not connected to the Internet!",
            style: TextStyle(color: Theme.of(context).backgroundColor),
            textAlign: TextAlign.center,
          ),
          content: Container(
            height: 240,
            child: Column(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(bottom: 30),
                  height: 50,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/logo.png'),
                    ),
                  ),
                ),
                Text(
                  "Without internet connection, we cannot provide you full usability.\nPlease connect your device to the internet to get access to all features of the app",
                  style: TextStyle(color: Colors.white),
                ),
                Container(
                  margin: EdgeInsets.only(top: 15),
                  child: RaisedButton(
                    color: Theme.of(context).backgroundColor,
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      'OK',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  Future<void> _saveDeviceToken() async {
    String fcmToken = await _fcm.getToken();
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    if (fcmToken != null) {
      return Firestore.instance
          .collection('users')
          .document(user.uid)
          .collection('tokens')
          .document(fcmToken)
          .setData({
        'token': fcmToken,
        'createdAt': Timestamp.now(),
      });
    }
  }

  double _round(double val, int places) {
    double mod = pow(10.0, places);
    return ((val * mod).round().toDouble() / mod);
  }

  Future<void> _ifUserInCircle(Position position) async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    DocumentSnapshot userData =
        await Firestore.instance.collection('users').document(user.uid).get();

    /// fetching circles from firebase
    QuerySnapshot circleDocs =
        await Firestore.instance.collection('circles').getDocuments();
    circleDocs.documents.forEach((circleData) async {
      double distanceMarkerCircle = await Geolocator().distanceBetween(
        position.latitude,
        position.longitude,
        circleData['latitude'],
        circleData['longitude'],
      );

      //chceck if user is in the circle
      if (distanceMarkerCircle < circleData['radius'] &&
          user.uid != circleData['userId']) {
        // check if userId matches trackedUsers id
        await Firestore.instance
            .collection('circles')
            .document(circleData['circleId'])
            .collection('trackedUsers')
            .getDocuments()
            .then((trackedUsersDocs) {
          trackedUsersDocs.documents.forEach((trackedUser) async {
            if (trackedUser['userId'] == user.uid) {
              //delte document about leaving circle if exists
              await Firestore.instance
                  .collection('out_of_circle')
                  .document(
                      '${user.uid}:${circleData['userId']}:${circleData['circleId']}')
                  .get()
                  .then((leftDoc) {
                if (leftDoc.exists) {
                  Firestore.instance
                      .collection('out_of_circle')
                      .document(
                          '${user.uid}:${circleData['userId']}:${circleData['circleId']}')
                      .delete();
                }
              });

              //add info to firebase about being in
              await Firestore.instance
                  .collection('in_circle')
                  .document(
                      '${user.uid}:${circleData['userId']}:${circleData['circleId']}')
                  .setData({
                'enteredBy': user.uid,
                'enteredAt': Timestamp.now(),
                'circleCreatedBy': circleData['userId'],
                'nameOfCircle': circleData['name'],
                'circleId': circleData['circleId'],
                'enteredByUser': userData['username'],
              });
              print('I am in the circle!');
            }
          });
        });
      }

      //get last circle of user
      //chceck if user just left the circle
      if (distanceMarkerCircle > circleData['radius'] &&
          user.uid != circleData['userId']) {
        await Firestore.instance
            .collection('in_circle')
            .document(
                '${user.uid}:${circleData['userId']}:${circleData['circleId']}')
            .get()
            .then((doc) async {
          if (doc.exists) {
            await Firestore.instance
                .collection('circles')
                .document(circleData['circleId'])
                .collection('trackedUsers')
                .getDocuments()
                .then((trackedUsersDocs) {
              trackedUsersDocs.documents.forEach((trackedUser) async {
                if (trackedUser['userId'] == user.uid) {
                  print('I just left the circle!');
                  //add information to firebase that user left the circle
                  await Firestore.instance
                      .collection('out_of_circle')
                      .document(
                          '${user.uid}:${circleData['userId']}:${circleData['circleId']}')
                      .setData({
                    'leftBy': user.uid,
                    'leftAt': Timestamp.now(),
                    'circleCreatedBy': circleData['userId'],
                    'nameOfCircle': circleData['name'],
                    'circleId': circleData['circleId'],
                    'leftByUser': userData['username'],
                  });

                  //delete last information about being in the circle
                  await Firestore.instance
                      .collection('in_circle')
                      .document(
                          '${user.uid}:${circleData['userId']}:${circleData['circleId']}')
                      .delete();
                }
              });
            });
          }
        });
      }
    });
  }

  //subscribe position of user and send it to firebase
  //check if user is in the circle
  void _subscribePosition() async {
    double lastLatitude = 1;
    double lastLongitude = 1;
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    DocumentSnapshot userData =
        await Firestore.instance.collection('users').document(user.uid).get();
    _positionStream = Geolocator()
        .getPositionStream(_locationOptions)
        .listen((Position position) async {
      Position position = await Geolocator()
          .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      if (lastLatitude != _round(position.latitude, 4) ||
          lastLongitude != _round(position.longitude, 4)) {
        lastLatitude = _round(position.latitude, 4);
        lastLongitude = _round(position.longitude, 4); // change precision

        await Firestore.instance
            .collection('locations')
            .document(user.uid)
            .setData({
          'userId': user.uid,
          'createdAt': Timestamp.now(),
          'latitude': position.latitude,
          'longitude': position.longitude,
          'accuracy': position.accuracy,
          'heading': position.heading,
          'userName': userData['username'],
        });

        _ifUserInCircle(position);
      }
    });
  }

  void _selectPage(int index) {
    setState(() {
      _selectedPageIndex = index;
    });
  }

  //check if app is on background
  //set periodic timer,send location and chceck if user is in the circle when app is in background mode
  //if app is resumed cancel timer
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.resumed:
        print('resumed');
        timer.cancel();
        break;
      case AppLifecycleState.inactive:
        print('inactive');
        break;
      case AppLifecycleState.paused:
        print('paused');
        //change time
        timer = Timer.periodic(Duration(seconds: 180), (_) async {
          Position position = await Geolocator()
              .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
          FirebaseUser user = await FirebaseAuth.instance.currentUser();
          DocumentSnapshot userData = await Firestore.instance
              .collection('users')
              .document(user.uid)
              .get();
          Firestore.instance
              .collection('locations')
              .document(user.uid)
              .setData({
            'userId': user.uid,
            'createdAt': Timestamp.now(),
            'latitude': position.latitude,
            'longitude': position.longitude,
            'accuracy': position.accuracy,
            'heading': position.heading,
            'madeBy': 'backgroundTimer',
            'userName': userData['username'],
          });
          _ifUserInCircle(position);
        });
        break;
      case AppLifecycleState.detached:
        print('detached');
        break;
    }
  }

  @override
  void dispose() {
    super.dispose();
    if (_positionStream != null) {
      _positionStream.cancel();
    }
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => Future.value(false),
      child: Scaffold(
        body: _pages[_selectedPageIndex],
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          //showSelectedLabels: false,
          //showUnselectedLabels: false,
          onTap: _selectPage,
          backgroundColor: Theme.of(context).accentColor,
          unselectedItemColor: Colors.white,
          selectedItemColor: Theme.of(context).backgroundColor,
          items: [
            BottomNavigationBarItem(
              icon: Icon(
                Icons.home,
                size: 30,
              ),
              title: Text('Home'),
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.chat,
                size: 30,
              ),
              title: Text('Messages'),
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.people,
                size: 30,
              ),
              title: Text('Friends'),
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.location_on,
                size: 30,
              ),
              title: Text('Places'),
            ),
          ],
          currentIndex: _selectedPageIndex,
        ),
      ),
    );
  }
}
