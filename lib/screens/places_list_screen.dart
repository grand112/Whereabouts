import 'package:Whereabouts/screens/add_place_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../widgets/place/places.dart';

class PlacesListScreen extends StatefulWidget {
  @override
  _PlacesListScreenState createState() => _PlacesListScreenState();
}

class _PlacesListScreenState extends State<PlacesListScreen> {
  Future<List<DocumentSnapshot>> _getFriendsPlaces() async {
    List<DocumentSnapshot> friendsPlaces = [];
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    QuerySnapshot friendsQuery = await Firestore.instance
        .collection('users')
        .document(user.uid)
        .collection('friends')
        .getDocuments();
    await Future.wait(friendsQuery.documents.map((friend) async {
      QuerySnapshot friendsPlacesQuery = await Firestore.instance
          .collection('users')
          .document(friend['sentBy'])
          .collection('places')
          .getDocuments();
      friendsPlacesQuery.documents.forEach((place) {
        friendsPlaces.add(place);
      });
    }));
    return friendsPlaces;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        brightness: Brightness.dark,
        backgroundColor: Theme.of(context).accentColor,
        title: Text(
          'Great places',
          style: TextStyle(
              color: Theme.of(context).backgroundColor,
              fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.add,
              color: Theme.of(context).backgroundColor,
            ),
            onPressed: () {
              Navigator.of(context).pushNamed(AddPlaceScreen.routeName);
            },
          ),
        ],
      ),
      body: Container(
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
        child: ListView(
          children: [
            Column(
              children: [
                Container(
                  margin: EdgeInsets.only(
                    top: 25,
                    bottom: 10,
                  ),
                  child: Text(
                    'Places discovered by you',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                ),
                FutureBuilder(
                    future: FirebaseAuth.instance.currentUser(),
                    builder: (ctx, user) {
                      if (user.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      return StreamBuilder(
                        stream: Firestore.instance
                            .collection('users')
                            .document(user.data.uid)
                            .collection('places')
                            .snapshots(),
                        builder: (ctx, futureSnapshot) {
                          if (futureSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          final placesDocs = futureSnapshot.data.documents;
                          if (placesDocs.length == 0) {
                            return Card(
                              margin: EdgeInsets.only(
                                left: 25,
                                right: 25,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              color: Theme.of(context).accentColor,
                              child: Center(
                                child: Container(
                                  margin: EdgeInsets.only(
                                    top: 10,
                                    bottom: 10,
                                  ),
                                  child: Column(
                                    children: [
                                      Text(
                                        'A bit empty here  :(\n\nAdd some places to share',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                          color:
                                              Theme.of(context).backgroundColor,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(
                                          top: 10,
                                        ),
                                        child: RaisedButton.icon(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(20),
                                            ),
                                          ),
                                          color:
                                              Theme.of(context).backgroundColor,
                                          onPressed: () {
                                            Navigator.of(context).pushNamed(
                                                AddPlaceScreen.routeName);
                                          },
                                          icon: Icon(Icons.add),
                                          label: Text(
                                            'Add new place',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }
                          return ListView.builder(
                            scrollDirection: Axis.vertical,
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemBuilder: (ctx, index) {
                              return Places(
                                  placesDocs[index]['address'],
                                  placesDocs[index]['imageUrl'],
                                  placesDocs[index]['info'],
                                  placesDocs[index]['mapUrl'],
                                  placesDocs[index]['name'],
                                  placesDocs[index]['discoveredBy'],
                                  true);
                            },
                            itemCount: placesDocs.length,
                          );
                        },
                      );
                    }),
                Container(
                  margin: EdgeInsets.only(
                    top: 25,
                    bottom: 10,
                  ),
                  child: Text(
                    'Places discovered by your friends',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                ),
                FutureBuilder(
                  future: _getFriendsPlaces(),
                  builder: (ctx, places) {
                    if (places.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    if (places.data.length == 0) {
                      return Card(
                        margin: EdgeInsets.only(
                          left: 25,
                          right: 25,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        color: Theme.of(context).accentColor,
                        child: Center(
                          child: Container(
                            margin: EdgeInsets.only(
                              top: 10,
                              bottom: 10,
                            ),
                            child: Text(
                              'Your friends have no places to share yet.\n\nEncourage them to add some :)',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: Theme.of(context).backgroundColor,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      );
                    }
                    return ListView.builder(
                      scrollDirection: Axis.vertical,
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemBuilder: (ctx, index) {
                        return Places(
                            places.data[index]['address'],
                            places.data[index]['imageUrl'],
                            places.data[index]['info'],
                            places.data[index]['mapUrl'],
                            places.data[index]['name'],
                            places.data[index]['discoveredBy'],
                            false);
                      },
                      itemCount: places.data.length,
                    );
                  },
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
