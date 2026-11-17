import 'package:flutter/material.dart';

class OnboardingData {
  const OnboardingData({
    required this.title,
    required this.description,
    this.icon,
    this.supportingIcons = const [],
  });

  final String title;
  final String description;
  final IconData? icon;
  final List<IconData> supportingIcons;
}

const onboardingPages = [
  OnboardingData(
    title: 'Selamat Datang!',
    description:
        'Kenali kesehatan reproduksi bersama SIKERA. Temukan materi edukasi dan panduan perawatan diri untuk keseharianmu.',
  ),
  OnboardingData(
    title: 'Edukasi & Pemantauan Mandiri',
    description:
        'Pelajari modul kesehatan reproduksi, catat siklus haid serta status gizi, dan ajukan pertanyaan anonim kepada konselor kampus.',
    icon: Icons.menu_book_rounded,
    supportingIcons: [Icons.calendar_month_outlined, Icons.forum_outlined],
  ),
  OnboardingData(
    title: 'Siap Untuk Memulai?',
    description:
        'Masuk atau buat akun untuk mulai belajar dan mencatat perkembanganmu bersama SIKERA.',
    icon: Icons.person_add_alt_1_rounded,
    supportingIcons: [Icons.school_outlined, Icons.login_rounded],
  ),
];
