import 'package:flutter/material.dart';
import 'dart:async';
import 'package:location/location.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatefulWidget {
  final double fromLat;
  final double fromLong;
  final double toLat;
  final double toLong;
  final bool useMyLocation;

  MapScreen(
      {this.fromLat,
      this.fromLong,
      this.toLat,
      this.toLong,
      this.useMyLocation});
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  static const double CAMERA_ZOOM = 16;
  static const double CAMERA_TILT = 80;
  static const double CAMERA_BEARING = 30;
  LatLng destLocation;
  LatLng sourceLocation;

  static const String k_googleAPIKey =
      'AIzaSyAcFr4okH0wWB4sCNFDWOEiT86PjD_fncM';

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
  bool _useMyLocation;

  @override
  void initState() {
    super.initState();
    sourceLocation = LatLng(widget.fromLat, widget.fromLong);
    destLocation = LatLng(widget.toLat, widget.toLong);
    _useMyLocation = widget.useMyLocation;

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
    if (_useMyLocation) {
      currentLocation = await location.getLocation();
    } else {
      currentLocation = LocationData.fromMap({
        "latitude": sourceLocation.latitude,
        "longitude": sourceLocation.longitude
      });
    }
    destinationLocation = LocationData.fromMap({
      "latitude": destLocation.latitude,
      "longitude": destLocation.longitude
    });
  }

  void showPinsOnMap() {
    // get a LatLng for the source location
    // from the LocationData currentLocation object
    var pinPosition =
        LatLng(currentLocation.latitude, currentLocation.longitude);
    // get a LatLng out of the LocationData object
    var destPosition =
        LatLng(destinationLocation.latitude, destinationLocation.longitude);
    // add the initial source location pin
    _markers.add(Marker(
        markerId: MarkerId('sourcePin'),
        position: pinPosition,
        icon: sourceIcon));
    // destination pin
    _markers.add(Marker(
        markerId: MarkerId('destPin'),
        position: destPosition,
        icon: destinationIcon));
    // set the route lines on the map from source to destination
    // for more info follow this tutorial
    setPolylines();
  }

  void setPolylines() async {
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        k_googleAPIKey,
        PointLatLng(
          currentLocation.latitude,
          currentLocation.longitude,
        ),
        PointLatLng(
            destinationLocation.latitude, destinationLocation.longitude));
    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
      setState(() {
        _polylines.add(Polyline(
            width: 5, // set the width of the polylines
            polylineId: PolylineId('poly'),
            color: Color(0xff287ac6),
            points: polylineCoordinates));
      });
    }
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
  @override
  Widget build(BuildContext context) {
    CameraPosition initialCameraPosition = CameraPosition(
        zoom: CAMERA_ZOOM,
        tilt: CAMERA_TILT,
        bearing: CAMERA_BEARING,
        target: sourceLocation);
    if (currentLocation != null) {
      initialCameraPosition = CameraPosition(
          target: LatLng(currentLocation.latitude, currentLocation.longitude),
          zoom: CAMERA_ZOOM,
          tilt: CAMERA_TILT,
          bearing: CAMERA_BEARING);
    }
    return Scaffold(
      appBar: AppBar(title: Text("Map View")),
      body: Stack(
        children: <Widget>[
          GoogleMap(
              myLocationEnabled: true,
              compassEnabled: true,
              tiltGesturesEnabled: false,
              markers: _markers,
              polylines: _polylines,
              mapType: MapType.normal,
              initialCameraPosition: initialCameraPosition,
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
                // my map has completed being created;
                // i'm ready to show the pins on the map
                showPinsOnMap();
              })
        ],
      ),
    );
  }
}
