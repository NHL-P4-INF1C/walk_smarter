import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'utils/pocketbase.dart';
import 'components/bottombar.dart';
import 'components/navbar.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;

var pb = PocketBaseSingleton().instance;

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  late GoogleMapController mapController;

  // ignore: unused_fields
  bool hasPopUp = false;
  bool isTimerActive = false;
  bool isListRefreshTimerIsActive = false;
  late Timer _timer;
  late Timer _refreshTimer;
  Marker? _currentLocationMarker;
  String closestPOIName = "";
  List<String> namesOfFoundPOI = [];

  final LatLng _center = const LatLng(52.778382, 6.913517);

  String mapStyle = '';
  @override
  void initState() {
    super.initState();
    rootBundle.loadString('assets/map_style.json').then((string) {
      setState(() {
        mapStyle = string;
      });
    });
    requestLocationPermission();
  }

  @override
  void dispose() {
    _timer.cancel();
    _refreshTimer.cancel();
    isTimerActive = false;
    isListRefreshTimerIsActive = false;
    super.dispose();
  }

  void stopTimers() {
    _timer.cancel();
    _refreshTimer.cancel();
    isTimerActive = false;
    isListRefreshTimerIsActive = false;
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    print('Map created and controller initialized');
    if (mapStyle.isNotEmpty) {
      // ignore: deprecated_member_use
      mapController.setMapStyle(mapStyle);
    }
    startLocationUpdates();
    startListRefreshTimer();
  }

  Future<String> fetchPoints() async {
    try {
      final response = await pb
          .collection('users')
          .getOne(pb.authStore.model['id'].toString());
      return response.data['points'].toString();
    } catch (error) {
      print('Error: $error');
      return 'Err';
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    handleSwitchCase(context, index);
  }

  void handleSwitchCase(BuildContext context, int index) {
    stopTimers();
    switch (index) {
      case 0:
        Navigator.pushNamed(context, '/homepage');
        return;
      case 1:
        Navigator.pushNamed(context, '/leaderboard');
        return;
      case 2:
        Navigator.pushNamed(context, '/friendspage',
            arguments: pb.authStore.model['id']);
      default:
        return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Navbar(),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            minMaxZoomPreference: MinMaxZoomPreference(15, 30),
            zoomControlsEnabled: false,
            initialCameraPosition: CameraPosition(
              target: _center,
              zoom: 11.0,
            ),
            markers:
                _currentLocationMarker != null ? {_currentLocationMarker!} : {},
          ),
          BottomNavBar(
            selectedIndex: _selectedIndex,
            onTap: _onItemTapped,
          ),
        ],
      ),
    );
  }

  Future<void> getPOIThroughHttp() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    String key = '&key=${dotenv.env['GOOGLE_API_KEY']}';
    String radius = '&radius=100';
    String location = '?location=${position.latitude}%2C${position.longitude}';
    String link =
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json';
    String request = link + location + radius + key;

    var response = await http.get(Uri.parse(request));
    var decodedResponse = json.decode(response.body);

    var closestPOI = decodedResponse['results'][0];
    double closestPOIDistance = 100.0;

    for (var test in decodedResponse['results']) {
      double lat = test['geometry']['location']['lat'] as double;
      double lng = test['geometry']['location']['lng'] as double;

      var distance = Geolocator.distanceBetween(
          position.latitude, position.longitude, lat, lng);

      if (distance < closestPOIDistance && !closestPOI['types'].contains('transit_station')) {
         print(closestPOI['types'].contains('transit_station'));

        closestPOI = test;
        closestPOIDistance = distance;
      }
    }

    closestPOIName = closestPOI['name'];

    if (closestPOIDistance < 50 &&
        !hasPopUp &&
        !namesOfFoundPOI.contains(closestPOIName)) {
      hasPopUp = true;
      _showQuestionDialog(
          context,
          'It appears that you are located near $closestPOIName. Click on OK to get some more knowledge about this location? If you wish to suppress this message for the location: $closestPOIName, then click outside of the pop up.',
          closestPOI);
    }

    print(
        'Distance to ${closestPOI['name']} (${closestPOI['types'][0]}): $closestPOIDistance meters');
  }

  void _showQuestionDialog(
      BuildContext context, String message, var closestPOI) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async {
            _onDialogDismissed();
            namesOfFoundPOI.add(closestPOIName);
            return true;
          },
          child: AlertDialog(
            title: Text('Point of interest found!'),
            content: Text(message),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  namesOfFoundPOI.add(closestPOIName);
                  Navigator.pushNamed(context, '/informationpage',
                      arguments: closestPOI);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _onDialogDismissed() {
    hasPopUp = false;
  }

  Future<void> requestLocationPermission() async {
    var status = await Permission.locationWhenInUse.status;
    if (status.isDenied) {
      if (await Permission.locationWhenInUse.request().isGranted) {
        fetchLocation();
      } else {
        print('Location permission denied');
      }
    } else {
      fetchLocation();
    }
  }

  void startLocationUpdates() {
    if (!isTimerActive) {
      isTimerActive = true;
      _timer = Timer.periodic(Duration(seconds: 5), (timer) {
        if (!hasPopUp) {
          print('pop up called');
          getPOIThroughHttp();
        }
      });
    }
  }

  void startListRefreshTimer() {
    if (!isListRefreshTimerIsActive) {
      isListRefreshTimerIsActive = true;
      _refreshTimer = Timer.periodic(Duration(seconds: 300), (timer) {
        cleanList();
        print('Cleaning called');
      });
    }
  }

  void cleanList() {
    namesOfFoundPOI.clear();
  }

  Future<void> fetchLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      LatLng currentLatLng = LatLng(position.latitude, position.longitude);
      mapController.animateCamera(CameraUpdate.newLatLng(currentLatLng));
      _currentLocationMarker = Marker(
        markerId: MarkerId('currentLocation'),
        position: currentLatLng,
      );
    });
    print('Location: ${position.latitude}, ${position.longitude}');
  }
}
