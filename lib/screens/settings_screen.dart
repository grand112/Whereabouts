import 'package:Whereabouts/helpers/app_localizations.dart';
import 'package:Whereabouts/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  static const routeName = '/settings-screen';

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isLoading = false;

  Future<void> saveSettings(String language) async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    await Firestore.instance
        .collection('users')
        .document(user.uid)
        .collection('settings')
        .document(user.uid)
        .setData({
      'language': language,
      'changedAt': Timestamp.now(),
    });
  }

  @override
  Widget build(BuildContext context) {
    final double heightOfScreen = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Theme.of(context).backgroundColor,
        ),
        brightness: Brightness.dark,
        backgroundColor: Theme.of(context).accentColor,
        title: Text(
          AppLocalizations.of(context).translate('settings_screen', 'settings'),
          style: TextStyle(
              color: Theme.of(context).backgroundColor,
              fontWeight: FontWeight.bold),
        ),
      ),
      body: Container(
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
        child: _isLoading
            ? Container(
                height: double.infinity,
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(
                      top: 25,
                    ),
                    child: Text(
                      AppLocalizations.of(context)
                          .translate('settings_screen', 'change'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isLoading = true;
                      });
                      Locale newLocale = Locale('pl', 'PL');
                      Whereabouts.setLocale(context, newLocale);
                      saveSettings('pl');
                      setState(() {
                        _isLoading = false;
                      });
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      margin: EdgeInsets.only(
                        top: 25,
                        left: 70,
                        right: 70,
                      ),
                      width: double.infinity,
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        color: Theme.of(context).accentColor,
                        child: Container(
                          height: heightOfScreen * 0.2,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                                image: AssetImage('assets/pl_flag.png'),
                                fit: BoxFit.cover),
                            borderRadius: BorderRadius.circular(
                              20,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isLoading = true;
                      });
                      Locale newLocale = Locale('en', 'US');
                      Whereabouts.setLocale(context, newLocale);
                      saveSettings('en');
                      setState(() {
                        _isLoading = false;
                      });
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      margin: EdgeInsets.only(
                        top: 25,
                        left: 70,
                        right: 70,
                      ),
                      width: double.infinity,
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        color: Theme.of(context).accentColor,
                        child: Container(
                          height: heightOfScreen * 0.2,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                                image: AssetImage('assets/eng_flag.png'),
                                fit: BoxFit.cover),
                            borderRadius: BorderRadius.circular(
                              20,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
