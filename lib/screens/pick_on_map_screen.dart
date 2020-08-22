import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PickOnMapScreen extends StatefulWidget {
  static const routeName = '/pick-on-map-screen';

  @override
  _PickOnMapScreenState createState() => _PickOnMapScreenState();
}

class _PickOnMapScreenState extends State<PickOnMapScreen> {
  CameraPosition _initialCameraPosition;
  LatLng _pickedLocation;

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
      zoom: 16,
    );
    setState(() {
      _initialCameraPosition = cameraPosition;
    });
  }

  void _selectOnMap(LatLng position) {
    setState(() {
      _pickedLocation = position;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(
        title: Text('Select place on map'),
        actions: <Widget>[
            IconButton(
              icon: Icon(Icons.check),
              onPressed: _pickedLocation == null
                  ? null
                  : () {
                      Navigator.of(context).pop(_pickedLocation);
                    },
            ),
        ],
      ),
      body: _initialCameraPosition == null
          ? Container(
              color: Theme.of(context).backgroundColor,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          : GoogleMap(
              initialCameraPosition: _initialCameraPosition,
              onTap: _selectOnMap,
              markers: _pickedLocation == null
            ? null
            : {
                Marker(
                  markerId: MarkerId('m1'),
                  position: _pickedLocation,
                ),
              },
            ),
    );
  }
}
