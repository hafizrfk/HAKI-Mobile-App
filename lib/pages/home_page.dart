import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:uasayam/pages/user_profile_page.dart';

class HomePage extends StatefulWidget {
  final Map<String, dynamic> userData;

  const HomePage({
    super.key,
    required this.userData,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Map<String, dynamic> sensorData = {
    'Mq2': 0,
    'dht': 0.0,
    'gas': 0,
    'humidity': 0.0,
  };
  Timer? _timer;
  final DatabaseReference _testRef =
      FirebaseDatabase.instance.ref().child('test');

  @override
  void initState() {
    super.initState();
    // Listen to real-time updates
    _testRef.onValue.listen((event) {
      if (event.snapshot.value != null) {
        setState(() {
          // Safely convert the data using cast
          final dynamic data = event.snapshot.value;
          if (data is Map) {
            sensorData = Map<String, dynamic>.from(data);
          } else {
            print('Invalid data format received from Firebase');
          }
        });
      }
    }, onError: (error) {
      print('Error listening to Firebase: $error');
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sensor Data'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UserProfilePage(
                    userData: widget.userData,
                  ),
                ),
              );
            },
          ),
          IconButton(
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/auth');
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome, ${widget.userData['nama']}!',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 24),
              Text(
                'Sensor Readings',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildSensorRow('MQ2 Sensor', '${sensorData['Mq2']}'),
                      const Divider(),
                      _buildSensorRow('Temperature', '${sensorData['dht']}°C'),
                      const Divider(),
                      _buildSensorRow('Gas Level', '${sensorData['gas']}'),
                      const Divider(),
                      _buildSensorRow(
                          'Humidity', '${sensorData['humidity']}%'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSensorRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
