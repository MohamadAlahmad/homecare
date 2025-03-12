// ignore_for_file: non_constant_identifier_names, use_build_context_synchronously

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:homecare/core/utils/globals.dart';
import 'package:homecare/mvc/controller/connection_controller.dart';
import 'package:homecare/core/theme/homecare_style.dart';
import 'package:homecare/core/theme/themes.dart';
import 'package:homecare/core/utils/location_picker.dart';
import 'package:homecare/mvc/controller/cities_controller.dart';
import 'package:homecare/mvc/controller/regions_controller.dart';
import 'package:homecare/mvc/controller/shared_preferences_controller.dart';
import 'package:homecare/mvc/model/api/city.dart';
import 'package:homecare/mvc/model/api/region.dart';
import 'package:homecare/widgets/buttons.dart';
import 'package:homecare/widgets/custom_dropdown_button.dart';
import 'package:homecare/widgets/custom_text_field.dart';
import 'package:homecare/widgets/header_widget.dart';
import 'package:homecare/widgets/menu_text.dart';
import 'package:homecare/widgets/progress_indicator.dart';
import 'package:permission_handler/permission_handler.dart';

class PersonalProfileScreen extends StatefulWidget {
  const PersonalProfileScreen({super.key});

  @override
  State<PersonalProfileScreen> createState() => _PersonalProfileScreenState();
}

class _PersonalProfileScreenState extends State<PersonalProfileScreen> {

  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController lastNameCtrl = TextEditingController();
  final TextEditingController phoneCtrl = TextEditingController();
  final TextEditingController occupationCtrl = TextEditingController();
  final TextEditingController birthdayCtrl = TextEditingController();
  final TextEditingController addressCtrl = TextEditingController();
  SharedPrefsController sharedPrefsController = SharedPrefsController();
  CitiesController citiesController = Get.find();
  RegionsController regionsController = Get.find();
  final formKey = GlobalKey<FormState>();
  String selectedCity = '';
  int selectedCityId = 1;
  //bool citySelected = false;
  //bool regionSelected = false;
  String selectedRegion = '';
  int selectedRegionId = 0;
  String? selectedGender;
  String birthDate = '';
  LatLng? selectedLocation;

  bool showBirthDateMsg = false;
  bool showLocationMsg = false;
  bool showCityMsg = false;
  bool showRegionMsg = false;

  double latitude = 0.0;
  double longitude = 0.0;

