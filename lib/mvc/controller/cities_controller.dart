import 'package:get/get.dart';
import 'package:homecare/mvc/model/api/city.dart';

class CitiesController extends GetxController {
  List<City> cities = [];

  saveCities(List<City> list) {
    cities = list;
    update();
  }

  List<City> getCities() {
    return cities;
  }

}