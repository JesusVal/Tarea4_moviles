import 'package:address_search_field/address_search_field.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomeMap extends StatefulWidget {
  const HomeMap({Key key}) : super(key: key);

  @override
  _HomeMapState createState() => _HomeMapState();
}

class _HomeMapState extends State<HomeMap> {
  Set<Marker> _mapMarkers = Set();
  GoogleMapController _mapController;
  TextEditingController _searchAdreessController = TextEditingController();
  Position _currentPosition;
  Position _defaultPosition = Position(
    longitude: 20.608148,
    latitude: -103.417576,
  );

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      // future: _getCurrentPosition(),
      builder: (context, result) {
        if (result.error == null) {
          if (_currentPosition == null) _currentPosition = _defaultPosition;
          return Scaffold(
            body: Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: LatLng(
                      _currentPosition.latitude,
                      _currentPosition.longitude,
                    ),
                  ),
                  onMapCreated: _onMapCreated,
                  markers: _mapMarkers,
                  onLongPress: _setMarker,
                ),
                Positioned(
                  bottom: 30,
                  left: 10,
                  // right: 10,
                  child: FloatingActionButton(
                    onPressed: () {
                      _getCurrentPosition();
                    },
                    child: Icon(
                      Icons.my_location,
                      color: Colors.blue,
                    ),
                    backgroundColor: Colors.white,
                  ),
                ),
                Positioned(
                  top: 60,
                  left: 10,
                  right: 10,
                  child: AddressSearchField(
                    country: 'México',
                    city: "Guadalajara",
                    hintText: "Address",
                    noResultsText: "No hay resultados.",
                    onDone:
                        (BuildContext dialogContext, AddressPoint point) async {
                      if (point.found) {
                        _searchAddress(LatLng(point.latitude, point.longitude));
                        Navigator.of(context).pop();
                        print('founded');
                        print(point.latitude);
                        print(point.longitude);
                      }
                    },
                  ),
                ),
              ],
            ),
          );
        } else {
          Scaffold(
            body: Center(
              child: Text("Se ha producido un error"),
            ),
          );
        }
        return Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }

  void _onMapCreated(controller) {
    setState(() {
      _mapController = controller;
    });
  }

  void _setMarker(LatLng coord) async {
    // get address
    String _markerAddress = await _getGeocodingAddress(
      Position(
        latitude: coord.latitude,
        longitude: coord.longitude,
      ),
    );

    // add marker
    setState(() {
      _mapMarkers.add(
        Marker(
          markerId: MarkerId(coord.toString()),
          position: coord,
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
          infoWindow: InfoWindow(
            title: coord.toString(),
            // snippet: _markerAddress,
          ),
        ),
      );
    });
  }

  Future<void> _getCurrentPosition() async {
    // verify permissions
    /*LocationPermission permission = await checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await requestPermission();
    }*/

    // get current position
    _currentPosition = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    // get address
    String _currentAddress = await _getGeocodingAddress(_currentPosition);

    // add marker
    setState(() {
      _mapMarkers.add(
        Marker(
          markerId: MarkerId(_currentPosition.toString()),
          position:
              LatLng(_currentPosition.latitude, _currentPosition.longitude),
          infoWindow: InfoWindow(
            title: _currentPosition.toString(),
            snippet: _currentAddress,
          ),
        ),
      );
    });
    // move camera
    _mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(
            _currentPosition.latitude,
            _currentPosition.longitude,
          ),
          zoom: 15.0,
        ),
      ),
    );
  }

  Future<String> _getGeocodingAddress(Position position) async {
    var places = await Geolocator()
        .placemarkFromCoordinates(position.latitude, position.longitude);
    if (places != null && places.isNotEmpty) {
      final Placemark place = places.first;
      return "${place.thoroughfare}, ${place.locality}";
    }
    return "No address available";
  }

  Future<void> _searchAddress(LatLng address) async {
    try {
      _mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(
              address.latitude,
              address.longitude,
            ),
            zoom: 15.0,
          ),
        ),
      );

      setState(() {
        _mapMarkers.add(
          Marker(
            markerId: MarkerId(address.toString()),
            position: address,
            infoWindow: InfoWindow(
              title: _currentPosition.toString(),
              snippet: address.toString(),
            ),
          ),
        );
      });
    } catch (e) {
      print(e);
    }
  }
}
