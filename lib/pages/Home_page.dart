import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  @override
  void initState() {
    super.initState();
    _loadUserInformation();
  }

  Future<void> _loadUserInformation() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      _name = sharedPreferences.getString('name') ?? '';
      _gender = sharedPreferences.getString('gender') ?? '';
      final quitDateTimestamp = sharedPreferences.getInt('quitDate');
      _quitDate = quitDateTimestamp != null ? DateTime.fromMillisecondsSinceEpoch(quitDateTimestamp) : null;

      final now = DateTime.now();
      if (_quitDate != null) {
        _quitDays = now.difference(_quitDate!).inDays;
      }
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Main Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Name: $_name',
              style: const TextStyle(fontSize: 18.0),
            ),
            Text(
              'Gender: $_gender',
              style: const TextStyle(fontSize: 18.0),
            ),
            Text(
              'Quit Date: ${_quitDate != null ? _quitDate.toString().split(' ')[0] : 'Not set'}',
              style: const TextStyle(fontSize: 18.0),
            ),
            Text(
              'Quit Days: $_quitDays',
              style: const TextStyle(fontSize: 18.0),
            ),
            ElevatedButton(
              onPressed: _resetUserInformation,
              child: const Text('Reset Information'),
            ),
          ],
        ),
      ),
    );
  }
}
