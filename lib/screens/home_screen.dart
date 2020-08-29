import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../screens/edit_profile_screen.dart';
import '../widgets/drawer/home_drawer.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _defaultBackground =
      'https://firebasestorage.googleapis.com/v0/b/whereabouts-b22a6.appspot.com/o/logo%2Flogo_title_white.png?alt=media&token=87e02392-c602-49c0-837d-cb401fab2111';
  int _placesCount;
  int _friendsCount;
  int _trackedCount;

  @override
  void initState() {
    super.initState();
    _getPlacesCount();
    _getFriendsCount();
    _getTrackedCount();
  }

  Future<DocumentSnapshot> _getUserData() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    return await Firestore.instance
        .collection('users')
        .document(user.uid)
        .get();
  }

  Future<void> _getFriendsCount() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    QuerySnapshot friends = await Firestore.instance
        .collection('users')
        .document(user.uid)
        .collection('friends')
        .where("accepted", isEqualTo: "yes")
        .getDocuments();
    List<DocumentSnapshot> friendsDocuments = friends.documents;
    setState(() {
      _friendsCount = friendsDocuments.length;
    });
  }

  Future<void> _getTrackedCount() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    QuerySnapshot trackedPlacesQuery = await Firestore.instance
        .collection('circles')
        .where('userId', isEqualTo: user.uid)
        .getDocuments();
    List<DocumentSnapshot> trackedPlacesDocuments = trackedPlacesQuery.documents;
    setState(() {
      _trackedCount = trackedPlacesDocuments.length;
    });
  }

  Future<void> _getPlacesCount() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    QuerySnapshot places = await Firestore.instance
        .collection('users')
        .document(user.uid)
        .collection('places')
        .getDocuments();
    List<DocumentSnapshot> placesDocuments = places.documents;
    setState(() {
      _placesCount = placesDocuments.length;
    });
  }

  var scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    final double heightOfScreen = MediaQuery.of(context).size.height;
    return Scaffold(
      drawer: HomeDrawer(),
      key: scaffoldKey,
      body: Container(
        color: Colors.white,
        child: Column(
          children: <Widget>[
            Stack(
              children: <Widget>[
                FutureBuilder(
                    future: _getUserData(),
                    builder: (ctx, futureSnapshot) {
                      if (futureSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      if (futureSnapshot.connectionState ==
                          ConnectionState.none) {
                        return Center(
                          child: Icon(Icons.error),
                        );
                      }
                      return Container(
                        color: Theme.of(context).accentColor,
                        height: heightOfScreen * 0.4,
                        child: CachedNetworkImage(
                          fit: futureSnapshot.data['background'] ==
                                  _defaultBackground
                              ? BoxFit.contain
                              : BoxFit.cover,
                          height: 40,
                          width: 40,
                          imageUrl: futureSnapshot.data['background'],
                          placeholder: (context, url) =>
                              Center(child: CircularProgressIndicator()),
                          errorWidget: (context, url, error) =>
                              Icon(Icons.error),
                        ),
                        width: double.infinity,
                      );
                    }),
                Positioned(
                  left: -4.0,
                  right: -4.0,
                  bottom: -4.0,
                  child: Container(
                    height: 30,
                    width: double.infinity,
                    child: Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 20,
                  child: IconButton(
                      icon: Icon(
                        Icons.menu,
                      ),
                      iconSize: 40,
                      color: Colors.amber[600],
                      onPressed: () {
                        scaffoldKey.currentState.openDrawer();
                      }),
                ),
              ],
            ),
            Container(
              padding: EdgeInsets.only(
                left: 15,
                right: 15,
              ),
              width: double.infinity,
              margin: EdgeInsets.only(bottom: 20),
              child: FutureBuilder(
                  future: _getUserData(),
                  builder: (ctx, futureSnapshot) {
                    if (futureSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    if (futureSnapshot.connectionState ==
                        ConnectionState.none) {
                      return Center(
                        child: Icon(Icons.error),
                      );
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            ClipOval(
                              child: Container(
                                color: Theme.of(context).backgroundColor,
                                child: CachedNetworkImage(
                                  fit: BoxFit.cover,
                                  height: 70,
                                  width: 70,
                                  imageUrl: futureSnapshot.data['image_url'],
                                  placeholder: (context, url) => Center(
                                      child: CircularProgressIndicator()),
                                  errorWidget: (context, url, error) =>
                                      Icon(Icons.error),
                                ),
                              ),
                            ),
                            RaisedButton(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                              color: Theme.of(context).backgroundColor,
                              onPressed: () {
                                Navigator.of(context)
                                    .pushNamed(EditProfileScreen.routeName).whenComplete(() => setState(() {}));
                                
                              },
                              child: Text('Edit Profile'),
                            ),
                          ],
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 10),
                          child: Text(
                            futureSnapshot.data['username'],
                            style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(bottom: 10),
                          child: Text(
                            futureSnapshot.data['hobby'] == null
                                ? 'Hobby/Proffesion'
                                : futureSnapshot.data['hobby'],
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.grey[400],
                            ),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(bottom: 5),
                          child: Text(
                            futureSnapshot.data['about'] == null
                                ? 'This user hasn\'t provided their profile description yet'
                                : futureSnapshot.data['about'],
                            style: TextStyle(
                              fontSize: 15,
                            ),
                          ),
                        ),
                        Divider(
                          color: Colors.grey[200],
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: <Widget>[
                              Column(
                                children: <Widget>[
                                  Text(
                                    'FRIENDS',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey[400],
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    _friendsCount == null
                                        ? ''
                                        : _friendsCount.toString(),
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18),
                                  ),
                                ],
                              ),
                              Column(
                                children: <Widget>[
                                  Text(
                                    'TRACKED PLACES',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey[400],
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                 Text(
                                    _trackedCount == null
                                        ? ''
                                        : _trackedCount.toString(),
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18),
                                  ),
                                ],
                              ),
                              Column(
                                children: <Widget>[
                                  Text(
                                    'DISCOVERED PLACES',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey[400],
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    _placesCount == null
                                        ? ''
                                        : _placesCount.toString(),
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )
                      ],
                    );
                  }),
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}
