// ignore_for_file: non_constant_identifier_names, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:homecare/core/utils/globals.dart';
import 'package:homecare/mvc/controller/connection_controller.dart';
import 'package:homecare/core/theme/homecare_style.dart';
import 'package:homecare/core/theme/themes.dart';
import 'package:homecare/mvc/controller/shared_preferences_controller.dart';
import 'package:homecare/mvc/model/api/nurse.dart';
import 'package:homecare/widgets/buttons.dart';
import 'package:homecare/widgets/custom_circular_progress_indicator.dart';
import 'package:homecare/widgets/custom_text_field.dart';
import 'package:homecare/widgets/header_widget.dart';
import 'package:homecare/widgets/menu_text.dart';
import 'package:homecare/widgets/nurse/available_nurse_card.dart';
import 'package:homecare/widgets/progress_indicator.dart';

class AddPatientBySupporterScreen extends StatefulWidget {
  const AddPatientBySupporterScreen({super.key});

  @override
  State<AddPatientBySupporterScreen> createState() => _AddPatientBySupporterScreenState();
}

class _AddPatientBySupporterScreenState extends State<AddPatientBySupporterScreen> {

  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController lastNameCtrl = TextEditingController();
  final TextEditingController phoneCtrl = TextEditingController();
  final TextEditingController operationTypeCtrl = TextEditingController();
  SharedPrefsController sharedPrefsController = SharedPrefsController();
  final formKey = GlobalKey<FormState>();
  bool showNurseMsg = false;

  List<Nurse> listOfNurses = [];
  getNurses() async {
    listOfNurses = await ConnectionController.getNurses(
      token: sharedPrefsController.getToken(),
      onlyMales: false,
    ).then((list) {
      if(sharedPrefsController.sessionTerminated()) {
        HomeCareStyle.showReLoginDialog(context);
        return [];
      }
      return list;
    });
    if(mounted) {
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
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SafeArea(
          child: Stack(
            children: [
              HeaderWidget(context, title: 'إضافة مريض'),
              Padding(
                padding: const EdgeInsets.only(top: 50.0, left: 10.0, right: 10.0),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
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
                        const SizedBox(height: 10.0),
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
                        const SizedBox(height: 10.0),
                        MenuText(' :  نوع المعاينة'),
                        CustomTextFieldWithLabel(
                          context,
                          controller: operationTypeCtrl,
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
                        AvailableNurses(),
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

    /*if(selectedNurseId == -1) {
      setState(() {
        showNurseMsg = true;
      });
      return;
    } else {
      setState(() {
        showNurseMsg = false;
      });
    }*/

    if (isFormValid) {
      // All validations passed
      setState(() {
        loading = true;
      });

      debugPrint('First name  : ${nameCtrl.text}');
      debugPrint('Last name   : ${lastNameCtrl.text}');
      debugPrint('Alt Phone   : ${operationTypeCtrl.text}');
      String token = sharedPrefsController.getToken();
      var result = await ConnectionController.addPatientBySupporter(
        firstName: nameCtrl.text,
        lastName: lastNameCtrl.text,
        token: token,
        dialCode: '+963',
        phoneNumber: phoneCtrl.text,
        operationType: operationTypeCtrl.text,
        suggestedNurseId: selectedNurseId,
      );
      setState(() {
        loading = false;
      });
      if(sharedPrefsController.sessionTerminated()) {
        HomeCareStyle.showReLoginDialog(context);
      } else if(result) {
        HomeCareStyle.showSnackBar(
          context,
          success: true,
          content: 'تم الطلب بنجاح',
          icon: Icons.check_circle,
        );
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

  Padding RequiredText() => Padding(
    padding: const EdgeInsets.only(right: 10.0),
    child: Align(
      alignment: Alignment.centerRight,
      child: Text('الممرض مطلوب', style: TextStyle(fontSize: 12.0, color: Colors.red[900]!)),
    ),
  );

  int selectedNurseId = -1;

  Column AvailableNurses() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if(showNurseMsg) RequiredText(),
            Text('الممرضين المتاحين', style: TextStyle(fontSize: 18.0, color: Colors.black)),
          ],
        ),
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
}
