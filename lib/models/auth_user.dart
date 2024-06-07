import 'package:firebase_auth/firebase_auth.dart';

class AuthUser {
  final String uid;
  final String email;
  final String? displayName;

  const AuthUser({
    required this.uid,
    required this.email,
    this.displayName,
  });

  Map<String, dynamic> toMap() => {
    'uid': uid,
    'email': email,
    'displayName': displayName,
  };

  factory AuthUser.fromUserCredentials(UserCredential userCredential) => AuthUser(
    uid: userCredential.user!.uid,
    email: userCredential.user!.email!,
    displayName: userCredential.user!.displayName,
  );
}