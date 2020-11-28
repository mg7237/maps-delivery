import 'package:flutter/material.dart';
import 'package:driver/map.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage();
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController _startPositionLat = TextEditingController();
  TextEditingController _startPositionLong = TextEditingController();
  TextEditingController _endPositionLat = TextEditingController();
  TextEditingController _endPositionLong = TextEditingController();
  bool _useCurrentLocation = false;

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
          SizedBox(height: 70),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              InkWell(
                  onTap: () {
                    double fromLat;
                    double fromLong;
                    try {
                      // if (!_useCurrentLocation) {
                      //   fromLat = double.parse(_startPositionLat.text);
                      //   fromLong = double.parse(_startPositionLong.text);
                      // } else {
                      //   fromLat = 0.0;
                      //   fromLong = 0.0;
                      // }
                      double toLat =
                          12.96006; //double.parse(_endPositionLat.text);
                      double toLong =
                          77.75122; // double.parse(_endPositionLong.text);
                      // if (_useCurrentLocation && (toLat == 0 || toLong == 0)) {
                      //   AlertDialog(
                      //       title: Text(
                      //           "Please ensure to lat and to long values are non zero values"));
                      // } else if (toLat == 0 ||
                      //     toLong == 0 ||
                      //     fromLat == 0 ||
                      //     fromLong == 0) {
                      //   AlertDialog(
                      //       title: Text(
                      //           "Please ensure lat and long values are non zero values"));
                      // }
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => MapScreen(
                                    toLat: toLat,
                                    toLong: toLong,
                                  )));
                    } catch (e) {
                      AlertDialog(
                          title: Text(
                              "Please ensure lat, long values are double"));
                      print(e);
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
          )
        ]),
      ),
    );
  }
}
