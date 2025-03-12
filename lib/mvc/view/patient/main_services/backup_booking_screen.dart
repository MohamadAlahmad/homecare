//ignore_for_file: constant_identifier_names, non_constant_identifier_names, use_build_context_synchronously

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
import 'package:homecare/mvc/model/api/region.dart';
import 'package:homecare/mvc/view/patient/main_services/booking_details_screen.dart';
import 'package:homecare/widgets/buttons.dart';
import 'package:homecare/widgets/custom_circular_progress_indicator.dart';
import 'package:homecare/widgets/custom_dropdown.dart';
import 'package:homecare/widgets/custom_text_field.dart';
import 'package:homecare/widgets/expanded_list.dart';
import 'package:homecare/widgets/header_widget.dart';
import 'package:homecare/widgets/nurse/available_nurse_card.dart';
import 'package:table_calendar/table_calendar.dart';

class BackupBookingScreen extends StatefulWidget {
  final int serviceId;
  final num price;
  final bool isNursingService;
  const BackupBookingScreen({super.key, required this.serviceId, required this.price, required this.isNursingService});

  @override
  State<BackupBookingScreen> createState() => _BackupBookingScreenState();
}

class _BackupBookingScreenState extends State<BackupBookingScreen> {

  DateTime focusedDay = DateTime.now(); // Keeps track of the current month
  DateTime firstDay = DateTime(DateTime.now().year, DateTime.now().month);
  DateTime lastDay = DateTime(DateTime.now().year, DateTime.now().month + 1, 31);

  List<DateTime> selectedDays = []; // Holds multiple selected days

  final List<String> timeValues = [
    for (int i = 10; i <= 23; i++) ...[
      "${i.toString().padLeft(2, '0')}:00",
      if (i < 23) "${i.toString().padLeft(2, '0')}:30",
    ],
  ];

  final List<int> secondListValues = [1, 3, 6, 10];

