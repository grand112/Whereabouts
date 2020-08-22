import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../screens/friends_location_screen.dart';
import '../screens/add_track_place_screen.dart';
import '../screens/users_screen.dart';
import '../lists/friends_list.dart';
import '../lists/requests.dart';

class FriendsScreen extends StatefulWidget {
  @override
  _FriendsScreenState createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  FirebaseUser _user;

  @override
  void initState() {
    super.initState();
    _getUserData();
  }

  Future<void> _getUserData() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    setState(() {
      _user = user;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        brightness: Brightness.dark,
        backgroundColor: Theme.of(context).accentColor,
        title: Text(
          'Stay in touch with your friends',
          style: TextStyle(
              color: Theme.of(context).backgroundColor,
              fontWeight: FontWeight.bold),
        ),
      ),
      body: Container(
        width: double.infinity,
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
        child: ListView(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  child: Text(
                    'Monitor your family members or friends location and get notifications',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                  margin: EdgeInsets.only(
                    left: 15,
                    right: 15,
                    top: 25,
                    bottom: 10,
                  ),
                ),
                RaisedButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(20),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context)
                        .pushNamed(AddTrackPlaceScreen.routeName);
                  },
                  child: Text('Pick a place and friends to track'),
                ),
                Container(
                  margin: EdgeInsets.only(
                    top: 25,
                    left: 15,
                    right: 15,
                  ),
                  child: Divider(
                    color: Theme.of(context).accentColor,
                    height: 5,
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(
                    top: 25,
                    bottom: 25,
                  ),
                  child: RaisedButton.icon(
                    icon: Icon(Icons.map),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(20),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context)
                          .pushNamed(FriendsLocationScreen.routeName);
                    },
                    label: Text('Find your friends on the map'),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(
                    left: 15,
                    right: 15,
                    bottom: 25,
                  ),
                  child: Divider(
                    color: Theme.of(context).accentColor,
                    height: 7,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      child: Text(
                        'Looking for new people?',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      margin: EdgeInsets.only(
                        right: 10,
                      ),
                    ),
                    RaisedButton.icon(
                      icon: Icon(
                        Icons.add,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(20),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pushNamed(UsersScreen.routeName);
                      },
                      label: Text('Add a friend'),
                    ),
                  ],
                ),
                Container(
                  margin: EdgeInsets.only(
                    top: 25,
                    left: 15,
                    right: 15,
                  ),
                  child: Divider(
                    color: Theme.of(context).accentColor,
                    height: 7,
                  ),
                ),
                Container(
                  child: Text(
                    'List of your friends',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                  margin: EdgeInsets.only(
                    top: 25,
                  ),
                ),
                _user == null
                    ? CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(context).backgroundColor),
                      )
                    : FriendsList(_user),
                Container(
                  child: Text(
                    'Friend invites',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                  margin: EdgeInsets.only(
                    top: 10,
                  ),
                ),
                _user == null
                    ? CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(context).backgroundColor),
                      )
                    : Requests(_user),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
