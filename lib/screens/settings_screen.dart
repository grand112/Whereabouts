import 'package:Whereabouts/main.dart';
import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  static const routeName = '/settings-screen';

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
          'Settings',
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(
                top: 25,
              ),
              child: Text(
                "Change language: ",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                Locale newLocale = Locale('pl', 'PL');
                Whereabouts.setLocale(context, newLocale);
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
                Locale newLocale = Locale('en', 'US');
                Whereabouts.setLocale(context, newLocale);
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
