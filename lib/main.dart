import 'package:flutter/material.dart';

import 'Login/login.dart';
import 'SSA/attendance.dart' as ssa_attendance;
import 'SSA/billing.dart' as ssa_billing;
import 'SSA/dashboard.dart' as ssa_dashboard;
import 'SSA/myprofile.dart' as ssa_myprofile;
import 'SSA/reports.dart' as ssa_reports;
import 'SSA/schedulelecture.dart' as ssa_schedulelecture;
import 'SSA/vcmanagement.dart' as ssa_vcmanagement;
import 'SSA/vtmanagement.dart' as ssa_vtmanagement;
import 'SSA/vtpmanagement.dart' as ssa_vtpmanagement;
import 'SSA/students_route.dart' as ssa_students;
import 'VC Coordinator/attendance.dart' as vc_coordinator_attendance;
import 'VC Coordinator/billing.dart' as vc_coordinator_billing;
import 'VC Coordinator/dashboard.dart' as vc_coordinator_dashboard;
import 'VC Coordinator/myprofile.dart' as vc_coordinator_myprofile;
import 'VC Coordinator/reports.dart' as vc_coordinator_reports;
import 'VC Coordinator/schedulelecture.dart'
    as vc_coordinator_schedulelecture;
import 'VC Coordinator/students.dart' as vc_coordinator_students;
import 'VC Coordinator/vcmonitoring.dart' as vc_coordinator_vcmonitoring;
import 'VC Coordinator/vcportal.dart' as vc_coordinator_vcportal;
import 'VC Coordinator/vtmanagement.dart' as vc_coordinator_vtmanagement;
import 'VTP Manager/attendance.dart';
import 'VTP Manager/billing.dart';
import 'VTP Manager/dashboard.dart' as vtp_manager;
import 'VT Instructor/attendance.dart' as vt_instructor_attendance;
import 'VT Instructor/class_monitor.dart' as vt_instructor_class_monitor;
import 'VT Instructor/dashboard.dart' as vt_instructor;
import 'VT Instructor/exams_marks.dart' as vt_instructor_exams_marks;
import 'VT Instructor/exit_survey.dart' as vt_instructor_exir_survey;
import 'VT Instructor/internships.dart' as vt_instructor_internships;
import 'VT Instructor/lesson_plan.dart' as vt_instructor_lesson_plan;
import 'VT Instructor/my_profile.dart' as vt_instructor_my_profile;
import 'VT Instructor/parent_teacher_meeting.dart'
    as vt_instructor_parent_teacher_meeting;
import 'VT Instructor/raw_materials.dart' as vt_instructor_raw_materials;
import 'VT Instructor/schedulelecture.dart' as vt_instructor_schedulelecture;
import 'VT Instructor/students.dart' as vt_instructor_students;
import 'VT Instructor/student_enrollment.dart'
    as vt_instructor_student_enrollment;
import 'VT Instructor/teaching_register.dart'
    as vt_instructor_teaching_register;
