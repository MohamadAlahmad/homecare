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
import 'package:homecare/mvc/view/patient/profile_pages/my_profile_screen.dart';
import 'package:homecare/widgets/buttons.dart';
import 'package:homecare/widgets/code_textfield.dart';
import 'package:homecare/widgets/custom_circular_progress_indicator.dart';
import 'package:homecare/widgets/custom_dropdown_button.dart';
import 'package:homecare/widgets/custom_text_field.dart';
import 'package:homecare/widgets/header_widget.dart';
import 'package:homecare/widgets/menu_text.dart';
import 'package:homecare/widgets/progress_indicator.dart';
import 'package:permission_handler/permission_handler.dart';

class AddPatientScreen extends StatefulWidget {
  const AddPatientScreen({super.key});

  @override
  State<AddPatientScreen> createState() => _AddPatientScreenState();
}

class _AddPatientScreenState extends State<AddPatientScreen> {

  final PageController pageController = PageController();
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController lastNameCtrl = TextEditingController();
  final TextEditingController phoneCtrl = TextEditingController();
  final TextEditingController alterPhoneCtrl = TextEditingController();
  final TextEditingController birthdayCtrl = TextEditingController();
  final TextEditingController addressCtrl = TextEditingController();
  CitiesController citiesController = Get.find();
  RegionsController regionsController = Get.find();
  SharedPrefsController sharedPrefsController = SharedPrefsController();
  final formKey = GlobalKey<FormState>();

  String? selectedGender;
  String birthDate = '';
  LatLng? selectedLocation;
  int genderValue = 1;
  String selectedCity = '';
  int selectedCityId = 0;
  bool citySelected = false;
  bool regionSelected = false;
  String selectedRegion = '';
  int selectedRegionId = 0;

  bool showGenderMsg = false;
  bool showBirthDateMsg = false;
  bool showLocationMsg = false;
  bool showCityMsg = false;
  bool showRegionMsg = false;

  double latitude = 0.0;
  double longitude = 0.0;

  @override
  void initState() {
    selectedGender = 'ذكر';
    super.initState();
  }

