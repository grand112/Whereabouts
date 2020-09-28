import 'package:Whereabouts/helpers/app_localizations.dart';
import 'package:Whereabouts/screens/profile_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UsersScreen extends StatefulWidget {
  static const routeName = '/users-screen';

  @override
  _UsersScreenState createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  FirebaseUser _user;
  List<String> _friendList=[];

  @override
  void initState() {
    super.initState();
    _getUserInfo();
    _getFriends();
  }

  Future<void> _getUserInfo() async {
    _user = await FirebaseAuth.instance.currentUser();
  }

  Future<void> _getFriends() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    QuerySnapshot friends = await Firestore.instance
        .collection('users')
        .document(user.uid)
        .collection('friends')
        .where("accepted", isEqualTo: "yes")
        .getDocuments();
    
    friends.documents.forEach((element) { 
      _friendList.add(element['sentBy']);
    });
  }

  Future<void> _sendInvite(String userId) async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
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
      'accepted': 'no',
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Theme.of(context).backgroundColor,
        ),
        brightness: Brightness.dark,
        backgroundColor: Theme.of(context).accentColor,
        title: Text(
          AppLocalizations.of(context).translate('users_screen', 'add'),
          style: TextStyle(
              color: Theme.of(context).backgroundColor,
              fontWeight: FontWeight.bold),
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
              stream: Firestore.instance.collection('users').snapshots(),
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
                return ListView.builder(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemBuilder: (ctx, index) {
                    return docs[index]['userId'] == _user.uid  || _friendList.contains(docs[index]['userId'])
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
                                      imageUrl: docs[index]['image_url'],
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
                                    docs[index]['username'],
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
                                        docs[index]['userId'],
                                      ),
                                    ),
                                  );
                                },
                                child: Text(
                                  AppLocalizations.of(context)
                                      .translate('users_screen', 'profile'),
                                ),
                              ),
                              IconButton(
                                  icon: Icon(
                                    Icons.add,
                                    color: Theme.of(context).backgroundColor,
                                  ),
                                  onPressed: () {
                                    _sendInvite(docs[index]['userId']);
                                    showDialog(
                                      context: context,
                                      child: new AlertDialog(
                                        backgroundColor:
                                            Theme.of(context).accentColor,
                                        title: new Text(
                                          AppLocalizations.of(context)
                                              .translate(
                                                  'users_screen', 'invite'),
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
                                                      fit: BoxFit.contain),
                                                ),
                                              ),
                                              Center(
                                                  child: RaisedButton(
                                                color: Theme.of(context)
                                                    .backgroundColor,
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                                child: Text('OK'),
                                              )),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  })
                            ],
                          );
                  },
                  itemCount: docs.length,
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
