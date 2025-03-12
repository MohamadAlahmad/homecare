import 'package:get/get.dart';
import 'package:homecare/mvc/model/api/region.dart';

class RegionsController extends GetxController {
  List<Region> regions1 = [];
  List<Region> regions2 = [];

  saveRegions1(List<Region> list) {
    regions1 = list;
    update();
  }

  List<Region> getRegions1() {
    return regions1;
  }

  saveRegions2(List<Region> list) {
    regions2 = list;
    update();
  }

  List<Region> getRegions2() {
    return regions2;
  }

}