  @override
  void initState() {
    initializeData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: Colors.white,
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SafeArea(
          child: Stack(
            children: [
              HeaderWidget(context, title: 'الملف الشخصي'),
              Padding(
                padding: const EdgeInsets.only(top: 50.0, left: 10.0, right: 10.0),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Stack(
                          children: [
                            const Align(alignment: Alignment.center, child: CircleAvatar(radius: 75.0, backgroundColor: HomeCareTheme.secondaryColor)),
                            Align(
                              alignment: Alignment.center,
                              child: Padding(
                                padding: const EdgeInsets.only(right: 120.0, top: 75.0),
                                child: IconButton(
                                  onPressed: () {},
                                  icon: const Icon(CupertinoIcons.add_circled_solid, color: HomeCareTheme.primaryColor, size: 50.0),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10.0),
                        MenuText(' : الاسم'),
                        CustomTextFieldWithLabel(
                          context,
                          hintText: 'الاسم',
                          controller: nameCtrl,
                          fontSize: 16.0,
                          hintColor: Colors.grey,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'حقل مطلوب';
                            }
                            return null; // No errors
                          },
                        ),
                        MenuText(' : الكنية'),
                        CustomTextFieldWithLabel(
                          context,
                          hintText: 'الكنية',
                          controller: lastNameCtrl,
                          fontSize: 16.0,
                          hintColor: Colors.grey,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'حقل مطلوب';
                            }
                            return null; // No errors
                          },
                        ),
                        MenuText(' : رقم الهاتف'),
                        CustomTextFieldWithLabel(
                          context,
                          enabled: false,
                          hintText: 'رقم الهاتف',
                          controller: phoneCtrl,
                          fontSize: 16.0,
                          hintColor: Colors.grey,
                          numeric: true,
                        ),
                        MenuText(' : نوع العمل'),
                        CustomTextFieldWithLabel(
                          context,
                          controller: occupationCtrl,
                          hintText: '',
                          fontSize: 16.0,
                          hintColor: Colors.grey[600]!,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'حقل مطلوب';
                            }
                            return null; // No errors
                          },
                        ),
                        const SizedBox(height: 10.0),
                        //const SizedBox(height: 10.0),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            MenuText(' : المدينة'),
                            const SizedBox(height: 5.0),
                            CustomDropdownWidget<City>(
                              //enabled: true,
                              items: citiesController.cities,
                              selectedItem: selectedCity.isEmpty
                                  ? null
                                  : citiesController.cities.firstWhere(
                                    (city) => city.name == selectedCity,
                                orElse: () => citiesController.cities[0],
                              ),
                              onItemSelected: (City? value) {
                                setState(() {
                                  selectedCityId = value?.id ?? 0;
                                  selectedCity = value?.name ?? '';
                                  //citySelected = true;
                                });
                              },
                              hintText: 'المدينة',
                              showMsg: showCityMsg,
                              displayText: (City city) => city.name,
                            ),
                          ],
                        ),
                        const SizedBox(height: 10.0),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                showRegionMsg ? Text('حقل مطلوب', style: TextStyle(fontSize: 12.0, color: Colors.red[900]!)) : const SizedBox(),
                                MenuText(' : المنطقة'),
                              ],
                            ),
                            const SizedBox(height: 5.0),
                            CustomDropdownWidget<Region>(
                              //enabled: citySelected,
                              showMsg: showRegionMsg,
                              items: selectedCityId == 1 ? regionsController.regions1 : regionsController.regions2,
                              selectedItem: selectedRegion.isEmpty
                                  ? null
                                  : selectedCityId == 1 ? regionsController.regions1.firstWhere(
                                    (region) => region.name == selectedRegion,
                                orElse: () => regionsController.regions1[0],
                              ) : regionsController.regions2.firstWhere(
                                    (region) => region.name == selectedRegion,
                                orElse: () => regionsController.regions2[0],
                              ),
                              onItemSelected: (Region? value) {
                                setState(() {
                                  selectedRegion = value?.name ?? '';
                                  //regionSelected = true;
                                  selectedRegionId = value?.id ?? 0;
                                });
                              },
                              hintText:  'المنطقة',
                              displayText: (Region region) => region.name,
                            ),
                          ],
                        ),
                        const SizedBox(height: 10.0),
                        MenuText(' : تفاصيل العنوان'),
                        CustomTextFieldWithLabel(
                          context,
                          hintText: 'تفاصيل العنوان . . .',
                          isDetails: true,
                          controller: addressCtrl,
                          fontSize: 16.0,
                          hintColor: Colors.grey,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'حقل مطلوب';
                            }
                            return null; // No errors
                          },
                        ),
                        MenuText(' : اختيار الموقع على الخارطة'),
                        CustomMenuItem(
                          context,
                          flag: showLocationMsg,
                          child: InkWell(
                            onTap: () async {
                              // Request location permission
                              PermissionStatus permissionStatus = await Permission.location.request();

                              LatLng initialLocation = const LatLng(33.5138, 36.2765); // Default to Damascus
                              bool useCurrentLocation = false;

                              if (permissionStatus.isGranted) {
                                // Get the current location if permission is granted
                                Position position = await Geolocator.getCurrentPosition();
                                initialLocation = LatLng(position.latitude, position.longitude);
                                useCurrentLocation = true;
                              }

                              final location = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => LocationPicker(
                                    initialLocation: initialLocation,
                                    useCurrentLocation: useCurrentLocation,
                                  ),
                                ),
                              );

                              if (location != null) {
                                setState(() {
                                  selectedLocation = location;
                                  latitude = selectedLocation!.latitude;
                                  longitude = selectedLocation!.longitude;
                                });
                              }
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                RotatedBox(
                                  quarterTurns: 1,
                                  child: Image.asset('assets/icons/arrow_down.png', scale: 2.0),
                                ),
                                Text(
                                  latitude == 0.0 && longitude == 0.0
                                      ? 'الموقع على الخارطة'
                                      : '${'$latitude'.substring(0, 5)} - ${'$longitude'.substring(0, 5)}',
                                  style: TextStyle(fontSize: 16.0, color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if(showLocationMsg) RequiredText(location: true),
                        MenuText(' : تاريخ الميلاد'),
                        CustomMenuItem(
                          context,
                          flag: showBirthDateMsg,
                          child: InkWell(
                            onTap: () {
                              showDatePicker(
                                context: context,
                                firstDate: DateTime(1900),
                                lastDate: DateTime.now(),
                                builder: (BuildContext context, Widget? child) {
                                  return Theme(
                                    data: ThemeData.light().copyWith(
                                      colorScheme: const ColorScheme.light(primary: HomeCareTheme.primaryColor), // Text color
                                      buttonTheme: const ButtonThemeData(textTheme: ButtonTextTheme.primary), // Button text color
                                    ),
                                    child: child!,
                                  );
                                },
                              ).then((value) {
                                setState(() {
                                  birthDate = value!.toString();
                                });
                              });
                            },
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Text(birthDate.isEmpty || birthDate == 'null' ? 'قم باختيار تاريخ الميلاد' : 'تاريخ ميلادك : ${birthDate.substring(0, 10)}', style: TextStyle(fontSize: 16.0, color: Colors.grey[600])),
                            ),
                          ),
                        ),
                        if(showBirthDateMsg) RequiredText(),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 50.0),
                          child: Center(
                            child: CustomButton(
                              width: HomeCareSize.width(context),
                              height: 50.0,
                              onPressed: loading ? () {} : validateAndSubmit,
                              title: loading ? HCIndicator() : const Text('حفظ التغييرات', style: TextStyle(fontSize: 16.0, color: Colors.white)),
                              backgroundColor: HomeCareTheme.primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool loading = false;

  void validateAndSubmit() async {
    // Perform form validation
    final isFormValid = formKey.currentState!.validate();

    // Validate custom fields
    bool isCustomValid = true;

    setState(() {
      // Birthdate validation
      if (birthDate.isEmpty) {
        showBirthDateMsg = true;
        isCustomValid = false;
      } else {
        showBirthDateMsg = false;
      }

      // City selector validation
      /*if (!citySelected) {
        showCityMsg = true;
        isCustomValid = false;
      } else {
        showCityMsg = false;
      }*/

      // Region selector validation
      if (selectedRegionId == 0) {
        showRegionMsg = true;
        isCustomValid = false;
      } else {
        showRegionMsg = false;
      }

      // Location validation
      if (latitude == 0.0 && longitude == 0.0) {
        showLocationMsg = true;
        isCustomValid = false;
      } else {
        showLocationMsg = false;
      }
    });

    // Check overall validation
    if (isFormValid && isCustomValid) {
      // All validations passed
      setState(() {
        loading = true;
      });

      debugPrint('First name     : ${nameCtrl.text}');
      debugPrint('Last name      : ${lastNameCtrl.text}');
      debugPrint('Date Birth     : $birthDate');
      debugPrint('Alt Phone      : ${phoneCtrl.text}');
      debugPrint('Occupation     : ${occupationCtrl.text}');
      debugPrint('Region Id      : $selectedRegionId');
      debugPrint('Region Details : ${addressCtrl.text}');
      String token = sharedPrefsController.getToken();
      var result = await ConnectionController.updateSupporterPersonalInfo(
        firstName: nameCtrl.text,
        lastName: lastNameCtrl.text,
        token: token,
        dateOfBirth: birthDate.substring(0, 10),
        occupation: occupationCtrl.text,
        personalImageId: null,
        latitude: latitude,
        longitude: longitude,
        regionId: selectedRegionId,
        details: addressCtrl.text,
      );
      setState(() {
        loading = false;
      });
      if(sharedPrefsController.sessionTerminated()) {
        HomeCareStyle.showReLoginDialog(context);
      } else if(result) {
        String fullName = '${nameCtrl.text} ${lastNameCtrl.text}';
        sharedPrefsController.saveFullName(fullName: fullName);
        HomeCareStyle.showSnackBar(
          context,
          success: true,
          content: 'تم الطلب بنجاح',
          icon: Icons.check_circle,
        );
        sharedPrefsController.saveFirstName(firstName: nameCtrl.text);
        sharedPrefsController.saveLastName(lastName: lastNameCtrl.text);
        sharedPrefsController.saveBirthDate(date: birthDate.substring(0, 10));
        sharedPrefsController.saveOccupation(occupation: occupationCtrl.text);
        sharedPrefsController.saveLatitude(latitude: latitude);
        sharedPrefsController.saveLongitude(longitude: longitude);
        sharedPrefsController.saveRegionId(regionId: selectedRegionId);
        sharedPrefsController.saveCityId(cityId: selectedCityId);
        sharedPrefsController.saveAddressDetails(details: addressCtrl.text);
        Navigator.pop(context);
      } else {
        HomeCareStyle.showSnackBar(
          context,
          content: sharedPrefsController.getMSG(),
          icon: Icons.info_outline,
        );
      }
    }
  }

  Padding RequiredText({bool? location = false}) => Padding(
    padding: const EdgeInsets.only(right: 10.0),
    child: Align(
      alignment: Alignment.centerRight,
      child: Text(location! ? 'الموقع مطلوب' : 'حقل مطلوب', style: TextStyle(fontSize: 12.0, color: Colors.red[900]!)),
    ),
  );

  initializeData() {
    nameCtrl.text = sharedPrefsController.getFirstName();
    lastNameCtrl.text = sharedPrefsController.getLastName();
    phoneCtrl.text = '0${sharedPrefsController.getMobileNumber()}';
    occupationCtrl.text = sharedPrefsController.getOccupation();
    birthDate = sharedPrefsController.getBirthDate();
    addressCtrl.text = sharedPrefsController.getAddressDetails();
    latitude = sharedPrefsController.getLatitude();
    longitude = sharedPrefsController.getLongitude();
    selectedCityId = sharedPrefsController.getCityId();
    selectedRegionId = sharedPrefsController.getRegionId();
    debugPrint('city id   ===> $selectedCityId');
    debugPrint('region id ===> $selectedRegionId');
    debugPrint('length ===> ${citiesController.cities.length}');
    debugPrint('length ===> ${regionsController.regions1.length}');
    selectedCity = citiesController.cities.isEmpty
        ? ''
        : citiesController.cities
        .firstWhere(
          (city) => selectedCityId == city.id,
      orElse: () => City(id: 0, name: ''), //fallback city
    ).name;

    selectedRegion = selectedCityId == 1
        ? regionsController.regions1.isEmpty
        ? ''
        : regionsController.regions1
        .firstWhere(
          (region) => selectedRegionId == region.id,
      orElse: () => Region(id: 0, name: ''), //fallback region
    ).name
        : regionsController.regions2.isEmpty
        ? ''
        : regionsController.regions2
        .firstWhere(
          (region) => selectedRegionId == region.id,
      orElse: () => Region(id: 0, name: ''), //fallback region
    ).name;

    debugPrint('city    ===> $selectedCity');
    debugPrint('Region  ===> $selectedRegion');
  }

}
