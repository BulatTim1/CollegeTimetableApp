import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String uid;
  final List<String> devices;
  final String? fullname;
  final Map<String, dynamic>? params;
  final String role;

  const User({
    required this.uid,
    required this.role,
    this.fullname,
    this.params,
    this.devices = const [],
  });

  Map<String, dynamic> toMap() => {
    'uid': uid,
    'role': role,
    'fullname': fullname,
    'params': params,
    'devices': devices,
  };

  factory User.fromDocumentSnapshot(DocumentSnapshot snapshot) => User(
    uid: snapshot.id,
    role: snapshot.get('role'),
    fullname: snapshot.get('fullname'),
    params: snapshot.get('params'),
    devices: List<String>.from(snapshot.get('devices')),
  );
}