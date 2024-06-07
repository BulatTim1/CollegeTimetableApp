import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'timetable_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String? _selectedGroupUid;
  String? _selectedTeacherUid;

  List<Map<String, dynamic>> _groupList = [];

  List<Map<String, dynamic>> _teacherList = [];

  @override
  void initState() {
    super.initState();
    _fetchGroups();
    _fetchTeachers();
  }

  Widget _buildGroupList() {
    return ListView.builder(
      itemCount: _groupList.length,
      itemBuilder: (context, index) {
        final group = _groupList[index];
        return Card(
            child: ListTile(
          title: Text(group['group']),
          onTap: () {
            setState(() {
              _selectedTeacherUid = null;
              _selectedGroupUid = group['uid'];
            });
          },
        ));
      },
    );
  }

  Widget _buildTeacherList() {
    return ListView.builder(
      itemCount: _teacherList.length,
      itemBuilder: (context, index) {
        final teacher = _teacherList[index];
        return Card(
            child: ListTile(
          title: Text(teacher['fullname']),
          onTap: () {
            setState(() {
              _selectedGroupUid = null;
              _selectedTeacherUid = teacher['uid'];
            });
          },
        ));
      },
    );
  }

  Widget _buildSelectedTimetable() {
    if (_selectedGroupUid != null) {
      // Fetch and display timetable for the selected group
      return TimetableScreen(selectedGroupUid: _selectedGroupUid!);
    } else if (_selectedTeacherUid != null) {
      // Fetch and display timetable for the selected teacher
      return TimetableScreen(selectedTeacherUid: _selectedTeacherUid!);
    } else {
      return const Text('Please select a group or teacher');
    }
  }

  Future<void> _fetchGroups() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('groups').get();
    List<Map<String, dynamic>> groups = [];
    for (final doc in snapshot.docs) {
      final data = doc.data();
      final group = {
        'uid': doc.id,
        'group': data['group'],
      };
      groups.add(group);
    }
    setState(() {
      _groupList = groups;
    });
  }

  Future<void> _fetchTeachers() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where("role", isEqualTo: "teacher")
        .get();
    List<Map<String, dynamic>> users = [];
    for (final doc in snapshot.docs) {
      final data = doc.data();
      final user = {
        'uid': doc.id,
        'fullname': data['fullname'],
      };
      users.add(user);
    }
    setState(() {
      _teacherList = users;
    });
  }

  Future<bool> onBackClick() async {
    if (_selectedGroupUid != null || _selectedTeacherUid != null) {
      setState(() {
        _selectedGroupUid = null;
        _selectedTeacherUid = null;
      });
      return false;
    } else {
      try {
        Navigator.of(context).pop();
      } catch (e) {
        print(e);
      }
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) async {
        onBackClick();
      },
        child: Scaffold(
      appBar: AppBar(
        title: const Text('Поиск расписания'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (_selectedGroupUid == null && _selectedTeacherUid == null) ...[
              const Text('Выберите группу:'),
              Expanded(
                  child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: const Color.fromARGB(32, 0, 0, 0)),
                child: _buildGroupList(),
              )),
              const Text('Или выберите преподавателя:'),
              Expanded(
                  child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: const Color.fromARGB(32, 0, 0, 0)),
                child: _buildTeacherList(),
              )),
            ],
            if (_selectedGroupUid != null || _selectedTeacherUid != null) ...[
              Expanded(child: _buildSelectedTimetable()),
            ],
          ],
        ),
      ),
    ));
  }
}
