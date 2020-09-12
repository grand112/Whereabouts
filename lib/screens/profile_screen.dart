import 'package:Whereabouts/helpers/app_localizations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../screens/chat_screen.dart';

class ProfileScreen extends StatefulWidget {
  final String userId;

  ProfileScreen(this.userId);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _defaultBackground =
      'https://firebasestorage.googleapis.com/v0/b/whereabouts-b22a6.appspot.com/o/logo%2Flogo_title_white.png?alt=media&token=87e02392-c602-49c0-837d-cb401fab2111';
  int _placesCount;
  int _friendsCount;
  int _trackedCount;
  bool _isFriend;
  FirebaseUser _user;

  @override
  void initState() {
    super.initState();
    _getPlacesCount();
    _getFriendsCount();
    _checkIfFriend();
    _getTrackedCount();
    _getUser();
  }

  Future<void> _getUser() async {
    _user = await FirebaseAuth.instance.currentUser();
  }

  Future<void> _getFriendsCount() async {
    QuerySnapshot friends = await Firestore.instance
        .collection('users')
        .document(widget.userId)
        .collection('friends')
        .where("accepted", isEqualTo: "yes")
        .getDocuments();
    List<DocumentSnapshot> friendsDocuments = friends.documents;
    setState(() {
      _friendsCount = friendsDocuments.length;
    });
  }

  Future<void> _getTrackedCount() async {
    QuerySnapshot trackedPlacesQuery = await Firestore.instance
        .collection('circles')
        .where('userId', isEqualTo: widget.userId)
        .getDocuments();
    List<DocumentSnapshot> trackedPlacesDocuments =
        trackedPlacesQuery.documents;
    setState(() {
      _trackedCount = trackedPlacesDocuments.length;
    });
  }

  Future<void> _checkIfFriend() async {
    bool isFriend;
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    QuerySnapshot isFriendQuery = await Firestore.instance
        .collection('users')
        .document(widget.userId)
        .collection('friends')
        .where('sentBy', isEqualTo: user.uid)
        .getDocuments();
    List<DocumentSnapshot> isFriendDocuments = isFriendQuery.documents;
    if (isFriendDocuments.length > 0) {
      isFriend = true;
    } else {
      isFriend = false;
    }
    setState(() {
      _isFriend = isFriend;
    });
  }

  Future<void> _getPlacesCount() async {
    QuerySnapshot places = await Firestore.instance
        .collection('users')
        .document(widget.userId)
        .collection('places')
        .getDocuments();
    List<DocumentSnapshot> placesDocuments = places.documents;
    setState(() {
      _placesCount = placesDocuments.length;
    });
  }

  Future<DocumentSnapshot> _getUserData() async {
    return await Firestore.instance
        .collection('users')
        .document(widget.userId)
        .get();
  }

