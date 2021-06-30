import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skype/provider/image_upload_provider.dart';
import 'package:skype/provider/user_provider.dart';
import 'package:skype/resources/auth_methods.dart';
import 'package:skype/screens/search_screen.dart';
import 'package:skype/screens/home_screen.dart';
import 'package:skype/screens/login_screen.dart';

Future<void> main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      // Initialize FlutterFire:
      future: Firebase.initializeApp(),
      builder: (context, snapshot) {
        // Check for errors
        if (snapshot.hasError) {
          return CircularProgressIndicator();
        }

        // Once complete, show your application
        if (snapshot.connectionState == ConnectionState.done) {
          AuthMethods _authMethods = AuthMethods();
          return MultiProvider(
            providers: [
              ChangeNotifierProvider(create: (_) => ImageUploadProvider()),
              ChangeNotifierProvider(create: (_) => UserProvider()),
            ],
            child: MaterialApp(
              title: "Skype Clone",
              debugShowCheckedModeBanner: false,
              initialRoute: "/",
              routes: {
                '/search_screen': (context) => SearchScreen(),
              },
              theme: ThemeData(
                brightness: Brightness.dark,
              ),
              home: _authMethods.getCurrentUser() != null
                  ? HomeScreen()
                  : LoginScreen(),
            ),
          );
        }

        // Otherwise, show something whilst waiting for initialization to complete
        return CircularProgressIndicator();
      },
    );
  }
}
