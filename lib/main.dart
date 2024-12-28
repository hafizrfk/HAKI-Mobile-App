import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'pages/auth_page.dart';
import 'pages/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Add Firebase configuration
  await Firebase.initializeApp(
    options: const FirebaseOptions(
        apiKey: "AIzaSyCc8j3inTtqukN_Sy4q_d3-48PEo1544ug",
        authDomain: "nyoba-2e635.firebaseapp.com",
        databaseURL:
            "https://nyoba-2e635-default-rtdb.asia-southeast1.firebasedatabase.app",
        projectId: "nyoba-2e635",
        storageBucket: "nyoba-2e635.firebasestorage.app",
        messagingSenderId: "1017142396221",
        appId: "1:1017142396221:web:f2fc622e1faefb6fd47154"),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Monitoring Kandang Ayam',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const AuthPage(),
      routes: {
        '/auth': (context) => const AuthPage(),
        '/home_page': (context) {
          final userData = ModalRoute.of(context)!.settings.arguments
              as Map<String, dynamic>;
          return HomePage(userData: userData);
        },
      },
    );
  }
}
