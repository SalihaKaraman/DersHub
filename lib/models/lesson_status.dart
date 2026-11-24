import 'package:flutter/material.dart';

enum LessonStatus {
  scheduled,
  completed,
  cancelledByStudent,
  cancelledByTeacher,
  rescheduled,
  noShow;

  String get displayName {
    switch (this) {
      case LessonStatus.scheduled:
        return 'Planlandı';
      case LessonStatus.completed:
        return 'Yapıldı';
      case LessonStatus.cancelledByStudent:
        return 'Öğrenci İptal Etti';
      case LessonStatus.cancelledByTeacher:
        return 'Öğretmen İptal Etti';
      case LessonStatus.rescheduled:
        return 'Ertelendi';
      case LessonStatus.noShow:
        return 'Gelmedi';
    }
  }

  Color get color {
    switch (this) {
      case LessonStatus.scheduled:
        return const Color(0xFF4F46E5); // İndigo / Planlandı
      case LessonStatus.completed:
        return const Color(0xFF10B981); // Zümrüt Yeşili / Yapıldı
      case LessonStatus.cancelledByStudent:
        return const Color(0xFFF59E0B); // Amber / Öğrenci İptali
      case LessonStatus.cancelledByTeacher:
        return const Color(0xFFEF4444); // Kırmızı / Öğretmen İptali
      case LessonStatus.rescheduled:
        return const Color(0xFF0EA5E9); // Gökyüzü Mavisi / Ertelendi
      case LessonStatus.noShow:
        return const Color(0xFF8B5CF6); // Mor / Gelmedi
    }
  }

  IconData get icon {
    switch (this) {
      case LessonStatus.scheduled:
        return Icons.schedule_rounded;
      case LessonStatus.completed:
        return Icons.check_circle_rounded;
      case LessonStatus.cancelledByStudent:
        return Icons.person_off_rounded;
      case LessonStatus.cancelledByTeacher:
        return Icons.cancel_rounded;
      case LessonStatus.rescheduled:
        return Icons.update_rounded;
      case LessonStatus.noShow:
        return Icons.event_busy_rounded;
    }
  }

  static LessonStatus fromString(String? value, {bool isCompleted = false}) {
    if (value == null) {
      return isCompleted ? LessonStatus.completed : LessonStatus.scheduled;
    }
    switch (value.toLowerCase()) {
      case 'completed':
      case 'yapıldı':
        return LessonStatus.completed;
      case 'cancelledbystudent':
      case 'cancelled_student':
      case 'öğrenci iptal etti':
        return LessonStatus.cancelledByStudent;
      case 'cancelledbyteacher':
      case 'cancelled_teacher':
      case 'öğretmen iptal etti':
        return LessonStatus.cancelledByTeacher;
      case 'rescheduled':
      case 'ertelendi':
        return LessonStatus.rescheduled;
      case 'noshow':
      case 'no_show':
      case 'gelmedi':
        return LessonStatus.noShow;
      case 'scheduled':
      case 'planlandı':
      default:
        return isCompleted ? LessonStatus.completed : LessonStatus.scheduled;
    }
  }
}
