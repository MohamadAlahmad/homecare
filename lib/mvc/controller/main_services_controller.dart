import 'package:get/get.dart';
import 'package:homecare/mvc/model/local/main_service.dart';

class MainServicesController extends GetxController {
  List<MainService> services = [];

  setServices(List<MainService> list) {
    services = list;
    update();
  }

  List<MainService> getServices() {
    return services;
  }

}