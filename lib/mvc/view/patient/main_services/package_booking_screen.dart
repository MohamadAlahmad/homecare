import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homecare/core/theme/homecare_style.dart';
import 'package:homecare/core/theme/themes.dart';
import 'package:homecare/mvc/controller/cities_controller.dart';
import 'package:homecare/mvc/controller/connection_controller.dart';
import 'package:homecare/mvc/controller/regions_controller.dart';
import 'package:homecare/mvc/controller/shared_preferences_controller.dart';
import 'package:homecare/mvc/model/api/city.dart';
import 'package:homecare/mvc/model/api/nurse.dart';
import 'package:homecare/mvc/model/api/package.dart';
import 'package:homecare/mvc/model/api/region.dart';
import 'package:homecare/mvc/view/patient/profile_pages/my_profile_screen.dart';
import 'package:homecare/widgets/buttons.dart';
import 'package:homecare/widgets/custom_circular_progress_indicator.dart';
import 'package:homecare/widgets/custom_dropdown.dart';
import 'package:homecare/widgets/custom_text_field.dart';
import 'package:homecare/widgets/expanded_list.dart';
import 'package:homecare/widgets/header_widget.dart';
import 'package:homecare/widgets/custom_item_card.dart';
import 'package:homecare/widgets/patient/package_details_card.dart';
import 'package:table_calendar/table_calendar.dart';

class PackageBookingScreen extends StatefulWidget {
  final Package package;
  const PackageBookingScreen({super.key, required this.package});

  @override
  State<PackageBookingScreen> createState() => _PackageBookingScreenState();
}

class _PackageBookingScreenState extends State<PackageBookingScreen> {
  DateTime focusedDay = DateTime.now();
  DateTime firstDay = DateTime.now();
  DateTime lastDay = DateTime(2100);

  DateTime? selectedDay;

  final List<String> timeValues = [
    for (int i = 10; i <= 23; i++) ...[
      "${i.toString().padLeft(2, '0')}:00",
      if (i < 23) "${i.toString().padLeft(2, '0')}:30",
    ],
  ];

