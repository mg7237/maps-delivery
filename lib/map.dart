import 'package:flutter/material.dart';
import 'dart:async';
import 'package:location/location.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:driver/constants.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:driver/model.dart';
import 'package:driver/alert_dialog.dart';
import 'package:driver/distance_calculator.dart';

class MapScreen extends StatefulWidget {
  final double toLat;
  final double toLong;
  final int tripId;

  MapScreen({this.toLat, this.toLong, this.tripId});
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  static const double CAMERA_ZOOM = 15;
  static const double CAMERA_TILT = 0;
  static const double CAMERA_BEARING = 0;
  bool setCameraToStart = false;
  Location location = Location();

  final FirebaseDatabase _database = FirebaseDatabase.instance;

  LatLng destLocation;
  // Default India Lat Lang used as temporary starting point to avoid null error on page load

  Completer<GoogleMapController> _controller = Completer();
  Set<Marker> _markers = Set<Marker>();
// for my drawn routes on the map
  Map<PolylineId, Polyline> _polylines = {};
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

  String uid;
  ActiveDriver activeDriver;
  DriverLocation driverLocation;
  String activeDriverKey;
  String driverLocationKey;
  int tripId;
  DistanceCalculator distanceCalculator;

  void _startAsyncJobs() async {
    // Create new entry for trip start
    // try {
    // create instance of Destination Location
    print("DESTINATION START -> $destLocation");

    DriverLatLong driverLatLong = await DriverLatLong().getCurrentLocation();

    currentLocation = LocationData.fromMap(
        {"latitude": driverLatLong.lat, "longitude": driverLatLong.long});

    // currentLocation =
    //     LocationData.fromMap({"latitude": 12.8, "longitude": 77.8});
    print("DESTINATION START AGAIN -> $destLocation");
    // create an instance of Location
    location.changeSettings(
        accuracy: LocationAccuracy.navigation, interval: 2000);

    // set the initial location

    // create instance of Destination Location
    print("DESTINATION START -> $destLocation");
    print("Current START -> $currentLocation");

    polylinePoints = PolylinePoints();

    // subscribe to changes in the user's location
    // by "listening" to the location's onLocationChanged event

    activeDriverKey = _database.reference().child('active_driver').push().key;

    // Create trip id
    activeDriver =
        ActiveDriver(key: activeDriverKey, tripId: tripId, status: "STARTED");

    _database
        .reference()
        .child("active_driver")
        .child(activeDriverKey)
        .set(activeDriver.toJson());

    // driverLocationKey =
    //     _database.reference().child('driver_location').push().key;
    driverLocation = DriverLocation(
        tripId: tripId,
        lat: (currentLocation?.latitude),
        long: (currentLocation?.longitude),
        targetLat: (destLocation?.latitude),
        targetLong: (destLocation?.longitude));
    _database
        .reference()
        .child("driver_location")
        .push()
        .set(driverLocation.toJson());

    location.onLocationChanged.listen((event) {
      // event contains the lat and long of the
      // current user's position in real time,
      // so we're holding on to it
      //sourceLocation = LatLng(event.latitude, event.longitude);
      currentLocation = event;
      print("Current Loc: ${event.latitude} , ${event.longitude}");
      updatePinOnMap();

      // _database
      //     .reference()
      //     .child("driver_location")
      //     .child(driverLocationKey)
      //     .remove();

      // driverLocationKey =
      //     _database.reference().child('driver_location').push().key;

      driverLocation = DriverLocation(
          tripId: tripId,
          lat: event.latitude,
          long: event.longitude,
          targetLat: destinationLocation.latitude,
          targetLong: destinationLocation.longitude);

      _database
          .reference()
          .child("driver_location")
          .push()
          .set(driverLocation.toJson());
      distanceCalculator = DistanceCalculator(
          destLat: destLocation.latitude,
          destLong: destLocation.latitude,
          sourceLat: event.latitude,
          sourceLong: event.longitude);
      double totalDistanceInM = distanceCalculator.calcDistance();

      // If distance less than 50 (hard coding) meters then assume trip completed.
      if (totalDistanceInM < 50) {
        activeDriver.status = 'COMPLETED';
        _database
            .reference()
            .child("active_driver")
            .child(activeDriverKey)
            .set(activeDriver.toJson);

        _database.reference().child("tripId").child(driverLocationKey).remove();
      }
    });

    // set custom marker pins
    setSourceAndDestinationIcons();
    // } catch (e) {
    //   AlertDialogs alertDialogs =
    //       AlertDialogs(title: "Exception", message: "${e.toString()}");
    //   alertDialogs.asyncAckAlert(context);
    // }
  }

