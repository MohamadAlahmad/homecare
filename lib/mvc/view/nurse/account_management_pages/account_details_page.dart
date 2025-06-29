// ignore_for_file: non_constant_identifier_names, use_build_context_synchronously

import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:homecare/core/utils/globals.dart';
import 'package:homecare/mvc/controller/cities_controller.dart';
import 'package:homecare/mvc/controller/connection_controller.dart';
import 'package:homecare/core/theme/homecare_style.dart';
import 'package:homecare/core/theme/themes.dart';
import 'package:homecare/core/utils/location_picker.dart';
import 'package:homecare/mvc/controller/regions_controller.dart';
import 'package:homecare/mvc/controller/shared_preferences_controller.dart';
import 'package:homecare/mvc/model/api/city.dart';
import 'package:homecare/mvc/model/api/region.dart';
import 'package:homecare/mvc/view/nurse/home_nurse.dart';
import 'package:homecare/widgets/buttons.dart';
import 'package:homecare/widgets/custom_dropdown_button.dart';
import 'package:homecare/widgets/custom_text_field.dart';
import 'package:homecare/widgets/header_widget.dart';
import 'package:homecare/widgets/menu_text.dart';
import 'package:homecare/widgets/nurse/upload_button.dart';
import 'package:homecare/widgets/profile_image_widget.dart';
import 'package:homecare/widgets/progress_indicator.dart';
import 'package:permission_handler/permission_handler.dart';

class NurseAccountDetailsPage extends StatefulWidget {
  const NurseAccountDetailsPage({super.key});

  @override
  State<NurseAccountDetailsPage> createState() => _NurseAccountDetailsPageState();
}

class _NurseAccountDetailsPageState extends State<NurseAccountDetailsPage> {
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController lastNameCtrl = TextEditingController();
  final TextEditingController phoneCtrl = TextEditingController();
  final TextEditingController alterPhoneCtrl = TextEditingController();
  final TextEditingController birthdayCtrl = TextEditingController();
  final TextEditingController addressCtrl = TextEditingController();
  SharedPrefsController sharedPrefsController = SharedPrefsController();
  CitiesController citiesController = Get.find();
  RegionsController regionsController = Get.find();
  final formKey = GlobalKey<FormState>();
  String selectedCity = '';
  int selectedCityId = 1;
  String selectedRegion = '';
  int selectedRegionId = 0;
  String? selectedGender;
  String birthDate = '';
  LatLng? selectedLocation;
  late int genderValue;

  bool showGenderMsg = false;
  bool showBirthDateMsg = false;
  bool showLocationMsg = false;
  bool showCityMsg = false;
  bool showRegionMsg = false;

  double latitude = 0.0;
  double longitude = 0.0;

  String? profileImagePath; // Renamed to profileImagePath
  List<String?> filePaths = List.filled(6, null);
  List<String?> fileNames = List.filled(6, null);
  List<int> fileIds = [];
  List<String> fileUrls = [];

  bool loading = false;
  List<bool> fileLoadingStates = List.filled(6, false); // Track loading state for each file

  Future<void> pickFile(int fileIndex) async {
    final androidInfo = await DeviceInfoPlugin().androidInfo;
    final sdkInt = androidInfo.version.sdkInt;
    PermissionStatus status;

    if (sdkInt >= 33) {
      // For Android 13 and above, use READ_MEDIA_IMAGES or appropriate permission
      status = await Permission.photos.request();
    } else {
      // For Android 12 and below, use READ_EXTERNAL_STORAGE
      status = await Permission.storage.request();
    }

    if (status.isGranted) {
      FilePickerResult? result = await FilePicker.platform.pickFiles();
      if (result != null) {
        setState(() {
          filePaths[fileIndex] = result.files.single.path;
          fileNames[fileIndex] = result.files.single.name;
          fileLoadingStates[fileIndex] = true; // Set loading state to true
        });
        await uploadAttachment(fileIndex);
        setState(() {
          fileLoadingStates[fileIndex] = false; // Set loading state to false after upload
        });
      }
    } else if (status.isDenied) {
      Fluttertoast.showToast(
        msg: "الرجاء السماح بالوصول إلى التخزين لاختيار ملف",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.grey[600],
        textColor: Colors.white,
        fontSize: 16.0,
      );
    } else if (status.isPermanentlyDenied) {
      Fluttertoast.showToast(
        msg: "تم رفض الوصول إلى التخزين بشكل دائم. يرجى تمكين الأذن من إعدادات التطبيق.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.grey[600],
        textColor: Colors.white,
        fontSize: 16.0,
      );
      await openAppSettings();
    }
  }

