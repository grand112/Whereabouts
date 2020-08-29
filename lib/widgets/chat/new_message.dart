import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NewMessage extends StatefulWidget {
  final String toUserId;
  final FirebaseUser user;

  NewMessage(
    this.toUserId,
    this.user,
  );

  @override
  _NewMessageState createState() => _NewMessageState();
}

class _NewMessageState extends State<NewMessage> {
  final _controller = new TextEditingController();
  var _enteredMessage = '';

  void _sendMessage() async {
    FocusScope.of(context).unfocus();
    _controller.clear();

    final userData = await Firestore.instance
        .collection('users')
        .document(widget.user.uid)
        .get();
    final toUserData = await Firestore.instance
        .collection('users')
        .document(widget.toUserId)
        .get();

    final store1 = await Firestore.instance
        .collection('chats')
        .document(widget.user.uid + ':' + widget.toUserId)
        .collection(widget.user.uid + ':' + widget.toUserId)
        .getDocuments();

    final store2 = await Firestore.instance
        .collection('chats')
        .document(widget.toUserId + ':' + widget.user.uid)
        .collection(widget.toUserId + ':' + widget.user.uid)
        .getDocuments();

    if (store1.documents.length == 0) {
      if (store2.documents.length == 0) {
        await Firestore.instance
            .collection('chats')
            .document(widget.user.uid + ':' + widget.toUserId)
            .collection(widget.user.uid + ':' + widget.toUserId)
            .add({
          'text': _enteredMessage,
          'createdAt': Timestamp.now(),
          'sentBy': widget.user.uid,
          'sentTo': widget.toUserId,
          'sentByUsername': userData['username'],
          'sentToUsername': toUserData['username'],
          'sentByUserImage': userData['image_url'],
        });
      } else if (store2.documents.length != 0) {
        await Firestore.instance
            .collection('chats')
            .document(widget.toUserId + ':' + widget.user.uid)
            .collection(widget.toUserId + ':' + widget.user.uid)
            .add(
          {
            'text': _enteredMessage,
            'createdAt': Timestamp.now(),
            'sentBy': widget.user.uid,
            'sentTo': widget.toUserId,
            'sentByUsername': userData['username'],
            'sentToUsername': toUserData['username'],
            'sentByUserImage': userData['image_url'],
          },
        );
      }
    } else if (store1.documents.length != 0) {
      await Firestore.instance
          .collection('chats')
          .document(widget.user.uid + ':' + widget.toUserId)
          .collection(widget.user.uid + ':' + widget.toUserId)
          .add({
        'text': _enteredMessage,
        'createdAt': Timestamp.now(),
        'sentBy': widget.user.uid,
        'sentTo': widget.toUserId,
        'sentByUsername': userData['username'],
        'sentToUsername': toUserData['username'],
        'sentByUserImage': userData['image_url'],
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 8),
      padding: EdgeInsets.all(8),
      child: Row(
        children: <Widget>[
          Expanded(
            child: TextField(
              textCapitalization: TextCapitalization.sentences,
              autocorrect: true,
              enableSuggestions: true,
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Send a message',
                labelStyle: TextStyle(color: Theme.of(context).accentColor),
              ),
              onChanged: (value) {
                setState(() {
                  _enteredMessage = value;
                });
              },
            ),
          ),
          IconButton(
            color: Theme.of(context).backgroundColor,
            icon: Icon(
              Icons.send,
            ),
            onPressed: _enteredMessage.trim().isEmpty ? null : _sendMessage,
          )
        ],
      ),
    );
  }
}
