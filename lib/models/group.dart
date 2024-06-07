import 'package:cloud_firestore/cloud_firestore.dart';

class Group {
  final String id;
  final String group;
  final int? enrollmentYear;
  final int? issueYear;

  const Group({
    required this.id,
    required this.group,
    this.enrollmentYear,
    this.issueYear,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'group': group,
    'enrollmentYear': enrollmentYear,
    'issueYear': issueYear,
  };

  factory Group.fromDocumentSnapshot(DocumentSnapshot snapshot) => Group(
    id: snapshot.id,
    group: snapshot.get('group'),
    enrollmentYear: snapshot.get('enrollmentYear'),
    issueYear: snapshot.get('issueYear'),
  );
}