  String? selectedTime;
  int? selectedSecondValue;

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
    listOfNurses = await ConnectionController.getNurses(token: sharedPrefsController.getToken(), onlyMales: false).then((list) {
      if(sharedPrefsController.sessionTerminated()) {
        HomeCareStyle.showReLoginDialog(context);
        return [];
      }
      return list;
    });
    setState(() {});
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
            HeaderWidget(context, title: 'التاريخ والوقت', iconColor: HomeCareTheme.primaryColor),
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
                        const SizedBox(height: 10.0),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20.0),
                            color: HomeCareTheme.primaryColor.withValues(alpha: 0.1),
                          ),
                          child: TableCalendar(
                            firstDay: firstDay,
                            lastDay: lastDay,
                            focusedDay: focusedDay,
                            selectedDayPredicate: (day) => selectedDays.contains(day),
                            onDaySelected: (selectedDay, focusedDay) {
                              setState(() {
                                if (selectedDays.contains(selectedDay)) {
                                  // Remove the day if already selected
                                  selectedDays.remove(selectedDay);
                                } else {
                                  // Add the selected day
                                  selectedDays.add(selectedDay);
                                }
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
                                selectedSecondValue = null;
                              });
                            },
                          ),
                        ),
                        const SizedBox(height: 10),
                        if(!widget.isNursingService) const Divider(indent: 20.0, endIndent: 20.0),
                        if(!widget.isNursingService)Text('اختيار عدد ساعات الزيارة', style: TextStyle(fontSize: 18.0, color: Colors.black)),
                        if(!widget.isNursingService)const SizedBox(height: 20),
                        if(!widget.isNursingService) Directionality(
                          textDirection: TextDirection.rtl,
                          child: SizedBox(
                            height: 30.0,
                            child: ListView.builder(
                              physics: const BouncingScrollPhysics(),
                              scrollDirection: Axis.horizontal,
                              itemCount: secondListValues.length,
                              itemBuilder: (context, index) {
                                final value = secondListValues[index];
                                final isSelected = value == selectedSecondValue;
                                final isEnabled = isValueEnabled(value);

                                return GestureDetector(
                                  onTap: isEnabled
                                      ? () {
                                    setState(() {
                                      selectedSecondValue = value;
                                    });
                                  } : null,
                                  child: Container(
                                    width: 65.0,
                                    margin: const EdgeInsets.symmetric(horizontal: 10.0),
                                    padding: const EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 0.0),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? HomeCareTheme.primaryColor
                                          : isEnabled
                                          ? HomeCareTheme.primaryColor.withValues(alpha: 0.1)
                                          : Colors.grey[100],
                                      borderRadius: BorderRadius.circular(20.0),
                                    ),
                                    child: Center(
                                      child: Text(
                                        value.toString(),
                                        style: TextStyle(
                                          color: isSelected ? Colors.white : isEnabled ? Colors.black : Colors.grey,
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
                        if(!widget.isNursingService) const SizedBox(height: 10),
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
                            padding: EdgeInsets.all(10.0),
                            //margin: EdgeInsets.all(10.0),
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
                      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
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
    );
  }

  int selectedNurseId = -1;

  Column AvailableNurses() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text('الممرضين المتاحين', style: TextStyle(fontSize: 18.0, color: Colors.black)),
        const SizedBox(height: 10.0),
        Directionality(
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
                      for (var n in listOfNurses) {
                        n.isSelected = false;
                      }
                      nurse.isSelected = true;
                      selectedNurseId = nurse.id;
                      debugPrint(selectedNurseId.toString());
                    });
                  },
                  child: AvailableNurseCard(
                    id: nurse.id,
                    firstName: nurse.firstName,
                    lastName: nurse.lastName,
                    rate: nurse.rate,
                    isSelected: nurse.isSelected,
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  void pressMethod() {
    bool hasRequiredError = false;
    bool hasError = false;

    // Check required fields
    if (selectedTime == null || selectedDays.isEmpty || (selectedSecondValue == null && !widget.isNursingService)/* || selectedNurseId == -1*/) {
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
      Get.snackbar(
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

    //log the original combined dates for debugging
    debugPrint("Local Dates: $selectedDatesWithTime");

    // Convert to UTC format if required
    /*List<String> formattedDates = selectedDatesWithTime.map((date) {
      return DateTime.parse(date).toUtc().toIso8601String(); // This step ensures UTC format
    }).toList();*/

    debugPrint(selectedDatesWithTime.toString()); // Example: ["2024-12-11T18:19:00.000Z"]
    //Get.snackbar('Selected Dates', selectedDatesWithTime.join(', '));
    Navigator.push(context, MaterialPageRoute(builder: (context) => BookingDetailsScreen(
      serviceId: widget.serviceId,
      nurseId: selectedNurseId,
      visitDurationInHours: widget.isNursingService ? 0 : selectedSecondValue!,
      regionId: selectedRegionId,
      details: addressCtrl.text,
      visitsDates: selectedDatesWithTime,
      totalPrice: widget.price * selectedDatesWithTime.length,
    )));
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

/*
pressMethod() {
    bool hasRequiredError = false;
    bool hasError = false;
    String errorMessage = '';
    if (selectedTime == null) {
      errorMessage += 'يجب اختيار الوقت\n';
      hasRequiredError = true;
    }
    if (selectedDays.isEmpty) {
      errorMessage += 'يجب اختيار يوم واحد على الأقل\n';
      hasRequiredError = true;
    }
    if (selectedSecondValue == null) {
      errorMessage += 'يجب اختيار عدد ساعات الزيارة\n';
      hasRequiredError = true;
    }
    if (selectedNurseId == -1) {
      errorMessage += 'يجب اختيار الممرض\n';
      hasRequiredError = true;
    }
    if (isSwitched && selectedCity.isEmpty) {
      setState(() {
        showCityMsg = true;
      });
      hasError = true;
    }
    if (isSwitched && selectedRegion.isEmpty) {
      setState(() {
        showRegionMsg = true;
      });
      hasError = true;
    }
    if (isSwitched && addressCtrl.text.isEmpty) {
      setState(() {
        showAddressMsg = true;
      });
      hasError = true;
    }
    if (hasRequiredError) {
      Get.snackbar(
        '',
        '',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: HomeCareTheme.primaryColorLight.withValues(alpha: 0.8),
        duration: const Duration(milliseconds: 2000),
        titleText: Text('تنبيه', style: TextStyle(color: Colors.white, fontSize: 14.0), textAlign: TextAlign.center),
        messageText: Text(errorMessage.trim(), style: TextStyle(color: Colors.white, fontSize: 14.0), textAlign: TextAlign.center),
      );
      return;
    }
    if(hasError) {
      return;
    }
    // Proceed if no validation errors
    final selectedDatesWithTime = selectedDays.map((day) {
      final timeParts = selectedTime!.split(':');
      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);
      // Combine date and time
      final combinedDateTime = DateTime(
        day.year,
        day.month,
        day.day,
        hour,
        minute,
      );
      // Format it as ISO 8601 string
      return combinedDateTime.toIso8601String();
    }).toList();
    debugPrint(selectedDatesWithTime.toString()); // Example: ["2024-12-11T18:19:00.000Z"]
    Get.snackbar('Selected Dates', selectedDatesWithTime.join(', '));
    Navigator.push(context, MaterialPageRoute(builder: (context) => BookingDetailsScreen()));
  }
*/
/*pressMethod() {
    bool hasError = false;
    String errorMessage = ''; // Store all error messages in this string

    if (selectedTime == null) {
      errorMessage += 'يجب اختيار الوقت\n'; // Append message to errorMessage
      hasError = true;
    }
    if (selectedDays.isEmpty) {
      errorMessage += 'يجب اختيار يوم واحد على الأقل\n';
      hasError = true;
    }
    if (selectedSecondValue == null) {
      errorMessage += 'يجب اختيار عدد ساعات الزيارة\n';
      hasError = true;
    }
    if (isSwitched && selectedCity.isEmpty) {
      setState(() {
        showCityMsg = true;
      });
      errorMessage += 'يجب اختيار المدينة\n';
      hasError = true;
    }
    if (isSwitched && selectedRegion.isEmpty) {
      setState(() {
        showRegionMsg = true;
      });
      errorMessage += 'يجب اختيار المنطقة\n';
      hasError = true;
    }
    if (isSwitched && addressCtrl.text.isEmpty) {
      setState(() {
        showAddressMsg = true;
      });
      errorMessage += 'يجب اختيار العنوان\n';
      hasError = true;
    }
    if(selectedNurseId == -1) {
      errorMessage += 'يجب اختيار الممرض\n';
      hasError = true;
    }

    // If there's any error, show a single Snackbar with all the error messages
    if (hasError) {
      Get.snackbar(
        '',
        '',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: HomeCareTheme.primaryColorLight.withValues(alpha: 0.8),
        duration: const Duration(milliseconds: 2000),
        titleText: Text('تنبيه', style: TextStyle(color: Colors.white, fontSize: 14.0), textAlign: TextAlign.center),
        messageText: Text(errorMessage.trim(), style: TextStyle(color: Colors.white, fontSize: 14.0), textAlign: TextAlign.center),
      );
      return; // Don't proceed further if there's an error
    }

    // Proceed if no validation errors
    final selectedDatesWithTime = selectedDays.map((day) {
      final timeParts = selectedTime!.split(':');
      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);
      // Combine date and time
      final combinedDateTime = DateTime(
        day.year,
        day.month,
        day.day,
        hour,
        minute,
      );
      // Format it as ISO 8601 string
      return combinedDateTime.toIso8601String();
    }).toList();

    debugPrint(selectedDatesWithTime.toString()); // Example: ["2024-12-11T18:19:00.000Z"]
    Get.snackbar('Selected Dates', selectedDatesWithTime.join(', '));
    Navigator.push(context, MaterialPageRoute(builder: (context) => BookingDetailsScreen()));
  }*/