  @override
  void initState() {
    super.initState();
    tripId = widget.tripId;
    destLocation = LatLng(widget.toLat, widget.toLong);

    destinationLocation = LocationData.fromMap({
      "latitude": destLocation.latitude,
      "longitude": destLocation.longitude
    });
    print(
        "Init ${destinationLocation.latitude} , ${destinationLocation.longitude}");
    _startAsyncJobs();
  }

  void setSourceAndDestinationIcons() async {
    sourceIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5), 'assets/driving_pin.png');

    destinationIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5),
        'assets/destination_map_marker.png');
  }

  void showPinsOnMap() async {
    // get a LatLng for the source location
    // from the LocationData currentLocation object

    if (currentLocation == null) {
      currentLocation = await location.getLocation();
      print("DID GET CURRENT LOC $currentLocation");
      // await new Future.delayed(const Duration(seconds: 5));
      // Timer timer = Timer.periodic(Duration(milliseconds: 500), (t) async {
      //   if (currentLocation != null && destinationLocation != null) {
      //     currentLocation = await location.getLocation();
      //     t.cancel();
      //   } else {
      //     currentLocation = await location.getLocation();
      //   }
      // });
    }
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
    polylineCoordinates = [];
    if (currentLocation != null && destinationLocation != null) {
      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
          k_googleAPIKey,
          PointLatLng(
            currentLocation.latitude,
            currentLocation.longitude,
          ),
          PointLatLng(
              destinationLocation.latitude, destinationLocation.longitude),
          travelMode: TravelMode.driving);
      if (result.points.isNotEmpty) {
        for (int i = 0; i < result.points.length; i++) {
          if (i != (result.points.length - 1)) {
            polylineCoordinates.add(
                LatLng(result.points[i].latitude, result.points[i].longitude));
          }
        }
      }

      // result.points.forEach((PointLatLng point) {
      //   if (point !=
      //       PointLatLng(
      //           currentLocation.latitude, currentLocation.longitude)) {
      //     polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      //   }
      // }

      if (!this.mounted) {
        return;
      }
      setState(() {
        PolylineId id = PolylineId("poly");
        Polyline polyline = Polyline(
            polylineId: id, color: Colors.red, points: polylineCoordinates);
        _polylines[id] = polyline;
        // _polylines.add(Polyline(
        //     width: 5, // set the width of the polylines
        //     polylineId: PolylineId('poly'),
        //     color: Color(0xff287ac6),
        //     points: polylineCoordinates));
      });
    }
  }

  void updatePinOnMap() async {
    // create a new CameraPosition instance
    // every time the location changes, so the camera
    // follows the pin as it moves with an animation
    // 27.0858, 80.314003
    if (!setCameraToStart) {
      CameraPosition cPosition = CameraPosition(
        zoom: CAMERA_ZOOM,
        tilt: CAMERA_TILT,
        bearing: CAMERA_BEARING,
        target: LatLng(currentLocation.latitude, currentLocation.longitude),
      );
      final GoogleMapController controller = await _controller.future;
      controller.animateCamera(CameraUpdate.newCameraPosition(cPosition));

      setCameraToStart = true;
    }
    if (!this.mounted) {
      return;
    }
    setPolylines();

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
    CameraPosition initialCameraPosition = CameraPosition(
        zoom: CAMERA_ZOOM,
        tilt: CAMERA_TILT,
        bearing: CAMERA_BEARING,
        target: LatLng(
            destinationLocation.latitude, destinationLocation.longitude));
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
              tiltGesturesEnabled: true,
              markers: _markers,
              scrollGesturesEnabled: true,
              polylines: Set<Polyline>.of(_polylines.values),
              mapType: MapType.normal,
              initialCameraPosition: initialCameraPosition,
              onTap: (latLong) {
                _markers.removeWhere((m) => m.markerId.value == 'destPin');
                _markers.add(Marker(
                    markerId: MarkerId('destPin'),
                    position: latLong, // updated position
                    icon: destinationIcon));
                destinationLocation = LocationData.fromMap({
                  "latitude": latLong.latitude,
                  "longitude": latLong.longitude
                });
                setPolylines();
              },
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
