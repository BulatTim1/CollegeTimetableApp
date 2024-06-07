import 'package:cloud_firestore/cloud_firestore.dart';

class Timestamp {
  final String id;
  final List<String> days;
  final Map<String, Map<String, String>> times;

  const Timestamp({
    required this.id,
    required this.days,
    required this.times,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'days': days,
    'times': times,
  };

  factory Timestamp.fromDocumentSnapshot(DocumentSnapshot snapshot) => Timestamp(
    id: snapshot.id,
    days: List<String>.from(snapshot.get('days')),
    times: Map<String, Map<String, String>>.from(snapshot.get('times')),
  );
}