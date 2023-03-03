import 'dart:async';
import 'dart:developer';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:provider/provider.dart';
import 'package:weatherapi1/database/data.dart';
import 'package:weatherapi1/records/list_of_records.dart';
import 'package:weatherapi1/weather_provider.dart';
import 'package:hive/hive.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _controller = TextEditingController();
  late StreamSubscription subscription;
  var isDeviceConnected = false;
  bool isAlertSet = false;

  final _myBox = Hive.box('myList');
  RecordData data = RecordData();

  @override
  void initState() {
    getConnectivity();
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Provider.of<WeatherProvider>(context, listen: false).getCurrent('Pune');
    });
    if (_myBox.get('locList') == null) {
      data.initialList();
    } else {
      data.readData();
    }
  }

  getConnectivity() {
    subscription = Connectivity().onConnectivityChanged.listen(
      (ConnectivityResult result) async {
        isDeviceConnected = await InternetConnectionChecker().hasConnection;
        if (!isDeviceConnected && isAlertSet == false) {
          showDialogBox();
          setState(() {
            isAlertSet = true;
          });
        }
      },
    );
  }

  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
  }

  searchCity(String city) {
    Provider.of<WeatherProvider>(context, listen: false).getCurrent(city);
  }

  // addRecord(String item){
  //   Provider.of<WeatherProvider>(context, listen: false).addItem();
  // }
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/daylight.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Consumer<WeatherProvider>(
          builder: (context, value, child) {
            return Column(
              // mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  children: [
                    IconButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const ListOfRecords()));
                        },
                        icon: const Icon(Icons.add_box_outlined)),
                  ],
                ),
                Flexible(
                  child: Text(
                    value.getData.weather?.location.name ?? " ",
                    style: const TextStyle(
                        fontSize: 40, fontWeight: FontWeight.w400),
                  ),
                ),
                const SizedBox(height: 15),
                Text(value.getData.weather?.current.weatherDescriptions[0] ??
                    ""),
                if (value.isLoading)
                  const Center(child: CircularProgressIndicator())
                else if (value.getData.weather != null)
                  Center(
                      child: Text(
                    "${value.getData.weather?.current.temperature ?? " "}°",
                    style: const TextStyle(
                        fontSize: 70, fontWeight: FontWeight.bold),
                  ))
                else
                  const Text('error'),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 50, horizontal: 10),
                  child: TextField(
                    controller: _controller,
                    onSubmitted: (val) async {
                      searchCity(val);
                      data.list.add(value.getData.weather?.location.name ?? "");
                      data.writeData();

                      _controller.clear();
                    },
                    decoration: InputDecoration(
                      hintText: 'Enter city name',
                      focusedBorder: OutlineInputBorder(
                        borderSide:
                            const BorderSide(color: Colors.black, width: 1.0),
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide:
                            const BorderSide(color: Colors.black, width: 1.0),
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 50),
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                ElevatedButton(
                    onPressed: () async {
                      await Geolocator.requestPermission();
                      var position = await Geolocator.getCurrentPosition(
                              desiredAccuracy: LocationAccuracy.best)
                          .timeout(const Duration(seconds: 5));
                      String cityName = await getCityName(
                          position.latitude, position.longitude);
                      searchCity(cityName);
                    },
                    child: const Text('Get current location'))
              ],
            );
          },
        ),
      )),
    );
  }

  showDialogBox() => showCupertinoDialog<String>(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
              title: const Text('No Connection'),
              content: const Text('Please check your internet connection'),
              actions: <Widget>[
                TextButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    setState(() {
                      isAlertSet = false;
                    });
                    isDeviceConnected =
                        await InternetConnectionChecker().hasConnection;
                    if (!isDeviceConnected) {
                      showDialogBox();
                      setState(() {
                        isAlertSet = true;
                      });
                    }
                  },
                  child: const Text('OK'),
                )
              ]));

  Future<String> getCityName(double lat, double lng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
      Placemark placemark = placemarks[0];
      String cityName = placemark.locality!;
      return cityName;
    } catch (e) {
      log(e.toString());
    }
    return "";
  }
}
