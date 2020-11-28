import 'package:flutter/material.dart';
import 'package:driver/map.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:driver/constant.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage();
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController _endPositionLat = TextEditingController();
  TextEditingController _endPositionLong = TextEditingController();
  bool _validateLat = true;
  bool _validateLong = true;
  double toLat;
  double toLong;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Google Maps APP for Drivers")),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            "Option 1 - Use Lat and Long",
            style: TextStyle(fontSize: 24),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 150,
                child: TextField(
                  controller: _endPositionLat,
                  decoration: InputDecoration(
                    hintText: "Lat",
                    errorText:
                        !_validateLat ? 'Please enter double value' : null,
                  ),
                ),
              ),
              Container(
                width: 150,
                child: TextField(
                  controller: _endPositionLong,
                  decoration: InputDecoration(
                    hintText: "Long",
                    errorText:
                        !_validateLong ? 'Please enter double value' : null,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              InkWell(
                  onTap: () {
                    try {
                      toLat = double.parse(_endPositionLat.text);
                      _validateLat = true;
                    } catch (e) {
                      _validateLat = false;
                      print(e);
                    }
                    try {
                      toLong = double.parse(_endPositionLong.text);
                      _validateLong = true;
                    } catch (e) {
                      _validateLong = false;
                      print(e);
                    }
                    if (_validateLat && _validateLong) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => MapScreen(
                                    toLat: toLat,
                                    toLong: toLong,
                                  )));
                    }
                  },
                  child: Container(
                      decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: Colors.black, width: 1)),
                      width: 200,
                      height: 50,
                      child: Center(
                          child: Text("Show Map",
                              style: TextStyle(fontSize: 24))))),
            ],
          ),
          SizedBox(height: 50),
          Text(
            "Option 2 - Use auto suggest",
            style: TextStyle(fontSize: 24),
          ),
          SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              InkWell(
                  onTap: () async {
                    Prediction prediction = await PlacesAutocomplete.show(
                        context: context,
                        apiKey: k_googleAPIKey,
                        mode: Mode.overlay, // Mode.overlay
                        language: "en", // Hardcoded language Locale
                        components: [
                          Component(Component.country, "in")
                        ]); // Hardcoded India region for places filter

                    if (prediction != null) {
                      GoogleMapsPlaces _places = new GoogleMapsPlaces(
                          apiKey: k_googleAPIKey); //Same API_KEY as above
                      PlacesDetailsResponse detail =
                          await _places.getDetailsByPlaceId(prediction.placeId);
                      double toLat = detail.result.geometry.location.lat;
                      double toLong = detail.result.geometry.location.lng;

                      ///String address = prediction.description;

                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => MapScreen(
                                    toLat: toLat,
                                    toLong: toLong,
                                  )));
                    }
                  },
                  child: Container(
                      decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: Colors.black, width: 1)),
                      width: 200,
                      height: 50,
                      child: Center(
                          child: Text("Show Map",
                              style: TextStyle(fontSize: 24))))),
            ],
          ),
          SizedBox(height: 50),
          Text(
            "Note: You can also click on the map to change destination location",
            style: TextStyle(fontSize: 18),
          ),
        ]),
      ),
    );
  }
}
