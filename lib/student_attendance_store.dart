import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class StudentAttendanceRecord {
  const StudentAttendanceRecord({
    required this.name,
    required this.id,
    required this.initials,
    required this.present,
    required this.checkIn,
    required this.checkOut,
    required this.reason,
  });

  final String name;
  final String id;
  final String initials;
  final bool present;
  final String checkIn;
  final String checkOut;
  final String reason;

  Map<String, dynamic> toJson() => {
        'name': name,
        'id': id,
        'initials': initials,
        'present': present,
        'checkIn': checkIn,
        'checkOut': checkOut,
        'reason': reason,
      };

  static StudentAttendanceRecord fromJson(Map<String, dynamic> json) {
    return StudentAttendanceRecord(
      name: json['name'] as String? ?? '',
      id: json['id'] as String? ?? '',
      initials: json['initials'] as String? ?? '',
      present: json['present'] as bool? ?? false,
      checkIn: json['checkIn'] as String? ?? '--',
      checkOut: json['checkOut'] as String? ?? '--',
      reason: json['reason'] as String? ?? '',
    );
  }
}

class StudentAttendanceStore {
  static const _prefsKey = 'vt_student_attendance_latest';

  static Future<void> save(List<StudentAttendanceRecord> records) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(records.map((record) => record.toJson()).toList());
    await prefs.setString(_prefsKey, encoded);
  }

  static Future<List<StudentAttendanceRecord>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw == null) return const [];

    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map(
            (item) => StudentAttendanceRecord.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList();
    } catch (_) {
      return const [];
    }
  }
}

class VtAttendanceRecord {
  const VtAttendanceRecord({
    required this.name,
    required this.id,
    required this.initials,
    required this.present,
    required this.checkIn,
    required this.checkOut,
    required this.reason,
  });

  final String name;
  final String id;
  final String initials;
  final bool present;
  final String checkIn;
  final String checkOut;
  final String reason;

  Map<String, dynamic> toJson() => {
        'name': name,
        'id': id,
        'initials': initials,
        'present': present,
        'checkIn': checkIn,
        'checkOut': checkOut,
        'reason': reason,
      };

  static VtAttendanceRecord fromJson(Map<String, dynamic> json) {
    return VtAttendanceRecord(
      name: json['name'] as String? ?? 'VT Instructor',
      id: json['id'] as String? ?? 'VT2024001',
      initials: json['initials'] as String? ?? 'VT',
      present: json['present'] as bool? ?? false,
      checkIn: json['checkIn'] as String? ?? '--',
      checkOut: json['checkOut'] as String? ?? '--',
      reason: json['reason'] as String? ?? '-',
    );
  }
}

class VtAttendanceStore {
  static const _prefsKey = 'vt_instructor_attendance_latest';

  static Future<void> save(VtAttendanceRecord record) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, jsonEncode(record.toJson()));
  }

  static Future<VtAttendanceRecord?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw == null) return null;

    try {
      return VtAttendanceRecord.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
    } catch (_) {
      return null;
    }
  }
}

class VcAttendanceRecord {
  const VcAttendanceRecord({
    required this.name,
    required this.id,
    required this.initials,
    required this.present,
    required this.checkIn,
    required this.checkOut,
    required this.reason,
  });

  final String name;
  final String id;
  final String initials;
  final bool present;
  final String checkIn;
  final String checkOut;
  final String reason;

  Map<String, dynamic> toJson() => {
        'name': name,
        'id': id,
        'initials': initials,
        'present': present,
        'checkIn': checkIn,
        'checkOut': checkOut,
        'reason': reason,
      };

  static VcAttendanceRecord fromJson(Map<String, dynamic> json) {
    return VcAttendanceRecord(
      name: json['name'] as String? ?? 'VC Coordinator',
      id: json['id'] as String? ?? 'VC2024001',
      initials: json['initials'] as String? ?? 'VC',
      present: json['present'] as bool? ?? false,
      checkIn: json['checkIn'] as String? ?? '--',
      checkOut: json['checkOut'] as String? ?? '--',
      reason: json['reason'] as String? ?? '-',
    );
  }
}

class VcAttendanceStore {
  static const _prefsKey = 'vc_coordinator_attendance_latest';

  static Future<void> save(VcAttendanceRecord record) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, jsonEncode(record.toJson()));
  }

  static Future<VcAttendanceRecord?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw == null) return null;

    try {
      return VcAttendanceRecord.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
    } catch (_) {
      return null;
    }
  }
}
