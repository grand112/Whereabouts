import 'package:Whereabouts/helpers/app_localizations.dart';
import 'package:Whereabouts/widgets/chat/chat_info.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../screens/users_screen.dart';
import '../screens/profile_screen.dart';

class FriendsList extends StatefulWidget {
  final FirebaseUser user;
  final bool profile;

  FriendsList(
    this.user,
    this.profile,
  );

  @override
  _FriendsListState createState() => _FriendsListState();
}

class _FriendsListState extends State<FriendsList> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Card(
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
                .where("accepted", isEqualTo: "yes")
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
                  ? Column(
                      children: [
                        Container(
                          child: Text(
                            widget.profile
                                ? AppLocalizations.of(context)
                                    .translate('friends_list', 'noFriends')
                                : AppLocalizations.of(context)
                                    .translate('friends_list', 'noChat'),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                          margin: EdgeInsets.only(
                            top: 25,
                            left: 25,
                            right: 25,
                            bottom: 15,
                          ),
                        ),
                        RaisedButton.icon(
                          icon: Icon(
                            Icons.add,
                          ),
                          color: Theme.of(context).backgroundColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(20),
                            ),
                          ),
                          onPressed: () {
                            Navigator.of(context)
                                .pushNamed(UsersScreen.routeName);
                          },
                          label: Text(AppLocalizations.of(context)
                              .translate('friends_list', 'add')),
                        ),
                      ],
                    )
                  : ListView.builder(
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      itemBuilder: (ctx, index) {
                        return docs[index]['userId'] == widget.user.uid
                            ? Container()
                            : widget.profile
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: <Widget>[
                                      Container(
                                        margin: EdgeInsets.only(left: 10),
                                        child: ClipOval(
                                          child: Container(
                                            color: Theme.of(context)
                                                .backgroundColor,
                                            child: CachedNetworkImage(
                                              fit: BoxFit.cover,
                                              height: 50,
                                              width: 50,
                                              imageUrl: docs[index]
                                                  ['sentBy_imageUrl'],
                                              placeholder: (context, url) =>
                                                  CircularProgressIndicator(),
                                              errorWidget:
                                                  (context, url, error) =>
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
                                      Container(
                                        margin: EdgeInsets.only(
                                          right: 15,
                                        ),
                                        child: RaisedButton(
                                          color:
                                              Theme.of(context).backgroundColor,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(20),
                                            ),
                                          ),
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    ProfileScreen(
                                                  docs[index]['sentBy'],
                                                ),
                                              ),
                                            );
                                          },
                                          child: Text(
                                            AppLocalizations.of(context)
                                                .translate(
                                                    'friends_list', 'profile'),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                : ChatInfo(
                                    docs[index]['sentBy'],
                                    docs[index]['sentBy_imageUrl'],
                                    docs[index]['sentBy_username'],
                                    widget.user);
                      },
                      itemCount: docs.length,
                    );
            },
          ),
        ),
      ),
    );
  }
}
