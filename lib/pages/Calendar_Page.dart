// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_calendar_carousel/classes/event.dart';
import 'package:flutter_calendar_carousel/classes/event_list.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart' as kakao;
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart' show CalendarCarousel;

import '/pages/Journal_Page.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({Key? key}) : super(key: key);

  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  int _attendanceCount = 0;
  int _consecutiveDays = 0;
  bool _isAttendanceCompleted = false;
  late DocumentReference _userDocRef;
  final bool _isDisposed = false;

  final EventList<Event> _markedDateMap = EventList<Event>(events: {});

  @override
  void initState() {
    super.initState();
    _initializeFirestore();
    _loadAttendanceCount();
  }

  Future<void> _initializeFirestore() async {
    final kakao.User user = await kakao.UserApi.instance.me();
    _userDocRef = FirebaseFirestore.instance.collection('users').doc(user.id.toString());
  }

  Future<void> _loadAttendanceCount() async {
  final kakao.User user = await kakao.UserApi.instance.me();
  _userDocRef = FirebaseFirestore.instance.collection('users').doc(user.id.toString());
  final userDoc = await _userDocRef.get();
  final userData = userDoc.data() as Map<String, dynamic>?;
  if(!_isDisposed){
  if (userData != null) {
    setState(() {
      _attendanceCount = userData['attendanceCount'] ?? 0;
      _consecutiveDays = userData['consecutiveDays'] ?? 0;
      _isAttendanceCompleted = userData['isAttendanceCompleted'] ?? false;
    });
  }
}
  }


  Future<void> _checkAttendance() async {
    final now = DateTime.now();

    final userData = await _userDocRef.get();
    if (userData.exists) {
      final data = userData.data() as Map<String, dynamic>;
      final lastAttendanceDateStr = data['lastAttendanceDate'];
      if (lastAttendanceDateStr != null) {
        final lastAttendanceDate = DateTime.parse(lastAttendanceDateStr);
        final difference = now.difference(lastAttendanceDate).inDays;
        if (difference < 1) {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text('알림'),
              content: const Text('이미 오늘 출석체크를 하였습니다.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('확인'),
                ),
              ],
            ),
          );
          return;
        }
        if (difference == 1) {
          // 출석이 이어진 경우
          setState(() {
            _consecutiveDays++;
          });
        } else {
          // 출석이 중간에 빠진 경우
          setState(() {
            _consecutiveDays = 1;
          });
        }
      } else {
        // 첫 출석일 경우
        setState(() {
          _consecutiveDays = 1;
        });
      }
    }

    // 출석 체크
    setState(() {
      _attendanceCount++;
      _isAttendanceCompleted = true;
    });

    // Firestore에 출석체크 정보 업데이트
    await _userDocRef.set({
      'attendanceCount': _attendanceCount,
      'consecutiveDays': _consecutiveDays,
      'isAttendanceCompleted': _isAttendanceCompleted,
      'lastAttendanceDate': now.toIso8601String(),
    }, SetOptions(merge: true));

    // 출석체크한 날짜를 Firestore에 저장
    await _userDocRef.collection('attendance').doc(now.toIso8601String()).set({});

    // 출석체크한 날짜를 _markedDateMap에 추가
    _markedDateMap.add(
      now,
      Event(
        date: now,
        dot: Container(
          decoration: const BoxDecoration(
            color: Colors.green,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );

    // 알림 표시
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('알림'),
        content: const Text('출석체크 되었습니다.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('확인'),
          ),
        ],
      ),
    );

    // 화면 다시 그리기
    setState(() {});
  }

  Future<void> _resetAttendance() async {
    final now = DateTime.now();

    setState(() {
      _attendanceCount = 0;
      _consecutiveDays = 0;
      _isAttendanceCompleted = false;
      _markedDateMap.clear();
    });

    // 출석 관련 정보 초기화
    await _userDocRef.set({
      'attendanceCount': 0,
      'consecutiveDays': 0,
      'isAttendanceCompleted': false,
      'lastAttendanceDate': null,
    }, SetOptions(merge: true));

    // 출석 기록 삭제
    final attendanceSnapshot = await _userDocRef.collection('attendance').get();
    for (final doc in attendanceSnapshot.docs) {
      await doc.reference.delete();
    }

    // ignore: use_build_context_synchronously
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('알림'),
        content: const Text('출석체크 기록이 초기화되었습니다.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  void _writeJournal() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => JournalPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          '출석체크',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              '출석 일수: $_attendanceCount일',
              style: const TextStyle(fontSize: 18.0),
            ),
            Text(
              '연속 출석일: $_consecutiveDays일',
              style: const TextStyle(fontSize: 18.0),
            ),
            const SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _checkAttendance,
                  child: const Text('출석체크'),
                ),
                const SizedBox(width: 16.0),
                ElevatedButton(
                  onPressed: _resetAttendance,
                  child: const Text('출석체크 기록 초기화'),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _writeJournal,
              child: const Text('일지 작성'),
            ),
            const SizedBox(height: 16.0),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16.0),
              child: CalendarCarousel<Event>(
                onDayPressed: (DateTime date, List<Event> events) {
                },
                weekendTextStyle: const TextStyle(
                  color: Color.fromARGB(255, 36, 128, 205),
                ),
                thisMonthDayBorderColor: Colors.grey,
                markedDatesMap: _markedDateMap,
                customDayBuilder: (
                  bool isSelectable,
                  int index,
                  bool isSelectedDay,
                  bool isToday,
                  bool isPrevMonthDay,
                  TextStyle textStyle,
                  bool isNextMonthDay,
                  bool isThisMonthDay,
                  DateTime day,
                ) {
                  final eventList = _markedDateMap.events[day];
                  if (eventList != null && eventList.isNotEmpty) {
                    return Container(
                      margin: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.green,
                      ),
                      child: Center(
                        child: Text(
                          day.day.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  } else {
                    return null;
                  }
                },
                weekFormat: false,
                height: 360.0,
                daysHaveCircularBorder: false,
              ),
            ),
          ],
        ),
      ),
    );
  }
}