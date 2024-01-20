import 'package:flutter/material.dart';
import 'package:smart_parking_app/widgets/login.dart';
import 'package:smart_parking_app/widgets/searchPark.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        useMaterial3: true,
        primaryColor: Color.fromARGB(255, 141, 255, 160),
        primaryColorDark: Color.fromARGB(255, 141, 255, 160),
        
      ),
      routes: {
        '/login' :(context) => Login(),
        '/allPark' :(context) => SearchPark(),//
      },
      initialRoute: '/login',
    );
  }
}


