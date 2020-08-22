import '../../screens/auth_screen.dart';
import 'package:flutter/material.dart';

class SwipeImage extends StatelessWidget {
  final String image;
  final String title;
  final String content;
  bool isLogin = true;

  SwipeImage(this.image, this.title, this.content);

  @override
  Widget build(BuildContext context) {
    var isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    final double heightOfScreen = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
            height: double.infinity,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Theme.of(context).backgroundColor,
              image:
                  DecorationImage(image: AssetImage(image), fit: BoxFit.cover),
            ),
          ),
          Container(
            margin: EdgeInsets.only(top:50),
              height: heightOfScreen*0.1,
              decoration: BoxDecoration(
                color: Color.fromRGBO(0, 0, 0, 0.7),
                image: DecorationImage(
                    image: AssetImage('assets/title_white.png'),
                    fit: BoxFit.contain),
              ),
            ),
          
          Container(
            height: isPortrait ? heightOfScreen * 0.32 : heightOfScreen * 0.52,
            margin: EdgeInsets.only(
              top: isPortrait ? heightOfScreen * 0.6 : heightOfScreen * 0.45,
            ),
            child: Container(
              color: Color.fromRGBO(0, 0, 0, 0.7),
              margin: EdgeInsets.only(bottom: 20),
              padding: EdgeInsets.only(top: 20, bottom: 10),
              child: Column(
                children: <Widget>[
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: heightOfScreen * 0.05),
                    child: Text(
                      content,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        height: 1.3,
                      ),
                    ),
                  ),
                  Container(
                    child: Padding(
                      padding: EdgeInsets.only(top: isPortrait ? 35 : 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          Expanded(
                            child: FlatButton.icon(
                              onPressed: () {
                                Navigator.of(context).pushNamed(
                                    AuthScreen.routeName,
                                    arguments: isLogin);
                              },
                              icon: Icon(
                                Icons.add_to_home_screen,
                                color: Colors.white,
                              ),
                              label: Text(
                                'LOG IN',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: FlatButton.icon(
                              onPressed: () {
                                isLogin = !isLogin;
                                Navigator.of(context).pushNamed(
                                    AuthScreen.routeName,
                                    arguments: isLogin);
                              },
                              icon: Icon(
                                Icons.person_add,
                                color: Colors.white,
                              ),
                              label: Text(
                                'CREATE\nAN ACCOUNT',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
