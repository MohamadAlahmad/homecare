import 'package:device_info_plus/device_info_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:homecare/core/theme/homecare_style.dart';
import 'package:homecare/core/theme/themes.dart';
import 'package:homecare/mvc/controller/cities_controller.dart';
import 'package:homecare/mvc/controller/connection_controller.dart';
import 'package:homecare/mvc/controller/regions_controller.dart';
import 'package:homecare/mvc/controller/shared_preferences_controller.dart';
import 'package:homecare/mvc/model/api/city.dart';
import 'package:homecare/mvc/model/api/lab_model.dart';
import 'package:homecare/mvc/model/api/lab_test_model.dart';
import 'package:homecare/mvc/model/api/nurse.dart';
import 'package:homecare/mvc/model/api/region.dart';
import 'package:homecare/mvc/view/patient/main_services/booking_details_screen.dart';
import 'package:homecare/widgets/buttons.dart';
import 'package:homecare/widgets/custom_circular_progress_indicator.dart';
import 'package:homecare/widgets/custom_dropdown.dart';
import 'package:homecare/widgets/custom_text_field.dart';
import 'package:homecare/widgets/expanded_list.dart';
import 'package:homecare/widgets/header_widget.dart';
import 'package:homecare/widgets/message_widget.dart';
import 'package:homecare/widgets/custom_item_card.dart';
import 'package:homecare/widgets/nurse/upload_button.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:image_picker/image_picker.dart';