  Future<void> uploadAttachment(int fileIndex) async {
    setState(() {
      loading = true;
      fileLoadingStates[fileIndex] = true;
    });

    try {
      String? filePath = filePaths[fileIndex];

      if (filePath == null) {
        setState(() {
          loading = false;
          fileLoadingStates[fileIndex] = false;
        });
        return;
      }

      if (fileIds[fileIndex] == -1 && fileUrls[fileIndex].isEmpty) {
        // New file upload
        int result = await ConnectionController.uploadFile(
          folderName: 2,
          token: sharedPrefsController.getToken(),
          filePath: filePath,
        );

        if (result != -1) {
          showSuccessToast("تم تحميل الملف");
          setState(() {
            fileIds[fileIndex] = result;
          });
          debugPrint('File ID for index $fileIndex: $result');
        } else {
          showErrorToast("فشل تحميل الملف");
        }
      } else {
        // Update existing file - chain operations properly
        bool deleteSuccess = await ConnectionController.deleteFile(
          token: sharedPrefsController.getToken(),
          id: fileIds[fileIndex],
        );

        if (deleteSuccess) {
          int uploadResult = await ConnectionController.uploadFile(
            folderName: 2,
            token: sharedPrefsController.getToken(),
            filePath: filePath,
          );

          if (uploadResult != -1) {
            showSuccessToast("تم تحديث الملف");
            setState(() {
              fileIds[fileIndex] = uploadResult;
            });
            debugPrint('Updated File ID for index $fileIndex: $uploadResult');
          } else {
            showErrorToast("فشل تحديث الملف");
          }
        } else {
          showErrorToast("حدث خطأ أثناء حذف الملف القديم");
        }
      }
    } catch (e) {
      debugPrint('Error in uploadAttachment: $e');
      showErrorToast("حدث خطأ غير متوقع");
    } finally {
      setState(() {
        loading = false;
        fileLoadingStates[fileIndex] = false;
      });
    }
  }

