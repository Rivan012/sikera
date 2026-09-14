// ignore_for_file: constant_identifier_names

part of 'app_pages.dart';

abstract class Routes {
  Routes._();
  static const HOME = _Paths.HOME;
  static const SPLASH = _Paths.SPLASH;
  static const LOGIN = _Paths.LOGIN;
  static const REGISTER = _Paths.REGISTER;
  static const EDUCATION_MODULE_LIST = _Paths.EDUCATION_MODULE_LIST;
  static const EDUCATION_MODULE_DETAIL = _Paths.EDUCATION_MODULE_DETAIL;
  static const EDUCATION_PRETEST = _Paths.EDUCATION_PRETEST;
  static const EDUCATION_TOPIC = _Paths.EDUCATION_TOPIC;
  static const EDUCATION_POSTTEST = _Paths.EDUCATION_POSTTEST;
  static const EDUCATION_RESULT = _Paths.EDUCATION_RESULT;
  static const SELFCARE = _Paths.SELFCARE;
  static const SELFCARE_PERIOD = _Paths.SELFCARE_PERIOD;
  static const SELFCARE_BMI = _Paths.SELFCARE_BMI;
  static const SELFCARE_BLOOD_GUIDE = _Paths.SELFCARE_BLOOD_GUIDE;
  static const SELFCARE_HYGIENE_GUIDE = _Paths.SELFCARE_HYGIENE_GUIDE;
  static const POSTERS = _Paths.POSTERS;
  static const POSTER_DETAIL = _Paths.POSTER_DETAIL;
  static const CASES = _Paths.CASES;
  static const CASE_DETAIL = _Paths.CASE_DETAIL;
  static const FORUM = _Paths.FORUM;
  static const FORUM_DETAIL = _Paths.FORUM_DETAIL;
  static const FORUM_CREATE = _Paths.FORUM_CREATE;
  static const TRIVIA = _Paths.TRIVIA;
  static const MYTH_FACT = _Paths.MYTH_FACT;
}

abstract class _Paths {
  _Paths._();
  static const HOME = '/home';
  static const SPLASH = '/splash';
  static const LOGIN = '/login';
  static const REGISTER = '/register';
  static const EDUCATION_MODULE_LIST = '/education';
  static const EDUCATION_MODULE_DETAIL = '/education/detail';
  static const EDUCATION_PRETEST = '/education/pretest';
  static const EDUCATION_TOPIC = '/education/topic';
  static const EDUCATION_POSTTEST = '/education/posttest';
  static const EDUCATION_RESULT = '/education/result';
  static const SELFCARE = '/selfcare';
  static const SELFCARE_PERIOD = '/selfcare/period';
  static const SELFCARE_BMI = '/selfcare/bmi';
  static const SELFCARE_BLOOD_GUIDE = '/selfcare/blood-guide';
  static const SELFCARE_HYGIENE_GUIDE = '/selfcare/hygiene-guide';
  static const POSTERS = '/posters';
  static const POSTER_DETAIL = '/posters/detail';
  static const CASES = '/cases';
  static const CASE_DETAIL = '/cases/detail';
  static const FORUM = '/forum';
  static const FORUM_DETAIL = '/forum/detail';
  static const FORUM_CREATE = '/forum/create';
  static const TRIVIA = '/gamification/trivia';
  static const MYTH_FACT = '/gamification/myth-fact';
}
