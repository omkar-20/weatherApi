import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:provider/provider.dart';
import 'package:weatherapi1/splash_screen.dart';
import 'package:weatherapi1/weather_provider.dart';

Future<void> main() async {
  //initialize hive
  await Hive.initFlutter();

  //open the box
  var box = await Hive.openBox('myList');
  runApp((const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => WeatherProvider(),
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: SplashScreen(),
      ),
    );
  }
}
