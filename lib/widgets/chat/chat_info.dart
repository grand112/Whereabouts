import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../screens/chat_screen.dart';

class ChatInfo extends StatefulWidget {
  final String sentBy;
  final String sentByImageUrl;
  final String sentByUsername;
  final FirebaseUser user;
  ChatInfo(
    this.sentBy,
    this.sentByImageUrl,
    this.sentByUsername,
    this.user,
  );

  @override
  _ChatInfoState createState() => _ChatInfoState();
}

class _ChatInfoState extends State<ChatInfo> {
  String _lastMessage;
  String _time;
  String _from;
  StreamSubscription _store1;
  StreamSubscription _store2;

  @override
  void initState() {
    super.initState();
    _getMessagesData(widget.sentBy);
  }

  Future<void> _getMessagesData(String toUserId) async {
    final userData = await Firestore.instance
        .collection('users')
        .document(widget.user.uid)
        .get();
    _store1 = Firestore.instance
        .collection('chats')
        .document(widget.user.uid + ':' + toUserId)
        .collection(widget.user.uid + ':' + toUserId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((docs) {
      if (docs.documents.length != 0) {
        String lastMessage = docs.documents[0]['text'];
        DateTime dateTime =
            DateTime.parse(docs.documents[0]['createdAt'].toDate().toString());
        String time = DateFormat('HH:mm').format(dateTime);
        String from;
        if (docs.documents[0]['sentByUsername'] == userData['username']) {
          from = 'you';
        } else if (docs.documents[0]['sentByUsername'] !=
            userData['username']) {
          from = docs.documents[0]['sentByUsername'];
        }
        setState(() {
          _lastMessage = lastMessage;
          _time = time;
          _from = from;
        });
      }
    });

    _store2 = Firestore.instance
        .collection('chats')
        .document(toUserId + ':' + widget.user.uid)
        .collection(toUserId + ':' + widget.user.uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((docs) {
      if (docs.documents.length != 0) {
        String lastMessage = docs.documents[0]['text'];
        DateTime dateTime =
            DateTime.parse(docs.documents[0]['createdAt'].toDate().toString());
        String time = DateFormat('HH:mm').format(dateTime);
        String from;
        if (docs.documents[0]['sentByUsername'] == userData['username']) {
          from = 'you';
        } else if (docs.documents[0]['sentByUsername'] !=
            userData['username']) {
          from = docs.documents[0]['sentByUsername'];
        }
        setState(() {
          _lastMessage = lastMessage;
          _time = time;
          _from = from;
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    if (_store1 != null) {
      _store1.cancel();
    }
    if (_store2 != null) {
      _store2.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              widget.sentBy,
              widget.user,
            ),
          ),
        );
      },
      child: Row(
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
                  imageUrl: widget.sentByImageUrl,
                  placeholder: (context, url) => CircularProgressIndicator(),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              margin: EdgeInsets.only(
                top: 15,
                bottom: 15,
                left: 20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    widget.sentByUsername,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                        color: Colors.white),
                  ),
                  Text(
                    _lastMessage == null && _from == null
                        ? 'no previous messages'
                        : _from + ': ' + _lastMessage,
                    style: TextStyle(color: Colors.grey),
                  )
                ],
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(
              right: 20,
            ),
            child: Text(
              _time == null ? '' : _time.toString(),
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          )
        ],
      ),
    );
  }
}