  Future<void> _removeFriend() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    Firestore.instance
        .collection('users')
        .document(user.uid)
        .collection('friends')
        .document(widget.userId)
        .delete();
    Firestore.instance
        .collection('users')
        .document(widget.userId)
        .collection('friends')
        .document(user.uid)
        .delete();
    setState(() {
      _isFriend = !_isFriend;
    });
  }

  Future<void> _sendInvite() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    DocumentSnapshot myData =
        await Firestore.instance.collection('users').document(user.uid).get();
    await Firestore.instance
        .collection('users')
        .document(widget.userId)
        .collection('friends')
        .document(user.uid)
        .setData({
      'sentBy': user.uid,
      'sentBy_imageUrl': myData.data['image_url'],
      'sentBy_username': myData.data['username'],
      'sentTo': widget.userId,
      'sentAt': Timestamp.now(),
      'accepted': 'no',
    });
    setState(() {
      _isFriend = !_isFriend;
    });
  }

  @override
  Widget build(BuildContext context) {
    final double heightOfScreen = MediaQuery.of(context).size.height;
    return Scaffold(
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
                        return Container(
                          height: 1,
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
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
                      return Container(
                        margin: EdgeInsets.only(
                          top: heightOfScreen * 0.3,
                        ),
                        child: Center(
                          child: CircularProgressIndicator(
                            backgroundColor: Theme.of(context).backgroundColor,
                          ),
                        ),
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
                            Column(
                              children: <Widget>[
                                !_isFriend
                                    ? RaisedButton.icon(
                                        icon: Icon(
                                          Icons.add,
                                          size: 20,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(25),
                                        ),
                                        color:
                                            Theme.of(context).backgroundColor,
                                        onPressed: () {
                                          _sendInvite();
                                          showDialog(
                                            context: context,
                                            child: new AlertDialog(
                                              backgroundColor:
                                                  Theme.of(context).accentColor,
                                              title: new Text(
                                                AppLocalizations.of(context)
                                                    .translate('profile_screen',
                                                        'invite'),
                                                style: TextStyle(
                                                    color: Theme.of(context)
                                                        .backgroundColor),
                                                textAlign: TextAlign.center,
                                              ),
                                              content: Container(
                                                height: 150,
                                                child: Column(
                                                  children: <Widget>[
                                                    Container(
                                                      margin: EdgeInsets.only(
                                                        bottom: 10,
                                                      ),
                                                      height: 70,
                                                      decoration: BoxDecoration(
                                                        image: DecorationImage(
                                                            image: AssetImage(
                                                                'assets/logo.png'),
                                                            fit:
                                                                BoxFit.contain),
                                                      ),
                                                    ),
                                                    Center(
                                                        child: RaisedButton(
                                                      color: Theme.of(context)
                                                          .backgroundColor,
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                      child: Text('OK'),
                                                    )),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                        label: Text(
                                          AppLocalizations.of(context)
                                              .translate(
                                                  'profile_screen', 'add'),
                                        ),
                                      )
                                    : RaisedButton.icon(
                                        icon: Icon(
                                          Icons.delete,
                                          size: 20,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(25),
                                        ),
                                        color: Theme.of(context).errorColor,
                                        onPressed: () {
                                          _removeFriend();
                                          showDialog(
                                            context: context,
                                            child: new AlertDialog(
                                              backgroundColor:
                                                  Theme.of(context).accentColor,
                                              title: new Text(
                                                AppLocalizations.of(context)
                                                    .translate('profile_screen',
                                                        'removed'),
                                                style: TextStyle(
                                                    color: Theme.of(context)
                                                        .backgroundColor),
                                                textAlign: TextAlign.center,
                                              ),
                                              content: Container(
                                                height: 150,
                                                child: Column(
                                                  children: <Widget>[
                                                    Container(
                                                      margin: EdgeInsets.only(
                                                        bottom: 10,
                                                      ),
                                                      height: 70,
                                                      decoration: BoxDecoration(
                                                        image: DecorationImage(
                                                            image: AssetImage(
                                                                'assets/logo.png'),
                                                            fit:
                                                                BoxFit.contain),
                                                      ),
                                                    ),
                                                    Center(
                                                        child: RaisedButton(
                                                      color: Theme.of(context)
                                                          .backgroundColor,
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                      child: Text('OK'),
                                                    )),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                        label: Text(
                                          AppLocalizations.of(context)
                                              .translate(
                                                  'profile_screen', 'remove'),
                                        ),
                                      ),
                                _isFriend
                                    ? RaisedButton.icon(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(25),
                                        ),
                                        color:
                                            Theme.of(context).backgroundColor,
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => ChatScreen(
                                                widget.userId,
                                                _user,
                                              ),
                                            ),
                                          );
                                        },
                                        icon: Icon(
                                          Icons.message,
                                          size: 20,
                                        ),
                                        label: Text(
                                          AppLocalizations.of(context)
                                              .translate(
                                                  'profile_screen', 'send'),
                                        ),
                                      )
                                    : Container(),
                              ],
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
                                ? AppLocalizations.of(context)
                                    .translate('profile_screen', 'hobby')
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
                                ? AppLocalizations.of(context).translate(
                                    'profile_screen', 'noDescription')
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
                                    AppLocalizations.of(context)
                                        .translate('profile_screen', 'friends'),
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
                                    AppLocalizations.of(context)
                                        .translate('profile_screen', 'tracked'),
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
                                    AppLocalizations.of(context).translate(
                                        'profile_screen', 'discovered'),
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
