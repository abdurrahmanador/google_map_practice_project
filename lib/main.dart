import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
//22.851013, 89.532363
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home:HomeScreen()
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  GoogleMapController? _googleMapController;
  final Location _location=Location();
  LatLng _currentLocation=LatLng(0, 0);
  LatLng? _prevLocationn;
  final List<LatLng> _polyLineCoordinates=[];
  final Set<Polyline> _polyLines= {};
  Marker? marker;

  @override
  void initState() {
    super.initState();
    _initMap();
    _startLocationUpdate();
  }
  Future<void> _initMap()async{
    final locationData=await _location.getLocation();
    setState(() {
      _currentLocation=LatLng(locationData.latitude!,locationData.longitude!);
      _googleMapController?.animateCamera(CameraUpdate.newLatLng(_currentLocation));
      marker=Marker(markerId: MarkerId('CurrentLocation'),
      position: _currentLocation);
    });
  }

  void _startLocationUpdate(){
    Timer.periodic(Duration(seconds: 10),(timer)async{
      final locationData=await _location.getLocation();
      setState(() {
        _prevLocationn=_currentLocation;
        _currentLocation=LatLng(locationData.latitude!,locationData.longitude!);
        _updateMap();
      });
    });
  }

  void _updateMap(){
    setState(() {
      marker=Marker(markerId: MarkerId("CurrentLocation"),position: _currentLocation,
      infoWindow: InfoWindow(
        title: 'My Current Location',
        snippet: '${_currentLocation.latitude},${_currentLocation.longitude}'
      ));
      if(_prevLocationn?.latitude!=0.0){
        _polyLineCoordinates.add(_prevLocationn!);
      }
      _polyLineCoordinates.add(_currentLocation);
      if(_prevLocationn?.latitude!=0.0 && _currentLocation?.latitude!=0.0){
        _polyLines.add(
          Polyline(polylineId: PolylineId('polyline'),color: Colors.orange,
          points: _polyLineCoordinates)
        );
      }

    });
    _googleMapController?.animateCamera(CameraUpdate.newLatLng(_currentLocation));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Google Map"),
      ),
      body: GoogleMap(
        compassEnabled: true,
        onMapCreated: (controller){
          _googleMapController=controller;
        },
        initialCameraPosition: CameraPosition(
          target: _currentLocation,
          zoom: 17,
          tilt: 10,
        ),
        markers: marker!=null?<Marker>{marker!}:<Marker>{},
        polylines: _polyLines,
      ),
    );
  }
}

