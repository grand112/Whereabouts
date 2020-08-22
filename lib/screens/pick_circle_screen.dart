import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uuid/uuid.dart';

class PickCircleScreen extends StatefulWidget {
  static const routeName = '/add-circle-screen';

  @override
  _PickCircleScreenState createState() => _PickCircleScreenState();
}

class _PickCircleScreenState extends State<PickCircleScreen> {
  CameraPosition _initialCameraPosition;
  Circle _circle;
  bool _changeMap = true;
  double _radius = 30;

  @override
  void initState() {
    super.initState();
    _getInitialPosition();
  }

  void _getInitialPosition() async {
    Position position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    CameraPosition cameraPosition = CameraPosition(
      target: LatLng(position.latitude, position.longitude),
      tilt: 0,
      zoom: 18,
    );
    setState(() {
      _initialCameraPosition = cameraPosition;
    });
  }

  void _clearCircle() {
    setState(() {
      _circle = null;
    });
  }

  void _selectOnMap(LatLng position) {
    Uuid uuid = Uuid();
    String id = uuid.v1();
    setState(() {
      _circle = Circle(
        circleId: CircleId(id),
        radius: _radius,
        strokeColor: Colors.green,
        center: position,
        fillColor: Colors.green.withAlpha(70),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).accentColor,
        brightness: Brightness.dark,
        title: Text(
          'choose the places you want to follow:',
          style: TextStyle(
            color: Theme.of(context).backgroundColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.check,
              color: _circle == null
                  ? Colors.black
                  : Theme.of(context).backgroundColor,
            ),
            onPressed: _circle == null
                ? null
                : () {
                    Navigator.of(context).pop(_circle);
                  },
          ),
        ],
      ),
      body: Stack(
        children: <Widget>[
          _initialCameraPosition == null
              ? Container(
                  color: Theme.of(context).backgroundColor,
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              : GoogleMap(
                  mapType: _changeMap ? MapType.normal : MapType.hybrid,
                  initialCameraPosition: _initialCameraPosition,
                  onTap: _selectOnMap,
                  circles: _circle == null ? {} : {_circle}),
          Positioned(
            bottom: 70,
            left: 15,
            child: Container(
              color: Theme.of(context).accentColor,
              padding: EdgeInsets.only(bottom: 5, right: 5),
              child: _circle == null
                  ? Container()
                  : IconButton(
                      icon: Icon(Icons.delete,
                          size: 40, color: Theme.of(context).errorColor),
                      onPressed: () {
                        _clearCircle();
                      }),
            ),
          ),
          Positioned(
            top: 15,
            right: 15,
            child: Container(
              color: Theme.of(context).accentColor,
              padding: EdgeInsets.only(bottom: 5, right: 5),
              child: IconButton(
                  icon: Icon(Icons.map,
                      size: 40, color: Theme.of(context).backgroundColor),
                  onPressed: () {
                    setState(() {
                      _changeMap = !_changeMap;
                    });
                  }),
            ),
          ),
          Positioned(
            bottom: 15,
            left: 15,
            child: Container(
              color: Theme.of(context).accentColor,
              child: Row(
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(left: 10),
                    child: Text(
                      'Change radius:',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Slider(
                    min: 10,
                    max: 100,
                    value: _radius,
                    onChanged: (radius) {
                      setState(() {
                        _radius = radius;
                      });
                    },
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
