import 'package:flutter/material.dart';
//CORE
import "./core/app_colors.dart";
import "./core/app_themes.dart";
//VIEWS
import "/views/splash_screen.dart";
// import '/views/login_page.dart';

//Main Entry
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TaskPro',
      theme: AppTheme.lightTheme,
      // home: SplashScreen(), using named routes instead.
      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreen(),
        // '/loginPage': (context) => LoginPage(),
      },
    );
  }
}
