import 'package:college_timetable/auth_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'search_screen.dart';

class TimetableScreen extends StatefulWidget {
  final String? selectedGroupUid;
  final String? selectedTeacherUid;
  const TimetableScreen(
      {super.key, this.selectedGroupUid, this.selectedTeacherUid});

  @override
  createState() => _TimetableScreenState();
}

Map<String, String> _daysOfWeekRus = {
  'monday': 'Понедельник',
  'tuesday': 'Вторник',
  'wednesday': 'Среда',
  'thursday': 'Четверг',
  'friday': 'Пятница',
  'saturday': 'Суббота',
  'sunday': 'Воскресенье',
};

class _TimetableScreenState extends State<TimetableScreen> {
  String? _role;
  String? _currentDayOfWeek;
  DateTime _currentDay = DateTime.now();
  Map<String, dynamic>? _timetable;
  bool _isHoliday = false;
  Stream<DocumentSnapshot> _snapshot = const Stream.empty();

  @override
  void initState() {
    super.initState();
    _currentDayOfWeek = _getDayOfWeekKey(DateTime.now().weekday);
    if (widget.selectedGroupUid != null) {
      _role = "student";
      _fetchSelectedGroupTimetable(widget.selectedGroupUid!);
      // _snapshot = FirebaseFirestore.instance
      //   .collection('timetable_groups')
      //   .doc(widget.selectedGroupUid!)
      //   .get() as Stream<DocumentSnapshot<Object?>>;
    } else if (widget.selectedTeacherUid != null) {
      _role = "teacher";
      _fetchSelectedTeacherTimetable(widget.selectedTeacherUid!);
      // _snapshot = FirebaseFirestore.instance
      //   .collection('timetable_teachers')
      //   .doc(widget.selectedTeacherUid!)
      //   .get() as Stream<DocumentSnapshot<Object?>>;
    } else {
      _fetchUserRole();
    }
  }

