import 'package:get/get.dart';
import 'package:homecare/mvc/controller/cities_controller.dart';
import 'package:homecare/mvc/controller/regions_controller.dart';

class Binding implements Bindings {
  @override
  void dependencies() {
    Get.put(CitiesController());
    Get.put(RegionsController());
  }
}
