import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class PlaceDetailsScreen extends StatelessWidget {
  static const routeName = '/place-details-screen';

  @override
  Widget build(BuildContext context) {
    final double heightOfScreen = MediaQuery.of(context).size.height;
    final data = (ModalRoute.of(context).settings.arguments as Map);
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: Column(
          children: <Widget>[
            Stack(
              children: <Widget>[
                Container(
                  height: heightOfScreen * 0.4,
                  child: CachedNetworkImage(
                    fit: BoxFit.cover,
                    height: 40,
                    width: 40,
                    imageUrl: data['imageUrl'],
                    placeholder: (context, url) =>
                        Center(child: CircularProgressIndicator()),
                    errorWidget: (context, url, error) => Icon(Icons.error),
                  ),
                  width: double.infinity,
                ),
                Positioned(
                  left: -4.0,
                  right: -4.0,
                  bottom: -4.0,
                  child: Container(
                    height: 30,
                    width: double.infinity,
                    child: Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
            Text(
              data['name'],
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            SizedBox(
              height: 20,
            ),
            Container(
              margin: EdgeInsets.only(
                left: 15,
                right: 15,
              ),
              child: Text(
                data['info'] == null ? '' : data['info'],
              ),
            ),
            SizedBox(
              height: 15,
            ),
            Text(
              'Location: ',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
            ),
            Container(
              margin: EdgeInsets.all(15),
              height: 200,
              child: CachedNetworkImage(
                fit: BoxFit.cover,
                imageUrl: data['mapUrl'],
                placeholder: (context, url) =>
                    Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, error) => Icon(Icons.error),
              ),
            ),
            Container(
              margin: EdgeInsets.only(
                bottom: 25,
                right: 40,
                left: 40,
              ),
              child: Text(
                data['address'],
                textAlign: TextAlign.center,
              ),
            ),
            Text(
              'Discovered by: ' + data['discoveredBy'],
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