class BookingScreen extends StatefulWidget {
  final int serviceId;
  final num price;
  final bool isNursingService;
  final bool? isLabService;
  const BookingScreen({super.key, required this.serviceId, required this.price, required this.isNursingService, this.isLabService = false});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {

  DateTime focusedDay = DateTime.now();
  DateTime firstDay = DateTime(DateTime.now().year, DateTime.now().month);
  DateTime lastDay = DateTime(DateTime.now().year, DateTime.now().month + 1, 31);

  List<DateTime> selectedDays = [];

  final List<String> timeValues = [
    for (int i = 10; i <= 23; i++) ...[
      "${i.toString().padLeft(2, '0')}:00",
      if (i < 23) "${i.toString().padLeft(2, '0')}:30",
    ],
  ];

  final List<int> visitHoursCountList = [1, 3, 6, 10];

  String? selectedTime;
  int? visitHours;
  List<num> labTestsPrices = [];
  bool nursesExpanded = false;

  bool isValueEnabled(int value) {
    if (selectedTime == null) return true;

    final selectedHour = int.parse(selectedTime!.split(':')[0]);
    final selectedMinute = int.parse(selectedTime!.split(':')[1]);

    final totalMinutes = selectedHour * 60 + selectedMinute;
    final endOfDayMinutes = 24 * 60;

    if (value == 1) return true;
    if (value == 3 && totalMinutes + value * 60 <= endOfDayMinutes) return true;
    if (value == 6 && totalMinutes + value * 60 <= endOfDayMinutes) return true;
    if (value == 10 && totalMinutes + value * 60 <= endOfDayMinutes) return true;
    return false;
  }

  List<Nurse> listOfNurses = [];
  List<LabModel> listOfLabs = [];
  List<LabTestModel> listOfLabTests = [];

  bool isNursesFetched = false;
  bool isLabsFetched = false;
  bool isLabTestsFetched = false;

  getNurses() async {
    listOfNurses = await ConnectionController.getNurses(
      token: sharedPrefsController.getToken(),
      onlyMales: sharedPrefsController.getGender() == 1 ? true : false,
    ).then((list) {
      if(sharedPrefsController.sessionTerminated()) {
        HomeCareStyle.showReLoginDialog(context);
        return [];
      }
      return list;
    });
    setState(() {
      isNursesFetched = true;
    });
  }

  getLabs() async {
    listOfLabs = await ConnectionController.getLaboratories(
      token: sharedPrefsController.getToken(),
    ).then((list) {
      if(sharedPrefsController.sessionTerminated()) {
        HomeCareStyle.showReLoginDialog(context);
        return [];
      }
      return list;
    });
    setState(() {
      isLabsFetched = true;
    });
  }

  getLabTests() async {
    listOfLabTests = await ConnectionController.getLabTests(
      token: sharedPrefsController.getToken(),
    ).then((list) {
      if(sharedPrefsController.sessionTerminated()) {
        HomeCareStyle.showReLoginDialog(context);
        return [];
      }
      return list;
    });
    setState(() {
      isLabTestsFetched = true;
    });
  }

  @override
  void initState() {
    getNurses();
    getLabs();
    getLabTests();
    super.initState();
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
              HeaderWidget(context, title: 'التاريخ والوقت', iconColor: HomeCareTheme.primaryColor),
              Padding(
                padding: const .only(top: 45.0, left: 10.0, right: 10.0),
                child: SingleChildScrollView(
                  padding: .zero,
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      Column(
                        spacing: 10.0,
                        crossAxisAlignment: .end,
                        children: [
                          const SizedBox(height: 10.0),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: .circular(20.0),
                              color: HomeCareTheme.primaryColor.withValues(alpha: 0.1),
                            ),
                            child: TableCalendar(
                              firstDay: firstDay,
                              lastDay: lastDay,
                              focusedDay: focusedDay,
                              selectedDayPredicate: (day) => selectedDays.contains(day),
                              onDaySelected: (selectedDay, focusedDay) {
                                setState(() {
                                  if (widget.isLabService!) {
                                    // Allow only one day selection
                                    selectedDays = [selectedDay];
                                  } else {
                                    if (selectedDays.contains(selectedDay)) {
                                      // Remove the day if already selected
                                      selectedDays.remove(selectedDay);
                                    } else {
                                      // Add the selected day
                                      selectedDays.add(selectedDay);
                                    }
                                  }
                                  focusedDay = focusedDay;  // Update focused day
                                });
                              },
                              onPageChanged: (focusedDay) {
                                setState(() {
                                  this.focusedDay = focusedDay;  // Update only when navigating months
                                });
                              },
                              calendarFormat: CalendarFormat.month,
                              headerStyle: HeaderStyle(
                                formatButtonVisible: false,
                                leftChevronVisible: true,
                                rightChevronVisible: true,
                                leftChevronIcon: Icon(Icons.chevron_left, color: Colors.black),
                                rightChevronIcon: Icon(Icons.chevron_right, color: Colors.black),
                                titleTextStyle: TextStyle(color: Colors.black),
                              ),
                              calendarStyle: CalendarStyle(
                                isTodayHighlighted: true,
                                selectedDecoration: BoxDecoration(
                                  color: HomeCareTheme.primaryColor,
                                  shape: BoxShape.circle,
                                ),
                                todayTextStyle: TextStyle(color: Colors.black),
                                todayDecoration: BoxDecoration(
                                  color: HomeCareTheme.secondaryColor,
                                  shape: BoxShape.circle,
                                ),
                                holidayTextStyle: TextStyle(color: Colors.black),
                                defaultTextStyle: TextStyle(color: Colors.black),
                                weekendTextStyle: TextStyle(color: Colors.black),
                              ),
                              // Allow today and future days to be selectable
                              enabledDayPredicate: (day) {
                                // Allow today and future days (today is >= to now)
                                return !day.isBefore(DateTime.now().subtract(Duration(hours: 24)));
                              },
                            ),
                          ),
                          //const SizedBox(height: 20),
                          const Divider(indent: 20.0, endIndent: 20.0),
                          Text('اختيار الوقت', style: TextStyle(fontSize: 18.0, color: Colors.black)),
                          //const SizedBox(height: 20),
                          Directionality(
                            textDirection: TextDirection.rtl,
                            child: CustomDropdown(
                              selectedValue: selectedTime,
                              items: timeValues,
                              title: 'اختر الوقت',
                              onChanged: (newValue) {
                                setState(() {
                                  selectedTime = newValue;
                                  visitHours = null;
                                });
                              },
                            ),
                          ),
                          //const SizedBox(height: 10),
                          if(!widget.isNursingService && !widget.isLabService!) const Divider(indent: 20.0, endIndent: 20.0),
                          if(!widget.isNursingService && !widget.isLabService!) Text('اختيار عدد ساعات الزيارة', style: TextStyle(fontSize: 18.0, color: Colors.black)),
                          //if(!widget.isNursingService && !widget.isLabService!) const SizedBox(height: 20),
                          if(!widget.isNursingService && !widget.isLabService!) Directionality(
                            textDirection: TextDirection.rtl,
                            child: SizedBox(
                              height: 30.0,
                              child: ListView.builder(
                                physics: const BouncingScrollPhysics(),
                                scrollDirection: Axis.horizontal,
                                itemCount: visitHoursCountList.length,
                                itemBuilder: (context, index) {
                                  final value = visitHoursCountList[index];
                                  final isSelected = value == visitHours;

                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        visitHours = value;
                                      });
                                    },
                                    child: Container(
                                      width: 65.0,
                                      margin: const .symmetric(horizontal: 10.0),
                                      padding: const .fromLTRB(10.0, 5.0, 10.0, 0.0),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? HomeCareTheme.primaryColor
                                            : HomeCareTheme.primaryColor.withValues(alpha: 0.1),
                                        borderRadius: .circular(20.0),
                                      ),
                                      child: Center(
                                        child: Text(
                                          value.toString(),
                                          style: TextStyle(
                                            color: isSelected ? Colors.white : Colors.black,
                                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          //if(!widget.isNursingService && !widget.isLabService!) const SizedBox(height: 10),
                          const Divider(indent: 20.0, endIndent: 20.0),
                          AvailableNurses(),
                          if(widget.isLabService!) const Divider(indent: 20.0, endIndent: 20.0),
                          if(widget.isLabService!) LabTestTypes(),
                          if(widget.isLabService!) const Divider(indent: 20.0, endIndent: 20.0),
                          if(widget.isLabService!) AvailableLabs(),
                          //const SizedBox(height: 20),
                          const Divider(indent: 20.0, endIndent: 20.0),
                          Text('شرح الحالة (اختياري)', style: TextStyle(fontSize: 18.0, color: Colors.black)),
                          Padding(
                            padding: const .symmetric(horizontal: 5.0),
                            child: CustomTextField(
                              context,
                              controller: noteController,
                              fontSize: 14.0,
                              fillColor: HomeCareTheme.primaryColor.withValues(alpha: 0.1),
                              maxLines: 3,
                            ),
                          ),
                          const Divider(indent: 20.0, endIndent: 20.0),
                          Column(
                            crossAxisAlignment: .end,
                            children: [
                              Text('إرفاق ملف (اختياري)', style: TextStyle(fontSize: 18.0, color: Colors.black)),
                              const SizedBox(height: 5.0),
                              UploadButton(
                                onPressed: showUploadOptionsBottomSheet,
                                filePath: singleFilePath,
                                fileName: singleFileName,
                                loading: singleFileLoading,
                                forFillSession: true,
                              ),
                            ],
                          ),
                          const SizedBox(height: 10.0),
                          Padding(
                            padding: const .symmetric(horizontal: 10.0),
                            child: Row(
                              children: [
                                Directionality(
                                  textDirection: TextDirection.rtl,
                                  child: Switch(
                                    value: isSwitched,
                                    activeThumbColor: Colors.white,
                                    activeTrackColor: HomeCareTheme.primaryColor,
                                    inactiveThumbColor: HomeCareTheme.secondaryColor,
                                    inactiveTrackColor: Colors.white,
                                    onChanged: (bool newValue) {
                                      setState(() {
                                        isSwitched = newValue;
                                        if(!newValue) {
                                          showCityMsg = false;
                                          showRegionMsg = false;
                                          showAddressMsg = false;
                                        }
                                      });
                                    },
                                  ),
                                ),
                                const Spacer(),
                                Text('الحجز لموقع آخر', style: TextStyle(fontSize: 18.0, color: Colors.black)),
                              ],
                            ),
                          ),
                          ExpandedSection(
                            expand: isSwitched,
                            height: 215.0,
                            forwardDuration: const Duration(milliseconds: 700),
                            reverseDuration: const Duration(milliseconds: 700),
                            child: Container(
                              padding: .all(10.0),
                              //margin: .all(10.0),
                              decoration: BoxDecoration(
                                borderRadius: .circular(20.0),
                                color: HomeCareTheme.primaryColor.withValues(alpha: 0.1),
                              ),
                              child: Column(
                                mainAxisAlignment: .spaceBetween,
                                children: [
                                  Directionality(
                                    textDirection: TextDirection.rtl,
                                    child: CustomDropdown<City>(
                                      selectedValue: selectedCity.isEmpty
                                          ? null
                                          : citiesController.cities.firstWhere(
                                            (city) => city.name == selectedCity,
                                        //orElse: () => citiesController.cities[0],
                                      ),
                                      items: citiesController.cities,
                                      title: 'المدينة',
                                      onChanged: (City? value) {
                                        setState(() {
                                          selectedCityId = value?.id ?? 0;
                                          selectedCity = value?.name ?? '';
                                        });
                                      },
                                    ),
                                  ),
                                  showCityMsg ? Text('المدينة مطلوبة', style: TextStyle(fontSize: 12.0, color: Colors.red[900]!)) : const SizedBox(),
                                  Directionality(
                                    textDirection: TextDirection.rtl,
                                    child: CustomDropdown<Region>(
                                      selectedValue: selectedRegion.isEmpty
                                          ? null
                                          : selectedCityId == 1 ? regionsController.regions1.firstWhere(
                                            (region) => region.name == selectedRegion,
                                        orElse: () => regionsController.regions1[0],
                                      ) : regionsController.regions2.firstWhere(
                                            (region) => region.name == selectedRegion,
                                        orElse: () => regionsController.regions2[0],
                                      ),
                                      items: selectedCityId == 1 ? regionsController.regions1 : regionsController.regions2,
                                      title: 'المنطقة',
                                      onChanged: (Region? value) {
                                        setState(() {
                                          selectedRegionId = value?.id ?? 0;
                                          selectedRegion = value?.name ?? '';
                                        });
                                      },
                                    ),
                                  ),
                                  showRegionMsg ? Text('المنطقة مطلوبة', style: TextStyle(fontSize: 12.0, color: Colors.red[900]!)) : const SizedBox(),
                                  CustomTextFieldWithLabel(
                                    context,
                                    hintText: showAddressMsg ? 'العنوان مطلوب' : 'تفاصيل العنوان . . .',
                                    isDetails: true,
                                    controller: addressCtrl,
                                    fontSize: 16.0,
                                    borderRadius: 25.0,
                                    hintColor: showAddressMsg ? Colors.red[900]! : Colors.grey,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const .symmetric(horizontal: 10.0, vertical: 20.0),
                        child: RegisterButton(
                          context,
                          title: const Text('استمرار', style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
                          onPressed: pressMethod,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? singleFilePath;
  String? singleFileName;
  bool singleFileLoading = false;
  int singleFileId = -1;
  String singleFileUrl = '';
  final ImagePicker _imagePicker = ImagePicker();

  // New method to show bottom sheet with upload options
  void showUploadOptionsBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: .only(
              topLeft: Radius.circular(20.0),
              topRight: Radius.circular(20.0),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10.0),
              Container(
                width: 40.0,
                height: 4.0,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: .circular(2.0),
                ),
              ),
              const SizedBox(height: 10.0),
              ListTile(
                leading: Container(
                  padding: .all(8.0),
                  decoration: BoxDecoration(
                    color: HomeCareTheme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: .circular(10.0),
                  ),
                  child: Icon(
                    Icons.camera_alt,
                    color: HomeCareTheme.primaryColor,
                  ),
                ),
                title: Text(
                  'التقاط صورة من الكاميرا',
                  style: TextStyle(fontSize: 16.0),
                ),
                onTap: () {
                  Navigator.pop(context);
                  pickImageFromCamera();
                },
              ),
              ListTile(
                leading: Container(
                  padding: .all(8.0),
                  decoration: BoxDecoration(
                    color: HomeCareTheme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: .circular(10.0),
                  ),
                  child: Icon(
                    Icons.folder,
                    color: HomeCareTheme.primaryColor,
                  ),
                ),
                title: Text(
                  'اختيار ملف من الجهاز',
                  style: TextStyle(fontSize: 16.0),
                ),
                onTap: () {
                  Navigator.pop(context);
                  pickSingleFile();
                },
              ),
              const SizedBox(height: 20.0),
            ],
          ),
        );
      },
    );
  }

  // New method to pick image from camera
  Future<void> pickImageFromCamera() async {
    PermissionStatus status = await Permission.camera.request();

    if (status.isGranted) {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          singleFilePath = image.path;
          singleFileName = image.name;
          singleFileLoading = true;
        });
        await uploadSingleFile();
        setState(() {
          singleFileLoading = false;
        });
      }
    } else if (status.isDenied) {
      Fluttertoast.showToast(
        msg: "الرجاء السماح بالوصول إلى الكاميرا",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.grey[600],
        textColor: Colors.white,
        fontSize: 16.0,
      );
    } else if (status.isPermanentlyDenied) {
      Fluttertoast.showToast(
        msg: "تم رفض الوصول إلى الكاميرا بشكل دائم. يرجى تمكين الإذن من إعدادات التطبيق.",
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

  // Updated method to handle single file picking from storage
  Future<void> pickSingleFile() async {
    final androidInfo = await DeviceInfoPlugin().androidInfo;
    final sdkInt = androidInfo.version.sdkInt;
    PermissionStatus status;

    if (sdkInt >= 33) {
      status = await Permission.photos.request();
    } else {
      status = await Permission.storage.request();
    }

    if (status.isGranted) {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'webp'],
      );

      if (result != null) {
        setState(() {
          singleFilePath = result.files.single.path;
          singleFileName = result.files.single.name;
          singleFileLoading = true;
        });
        await uploadSingleFile();
        setState(() {
          singleFileLoading = false;
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
        msg: "تم رفض الوصول إلى التخزين بشكل دائم. يرجى تمكين الإذن من إعدادات التطبيق.",
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

  Future<void> uploadSingleFile() async {
    try {
      if (singleFilePath == null) return;

      if (singleFileId == -1 && singleFileUrl.isEmpty) {
        int result = await ConnectionController.uploadFile(
          folderName: 3, // 3 according to the enum of the backend , 3 for patient attachments
          token: sharedPrefsController.getToken(),
          filePath: singleFilePath!,
        );

        if (result != -1) {
          Fluttertoast.showToast(
            msg: "تم تحميل الملف",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.grey[600],
            textColor: Colors.white,
            fontSize: 16.0,
          );
          setState(() {
            singleFileId = result;
          });
          debugPrint('Single File ID: $result');
        } else {
          Fluttertoast.showToast(
            msg: "فشل تحميل الملف",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red[600],
            textColor: Colors.white,
            fontSize: 16.0,
          );
        }
      } else {
        // Update existing file
        bool deleteSuccess = await ConnectionController.deleteFile(
          token: sharedPrefsController.getToken(),
          id: singleFileId,
        );

        if (deleteSuccess) {
          int uploadResult = await ConnectionController.uploadFile(
            folderName: 3, // 3 according to the enum of the backend , 3 for patient attachments
            token: sharedPrefsController.getToken(),
            filePath: singleFilePath!,
          );

          if (uploadResult != -1) {
            Fluttertoast.showToast(
              msg: "تم تحديث الملف",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.grey[600],
              textColor: Colors.white,
              fontSize: 16.0,
            );
            setState(() {
              singleFileId = uploadResult;
            });
            debugPrint('Updated Single File ID: $uploadResult');
          } else {
            Fluttertoast.showToast(
              msg: "فشل تحديث الملف",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.red[600],
              textColor: Colors.white,
              fontSize: 16.0,
            );
          }
        } else {
          Fluttertoast.showToast(
            msg: "حدث خطأ أثناء حذف الملف القديم",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red[600],
            textColor: Colors.white,
            fontSize: 16.0,
          );
        }
      }
    } catch (e) {
      debugPrint('Error in uploadSingleFile: $e');
      Fluttertoast.showToast(
        msg: "حدث خطأ غير متوقع",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red[600],
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  int selectedNurseId = -1;
  Column AvailableNurses() {
    return Column(
      mainAxisSize: .min,
      crossAxisAlignment: .end,
      children: [
        Row(
          mainAxisAlignment: .spaceBetween,
          children: [
            IconButton(
              onPressed: () {
                setState(() {
                  nursesExpanded = !nursesExpanded;
                });
              },
              icon: nursesExpanded
                  ? RotatedBox(quarterTurns: 2, child: Image.asset('assets/icons/arrow_down.png', scale: 2.0))
                  : Image.asset('assets/icons/arrow_down.png', scale: 2.0),
            ),
            Text('الممرضين المتاحين (اختياري)', style: TextStyle(fontSize: 18.0, color: Colors.black)),
          ],
        ),
        const SizedBox(height: 10.0),
        ExpandedSection(
          height: 175.0,
          expand: nursesExpanded,
          forwardDuration: const Duration(milliseconds: 700),
          reverseDuration: const Duration(milliseconds: 700),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: SizedBox(
              height: 175.0,
              child: listOfNurses.isEmpty ?
              isNursesFetched ?
              MessageWidget(text: 'لا يوجد ممرضين') :
              HCCPI() :
              ListView.builder(
                itemCount: listOfNurses.length,
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  Nurse nurse = listOfNurses[index];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (nurse.isSelected) {
                          // Unselect the nurse if already selected
                          nurse.isSelected = false;
                          selectedNurseId = -1;
                        } else {
                          // Select the nurse and unselect others
                          for (var n in listOfNurses) {
                            n.isSelected = false;
                          }
                          nurse.isSelected = true;
                          selectedNurseId = nurse.id;
                        }
                        debugPrint(selectedNurseId.toString());
                      });
                    },
                    child: CustomItemCard(
                      id: nurse.id,
                      title: '${nurse.firstName} ${nurse.lastName}',
                      value: nurse.rate,
                      isSelected: nurse.isSelected,
                      disableStars: true,
                      imagePath: nurse.personalImageUrl,
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<int> selectedLabTestIds = [];
  List<String> selectedLabTestNames = [];

  Column LabTestTypes() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: .end,
      children: [
        Text('اختر أنواع التحليل', style: TextStyle(fontSize: 18.0, color: Colors.black)),
        const SizedBox(height: 10.0),
        Directionality(
          textDirection: TextDirection.rtl,
          child: SizedBox(
            height: 175.0,
            child: listOfLabTests.isEmpty
                ? isLabTestsFetched
                ? MessageWidget(text: 'لا توجد أنواع تحاليل')
                : HCCPI()
                : ListView.builder(
              itemCount: listOfLabTests.length,
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                LabTestModel labTestModel = listOfLabTests[index];
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      labTestModel.isSelected = !labTestModel.isSelected;
                      if (labTestModel.isSelected) {
                        selectedLabTestIds.add(labTestModel.id);
                        selectedLabTestNames.add(labTestModel.name);
                        labTestsPrices.add(labTestModel.price);
                      } else {
                        selectedLabTestIds.remove(labTestModel.id);
                        selectedLabTestNames.remove(labTestModel.name);
                        labTestsPrices.remove(labTestModel.price);
                      }
                    });
                  },
                  child: CustomItemCard(
                    id: labTestModel.id,
                    title: labTestModel.name,
                    value: labTestModel.price,
                    isSelected: labTestModel.isSelected,
                    forLabTest: true,
                    imagePath: 'assets/icons/labTest.png',
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  int selectedLabId = -1;
  String selectedLabName = '';
  Column AvailableLabs() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: .end,
      children: [
        Text('المخابر المتاحة (اختياري)', style: TextStyle(fontSize: 18.0, color: Colors.black)),
        const SizedBox(height: 10.0),
        Directionality(
          textDirection: TextDirection.rtl,
          child: SizedBox(
            height: 175.0,
            child: listOfLabs.isEmpty ?
            isLabsFetched ?
            MessageWidget(text: 'لا توجد مخابر') :
            HCCPI() :
            ListView.builder(
              itemCount: listOfLabs.length,
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                LabModel lab = listOfLabs[index];
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (lab.isSelected) {
                        // Unselect the nurse if already selected
                        lab.isSelected = false;
                        selectedLabId = -1;
                        selectedLabName = '';
                      } else {
                        // Select the nurse and unselect others
                        for (var n in listOfLabs) {
                          n.isSelected = false;
                        }
                        lab.isSelected = true;
                        selectedLabId = lab.id;
                        selectedLabName = lab.name;
                      }
                      debugPrint(selectedLabId.toString());
                    });
                  },
                  child: CustomItemCard(
                    id: lab.id,
                    title: lab.name,
                    value: lab.rate!,
                    isSelected: lab.isSelected,
                    imagePath: 'assets/icons/lab.png',
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Future<void> pressMethod() async {
    bool hasRequiredError = false;
    bool labTestRequired = false;
    bool hasError = false;

    // Check required fields
    if (selectedTime == null || selectedDays.isEmpty || (visitHours == null && !widget.isNursingService && !widget.isLabService!)) {
      hasRequiredError = true;
    }

    if (widget.isLabService! && selectedLabTestIds.isEmpty) {
      setState(() {
        labTestRequired = true;
      });
    }

    // Check conditions for switched
    if (isSwitched) {
      // Validate city
      if (selectedCity.isEmpty) {
        setState(() {
          showCityMsg = true;
        });
        hasError = true;
      } else {
        setState(() {
          showCityMsg = false;
        });
      }

      // Validate region
      if (selectedRegion.isEmpty) {
        setState(() {
          showRegionMsg = true;
        });
        hasError = true;
      } else {
        setState(() {
          showRegionMsg = false;
        });
      }

      // Validate address
      if (addressCtrl.text.isEmpty) {
        setState(() {
          showAddressMsg = true;
        });
        hasError = true;
      } else {
        setState(() {
          showAddressMsg = false;
        });
      }
    }

    // Handle required field errors
    if (hasRequiredError) {
      HomeCareStyle.showSnackBar(
        context,
        content: labTestRequired ? 'هناك حقول في الصفحة مطلوبة ، كما يرجى اختيار نوع تحليل واحد على الأقل' : 'هناك حقول في الصفحة مطلوبة',
        icon: CupertinoIcons.info,
      );
      return;
    } else if (labTestRequired) {
      HomeCareStyle.showSnackBar(
        context,
        content: 'يرجى اختيار نوع تحليل واحد على الأقل',
        icon: CupertinoIcons.info,
      );
      return;
    }

    // Stop navigation if there are errors
    if (hasError) {
      return;
    }

    // Proceed if no validation errors
    final selectedDatesWithTime = selectedDays.map((day) {
      final timeParts = selectedTime!.split(':');
      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);

      // Combine date and time in the local timezone
      final combinedDateTime = DateTime(
        day.year,
        day.month,
        day.day,
        hour,
        minute,
      );

      // Return it as a local ISO 8601 string without converting to UTC
      return combinedDateTime.toIso8601String();
    }).toList();

    num totalFinalPrice = visitHours != null ? widget.price * selectedDatesWithTime.length * visitHours! : widget.price * selectedDatesWithTime.length;

    if (widget.isLabService!) {
      for (var price in labTestsPrices) {
        totalFinalPrice += price;
      }
    }

    // Get nurse name if selected
    String? nurseName;
    if (selectedNurseId != -1) {
      final selectedNurse = listOfNurses.firstWhere((nurse) => nurse.id == selectedNurseId);
      nurseName = '${selectedNurse.firstName} ${selectedNurse.lastName}';
    }

    debugPrint(selectedDatesWithTime.toString()); // Example: ["2024-12-11T18:19:00.000Z"]
    Navigator.push(context, MaterialPageRoute(builder: (context) => BookingDetailsScreen(
      serviceId: widget.serviceId,
      nurseId: selectedNurseId,
      visitDurationInHours: (widget.isNursingService || widget.isLabService!) ? 0 : visitHours!,
      regionId: isSwitched ? selectedRegionId : sharedPrefsController.getRegionId(),
      details: isSwitched ? addressCtrl.text : '',
      visitsDates: selectedDatesWithTime,
      selectedLabTests: selectedLabTestNames,
      labTestsIds: selectedLabTestIds,
      totalPrice: totalFinalPrice,
      forLabService: widget.isLabService!,
      selectedLabId: selectedLabId,
      selectedLabName: selectedLabName,
      caseDescription: noteController.text,
      attachmentId: singleFileId,
      nurseName: nurseName,
      city: isSwitched ? selectedCity : null,
      region: isSwitched ? selectedRegion : null,
      fileName: singleFileName,
    )));
  }

  bool isSwitched = false;
  final TextEditingController addressCtrl = TextEditingController();
  final TextEditingController noteController = TextEditingController();
  SharedPrefsController sharedPrefsController = SharedPrefsController();
  CitiesController citiesController = Get.find();
  RegionsController regionsController = Get.find();
  String selectedCity = '';
  int selectedCityId = 1;
  String selectedRegion = '';
  int selectedRegionId = 0;

  bool showCityMsg = false;
  bool showRegionMsg = false;
  bool showAddressMsg = false;
}