  String? selectedTime;
  int? visitHours;

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
  getNurses() async {
    listOfNurses = await ConnectionController.getNurses(
      token: sharedPrefsController.getToken(),
      onlyMales: sharedPrefsController.getGender() == 1 ? true : false,
    ).then((list) {
      if (sharedPrefsController.sessionTerminated()) {
        HomeCareStyle.showReLoginDialog(context);
        return [];
      }
      return list;
    });

    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    getNurses();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            HeaderWidget(context, title: 'الحجز من خلال باقة'),
            Padding(
              padding: const EdgeInsets.only(top: 45.0, left: 10.0, right: 10.0),
              child: SingleChildScrollView(
                padding: EdgeInsets.zero,
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Directionality(
                          textDirection: TextDirection.rtl,
                          child: PackageDetailsCard(
                            name: widget.package.name,
                            details: widget.package.description,
                            numberOfSessions: widget.package.sessionsNumber,
                            price: widget.package.price,
                          ),
                        ),
                        const SizedBox(height: 10.0),
                        Text('اختيار تاريخ بدء الزيارات', style: TextStyle(fontSize: 18.0, color: Colors.black)),
                        const SizedBox(height: 20),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20.0),
                            color: HomeCareTheme.primaryColor.withValues(alpha: 0.1),
                          ),
                          child: TableCalendar(
                            firstDay: firstDay,
                            lastDay: lastDay,
                            focusedDay: focusedDay,
                            selectedDayPredicate: (day) => selectedDay != null && isSameDay(selectedDay, day),
                            onDaySelected: (selectedDay, focusedDay) {
                              setState(() {
                                this.selectedDay = selectedDay; // Only one day can be selected
                              });
                            },
                            onPageChanged: (focusedDay) {
                              setState(() {
                                this.focusedDay = focusedDay; // Update only when navigating months
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
                              return !day.isBefore(DateTime.now().subtract(Duration(hours: 24)));
                            },
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Divider(indent: 20.0, endIndent: 20.0),
                        Text('اختيار الوقت', style: TextStyle(fontSize: 18.0, color: Colors.black)),
                        const SizedBox(height: 20),
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
                        const SizedBox(height: 10),
                        const Divider(indent: 20.0, endIndent: 20.0),
                        AvailableNurses(),
                        const Divider(indent: 20.0, endIndent: 20.0),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: Row(
                            children: [
                              Directionality(
                                textDirection: TextDirection.rtl,
                                child: Switch(
                                  value: isSwitched,
                                  activeColor: Colors.white,
                                  activeTrackColor: HomeCareTheme.primaryColor,
                                  inactiveThumbColor: HomeCareTheme.secondaryColor,
                                  inactiveTrackColor: Colors.white,
                                  onChanged: (bool newValue) {
                                    setState(() {
                                      isSwitched = newValue;
                                      if (!newValue) {
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
                            padding: EdgeInsets.all(10.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20.0),
                              color: HomeCareTheme.primaryColor.withValues(alpha: 0.1),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Directionality(
                                  textDirection: TextDirection.rtl,
                                  child: CustomDropdown<City>(
                                    selectedValue: selectedCity.isEmpty
                                        ? null
                                        : citiesController.cities.firstWhere(
                                          (city) => city.name == selectedCity,
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
                                showCityMsg
                                    ? Text('المدينة مطلوبة', style: TextStyle(fontSize: 12.0, color: Colors.red[900]!))
                                    : const SizedBox(),
                                Directionality(
                                  textDirection: TextDirection.rtl,
                                  child: CustomDropdown<Region>(
                                    selectedValue: selectedRegion.isEmpty
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
                                showRegionMsg
                                    ? Text('المنطقة مطلوبة', style: TextStyle(fontSize: 12.0, color: Colors.red[900]!))
                                    : const SizedBox(),
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
                    ValueListenableBuilder(
                      valueListenable: loading,
                      builder: (context, value, _) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 50.0),
                          child: RegisterButton(
                            context,
                            title: value ? HCCPI() : const Text('حجز', style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
                            onPressed: pressMethod,
                          ),
                        );
                      }
                    ),
                    const SizedBox(height: 100.0),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  int selectedNurseId = -1;

  Column AvailableNurses() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
          expand: nursesExpanded,
          height: 175.0,
          forwardDuration: const Duration(milliseconds: 700),
          reverseDuration: const Duration(milliseconds: 700),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: SizedBox(
              height: 175.0,
              child: listOfNurses.isEmpty
                  ? HCCPI()
                  : ListView.builder(
                itemCount: listOfNurses.length,
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  Nurse nurse = listOfNurses[index];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (nurse.isSelected) {
                          nurse.isSelected = false;
                          selectedNurseId = -1;
                        } else {
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
                      imagePath: '',
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

  ValueNotifier<bool> loading = ValueNotifier(false);
  Future<void> pressMethod() async {
    bool hasRequiredError = false;
    bool hasError = false;

    // Check required fields
    if (selectedTime == null || selectedDay == null /* || selectedNurseId == -1*/) {
      hasRequiredError = true;
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
        content: 'هناك حقول في الصفحة مطلوبة',
        icon: CupertinoIcons.info,
      );
      /*Get.snackbar(
        '',
        '',
        margin: const EdgeInsets.only(top: 30.0),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: HomeCareTheme.primaryColorLight.withValues(alpha: 0.8),
        duration: const Duration(milliseconds: 1500),
        titleText: Text(
          'تنبيه',
          style: TextStyle(color: Colors.white, fontSize: 14.0),
          textAlign: TextAlign.center,
        ),
        messageText: Text(
          'هناك حقول في الصفحة مطلوبة',
          style: TextStyle(color: Colors.white, fontSize: 14.0),
          textAlign: TextAlign.center,
        ),
      );*/
      return;
    }
    // Stop navigation if there are errors
    if (hasError) {
      return;
    }
    // Proceed if no validation errors
    final timeParts = selectedTime!.split(':');
    final hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);

    // Combine date and time in the local timezone
    final combinedDateTime = DateTime(
      selectedDay!.year,
      selectedDay!.month,
      selectedDay!.day,
      hour,
      minute,
    );

    debugPrint(combinedDateTime.toIso8601String());
    String token = sharedPrefsController.getToken();
    loading.value = true;
    var result = await ConnectionController.bookServiceThroughPackage(
      packageId: widget.package.id,
      nurseId: selectedNurseId,
      firstVisitsDate: combinedDateTime.toIso8601String(),
      token: token,
      regionId: selectedRegionId == 0 ? null : selectedRegionId,
      details: addressCtrl.text.isEmpty ? null : addressCtrl.text,
    );
    loading.value = false;
    if(sharedPrefsController.sessionTerminated()) {
      HomeCareStyle.showReLoginDialog(context);
    } else if(result == 'true') {
      HomeCareStyle.showSnackBar(
        context,
        content: 'تم الحجز بنجاح',
        icon: Icons.check_circle,
        success: true,
      );
      Navigator.pop(context);
    } else if(result == 'enter-info') {
      HomeCareStyle.showInfoRequiredDialog(
        context,
        title: 'يجب عليك إدخال معلوماتك الشخصية أولاً',
        buttonTitle: 'نعم',
        content: 'هل تريد إدخال المعلومات الشخصية لإكمال الحجز ؟',
        onYesPressed: () async {
          Navigator.push(context, MaterialPageRoute(builder: (context) =>
              MyProfileScreen(
                youDidNotEnterYourInfo: true,
                forBookingThroughPackage: true,
              ),
          ));
        },
      );
    } else if(result == 'false') {
      HomeCareStyle.showSnackBar(
        context,
        content: sharedPrefsController.getMSG(),
        icon: CupertinoIcons.exclamationmark_circle_fill,
      );
    }
  }

  bool isSwitched = false;
  final TextEditingController addressCtrl = TextEditingController();
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