import 'package:flutter/material.dart';
//CORE
import "./core/app_colors.dart";
import "./core/app_themes.dart";
//VIEWS
import 'package:bizzareapp/views/create_listing_page.dart';
import 'package:bizzareapp/views/details_page.dart';
import 'package:bizzareapp/views/list_view_page.dart';
import 'package:bizzareapp/views/login_page.dart';
import 'package:bizzareapp/views/profile_page.dart';
import 'package:bizzareapp/views/splash_screen.dart';
import 'package:bizzareapp/views/update_listing_page.dart';

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
        '/loginPage': (context) => LoginPage(),
        '/listView': (context) => ListViewPage(),
        '/detailsPage': (context) => DetailsPage(),
        '/profilePage': (context) => ProfilePage(),
        '/createListing': (context) => CreateListingPage(),
        '/updateListing': (context) => UpdateListingPage(),
      },
    );
  }
}
