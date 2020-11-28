import 'package:flutter/material.dart';
import 'dart:async';
import 'package:location/location.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MyHomePage extends StatefulWidget {
  final String title;
  MyHomePage({this.title});
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static const double CAMERA_ZOOM = 16;
  static const double CAMERA_TILT = 80;
  static const double CAMERA_BEARING = 30;
  static const String k_googleAPIKey =
      'AIzaSyAcFr4okH0wWB4sCNFDWOEiT86PjD_fncM';
  static const LatLng SOURCE_LOCATION = LatLng(42.747932, -71.167889);
  static const LatLng DEST_LOCATION = LatLng(37.335685, -122.0605916);

  TextEditingController _startPositionLat = TextEditingController();
  TextEditingController _startPositionLong = TextEditingController();
  TextEditingController _endPositionLat = TextEditingController();
  TextEditingController _endPositionLong = TextEditingController();

  Completer<GoogleMapController> _controller = Completer();
  Set<Marker> _markers = Set<Marker>();
// for my drawn routes on the map
  Set<Polyline> _polylines = Set<Polyline>();
  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints;
// for my custom marker pins
  BitmapDescriptor sourceIcon;
  BitmapDescriptor destinationIcon;
// the user's initial location and current location
// as it moves
  LocationData currentLocation;
// a reference to the destination location
  LocationData destinationLocation;
// wrapper around the location API
  Location location;
  bool _useCurrentLocation = false;

  @override
  void initState() {
    // TODO: implement initState

    super.initState();

    // create an instance of Location
    // subscribe to changes in the user's location
    // by "listening" to the location's onLocationChanged event
    location = new Location();
    polylinePoints = PolylinePoints();
    location.onLocationChanged.listen((event) {
      // event contains the lat and long of the
      // current user's position in real time,
      // so we're holding on to it
      currentLocation = event;
    });
    updatePinOnMap();

    // set custom marker pins
    setSourceAndDestinationIcons();
    // set the initial location
    setInitialLocation();
  }

  void setSourceAndDestinationIcons() async {
    sourceIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5), 'assets/driving_pin.png');

    destinationIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5),
        'assets/destination_map_marker.png');
  }

  void setInitialLocation() async {
    // set the initial location by pulling the user's
    // current location from the location's getLocation()
    currentLocation = await location.getLocation();

    // hard-coded destination for this example
    destinationLocation = LocationData.fromMap({
      "latitude": DEST_LOCATION.latitude,
      "longitude": DEST_LOCATION.longitude
    });
  }

  void updatePinOnMap() async {
    // create a new CameraPosition instance
    // every time the location changes, so the camera
    // follows the pin as it moves with an animation
    CameraPosition cPosition = CameraPosition(
      zoom: CAMERA_ZOOM,
      tilt: CAMERA_TILT,
      bearing: CAMERA_BEARING,
      target: LatLng(currentLocation.latitude, currentLocation.longitude),
    );
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(cPosition));
    // do this inside the setState() so Flutter gets notified
    // that a widget update is due
    setState(() {
      // updated position
      var pinPosition =
          LatLng(currentLocation.latitude, currentLocation.longitude);

      // the trick is to remove the marker (by id)
      // and add it again at the updated location
      _markers.removeWhere((m) => m.markerId.value == 'sourcePin');
      _markers.add(Marker(
          markerId: MarkerId('sourcePin'),
          position: pinPosition, // updated position
          icon: sourceIcon));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Google Maps APP for Drivers")),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "Start Location",
                style: TextStyle(fontSize: 18),
              ),
              Row(
                children: [
                  Text(
                    "Use My Current Location",
                    style: TextStyle(fontSize: 14),
                  ),
                  Switch(
                      onChanged: (value) {
                        _useCurrentLocation = value;
                        if (value) {
                          _startPositionLat.clear();
                          _startPositionLong.clear();
                        }
                        setState(() {});
                      },
                      value: _useCurrentLocation),
                ],
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 150,
                child: TextField(
                  enabled: !_useCurrentLocation,
                  controller: _startPositionLat,
                  decoration: InputDecoration(hintText: "Lat"),
                ),
              ),
              Container(
                width: 150,
                child: TextField(
                  enabled: !_useCurrentLocation,
                  controller: _startPositionLong,
                  decoration: InputDecoration(hintText: "Long"),
                ),
              ),
            ],
          ),
          SizedBox(height: 30),
          Text(
            "End Location",
            style: TextStyle(fontSize: 18),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 150,
                child: TextField(
                  controller: _endPositionLat,
                  decoration: InputDecoration(hintText: "Lat"),
                ),
              ),
              Container(
                width: 150,
                child: TextField(
                  controller: _endPositionLong,
                  decoration: InputDecoration(hintText: "Long"),
                ),
              ),
            ],
          ),
        ]),
      ),
    );
  }
}
