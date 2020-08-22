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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        brightness: Brightness.dark,
        backgroundColor: Theme.of(context).accentColor,
        title: Text(
          'Your great places',
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
        child: FutureBuilder(
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
                    return Container(
                      width: double.infinity,
                      child: Center(
                        child: Text(
                          'A bit empty here  :(\n\nAdd some places to share',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }
                  return ListView.builder(
                    itemBuilder: (ctx, index) {
                      return Places(
                        placesDocs[index]['address'],
                        placesDocs[index]['imageUrl'],
                        placesDocs[index]['info'],
                        placesDocs[index]['mapUrl'],
                        placesDocs[index]['name'],
                      );
                    },
                    itemCount: placesDocs.length,
                  );
                },
              );
            }),
      ),
    );
  }
}
