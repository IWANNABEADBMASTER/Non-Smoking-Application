import 'package:flutter/material.dart';
import '/pages/Home_page.dart';
import '/pages/Calendar_Page.dart';
import '/pages/CounselPage.dart';
import '/pages/MyPage.dart';
import '/pages/Notification_page.dart';

class NavigationExample extends StatefulWidget {
  const NavigationExample({Key? key}) : super(key: key);

  @override
  State<NavigationExample> createState() => _NavigationExampleState();
}
class _NavigationExampleState extends State<NavigationExample> {
  int currentPageIndex = 0;
  List<String> notifications = []; //알림 리스트
   @override
  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Center(
        child: Text(
          'HOOHA',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => NotificationPage(notifications: notifications),
              ),
            );
          },
        ),
      ],
    ),
    bottomNavigationBar: NavigationBar(
      onDestinationSelected: (int index) {
        setState(() {
          currentPageIndex = index;
        });
      },
      selectedIndex: currentPageIndex,
      destinations: const <Widget>[
        NavigationDestination(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        NavigationDestination(
          icon: Icon(Icons.calendar_month_sharp),
          label: 'Calendar',
        ),
        NavigationDestination(
          icon: Icon(Icons.chat_outlined),
          label: 'Counsel',
        ),
        NavigationDestination(
          icon: Icon(Icons.supervised_user_circle_sharp),
          label: 'MyPage',
        ),
      ],
    ),
    body: _buildPage(currentPageIndex), // 수정된 부분
  );
}

Widget _buildPage(int index) {
  if (index == 0) {
    return MainPage(); // 사용자 정보가 표시될 페이지
  } else if (index == 1) {
    return CalendarPage();
  } else if (index == 2) {
    return CounselPage();
  } else if (index == 3) {
    return MyPage();
  } else {
    return Container();
  }
}
}