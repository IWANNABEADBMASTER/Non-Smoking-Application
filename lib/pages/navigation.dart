import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/Home_page.dart';
import 'package:flutter_application_1/pages/Calendar_Page.dart';
import 'package:flutter_application_1/pages/CounselPage.dart';
import 'package:flutter_application_1/pages/MyPage.dart';

class NavigationExample extends StatefulWidget {
  const NavigationExample({Key? key}) : super(key: key);

  @override
  State<NavigationExample> createState() => _NavigationExampleState();
}
class _NavigationExampleState extends State<NavigationExample> {
  int currentPageIndex = 0;
   @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      body: <Widget>[
        const HomePage(),
        const CalendarPage(),
        const CounselPage(),
        const MyPage(),
      ][currentPageIndex],
    );
  }
}