  void onGenderSelected(String? newGender) {
    setState(() {
      selectedGender = newGender;
      genderValue = (newGender == 'ذكر') ? 1 : 2;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SafeArea(
          child: Stack(
            children: [
              PageView(
                controller: pageController,
                scrollDirection: Axis.vertical,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  InfoScreen(),
                  VerifyScreen(),
                ],
              ),
              HeaderWidget(context, title: 'إضافة مريض'),
            ],
          ),
        ),
      ),
    );
  }

  bool loading = false;
  Widget InfoScreen() {
    return Padding(
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
              const Padding(
                padding: EdgeInsets.all(10.0),
                child: Center(child: Text('إضافة صورة', style: TextStyle(fontSize: 16.0))),
              ),
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
              MenuText(' : الجنس'),
              CustomMenuItem(
                context,
                flag: showGenderMsg,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    DropdownButton<String>(
                      value: selectedGender,
                      underline: const SizedBox(),
                      icon: Padding(
                        padding: const EdgeInsets.only(left: 25.0),
                        child: Image.asset('assets/icons/arrow_down.png', scale: 2.0),
                      ),
                      items: const <DropdownMenuItem<String>>[
                        DropdownMenuItem(value: 'ذكر', child: Text('ذكر')),
                        DropdownMenuItem(value: 'أنثى', child: Text('أنثى')),
                      ],
                      onChanged: onGenderSelected,
                    ),
                    const VerticalDivider(
                      indent: 10.0,
                      endIndent: 10.0,
                      color: Colors.grey,
                    ),
                    const Spacer(),
                    Text('قم باختيار الجنس', style: TextStyle(fontSize: 16.0, color: Colors.grey[600])),
                  ],
                ),
              ),
              if(showGenderMsg) RequiredText(),
              MenuText(' : رقم الهاتف'),
              CustomNumberTextField(
                context,
                controller: phoneCtrl,
                hintText: '  رقم الهاتف',
                fontSize: 16.0,
                hintColor: Colors.grey[600]!,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'حقل مطلوب';
                  } else if (value.length != 9) {
                    return 'يجب أن يتكون الرقم من 9 أرقام بالضبط';
                  } else if (!value.startsWith('9')) {
                    return 'يجب أن يبدأ الرقم بـ 9';
                  }
                  return null; // No errors
                },
              ),
              MenuText(' : رقم الهاتف البديل'),
              CustomNumberTextField(
                context,
                controller: alterPhoneCtrl,
                hintText: '  رقم الهاتف البديل',
                fontSize: 16.0,
                hintColor: Colors.grey[600]!,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'حقل مطلوب';
                  } else if (value.length != 9) {
                    return 'يجب أن يتكون الرقم من 9 أرقام بالضبط';
                  } else if (!value.startsWith('9')) {
                    return 'يجب أن يبدأ الرقم بـ 9';
                  }
                  return null; // No errors
                },
              ),
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      showCityMsg ? Text('حقل مطلوب', style: TextStyle(fontSize: 12.0, color: Colors.red[900]!)) : const SizedBox(),
                      MenuText(' : المدينة'),
                    ],
                  ),
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
                        citySelected = true;
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
                        regionSelected = true;
                        selectedRegionId = value?.id ?? 0;
                      });
                    },
                    hintText: 'المنطقة',
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
              const SizedBox(height: 10.0),
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
                    onPressed: validateAndSubmit,
                    title: const Text('حفظ التغييرات', style: TextStyle(fontSize: 16.0, color: Colors.white)),
                    backgroundColor: HomeCareTheme.primaryColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  final SharedPrefsController prefsController = SharedPrefsController();
  TextEditingController codeController1 = TextEditingController();
  TextEditingController codeController2 = TextEditingController();
  TextEditingController codeController3 = TextEditingController();
  TextEditingController codeController4 = TextEditingController();
  final formKey2 = GlobalKey<FormState>();
  Widget VerifyScreen() {
    return Form(
      key: formKey2,
      child: Column(
        children: [
          const SizedBox(height: 100.0),
          Text('أدخل الكود المرسَل إلى الرقم'),
          Text('+963 ${formatPhoneNumber(phoneCtrl.text)}', style: TextStyle(fontSize: 16.0, color: Colors.black, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          SizedBox(height: MediaQuery.of(context).size.height * 0.03),
          CodeTextField(
            controller1: codeController1,
            controller2: codeController2,
            controller3: codeController3,
            controller4: codeController4,
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.1),
          RegisterButton(
            context,
            onPressed: loading ? () {} : pressMethod,
            title: loading ? HCIndicator() : Text('تأكيد', style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  validateAndSubmit() {
    // Perform form validation
    final isFormValid = formKey.currentState!.validate();

    // Validate custom fields
    bool isCustomValid = true;

    setState(() {
      // Gender validation
      if (selectedGender == null) {
        showGenderMsg = true;
        isCustomValid = false;
      } else {
        showGenderMsg = false;
      }

      // Birthdate validation
      if (birthDate.isEmpty) {
        showBirthDateMsg = true;
        isCustomValid = false;
      } else {
        showBirthDateMsg = false;
      }

      // City selector validation
      if (!citySelected) {
        showCityMsg = true;
        isCustomValid = false;
      } else {
        showCityMsg = false;
      }

      // Region selector validation
      if (!regionSelected) {
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
      /*setState(() {
        loading = true;
      });*/

      debugPrint('First name  : ${nameCtrl.text}');
      debugPrint('Last name   : ${lastNameCtrl.text}');
      debugPrint('Date Birth  : $birthDate');
      debugPrint('Alt Phone   : ${alterPhoneCtrl.text}');
      debugPrint('Gender      : $genderValue');
      debugPrint('Region Id   : $selectedRegionId');
      String fullName = '${sharedPrefsController.getFirstName()} ${sharedPrefsController.getLastName()}';
      HomeCareStyle.showInfoRequiredDialog(
        context,
        title: 'الموافقة الالكترونية من قِبل المريض ${nameCtrl.text} ${lastNameCtrl.text} لإدارة حسابه من قِبل ${sharedPrefsController.getFirstName()} ${sharedPrefsController.getLastName()} ',
        buttonTitle: 'الموافقة',
        content: '''من خلال النقر على "الموافقة" أقر بأنني أنا (${nameCtrl.text} ${lastNameCtrl.text}) قرأت وفهمت سياسة الخصوصية وشروط الاستخدام الخاصة بتطبيق قلب ALB ، و أوافق على جمع واستخدام بياناتي الشخصية للأغراض المحددة في سياسة الخصوصية وأوافق علي إدارة حسابي من قِبل ${sharedPrefsController.getFirstName()} ${sharedPrefsController.getLastName()} ، وأعلم أنني أستطيع سحب موافقتي على إدارة حسابي في أي وقت عن طريق التواصل مع الدعم الفني بعد تأكيدي لهم بملكية الحساب ''',
        onYesPressed: () async {
          Navigator.pop(context);
          HomeCareStyle.showLoadingDialog(context);
          var result = await ConnectionController.requestAccountManagement(
            patientDialCode: '+963',
            patientPhoneNumber: phoneCtrl.text,
            patientName: fullName,
            token: sharedPrefsController.getToken(),
          );
          Navigator.pop(context);
          if(result) {
            pageController.nextPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          } else {
            HomeCareStyle.showSnackBar(
              context,
              content: prefsController.getMSG(),
              icon: CupertinoIcons.exclamationmark_circle_fill,
            );
          }
        },
      );
    }
  }

  pressMethod () async {
    FocusScope.of(context).unfocus();
    if(codeController1.text.isNotEmpty && codeController2.text.isNotEmpty && codeController3.text.isNotEmpty && codeController4.text.isNotEmpty) {
      setState(() {
        loading = true;
      });
      String code = codeController1.text + codeController2.text + codeController3.text + codeController4.text;
      debugPrint('User Phone ::: ${prefsController.getMobileNumber()}');
      debugPrint('User Type  ::: ${prefsController.getUserType()}');
      setState(() {
        loading = true;
      });

      debugPrint('First name  : ${nameCtrl.text}');
      debugPrint('Last name   : ${lastNameCtrl.text}');
      debugPrint('Date Birth  : $birthDate');
      debugPrint('Alt Phone   : ${alterPhoneCtrl.text}');
      debugPrint('Gender      : $genderValue');
      debugPrint('Region Id   : $selectedRegionId');
      String token = sharedPrefsController.getToken();
      var result = await ConnectionController.addPatient(
        firstName: nameCtrl.text,
        lastName: lastNameCtrl.text,
        token: token,
        dateOfBirth: birthDate.substring(0, 10),
        dialCodeForAlternativePhoneNumber: '+963',
        alternativePhoneNumber: alterPhoneCtrl.text,
        dialCode: '+963',
        phoneNumber: phoneCtrl.text,
        gender: genderValue,
        personalImageId: null,
        latitude: latitude,
        longitude: longitude,
        regionId: selectedRegionId,
        details: addressCtrl.text,
        code: code,
      );

      setState(() {
        loading = false;
      });

      if(sharedPrefsController.sessionTerminated()) {
        HomeCareStyle.showReLoginDialog(context);
      } else if(result == 'true') {
        HomeCareStyle.showSnackBar(
          context,
          success: true,
          content: 'تم الطلب بنجاح',
          icon: Icons.check_circle,
        );
        Navigator.pop(context);
      } else if(result == 'enter-info') {
        HomeCareStyle.showInfoRequiredDialog(
          context,
          title: 'يجب عليك إدخال معلوماتك الشخصية أولاً',
          buttonTitle: 'نعم',
          content: 'هل تريد إدخال المعلومات الشخصية لإكمال الحجز ؟',
          onYesPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) =>
                MyProfileScreen(
                  youDidNotEnterYourInfo: true,
                  forBookingThroughPackage: false,
                ),
            ));
          },
        );
      } else {
        HomeCareStyle.showSnackBar(
          context,
          content: sharedPrefsController.getMSG(),
          icon: Icons.info_outline,
        );
      }
    }
  }

  String formatPhoneNumber(String phoneNumber) {
    if (phoneNumber.length != 9) return phoneNumber;
    return '${phoneNumber.substring(0, 3)} ${phoneNumber.substring(3, 6)} ${phoneNumber.substring(6, 9)}';
  }

  Padding RequiredText({bool? location = false}) => Padding(
    padding: const EdgeInsets.only(right: 10.0),
    child: Align(
      alignment: Alignment.centerRight,
      child: Text(location! ? 'الموقع مطلوب' : 'حقل مطلوب', style: TextStyle(fontSize: 12.0, color: Colors.red[900]!)),
    ),
  );

  /*void validateAndSubmit() async {
    // Perform form validation
    final isFormValid = formKey.currentState!.validate();

    // Validate custom fields
    bool isCustomValid = true;

    setState(() {
      // Gender validation
      if (selectedGender == null) {
        showGenderMsg = true;
        isCustomValid = false;
      } else {
        showGenderMsg = false;
      }

      // Birthdate validation
      if (birthDate.isEmpty) {
        showBirthDateMsg = true;
        isCustomValid = false;
      } else {
        showBirthDateMsg = false;
      }

      // City selector validation
      if (!citySelected) {
        showCityMsg = true;
        isCustomValid = false;
      } else {
        showCityMsg = false;
      }

      // Region selector validation
      if (!regionSelected) {
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

    }
  }*/

}
