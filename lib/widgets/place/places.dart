import 'package:Whereabouts/helpers/app_localizations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../screens/place_details_screen.dart';

class Places extends StatelessWidget {
  final String address;
  final String imageUrl;
  final String info;
  final String mapUrl;
  final String name;
  final String discoveredBy;
  final bool usersPlace;

  Places(
    this.address,
    this.imageUrl,
    this.info,
    this.mapUrl,
    this.name,
    this.discoveredBy,
    this.usersPlace,
  );

  Future<void> _removeFromDataBase() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    return await Firestore.instance
        .collection('users')
        .document(user.uid)
        .collection('places')
        .getDocuments()
        .then((value) {
      for (DocumentSnapshot doc in value.documents) {
        if (doc.data['imageUrl'] == imageUrl) {
          doc.reference.delete();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        left: 10,
        right: 10,
        top: 10,
      ),
      child: !usersPlace
          ? Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.all(10),
                        child: ClipOval(
                          child: Container(
                            color: Theme.of(context).backgroundColor,
                            child: CachedNetworkImage(
                              fit: BoxFit.cover,
                              height: 70,
                              width: 70,
                              imageUrl: imageUrl,
                              placeholder: (context, url) =>
                                  Center(child: CircularProgressIndicator()),
                              errorWidget: (context, url, error) =>
                                  Icon(Icons.error),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          margin: EdgeInsets.only(right: 5, left: 3),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              SizedBox(height: 10),
                              Text(
                                name,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 17),
                              ),
                              SizedBox(height: 10),
                              Text(
                                info == null ? '' : info,
                              ),
                              SizedBox(height: 10),
                              Text(
                                address,
                                style: TextStyle(fontSize: 13),
                              ),
                              SizedBox(height: 5),
                              Text(
                                discoveredBy == null
                                    ? ''
                                    : AppLocalizations.of(context).translate(
                                            'places', 'discovered_by') +
                                        discoveredBy,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                  Container(
                    margin: EdgeInsets.only(
                      top: 10,
                      bottom: 10,
                    ),
                    child: RaisedButton(
                      onPressed: () {
                        Navigator.of(context).pushNamed(
                          PlaceDetailsScreen.routeName,
                          arguments: {
                            'address': address,
                            'imageUrl': imageUrl,
                            'info': info,
                            'mapUrl': mapUrl,
                            'name': name,
                            'usersPlace': usersPlace,
                            'discoveredBy': discoveredBy,
                          },
                        );
                      },
                      child: Text(AppLocalizations.of(context)
                          .translate('places', 'details')),
                    ),
                  ),
                ],
              ),
            )
          : Dismissible(
              key: ValueKey(imageUrl),
              background: Container(
                color: Theme.of(context).errorColor,
                child: Icon(
                  Icons.delete,
                  color: Colors.white,
                  size: 40,
                ),
                alignment: Alignment.centerRight,
                padding: EdgeInsets.only(right: 20),
              ),
              direction: DismissDirection.endToStart,
              onDismissed: (direction) {
                _removeFromDataBase();
              },
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.all(10),
                          child: ClipOval(
                            child: Container(
                              color: Theme.of(context).backgroundColor,
                              child: CachedNetworkImage(
                                fit: BoxFit.cover,
                                height: 70,
                                width: 70,
                                imageUrl: imageUrl,
                                placeholder: (context, url) =>
                                    Center(child: CircularProgressIndicator()),
                                errorWidget: (context, url, error) =>
                                    Icon(Icons.error),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            margin: EdgeInsets.only(right: 5, left: 3),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                SizedBox(height: 10),
                                Text(
                                  name,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 17),
                                ),
                                SizedBox(height: 10),
                                Text(
                                  info == null ? '' : info,
                                ),
                                SizedBox(height: 10),
                                Text(
                                  address,
                                  style: TextStyle(fontSize: 13),
                                ),
                                SizedBox(height: 5),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                    Container(
                      margin: EdgeInsets.only(
                        top: 10,
                        bottom: 10,
                      ),
                      child: RaisedButton(
                        onPressed: () {
                          Navigator.of(context).pushNamed(
                            PlaceDetailsScreen.routeName,
                            arguments: {
                              'address': address,
                              'imageUrl': imageUrl,
                              'info': info,
                              'mapUrl': mapUrl,
                              'name': name,
                              'discoveredBy': discoveredBy,
                            },
                          );
                        },
                        child: Text(AppLocalizations.of(context)
                            .translate('places', 'details')),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
