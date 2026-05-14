import 'package:flutter/material.dart';

import 'VTP Manager/attendance.dart';
import 'VTP Manager/billing.dart';
import 'VTP Manager/dashboard.dart';
import 'VTP Manager/myprofile.dart';
import 'VTP Manager/reports.dart';
import 'VTP Manager/schedulelecture.dart';
import 'VTP Manager/students.dart';
import 'VTP Manager/vcmanagement.dart';
import 'VTP Manager/vtmanagement.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/dashboard',
      routes: {
        '/dashboard': (context) => const DashboardPage(),
        '/vc-management': (context) => const VCManagementPage(),
        '/vt-management': (context) => const VTManagementPage(),
        '/students': (context) => const StudentsPage(),
        '/attendance': (context) => const AttendancePage(),
        '/billing': (context) => const BillingPage(),
        '/reports': (context) => const ReportsPage(),
        '/schedule-lecture': (context) => const ScheduleLecturePage(),
        '/my-profile': (context) => const MyProfilePage(),
      },
    );
  }
}
