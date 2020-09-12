import 'package:Whereabouts/helpers/app_localizations.dart';
import 'package:Whereabouts/lists/friends_list.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SelectChatScreen extends StatefulWidget {
  @override
  _SelectChatScreenState createState() => _SelectChatScreenState();
}

class _SelectChatScreenState extends State<SelectChatScreen> {
  FirebaseUser _user;
  DocumentSnapshot _userData;

  @override
  void initState() {
    super.initState();
    _getUserInfo();
  }

  Future<void> _getUserInfo() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    DocumentSnapshot userData =
        await Firestore.instance.collection('users').document(user.uid).get();
    setState(() {
      _user = user;
      _userData = userData;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        brightness: Brightness.dark,
        backgroundColor: Theme.of(context).accentColor,
        title: Row(
          children: [
            Container(
              margin: EdgeInsets.all(10),
              child: _userData == null
                  ? Container()
                  : ClipOval(
                      child: Container(
                        color: Theme.of(context).backgroundColor,
                        child: CachedNetworkImage(
                          fit: BoxFit.cover,
                          height: 40,
                          width: 40,
                          imageUrl: _userData['image_url'],
                          placeholder: (context, url) =>
                              CircularProgressIndicator(),
                          errorWidget: (context, url, error) =>
                              Icon(Icons.error),
                        ),
                      ),
                    ),
            ),
            Container(
              margin: EdgeInsets.only(
                left: 10,
              ),
              child: Text(
                AppLocalizations.of(context)
                    .translate('select_chat_screen', 'chats'),
                style: TextStyle(color: Theme.of(context).primaryColor),
              ),
            ),
          ],
        ),
      ),
      body: Container(
        height: double.infinity,
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
        child: _user == null ? Container() : FriendsList(_user, false),
      ),
    );
  }
}
