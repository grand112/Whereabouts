import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../lists/friends_list.dart';
import '../lists/requests.dart';
import '../screens/users_screen.dart';

class ManageFriendListScreen extends StatefulWidget {
  static const routeName = '/manage-friend-list-screen';

  @override
  _ManageFriendListScreenState createState() => _ManageFriendListScreenState();
}

class _ManageFriendListScreenState extends State<ManageFriendListScreen> {
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
         iconTheme: IconThemeData(
          color: Theme.of(context).backgroundColor,
        ),
        brightness: Brightness.dark,
        backgroundColor: Theme.of(context).accentColor,
        title: Text(
          'Manage your friend list',
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
        child: Column(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(
                top: 25,
              ),
              child: Row(
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
                : FriendsList(_user,true),
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
      ),
    );
  }
}
