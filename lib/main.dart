import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'app/core/services/storage_service.dart';
import 'app/core/theme/app_theme.dart';
import 'app/routes/app_pages.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env', isOptional: true);
  await StorageService.init();

  final savedTheme = StorageService.getThemeMode();

  ThemeMode themeMode = ThemeMode.system;
  if (savedTheme == 'dark') {
    themeMode = ThemeMode.dark;
  } else if (savedTheme == 'light') {
    themeMode = ThemeMode.light;
  }

  runApp(
    GetMaterialApp(
      title: "SIKERA",
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      initialRoute: Routes.SPLASH,
      getPages: AppPages.routes,
    ),
  );
}
