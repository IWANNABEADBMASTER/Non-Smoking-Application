// ignore_for_file: unused_field, unused_import

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Calendar_Page.dart' as calendar;

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  String _name = '';
  String _gender = '';
  DateTime? _quitDate;
  int _quitDays = 0;
  int _attendanceCount = 0;
  int _consecutiveDays = 0;

  @override
  void initState() {
    super.initState();
    _loadUserInformation();
    _loadAttendanceCount();
  }

  Future<void> _loadUserInformation() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      _name = sharedPreferences.getString('name') ?? '';
      _gender = sharedPreferences.getString('gender') ?? '';
      final quitDateTimestamp = sharedPreferences.getInt('quitDate');
      _quitDate = quitDateTimestamp != null
          ? DateTime.fromMillisecondsSinceEpoch(quitDateTimestamp)
          : null;

      final now = DateTime.now();
      if (_quitDate != null) {
        _quitDays = now.difference(_quitDate!).inDays;
      }
    });
  }

  Future<void> _loadAttendanceCount() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      _attendanceCount = sharedPreferences.getInt('attendanceCount') ?? 0;
      _consecutiveDays = sharedPreferences.getInt('consecutiveDays') ?? 0;
    });
  }

  Future<void> _resetUserInformation() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.remove('name');
    await sharedPreferences.remove('gender');
    await sharedPreferences.remove('quitDate');
    // 사용자 정보 초기화 후 다시 정보를 로드
    await _loadUserInformation();
  }

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    String imagePath = 'assets/images/3rd.png'; // 기본 이미지 경로

    // 연속 출석일에 따라 이미지 경로 변경
    if (_consecutiveDays == 2) {
      imagePath = 'assets/images/1st.png';
    } else if (_consecutiveDays >= 3) {
      imagePath = 'assets/images/2nd.png';
    } 

    return Scaffold(
      appBar: AppBar(
        title: const Text('메인'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$_name 님! 오늘도 방문해 주셨군요!',
              style: const TextStyle(fontSize: 18.0),
            ),
            Text(
              '금연 시작일: ${_quitDate != null ? _quitDate.toString().split(' ')[0] : 'Not set'}',
              style: const TextStyle(fontSize: 18.0),
            ),
            Text(
              '금연 일수: $_quitDays',
              style: const TextStyle(fontSize: 18.0),
            ),
              Text(
              '연속 출석일: $_consecutiveDays',
              style: const TextStyle(fontSize: 18.0),
            ),
            ElevatedButton(
              onPressed: _resetUserInformation,
              child: const Text('정보 다시입력'),
            ),
            const SizedBox(height: 20),
            Center(
              child: Image.asset(
              imagePath,
              width: 250,
              height: 250,
             ),
            ),
          ],
        ),
      ),
    );
  }
}
