import 'package:get/get.dart';

import 'admin_assessment_controller.dart';

class AdminBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AdminAssessmentController>(
      () => AdminAssessmentController(),
      fenix: true,
    );
  }
}
