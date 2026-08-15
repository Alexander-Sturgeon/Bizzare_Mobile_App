import 'package:flutter/material.dart';
//CORE
import "./core/app_themes.dart";
//VIEWS
import 'package:bizzareapp/views/create_listing_page.dart';
import 'package:bizzareapp/views/details_page.dart';
import 'package:bizzareapp/views/list_view_page.dart';
import 'package:bizzareapp/views/login_page.dart';
import 'package:bizzareapp/views/splash_screen.dart';
import 'package:bizzareapp/views/update_listing_page.dart';
//PROVIDER
import 'package:provider/provider.dart';
import 'package:bizzareapp/providers/loginstate_provider.dart';

//Main Entry
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => LoginStateProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Bizzare',
        theme: AppTheme.lightTheme, // use the global theme
        // home: SplashScreen(),
        initialRoute: '/',
        routes: {
          '/': (context) => SplashScreen(),
          '/loginPage': (context) => LoginPage(),
          '/listView': (context) => ListViewPage(),
          '/detailsPage': (context) => DetailsPage(),
          '/createListing': (context) => CreateListingPage(),
          '/updateListing': (context) => UpdateListingPage(),
        },
      ),
    );
  }
}
