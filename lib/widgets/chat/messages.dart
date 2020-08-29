import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import './message_bubble.dart';

class Messages extends StatefulWidget {
  final String toUserId;
  final FirebaseUser user;

  Messages(
    this.toUserId,
    this.user,
  );

  @override
  _MessagesState createState() => _MessagesState();
}

class _MessagesState extends State<Messages> {
  QuerySnapshot _store1;
  QuerySnapshot _store2;

  @override
  void initState() {
    super.initState();
    _getStorages();
  }

  Future<void> _getStorages() async {
    QuerySnapshot store1 = await Firestore.instance
        .collection('chats')
        .document(widget.user.uid + ':' + widget.toUserId)
        .collection(widget.user.uid + ':' + widget.toUserId)
        .getDocuments();

    QuerySnapshot store2 = await Firestore.instance
        .collection('chats')
        .document(widget.toUserId + ':' + widget.user.uid)
        .collection(widget.toUserId + ':' + widget.user.uid)
        .getDocuments();

    setState(() {
      _store1 = store1;
      _store2 = store2;
    });
  }

  Stream<QuerySnapshot> _checkStorages() {
    if (_store1.documents.length == 0) {
      if (_store2.documents.length == 0) {
        print(1);
        return Firestore.instance
            .collection('chats')
            .document(widget.user.uid + ':' + widget.toUserId)
            .collection(widget.user.uid + ':' + widget.toUserId)
            .orderBy(
              'createdAt',
              descending: true,
            )
            .snapshots();
      } else if (_store2.documents.length != 0) {
        print(2);
        return Firestore.instance
            .collection('chats')
            .document(widget.toUserId + ':' + widget.user.uid)
            .collection(widget.toUserId + ':' + widget.user.uid)
            .orderBy(
              'createdAt',
              descending: true,
            )
            .snapshots();
      }
    } 
    print(3);
    return Firestore.instance
        .collection('chats')
        .document(widget.user.uid + ':' + widget.toUserId)
        .collection(widget.user.uid + ':' + widget.toUserId)
        .orderBy(
          'createdAt',
          descending: true,
        )
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: FirebaseAuth.instance.currentUser(),
      builder: (ctx, futureSnapshot) {
        if (futureSnapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        return _store1 != null && _store2 != null
            ? StreamBuilder(
                stream: _checkStorages(),
                builder: (ctx, chatSnapshot) {
                  if (chatSnapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  final chatDocs = chatSnapshot.data.documents;
                  return ListView.builder(
                    reverse: true,
                    itemCount: chatDocs.length,
                    itemBuilder: (ctx, index) => MessageBubble(
                      chatDocs[index]['text'],
                      chatDocs[index]['sentByUsername'],
                      chatDocs[index]['sentByUserImage'],
                      chatDocs[index]['sentBy'] ==
                          futureSnapshot.data.uid, //returns true or false
                      key: ValueKey(chatDocs[index].documentID),
                    ),
                  );
                },
              )
            : Center(
                child: CircularProgressIndicator(),
              );
      },
    );
  }
}
