import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../screens/welcome_screen.dart';
import '../../screens/edit_profile_screen.dart';

class HomeDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Theme.of(context).accentColor,
        height: double.infinity,
        child: Column(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(
                top: 35,
              ),
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/logo_title_white.png'),
                ),
              ),
              height: 100,
              width: double.infinity,
            ),
            SizedBox(height: 50),
            Container(
              margin: EdgeInsets.only(
                left: 5,
                right: 5,
              ),
              padding: EdgeInsets.only(
                top: 5,
                bottom: 5,
              ),
              color: Theme.of(context).backgroundColor,
              child: ListTile(
                leading: Icon(
                  Icons.settings,
                  size: 30,
                  color: Theme.of(context).accentColor,
                ),
                title: Text(
                  'Settings',
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
                onTap: () {
                  //...
                },
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              margin: EdgeInsets.only(
                left: 5,
                right: 5,
              ),
              padding: EdgeInsets.only(
                top: 5,
                bottom: 5,
              ),
              color: Theme.of(context).backgroundColor,
              child: ListTile(
                leading: Icon(
                  Icons.person,
                  size: 30,
                  color: Theme.of(context).accentColor,
                ),
                title: Text(
                  'Edit profile',
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
                onTap: () {
                  Navigator.of(context).pushNamed(EditProfileScreen.routeName);
                },
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              margin: EdgeInsets.only(
                left: 5,
                right: 5,
              ),
              padding: EdgeInsets.only(
                top: 5,
                bottom: 5,
              ),
              color: Theme.of(context).backgroundColor,
              child: ListTile(
                leading: Icon(
                  Icons.exit_to_app,
                  size: 30,
                  color: Theme.of(context).accentColor,
                ),
                title: Text(
                  'Log out',
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
                onTap: () {
                  final GoogleSignIn googleSignIn = GoogleSignIn();
                  googleSignIn.signOut();
                  FirebaseAuth.instance.signOut();
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    '/welcome-screen',
                    ModalRoute.withName(WelcomeScreen.routeName),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
