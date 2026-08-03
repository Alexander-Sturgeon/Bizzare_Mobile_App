import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bizzareapp/providers/loginstate_provider.dart';
import 'package:bizzareapp/core/app_colors.dart';
import 'package:bizzareapp/core/app_themes.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  LoginPageState createState() {
    return LoginPageState();
  }
}

class LoginPageState extends State<LoginPage> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loginState = Provider.of<LoginStateProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text("Welcome to Bizzare!"),),

      body: Container(
        padding: EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text("Enter username: "),
          TextField(controller: usernameController, decoration: InputDecoration(
            hintText: "Enter username",
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.person)
          ),
          onChanged: (value) => loginState.user.username = value,
          ),

          SizedBox(height: 20,),

          Text("Enter password: "),
          TextField(controller: passwordController, obscureText: true, decoration: InputDecoration(
            hintText: "Enter password",
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.password)
          ),
          onChanged: (value) => loginState.user.password = value,
          ),

          SizedBox(height: 10,),

          Consumer<LoginStateProvider>(
            builder: (context, loginState, child) {

              // Check if the user is logged in and there are no error messages
              if (loginState.user.errorMessage.isEmpty && loginState.user.isLoggedIn) {

                Future.microtask(() {
                  Navigator.pushNamed(context, '/listView');
                }); 
                return Container();
              } else {

                return loginState.user.errorMessage.isNotEmpty
                ? Text(loginState.user.errorMessage, style: TextStyle(color: AppColors.danger),)
                : Container(); 
              }
            }),

                      SizedBox(height: 20,),

          Center(
            child: ElevatedButton(
              onPressed: () {
                loginState.login(usernameController.text, passwordController.text); 
              },
              child: Text('Login',),       
              ),
          ),
        ],),
      ),
    );
  }
}










// import 'package:flutter/material.dart';

// class LoginPage extends StatefulWidget {
//   const LoginPage({super.key});
//   @override
//   LoginPageState createState() {
//     return LoginPageState();
//   }
// }

// class LoginPageState extends State<LoginPage> {
//   @override
//   void dispose() {}
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Login")),
//       body: Container(child: Text("Hello world")),
//     );
//   }
// }
