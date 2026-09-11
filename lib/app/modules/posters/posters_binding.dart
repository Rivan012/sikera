import 'package:get/get.dart';

import 'posters_controller.dart';

class PostersBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PostersController>(
      () => PostersController(),
      fenix: true,
    );
  }
}
