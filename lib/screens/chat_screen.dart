import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../widgets/chat/new_message.dart';
import '../widgets/chat/messages.dart';

class ChatScreen extends StatefulWidget {
  final String toUserId;
  final FirebaseUser user;

  ChatScreen(
    this.toUserId,
    this.user,
  );

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  DocumentSnapshot _userData;

  @override
  void initState() {
    super.initState();
    _getUserData();
  }
  
  Future<void> _getUserData() async {
    DocumentSnapshot userData = await Firestore.instance
        .collection('users')
        .document(widget.toUserId)
        .get();
    setState(() {
      _userData = userData;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        brightness: Brightness.dark,
        backgroundColor: Theme.of(context).accentColor,
        title: _userData == null
            ? Container()
            : Row(
                children: [
                  Container(
                    margin: EdgeInsets.only(
                      bottom: 10,
                      top: 10,
                      right: 10,
                    ),
                    child: Container(
                      margin: EdgeInsets.only(
                        right: 5,
                      ),
                      child: ClipOval(
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
                  ),
                  Text(
                    _userData['username'],
                    style: TextStyle(color: Theme.of(context).primaryColor),
                  ),
                ],
              ),
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            Expanded(
              child: Messages(
                widget.toUserId,
                widget.user,
              ),
            ),
            NewMessage(
              widget.toUserId,
              widget.user,
            ),
          ],
        ),
      ),
    );
  }
}