import 'VT Instructor/textbooks.dart' as vt_instructor_textbooks;
import 'VT Instructor/vc_monitoring.dart' as vt_instructor_vc_monitoring;
import 'VTP Manager/myprofile.dart';
import 'VTP Manager/notifications.dart';
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
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginPage(),
        '/dashboard': (context) => const vtp_manager.DashboardPage(),
        '/vtp-manager/dashboard': (context) =>
            const vtp_manager.DashboardPage(),
        '/vtp-manager/students': (context) => const StudentsPage(),
        '/vtp-manager/attendance': (context) => const AttendancePage(),
        '/vtp-manager/schedule-lecture': (context) =>
            const ScheduleLecturePage(),
        '/ssa/dashboard': (context) => const ssa_dashboard.DashboardPage(),
        '/ssa/vtp-management': (context) =>
            const ssa_vtpmanagement.VTPManagementPage(),
        '/ssa/vc-management': (context) =>
            const ssa_vcmanagement.VCManagementPage(),
        '/ssa/vt-management': (context) =>
            const ssa_vtmanagement.VTManagementPage(),
        '/ssa/students': (context) => const ssa_students.StudentsPage(),
        '/ssa/attendance': (context) => const ssa_attendance.AttendancePage(),
        '/ssa/billing': (context) => const ssa_billing.BillingPage(),
        '/ssa/reports': (context) => const ssa_reports.ReportsPage(),
        '/ssa/schedule-lecture': (context) =>
            const ssa_schedulelecture.ScheduleLecturePage(),
        '/ssa/my-profile': (context) => const ssa_myprofile.MyProfilePage(),
        '/vc-coordinator/dashboard': (context) =>
            const vc_coordinator_dashboard.DashboardPage(),
        '/vc-coordinator/vt-management': (context) =>
            const vc_coordinator_vtmanagement.VTManagementPage(),
        '/vc-coordinator/students': (context) =>
            const vc_coordinator_students.StudentsPage(),
        '/vc-coordinator/attendance': (context) =>
            const vc_coordinator_attendance.AttendancePage(),
        '/vc-coordinator/vc-monitoring': (context) =>
            const vc_coordinator_vcmonitoring.VCMonitoringPage(),
        '/vc-coordinator/vc-portal': (context) =>
            const vc_coordinator_vcportal.VCPortalPage(),
        '/vc-coordinator/billing': (context) =>
            const vc_coordinator_billing.BillingPage(),
        '/vc-coordinator/reports': (context) =>
            const vc_coordinator_reports.ReportsPage(),
        '/vc-coordinator/schedule-lecture': (context) =>
            const vc_coordinator_schedulelecture.ScheduleLecturePage(),
        '/vc-coordinator/my-profile': (context) =>
            const vc_coordinator_myprofile.MyProfilePage(),
        '/vt-instructor/dashboard': (context) =>
            const vt_instructor.DashboardPage(),
        '/vt-instructor/students': (context) =>
            const vt_instructor_students.StudentsPage(),
        '/vt-instructor/student-enrollment': (context) =>
            const vt_instructor_student_enrollment.StudentEnrollmentPage(),
        '/vt-instructor/exit-survey': (context) =>
            const vt_instructor_exir_survey.ExirSurveyPage(),
        '/vt-instructor/exir-survey': (context) =>
            const vt_instructor_exir_survey.ExirSurveyPage(),
        '/vt-instructor/attendance': (context) =>
            const vt_instructor_attendance.AttendancePage(),
        '/vt-instructor/attendence': (context) =>
            const vt_instructor_attendance.AttendancePage(),
        '/vt-instructor/class-monitor': (context) =>
            const vt_instructor_class_monitor.ClassMonitorPage(),
        '/vt-instructor/textbooks': (context) =>
            const vt_instructor_textbooks.TextbooksPage(),
        '/vt-instructor/vc-monitoring': (context) =>
            const vt_instructor_vc_monitoring.VCMonitoringPage(),
        '/vt-instructor/raw-materials': (context) =>
            const vt_instructor_raw_materials.RawMaterialsPage(),
        '/vt-instructor/parent-teacher-meeting': (context) =>
            const vt_instructor_parent_teacher_meeting
                .ParentTeacherMeetingPage(),
        '/vt-instructor/internships': (context) =>
            const vt_instructor_internships.InternshipsPage(),
        '/vt-instructor/exam-marks': (context) =>
            const vt_instructor_exams_marks.ExamsMarksPage(),
        '/vt-instructor/exams-marks': (context) =>
            const vt_instructor_exams_marks.ExamsMarksPage(),
        '/vt-instructor/teaching-register': (context) =>
            const vt_instructor_teaching_register.TeachingRegisterPage(),
        '/vt-instructor/lesson-plan': (context) =>
            const vt_instructor_lesson_plan.LessonPlanPage(),
        '/vt-instructor/schedule-lecture': (context) =>
            const vt_instructor_schedulelecture.ScheduleLecturePage(),
        '/vt-instructor/my-profile': (context) =>
            const vt_instructor_my_profile.VTInstructorMyProfilePage(),
        '/vc-management': (context) => const VCManagementPage(),
        '/vt-management': (context) => const VTManagementPage(),
        '/students': (context) => const StudentsPage(),
        '/attendance': (context) => const AttendancePage(),
        '/billing': (context) => const BillingPage(),
        '/reports': (context) => const ReportsPage(),
        '/schedule-lecture': (context) => const ScheduleLecturePage(),
        '/my-profile': (context) => const MyProfilePage(),
        '/notifications': (context) => const NotificationsPage(),
      },
    );
  }
}
