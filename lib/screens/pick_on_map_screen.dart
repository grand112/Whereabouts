import 'dart:async';

import 'package:Whereabouts/helpers/app_localizations.dart';
import 'package:Whereabouts/helpers/location_helper.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:search_map_place/search_map_place.dart';

class PickOnMapScreen extends StatefulWidget {
  static const routeName = '/pick-on-map-screen';

  @override
  _PickOnMapScreenState createState() => _PickOnMapScreenState();
}

class _PickOnMapScreenState extends State<PickOnMapScreen> {
  Completer<GoogleMapController> _controller = Completer();
  CameraPosition _initialCameraPosition;
  LatLng _pickedLocation;
  bool _changeMap = true;

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
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Theme.of(context).backgroundColor,
        ),
        brightness: Brightness.dark,
        backgroundColor: Theme.of(context).accentColor,
        title: Text(
          AppLocalizations.of(context)
              .translate('pick_on_map_screen', 'select'),
          style: TextStyle(color: Theme.of(context).primaryColor),
        ),
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
          : Stack(
              children: [
                GoogleMap(
                  mapType: _changeMap ? MapType.normal : MapType.hybrid,
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
                  onMapCreated: (GoogleMapController controller) {
                    _controller.complete(controller);
                  },
                ),
                Positioned(
                  top: 90,
                  right: MediaQuery.of(context).size.width * 0.05,
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
                  top: 15,
                  left: MediaQuery.of(context).size.width * 0.05,
                  right: MediaQuery.of(context).size.width * 0.05,
                  child: SearchMapPlaceWidget(
                    placeholder: AppLocalizations.of(context)
                        .translate('friends_location_screen', 'search'),
                    darkMode: true,
                    iconColor: Theme.of(context).backgroundColor,
                    apiKey: GOOGLE_API_KEY,
                    language: AppLocalizations.of(context).locale.languageCode,
                    location: _initialCameraPosition.target,
                    radius: 30000,
                    onSelected: (Place place) async {
                      final geolocation = await place.geolocation;

                      final GoogleMapController controller =
                          await _controller.future;
                      controller.animateCamera(
                          CameraUpdate.newLatLng(geolocation.coordinates));
                      controller.animateCamera(
                          CameraUpdate.newLatLngBounds(geolocation.bounds, 0));
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