  Future<void> _fetchUserRole() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final Map<String, dynamic>? userData =
          userSnapshot.data() as Map<String, dynamic>?;
      if (userData != null && userData.containsKey('role')) {
        Map<String, dynamic>? timetable;
        if (userData['role'] == 'student') {
          timetable = await _fetchStudentTimetable(userData);
        } else if (userData['role'] == 'teacher') {
          timetable = await _fetchTeacherTimetable(userData, user.uid);
        }
        setState(() {
          _role = userData['role'];
          _timetable = timetable;
        });
      }
    }
  }

  Future<Map<String, dynamic>> _fetchStudentTimetable(
      Map<String, dynamic> userData) async {
    final String groupUid = userData['params']['group'].id;
    final DocumentSnapshot snap = await FirebaseFirestore.instance
        .collection('timetable_groups')
        .doc(groupUid)
        .get();
    final timetable = snap.data() as Map<String, dynamic>?;
    if (timetable != null) {
      return await _fetchTimetableDetails(timetable);
    }
    return {};
  }

  Future<void> _fetchSelectedGroupTimetable(String groupUid) async {
    final DocumentSnapshot snap = await FirebaseFirestore.instance
        .collection('timetable_groups')
        .doc(groupUid)
        .get();
    var timetable = snap.data() as Map<String, dynamic>?;
    if (timetable != null) {
      timetable = await _fetchTimetableDetails(timetable);
      setState(() {
        _timetable = timetable;
      });
    }
  }

  Future<Map<String, dynamic>> _fetchTeacherTimetable(
      Map<String, dynamic> userData, String uid) async {
    final DocumentSnapshot snap = await FirebaseFirestore.instance
        .collection('timetable_teachers')
        .doc(uid)
        .get();
    final timetable = snap.data() as Map<String, dynamic>?;
    if (timetable != null) {
      return await _fetchTimetableDetails(timetable);
    }
    return {};
  }

  Future<void> _fetchSelectedTeacherTimetable(String teacherUid) async {
    final DocumentSnapshot snap = await FirebaseFirestore.instance
        .collection('timetable_teachers')
        .doc(teacherUid)
        .get();
    var timetable = snap.data() as Map<String, dynamic>?;
    if (timetable != null) {
      timetable = await _fetchTimetableDetails(timetable);
      setState(() {
        _timetable = timetable;
      });
    }
  }

  String _getDayOfWeekKey(int dayOfWeek) {
    switch (dayOfWeek) {
      case DateTime.monday:
        return 'monday';
      case DateTime.tuesday:
        return 'tuesday';
      case DateTime.wednesday:
        return 'wednesday';
      case DateTime.thursday:
        return 'thursday';
      case DateTime.friday:
        return 'friday';
      case DateTime.saturday:
        return 'saturday';
      case DateTime.sunday:
        return 'sunday';
      default:
        return '';
    }
  }

  String _getCurrentTimestamp(DateTime date) {
    final String day = date.day.toString().padLeft(2, '0');
    final String month = date.month.toString().padLeft(2, '0');
    return '$day.$month';
  }

  Future<Map<String, dynamic>> _fetchTimetableDetails(
      Map<String, dynamic> timetable) async {
    final String currentTimestamp = _getCurrentTimestamp(_currentDay);

    for (final dayOfWeek in timetable['dayOfWeek'].keys) {
      if (dayOfWeek == _currentDayOfWeek) {
        final lessons = timetable['dayOfWeek'][dayOfWeek];
        for (final lesson in lessons.keys) {
          final lessonData = lessons[lesson];
          final subjectRef = lessonData['subject'];
          final groupRef = lessonData['group'];
          final teacherRef = lessonData['teacher'];

          if (subjectRef != null) {
            try {
              lessonData['subject'] =
                  (await subjectRef.get()).data() as Map<String, dynamic>?;
            } catch (e) {}
          }

          if (groupRef != null) {
            try {
              lessonData['group'] =
                  (await groupRef.get()).data() as Map<String, dynamic>?;
            } catch (e) {}
          }

          if (teacherRef != null) {
            try {
              lessonData['teacher'] =
                  (await teacherRef.get()).data() as Map<String, dynamic>?;
            } catch (e) {}
          }
        }
      }
    }
    try {
      final DocumentSnapshot holidaySnapshot = await FirebaseFirestore.instance
          .collection('holidays')
          .doc(_currentDay.year.toString())
          .get();
    } catch (e) {}

    final Map<String, dynamic>? holidayData =
        holidaySnapshot.data() as Map<String, dynamic>?;

    setState(() {
      _isHoliday = false;
    });
    if (holidayData != null && holidayData.containsKey('holidays')) {
      final List<String> holidayList =
          List<String>.from(holidayData['holidays']);
      if (holidayList.contains(currentTimestamp)) {
        setState(() {
          _isHoliday = true;
        });
      }
    }
    var isShortDay = false;
    if (holidayData != null && holidayData.containsKey('shortdays')) {
      final List<String> shortdaysList =
          List<String>.from(holidayData['shortdays']);
      if (shortdaysList.contains(currentTimestamp)) {
        isShortDay = true;
      }
    }
    final QuerySnapshot timestampSnapshot = await FirebaseFirestore.instance
        .collection('timestamps')
        .where("days",
            arrayContains: isShortDay ? "shortday" : _currentDayOfWeek)
        .get();
    final List<DocumentSnapshot> timestampDocs = timestampSnapshot.docs;
    for (final doc in timestampDocs) {
      final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      if (timetable['dayOfWeek'].keys.contains(_currentDayOfWeek)) {
        for (final lesson in timetable['dayOfWeek'][_currentDayOfWeek].keys) {
          timetable['dayOfWeek'][_currentDayOfWeek][lesson]['startTime'] =
              data['times'][lesson]['starttime'];
          timetable['dayOfWeek'][_currentDayOfWeek][lesson]['endTime'] =
              data['times'][lesson]['endtime'];
        }
        break;
      }
    }
    return timetable;
  }

  Future<void> _goToNextDay() async {
    setState(() {
      _currentDay = _currentDay.add(const Duration(days: 1));
      if (_currentDay.weekday == 7) {
        _currentDay = _currentDay.add(const Duration(days: 1));
      }
      _currentDayOfWeek = _getDayOfWeekKey(_currentDay.weekday);
    });
    final timetable = await _fetchTimetableDetails(_timetable!);
    setState(() {
      _timetable = timetable;
    });
  }

  Future<void> _goToPreviousDay() async {
    setState(() {
      _currentDay = _currentDay.subtract(const Duration(days: 1));
      if (_currentDay.weekday == 7) {
        _currentDay = _currentDay.subtract(const Duration(days: 1));
      }
      _currentDayOfWeek = _getDayOfWeekKey(_currentDay.weekday);
    });
    final timetable = await _fetchTimetableDetails(_timetable!);
    setState(() {
      _timetable = timetable;
    });
  }
  Widget _buildTimetable() {
    Widget buildDayTimetable(String day) {
      if (_timetable?['dayOfWeek'].containsKey(day) && !_isHoliday) {
        return Column(
          children: [
            for (final lesson in _timetable?['dayOfWeek'][day].keys) ...[
              if (_timetable?['dayOfWeek'][day][lesson]
                  .keys
                  .contains('startTime'))
                Container(
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), 
                  color: (int.parse(lesson) % 2 == 1) ? Theme.of(context).scaffoldBackgroundColor: const Color.fromARGB(32, 0, 0, 0)),
                  child: Row(children: [Expanded(
                      child: Column(children: [
                    Text(
                        "$lesson. ${_timetable?['dayOfWeek'][day][lesson]['startTime']} - ${_timetable?['dayOfWeek'][day][lesson]['endTime']}",
                        style: const TextStyle(fontSize: 24)),
                    Row(children: [
                      Expanded(
                          child: Column(children: [
                        Text(
                            (!_timetable!['dayOfWeek'][day][lesson]['subject'].toString().contains("Document")) ? _timetable!['dayOfWeek'][day][lesson]['subject']
                                ['name']: "",
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 18)),
                        Text(
                            "Аудитория: ${_timetable?['dayOfWeek'][day][lesson]['auditory']}",
                            textAlign: TextAlign.center),
                        Text(
                            (_role == "teacher" &&
                                    _timetable!['dayOfWeek'][day][lesson]
                                            ['group'] !=
                                        null &&
                                    !_timetable!['dayOfWeek'][day][lesson]
                                            ['group'].toString().contains("Document"))
                                ? "Группа: ${_timetable!['dayOfWeek'][day][lesson]['group']['group']}"
                                : (_role == "student" &&
                                        _timetable!['dayOfWeek'][day][lesson]
                                                ['teacher'] !=
                                            null &&
                                    !_timetable!['dayOfWeek'][day][lesson]
                                            ['teacher'].toString().contains("Document"))
                                    ? "Преподаватель: ${_timetable!['dayOfWeek'][day][lesson]['teacher']['fullname']}"
                                    : "",
                            textAlign: TextAlign.center),
                        const Padding(padding: EdgeInsets.only(bottom: 10))
                      ])),
                    ])
                  ]))]),
                ),
            ],
          ],
        );
      } else {
        return const Text('Расписания нет');
      }
    }

    void presentDatePicker() {
      showDatePicker(
        context: context,
        initialDate: _currentDay,
        firstDate: DateTime(2020),
        lastDate: DateTime(2026),
        locale: const Locale('ru', 'RU'),
      ).then((pickedDate) {
        if (pickedDate != null) {
          setState(() {
            _currentDay = pickedDate;
            _currentDayOfWeek = _getDayOfWeekKey(pickedDate.weekday);
          });
          _fetchTimetableDetails(_timetable!);
        }
      });
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: _snapshot,
      builder: (context, snapshot) {
        if (_timetable != null) {
          return ListView(
            children: [
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () {
                          _goToPreviousDay();
                        },
                      ),
                      TextButton(
                        onPressed: () => presentDatePicker(),
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.grey[200]
                        ),
                        child: Text(
                          "${_daysOfWeekRus[_currentDayOfWeek]!} ${_getCurrentTimestamp(_currentDay)}",
                          style: const TextStyle(fontSize: 18),
                          ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.arrow_forward),
                        onPressed: () {
                          _goToNextDay();
                        },
                      ),
                    ],
                  ),
                  buildDayTimetable(_currentDayOfWeek!),
                ],
              ),
            ],
          );
        } else if (_role != null && !_role!.contains("student") && !_role!.contains("teacher")) {
          return const Center(
            child: Text("У вас нет расписания."),
          );
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.selectedGroupUid == null && widget.selectedTeacherUid == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Расписание'),
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 20),
              child: IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SearchScreen()),
                );
              },
            )),
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                FirebaseAuth.instance.signOut();
                Navigator.pushAndRemoveUntil(
                  context, 
                  MaterialPageRoute(builder: (context) => const AuthScreen()),
                  (_) => false);
              },
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: _buildTimetable(),
        ),
      );
    } else {
      return _buildTimetable();
    }
  }
}
