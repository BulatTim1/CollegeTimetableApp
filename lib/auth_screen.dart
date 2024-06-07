import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'timetable_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _error = "";

  @override
  void initState() {
    super.initState();
    Firebase.initializeApp();
    _auth.setLanguageCode("ru");
  }

  Future<void> _signInWithEmailAndPassword() async {
    try {
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      
      // Get the current user
      final User? user = userCredential.user;

      final messaging = FirebaseMessaging.instance;

      final settings = await messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      print('Permission granted: ${settings.authorizationStatus}');

      // Save device notification ID to Firestore
      String? deviceNotificationId = await messaging.getToken();
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set({
          'devices': FieldValue.arrayUnion([deviceNotificationId])
        }, SetOptions(merge: true));
        if (!context.mounted) return;
        Navigator.pushAndRemoveUntil(
          context, 
          MaterialPageRoute(builder: (context) => const TimetableScreen()),
          (_) => false);
      }
      
      // Do something after successful sign-in
      // e.g., navigate to a different screen
    } catch (e) {
      // Handle sign-in errors
      if (kDebugMode) {
        print(e.toString());
      }
      setState(() {
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Вход'),
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Почта',
              ),
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Пароль',
              ),
              obscureText: true,
            ),
            if (_error != "") ...[const SizedBox(height: 16.0), Text(_error.split("] ")[1], style: const TextStyle(color: Colors.red),)],
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _signInWithEmailAndPassword,
              child: const Text('Войти'),
            ),
            // TextButton(
            //   onPressed: () {
            //     // Implement forgot password logic
            //   },
            //   child: const Text('Забыли пароль?'),
            // ),
          ],
        ),
      ),
    );
  }
}

// void main() {
//   runApp(MaterialApp(
//     home: AuthScreen(),
//   ));
// }