  void showSuccessToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.grey[600],
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  void showErrorToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.red[600],
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  Future<void> pickImage() async {
    final androidInfo = await DeviceInfoPlugin().androidInfo;
    final sdkInt = androidInfo.version.sdkInt;

    PermissionStatus status;

    if (sdkInt >= 33) {
      // For Android 13 and above, use READ_MEDIA_IMAGES
      status = await Permission.photos.request();
    } else {
      // For Android 12 and below, use READ_EXTERNAL_STORAGE
      status = await Permission.storage.request();
    }

    if (status.isGranted) {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null) {
        setState(() {
          profileImagePath = result.files.single.path;
        });
        uploadProfileImage(profileImagePath!);
      }
    } else if (status.isDenied) {
      Fluttertoast.showToast(
        msg: "الرجاء السماح بالوصول إلى التخزين لاختيار صورة",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.grey[600],
        textColor: Colors.white,
        fontSize: 16.0,
      );
    } else if (status.isPermanentlyDenied) {
      Fluttertoast.showToast(
        msg: "تم رفض الوصول إلى التخزين بشكل دائم. يرجى تمكين الأذن من إعدادات التطبيق.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.grey[600],
        textColor: Colors.white,
        fontSize: 16.0,
      );
      await openAppSettings();
    }
  }

  Future<void> uploadProfileImage(String filePath) async {
    setState(() {
      loading = true;
    });

    int result = await ConnectionController.uploadFile(
      folderName: 1,
      token: sharedPrefsController.getToken(),
      filePath: filePath,
    );
    setState(() {
      loading = false;
    });

    if (result != -1) {
      Fluttertoast.showToast(
        msg: "تم تحميل الصورة",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.grey[600],
        textColor: Colors.white,
        fontSize: 16.0,
      );
      // Update the profile image URL in shared preferences
      //sharedPrefsController.saveProfileImageUrl(imageUrl: filePath);
    } else {
      Fluttertoast.showToast(
        msg: "فشل تحميل الصورة",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.grey[600],
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  @override
  void initState() {
    initializeData();
    super.initState();
  }

  initializeData() {
    nameCtrl.text = sharedPrefsController.getFirstName();
    lastNameCtrl.text = sharedPrefsController.getLastName();
    genderValue = sharedPrefsController.getGender();
    if (genderValue == 0) genderValue = 1;
    selectedGender = genderValue == 2 ? 'أنثى' : 'ذكر';
    phoneCtrl.text = '${sharedPrefsController.getMobileNumber()}+';
    alterPhoneCtrl.text = sharedPrefsController.getAltMobileNumber();
    birthDate = sharedPrefsController.getBirthDate();
    addressCtrl.text = sharedPrefsController.getAddressDetails();
    latitude = sharedPrefsController.getLatitude();
    longitude = sharedPrefsController.getLongitude();
    selectedCityId = sharedPrefsController.getCityId();
    selectedRegionId = sharedPrefsController.getRegionId();

    // Load the lists of attachments' Ids and Urls
    fileIds = sharedPrefsController.getListOfAttachmentsIds();
    fileUrls = sharedPrefsController.getListOfAttachmentsUrls();

    // Update the filePaths and fileNames lists based on the loaded data
    for (int i = 0; i < 6; i++) {
      if (fileUrls[i].isNotEmpty) {
        filePaths[i] = fileUrls[i];
        fileNames[i] = fileUrls[i].split('/').last; // Extract the file name from the URL
      }
    }

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
    for(int i = 0; i< fileIds.length; i++) {
      print('[${fileIds[i]}] -');
    }
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
                            Align(
                              alignment: Alignment.center,
                              child: profileImagePath != null
                                  ? CircleAvatar(
                                radius: 75.0,
                                backgroundColor: HomeCareTheme.secondaryColor,
                                backgroundImage: FileImage(File(profileImagePath!)),
                              ) : ProfileImageWidget(
                                sharedPrefsController: sharedPrefsController,
                                width: 150.0,
                                height: 150.0,
                              ),
                            ),
                            Align(
                              alignment: Alignment.center,
                              child: Padding(
                                padding: const EdgeInsets.only(right: 120.0, top: 75.0),
                                child: IconButton(
                                  onPressed: pickImage,
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
                        if (showGenderMsg) RequiredText(),
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
                        const SizedBox(height: 10.0),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            MenuText(' : المدينة'),
                            const SizedBox(height: 5.0),
                            CustomDropdownWidget<City>(
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
                              showMsg: showRegionMsg,
                              items: selectedCityId == 1 ? regionsController.regions1 : regionsController.regions2,
                              selectedItem: selectedRegion.isEmpty
                                  ? null
                                  : selectedCityId == 1
                                  ? regionsController.regions1.firstWhere(
                                    (region) => region.name == selectedRegion,
                                orElse: () => regionsController.regions1[0],
                              )
                                  : regionsController.regions2.firstWhere(
                                    (region) => region.name == selectedRegion,
                                orElse: () => regionsController.regions2[0],
                              ),
                              onItemSelected: (Region? value) {
                                setState(() {
                                  selectedRegion = value?.name ?? '';
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
                        if (showLocationMsg) RequiredText(location: true),
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
                                      colorScheme: const ColorScheme.light(primary: HomeCareTheme.primaryColor),
                                      buttonTheme: const ButtonThemeData(textTheme: ButtonTextTheme.primary),
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
                        if (showBirthDateMsg) RequiredText(),
                        const SizedBox(height: 20.0),
                        MenuText(' : إرفاق المستندات'),
                        Row(
                          children: [
                            for (int i = 0; i < 3; i++)
                              UploadButton(
                                onPressed: () => pickFile(i),
                                filePath: filePaths[i],
                                fileName: fileNames[i],
                                loading: fileLoadingStates[i],
                              ),
                          ],
                        ),
                        Row(
                          children: [
                            for (int i = 3; i < 6; i++)
                              UploadButton(
                                onPressed: () => pickFile(i),
                                filePath: filePaths[i],
                                fileName: fileNames[i],
                                loading: fileLoadingStates[i], // Pass the loading state
                              ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 50.0),
                          child: Center(
                            child: CustomButton(
                              width: HomeCareSize.width(context),
                              height: 50.0,
                              onPressed: loading ? () {} : validateAndSubmit,
                              title: loading ? HCIndicator() : const Text('حفظ', style: TextStyle(fontSize: 16.0, color: Colors.white)),
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

      String token = sharedPrefsController.getToken();
      var result = await ConnectionController.updateNursePersonalInfo(
        firstName: nameCtrl.text,
        lastName: lastNameCtrl.text,
        token: token,
        dateOfBirth: birthDate.substring(0, 10),
        dialCodeForAlternativePhoneNumber: '+963',
        alternativePhoneNumber: alterPhoneCtrl.text,
        gender: genderValue,
        personalImageId: sharedPrefsController.getIdOfProfileImage(),
        attachmentIds: fileIds,
        latitude: latitude,
        longitude: longitude,
        regionId: selectedRegionId,
        details: addressCtrl.text,
      );
      setState(() {
        loading = false;
      });
      if (sharedPrefsController.sessionTerminated()) {
        HomeCareStyle.showReLoginDialog(context);
      } else if (result) {
        String fullName = '${nameCtrl.text} ${lastNameCtrl.text}';
        sharedPrefsController.saveFullName(fullName: fullName);
        sharedPrefsController.setMustFillInfo(flag: false);
        HomeCareStyle.showSnackBar(
          context,
          success: true,
          content: 'تم الطلب بنجاح',
          icon: Icons.check_circle,
        );
        sharedPrefsController.saveFirstName(firstName: nameCtrl.text);
        sharedPrefsController.saveLastName(lastName: lastNameCtrl.text);
        sharedPrefsController.saveBirthDate(date: birthDate.substring(0, 10));
        debugPrint('I SAVE ###  ${alterPhoneCtrl.text}');
        sharedPrefsController.saveAltMobileNumber(altMobile: alterPhoneCtrl.text);
        sharedPrefsController.saveGender(gender: genderValue);
        sharedPrefsController.saveLatitude(latitude: latitude);
        sharedPrefsController.saveLongitude(longitude: longitude);
        sharedPrefsController.saveRegionId(regionId: selectedRegionId);
        sharedPrefsController.saveCityId(cityId: selectedCityId);
        sharedPrefsController.saveAddressDetails(details: addressCtrl.text);

        // Save the updated lists
        sharedPrefsController.saveListOfAttachmentsUrls(urls: filePaths.map((path) => path ?? '').toList());
        sharedPrefsController.saveListOfAttachmentsIds(ids: fileIds);

        Navigator.pop(context);
        pageNurseController.animateToPage(2,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutQuad,
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

  Padding RequiredText({bool? location = false}) => Padding(
    padding: const EdgeInsets.only(right: 10.0),
    child: Align(
      alignment: Alignment.centerRight,
      child: Text(location! ? 'الموقع مطلوب' : 'حقل مطلوب', style: TextStyle(fontSize: 12.0, color: Colors.red[900]!)),
    ),
  );

}
