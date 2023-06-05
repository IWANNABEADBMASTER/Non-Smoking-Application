// ignore_for_file: depend_on_referenced_packages

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart' as kakao;


class MyPage extends StatefulWidget {
  const MyPage({Key? key}) : super(key: key);

  @override
  _MyPageState createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  TextEditingController _nameController = TextEditingController();
  String? _selectedGender;
  DateTime? _quitDate;
  String? _selectedJob;


  DateTime dateTime = DateTime.now(); // 사용자가 선택한 시간을 저장
  bool isNotificationEnabled = false; // 알림 활성화 여부
  int notificationId = 0; // 푸시 알림 ID
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    initializeNotifications(); // 알림 설정 초기화
    _loadUserInformation();
  }

  Future<void> _loadUserInformation() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      _nameController.text = sharedPreferences.getString('name') ?? '';
      _selectedGender = sharedPreferences.getString('gender');
      _selectedJob = sharedPreferences.getString('job');
      final quitDateMilliseconds = sharedPreferences.getInt('quitDate');
      _quitDate = quitDateMilliseconds != null
          ? DateTime.fromMillisecondsSinceEpoch(quitDateMilliseconds)
          : null;
    });
  }

  Future<void> _saveUserInformation() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString('name', _nameController.text);
    sharedPreferences.setString('gender', _selectedGender ?? '');
    sharedPreferences.setString('job', _selectedJob ?? '');
    if (_quitDate != null) {
      sharedPreferences.setInt('quitDate', _quitDate!.millisecondsSinceEpoch);
    } else {
      sharedPreferences.remove('quitDate');
    }
  }

  Future<void> _updateUserInformation() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    final userId = sharedPreferences.getString('userId');

    if (userId != null) {
      final userDocRef = FirebaseFirestore.instance.collection('users').doc(userId);

      await userDocRef.update({
        'displayName': _nameController.text,
        'gender': _selectedGender,
        'quitDate': _quitDate != null ? _quitDate!.millisecondsSinceEpoch : null,
        'job': _selectedJob,
      });
      setState(() {
      // 사용자 정보가 업데이트되었으므로 상태를 갱신합니다.
      sharedPreferences.setString('name', _nameController.text);
      sharedPreferences.setString('gender', _selectedGender ?? '');
      sharedPreferences.setString('job', _selectedJob ?? '');
      if (_quitDate != null) {
        sharedPreferences.setInt('quitDate', _quitDate!.millisecondsSinceEpoch);
      } else {
        sharedPreferences.remove('quitDate');
      }
    });
    }
  }

  void toggleNotification(bool value) {
    setState(() {
      isNotificationEnabled = value;
      if (isNotificationEnabled) {
        scheduleNotification(); // 알림이 활성화되면 알림 예약
      } else {
        cancelNotification(); // 알림이 비활성화되면 알림 취소
      }
    });
  }

  Future<void> cancelNotification() async {
    await flutterLocalNotificationsPlugin.cancel(notificationId);
  }

  Future<void> initializeNotifications() async {
    var initializationSettingsAndroid =
        const AndroidInitializationSettings('@mipmap/ic_launcher'); // Android 초기화 설정
    
    var initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,);

    await flutterLocalNotificationsPlugin
        .initialize(initializationSettings); // 알림 플러그인 초기화

    tz.initializeTimeZones(); // 시간대 초기화
  }

  Future<void> onSelectNotification(String? payload) async {
    if (payload != null) {
      debugPrint('Notification payload: $payload');
    }
  }

  Future<void> scheduleNotification() async {
    if (!isNotificationEnabled) {
      return; // 알림이 꺼져있을 때는 예약하지 않음
    }
    var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
        'channel_id', 'channel_name',
        channelDescription: 'channel_description',
        importance: Importance.high,
        priority: Priority.high); // Android 알림 설정
    
    var platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    var scheduledDate =
        tz.TZDateTime.from(dateTime, tz.local); // 사용자가 설정한 시간을 가져온다.

    // 다음 날의 동일한 시간으로 설정
    var nextDay = scheduledDate.add(const Duration(days: 1));

    await flutterLocalNotificationsPlugin.zonedSchedule(
      0, // 알림 ID
      'HOOHA 알림', // 알림 제목
      '출석체크 할 시간입니다!',
      nextDay, // 예약 시간
      platformChannelSpecifics, // 알림 설정
      //androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: '매일 알림',
      //androidAllowWhileIdle: true,
      //repeatInterval: RepeatInterval.daily,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: '이름'),
            ),
            const SizedBox(height: 16.0),
            DropdownButtonFormField<String>(
              value: _selectedGender,
              onChanged: (value) {
                setState(() {
                  _selectedGender = value;
                });
              },
              items: const [
                DropdownMenuItem(
                  value: 'male',
                  child: Text('남성'),
                ),
                DropdownMenuItem(
                  value: 'female',
                  child: Text('여성'),
                ),
              ],
              decoration: const InputDecoration(
                labelText: '성별',
              ),
            ),
            const SizedBox(height: 16.0),
            DropdownButtonFormField<String>(
              value: _selectedJob,
              onChanged: (value) {
                setState(() {
                  _selectedJob = value;
                });
              },
              items: const [
                DropdownMenuItem(
                  value: '직장인',
                  child: Text('직장인'),
                ),
                DropdownMenuItem(
                  value: '학생',
                  child: Text('학생'),
                ),
                DropdownMenuItem(
                  value: '주부',
                  child: Text('주부'),
                ),
                DropdownMenuItem(
                  value: '군인',
                  child: Text('군인'),
                ),
                DropdownMenuItem(
                  value: '무직',
                  child: Text('무직'),
                ),
              ],
              decoration: const InputDecoration(
                labelText: '직업',
              ),
            ),
            const SizedBox(height: 16.0),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _quitDate != null
                        ? '금연 시작일: ${_quitDate!.toString().substring(0, 10)}'
                        : '금연 시작일을 설정해주세요.',
                    style: TextStyle(fontSize: 16.0),
                  ),
                ),
                IconButton(
                  onPressed: () async {
                    final selectedDate = await showDatePicker(
                      context: context,
                      initialDate: _quitDate ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                    );
                    if (selectedDate != null) {
                      setState(() {
                        _quitDate = selectedDate;
                      });
                    }
                  },
                  icon: const Icon(Icons.calendar_today),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            SwitchListTile(
              title: const Text('출석체크 알림 설정'),
              value: isNotificationEnabled,
              onChanged: toggleNotification,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await _saveUserInformation();
          await _updateUserInformation(); 
        },
        child: const Icon(Icons.save),
      ),
    );
  }
}
