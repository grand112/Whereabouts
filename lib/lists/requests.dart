import 'package:Whereabouts/helpers/app_localizations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../screens/profile_screen.dart';

class Requests extends StatefulWidget {
  final FirebaseUser user;

  Requests(this.user);

  @override
  _RequestsState createState() => _RequestsState();
}

class _RequestsState extends State<Requests> {
  Future<void> _accepted(String userId) async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    await Firestore.instance
        .collection('users')
        .document(user.uid)
        .collection('friends')
        .document(userId)
        .updateData({
      'accepted': 'yes',
    });

    DocumentSnapshot myData =
        await Firestore.instance.collection('users').document(user.uid).get();

    await Firestore.instance
        .collection('users')
        .document(userId)
        .collection('friends')
        .document(user.uid)
        .setData({
      'sentBy': user.uid,
      'sentBy_imageUrl': myData.data['image_url'],
      'sentBy_username': myData.data['username'],
      'sentTo': userId,
      'sentAt': Timestamp.now(),
      'accepted': 'yes',
    });
  }

  Future<void> _declined(String userId) async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    await Firestore.instance
        .collection('users')
        .document(user.uid)
        .collection('friends')
        .document(userId)
        .delete();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(20),
        ),
      ),
      margin: EdgeInsets.only(
        top: 15,
        bottom: 15,
        left: 10,
        right: 10,
      ),
      color: Theme.of(context).accentColor,
      child: Container(
        padding: EdgeInsets.only(
          top: 10,
          bottom: 10,
        ),
        child: StreamBuilder(
          stream: Firestore.instance
              .collection('users')
              .document(widget.user.uid)
              .collection('friends')
              .where("accepted", isEqualTo: "no")
              .snapshots(),
          builder: (ctx, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            if (snapshot.connectionState == ConnectionState.none) {
              return Center(
                child: Icon(Icons.error),
              );
            }
            final docs = snapshot.data.documents;
            return docs.length == 0
                ? Container(
                    child: Text(
                      AppLocalizations.of(context)
                          .translate('requests', 'noRequests'),
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    margin: EdgeInsets.all(25),
                  )
                : ListView.builder(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    itemBuilder: (ctx, index) {
                      return docs[index]['userId'] == widget.user.uid
                          ? Container()
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[
                                Container(
                                  margin: EdgeInsets.only(left: 10),
                                  child: ClipOval(
                                    child: Container(
                                      color: Theme.of(context).backgroundColor,
                                      child: CachedNetworkImage(
                                        fit: BoxFit.cover,
                                        height: 50,
                                        width: 50,
                                        imageUrl: docs[index]
                                            ['sentBy_imageUrl'],
                                        placeholder: (context, url) =>
                                            CircularProgressIndicator(),
                                        errorWidget: (context, url, error) =>
                                            Icon(Icons.error),
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    margin: EdgeInsets.only(
                                      top: 25,
                                      bottom: 25,
                                      left: 20,
                                    ),
                                    child: Text(
                                      docs[index]['sentBy_username'],
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 17,
                                          color: Colors.white),
                                    ),
                                  ),
                                ),
                                RaisedButton(
                                  color: Theme.of(context).backgroundColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(20),
                                    ),
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ProfileScreen(
                                          docs[index]['sentBy'],
                                        ),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    AppLocalizations.of(context)
                                        .translate('requests', 'profile'),
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.only(
                                    left: 5,
                                  ),
                                  child: IconButton(
                                      iconSize: 35,
                                      color: Colors.green,
                                      icon: Icon(Icons.check),
                                      onPressed: () {
                                        _accepted(docs[index]['sentBy']);
                                      }),
                                ),
                                Container(
                                  margin: EdgeInsets.only(
                                    right: 5,
                                  ),
                                  child: IconButton(
                                      iconSize: 35,
                                      color: Colors.red,
                                      icon: Icon(Icons.clear),
                                      onPressed: () {
                                        _declined(docs[index]['sentBy']);
                                      }),
                                ),
                              ],
                            );
                    },
                    itemCount: docs.length,
                  );
          },
        ),
      ),
    );
  }
}
