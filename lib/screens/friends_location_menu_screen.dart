import 'package:Whereabouts/helpers/app_localizations.dart';
import 'package:flutter/material.dart';

import '../screens/add_track_place_screen.dart';
import '../screens/friends_location_screen.dart';

class FriendsLocationMenuScreen extends StatelessWidget {
  static const routeName = '/friends-location-menu-screen';

  @override
  Widget build(BuildContext context) {
    final double heightOfScreen = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Theme.of(context).backgroundColor,
        ),
        brightness: Brightness.dark,
        backgroundColor: Theme.of(context).accentColor,
        title: Text(
          AppLocalizations.of(context)
              .translate('friends_location_menu_screen', 'findFriends'),
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
            GestureDetector(
              onTap: () {
                Navigator.of(context)
                    .pushNamed(FriendsLocationScreen.routeName);
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
                        height: heightOfScreen * 0.33,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                              image: AssetImage('assets/map_marker.png'),
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
                          AppLocalizations.of(context).translate(
                              'friends_location_menu_screen', 'findFriends'),
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
                Navigator.of(context).pushNamed(AddTrackPlaceScreen.routeName);
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
                        height: heightOfScreen * 0.33,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                              image: AssetImage('assets/circle.png'),
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
                          AppLocalizations.of(context).translate(
                              'friends_location_menu_screen', 'monitor'),
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
