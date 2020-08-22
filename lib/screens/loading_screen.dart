import 'package:flutter/material.dart';

class LoadingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final double heightOfScreen = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Theme.of(context).accentColor,
      body: Center(
        child: Container(height: heightOfScreen*0.3,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/logo_title_white.png'),
            ),
          ),
        ),
      ),
    );
  }
}
