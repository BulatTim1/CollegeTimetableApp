import 'package:cloud_firestore/cloud_firestore.dart';

class Subject {
  final String id;
  final String name;

  const Subject({
    required this.id,
    required this.name,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
  };

  factory Subject.fromDocumentSnapshot(DocumentSnapshot snapshot) => Subject(
    id: snapshot.id,
    name: snapshot.get('name'),
  );
}