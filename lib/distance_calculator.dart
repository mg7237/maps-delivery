import 'package:latlong/latlong.dart';

class DistanceCalculator {
  double sourceLat;
  double sourceLong;
  double destLat;
  double destLong;

  DistanceCalculator(
      {this.sourceLat, this.sourceLong, this.destLat, this.destLong});

  double calcDistance() {
    final Distance distance = new Distance();

    // meter = 422591.551
    final double meter = distance(
        new LatLng(sourceLat, sourceLong), new LatLng(destLat, destLong));
    return meter;
  }
}
