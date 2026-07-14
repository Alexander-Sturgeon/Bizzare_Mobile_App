import 'dart:async';
import 'package:flutter/material.dart';
import '../core/app_colors.dart';

//DURATIOn 2-3 reccomended 4-5 max (based on app store)

//Must have a state for animation
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  //Adding a animation to the icon on the splash screen
  late AnimationController controller;
  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    Timer(Duration(seconds: 3), () {
      Navigator.pushNamed(context, '/loginPage');
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: AnimatedBuilder(
          animation: controller,
          builder: (context, child) {
            return Transform.rotate(
              angle: controller.value * 2 * 3.1416, //Full rotation is the math
              child: child,
            );
          },
          //Placeholder imagename
          child: Image.asset('assets/images/WSD.png', width: 150),
        ),
      ),
    );
  }
}
