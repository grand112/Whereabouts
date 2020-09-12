import 'package:Whereabouts/helpers/app_localizations.dart';
import 'package:flutter/material.dart';

import '../screens/friends_location_menu_screen.dart';
import '../screens/manage_friend_list_screen.dart';

class FriendsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final double heightOfScreen = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        brightness: Brightness.dark,
        backgroundColor: Theme.of(context).accentColor,
        title: Text(
          AppLocalizations.of(context).translate('friends_screen', 'stay'),
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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            GestureDetector(
              onTap: () {
                Navigator.of(context)
                    .pushNamed(FriendsLocationMenuScreen.routeName);
              },
              child: Container(
                margin: EdgeInsets.only(
                  top: 25,
                  left: 15,
                  right: 15,
                ),
                width: double.infinity,
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  color: Theme.of(context).accentColor,
                  child: Column(
                    children: [
                      Container(
                        height: heightOfScreen * 0.3,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                              image: AssetImage('assets/map.png'),
                              fit: BoxFit.contain),
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(
                          top: 10,
                          bottom: 10,
                        ),
                        child: Text(
                          AppLocalizations.of(context)
                              .translate('friends_screen', 'track'),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).backgroundColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.of(context)
                    .pushNamed(ManageFriendListScreen.routeName);
              },
              child: Container(
                margin: EdgeInsets.only(
                  top: 25,
                  left: 15,
                  right: 15,
                ),
                width: double.infinity,
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  color: Theme.of(context).accentColor,
                  child: Column(
                    children: [
                      Container(
                        height: heightOfScreen * 0.3,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                              image: AssetImage('assets/friends.jpg'),
                              fit: BoxFit.cover),
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(
                          top: 10,
                          bottom: 10,
                        ),
                        child: Text(
                          AppLocalizations.of(context)
                              .translate('friends_screen', 'manage'),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).backgroundColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
