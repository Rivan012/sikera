import 'package:get/get.dart';

import 'selfcare_controller.dart';

class SelfcareBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SelfcareController>(
      () => SelfcareController(),
      fenix: true,
    );
  }
}
