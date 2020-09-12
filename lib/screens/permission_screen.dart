import 'package:Whereabouts/helpers/app_localizations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:permission_handler/permission_handler.dart';

import './control_screen.dart';
import './welcome_screen.dart';

class PermissionScreen extends StatefulWidget {
  static const routeName = '/permission-screen';
  @override
  _PermissionScreenState createState() => _PermissionScreenState();
}

class _PermissionScreenState extends State<PermissionScreen> {
  bool denied = false;
  bool granted = false;
  bool restricted = false;
  bool permDenied = false;
  bool undetermined = false;
  @override
  void initState() {
    super.initState();
    _getPermission();
  }

  Future<void> _getPermission() async {
    PermissionStatus status = await Permission.location.request();
    if (status.isGranted) {
      Navigator.of(context).pushReplacementNamed(ControlScreen.routeName);
    }
    setState(() {
      denied = status.isDenied;
      granted = status.isDenied;
      restricted = status.isRestricted;
      permDenied = status.isPermanentlyDenied;
      undetermined = status.isUndetermined;
    });
  }

  @override
  Widget build(BuildContext context) {
    final double heightOfScreen = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Theme.of(context).accentColor,
      body: Stack(
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                height: heightOfScreen * 0.3,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/logo_title_white.png'),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(
                  left: 15,
                  right: 15,
                ),
                child: Text(
                  denied || restricted || permDenied || undetermined
                      ? AppLocalizations.of(context)
                          .translate('permission_screen', 'without')
                      : '',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              denied || restricted || permDenied || undetermined
                  ? Container(
                      margin: EdgeInsets.only(top: 30),
                      child: RaisedButton(
                        color: Theme.of(context).backgroundColor,
                        onPressed: () {
                          _getPermission();
                        },
                        child: Text(
                          AppLocalizations.of(context)
                              .translate('permission_screen', 'grant'),
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    )
                  : Container(),
            ],
          ),
          denied || restricted || permDenied || undetermined
              ? Positioned(
                  top: 25,
                  right: 10,
                  child: DropdownButton(
                    dropdownColor: Theme.of(context).backgroundColor,
                    underline: Container(),
                    icon: Icon(
                      Icons.more_vert,
                      color: Theme.of(context).primaryColor,
                    ),
                    items: [
                      DropdownMenuItem(
                        child: Container(
                          child: Row(
                            children: <Widget>[
                              Icon(Icons.exit_to_app),
                              SizedBox(
                                width: 8,
                              ),
                              Text(AppLocalizations.of(context)
                                  .translate('permission_screen', 'logOut')),
                            ],
                          ),
                        ),
                        value: 'logout',
                      ),
                    ],
                    onChanged: (itemIdentifier) {
                      if (itemIdentifier == 'logout') {
                        final GoogleSignIn googleSignIn = GoogleSignIn();
                        googleSignIn.signOut();
                        FirebaseAuth.instance.signOut();
                        Navigator.of(context).pushNamedAndRemoveUntil(
                          '/welcome-screen',
                          ModalRoute.withName(WelcomeScreen.routeName),
                        );
                      }
                    },
                  ),
                )
              : Container(),
        ],
      ),
    );
  }
}
