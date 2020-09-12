import 'package:Whereabouts/screens/loading_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';

import '../widgets/swipe/swipe_image.dart';

class WelcomeScreen extends StatefulWidget {
  static const routeName = '/welcome-screen';

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  void initState() {
    _checkInternetConnection();
    super.initState();
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: StreamBuilder(
      stream: Firestore.instance.collection('welcome_data').snapshots(),
      builder: (ctx, snapshot) {
        if (snapshot.hasData == false) {
          return LoadingScreen();
        }
        final docs = snapshot.data.documents;
        if (snapshot.connectionState == ConnectionState.waiting) {
          return LoadingScreen();
        }
        return Swiper(
          itemCount: docs.length,
          itemBuilder: (BuildContext context, int index) {
            return SwipeImage(
              docs[index]['image'],
              index,
            );
          },
          pagination: SwiperPagination(),
          control: SwiperControl(),
        );
      },
    ));
  }
}
