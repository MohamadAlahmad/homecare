// ignore_for_file: non_constant_identifier_names, use_build_context_synchronously

import 'dart:io';

import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:homecare/core/theme/homecare_style.dart';
import 'package:homecare/core/theme/themes.dart';
import 'package:homecare/core/utils/api.dart';
import 'package:homecare/core/utils/globals.dart';
import 'package:homecare/mvc/controller/connection_controller.dart';
import 'package:homecare/mvc/controller/shared_preferences_controller.dart';
import 'package:homecare/mvc/model/api/health_record_model.dart';
import 'package:homecare/mvc/model/api/previous_case.dart';
import 'package:homecare/widgets/brief_details_card.dart';
import 'package:homecare/widgets/buttons.dart';
import 'package:homecare/widgets/custom_circular_progress_indicator.dart';
import 'package:homecare/widgets/custom_item_card.dart';
import 'package:homecare/widgets/custom_text_field.dart';
import 'package:homecare/widgets/header_widget.dart';
import 'package:homecare/widgets/menu_text.dart';
import 'package:homecare/widgets/message_widget.dart';
import 'package:homecare/widgets/nurse/fill_session_modal.dart';
import 'package:homecare/widgets/nurse/upload_button.dart';
import 'package:homecare/widgets/re_login_widget.dart';
import 'package:homecare/widgets/vital_sign_card.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screen_protector/screen_protector.dart';

class VisitDetailsNurseScreen extends StatefulWidget {
  final int sessionId;

  const VisitDetailsNurseScreen({
    super.key,
    required this.sessionId,
  });

  @override
  State<VisitDetailsNurseScreen> createState() =>
      _VisitDetailsNurseScreenState();
}

class _VisitDetailsNurseScreenState extends State<VisitDetailsNurseScreen> {
  int value = 0;
  late PageController pageController;
  final SharedPrefsController sharedPrefsController = SharedPrefsController();

  // ── Vital-sign controllers (current visit) ──────────────────────────────
  final TextEditingController bloodPressureFirstCtrl = TextEditingController();
  final TextEditingController bloodPressureSecondCtrl = TextEditingController();
  final TextEditingController bloodSugarCtrl = TextEditingController();
  final TextEditingController heartRateCtrl = TextEditingController();
  final TextEditingController oxygenationCtrl = TextEditingController();
  final TextEditingController caseDescription = TextEditingController();
  final TextEditingController additionalServiceNameController =
  TextEditingController();
  final TextEditingController additionalServicePriceController =
  TextEditingController();
  final ScrollController scrollController = ScrollController();

  // ── Session & previous-case futures ─────────────────────────────────────
  late Future<HealthRecordModel?> _futureSession;
  late Future<PreviousCase?> _futurePreviousCase;

  // ── File upload state ────────────────────────────────────────────────────
  String _selectedFilePath = '';
  String _fileName = '';
  int _fileId = -1;
  bool _fileLoadingState = false;

  // ── Form key ─────────────────────────────────────────────────────────────
  final _formKey = GlobalKey<FormState>();

  // ── Derived from session (populated after load) ──────────────────────────
  num _finalLabPrice = 0;

  @override
  void initState() {
    super.initState();
    pageController = PageController(initialPage: value);
    _futureSession = _loadSession();
    _futurePreviousCase = _loadPreviousCase();
    _disableScreenshot();
  }

  @override
  void dispose() {
    _enableScreenshot();
    pageController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  // ── Data fetching ────────────────────────────────────────────────────────

  Future<HealthRecordModel?> _loadSession() async {
    final session = await ConnectionController.getSessionById(
      token: sharedPrefsController.getToken(),
      sessionId: widget.sessionId,
    );
    if (session != null) {
      _finalLabPrice = session.labTests.fold(0, (sum, t) => sum + t.price);
    }
    return session;
  }

  Future<PreviousCase?> _loadPreviousCase() async {
    // patientId is not available until the session loads, so we chain the futures.
    final session = await _futureSession;
    if (session == null) return null;
    return ConnectionController.getPreviousCase(
      token: sharedPrefsController.getToken(),
      patientId: session.id, // adjust to the correct patient-id field if needed
    );
  }

  // ── Screenshot protection ────────────────────────────────────────────────

  Future<void> _disableScreenshot() async {
    try {
      await ScreenProtector.protectDataLeakageOn();
    } catch (e) {
      debugPrint('Error disabling screenshot: $e');
    }
  }

  Future<void> _enableScreenshot() async {
    try {
      await ScreenProtector.protectDataLeakageOff();
    } catch (e) {
      debugPrint('Error enabling screenshot: $e');
    }
  }

  // ── File handling ────────────────────────────────────────────────────────

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        _selectedFilePath = result.files.single.path!;
        _fileName = result.files.single.name;
        _fileLoadingState = true;
      });
      await _uploadAttachment();
      setState(() => _fileLoadingState = false);
    }
  }

  Future<void> _uploadAttachment() async {
    final id = await ConnectionController.uploadFile(
      folderName: 2,
      token: sharedPrefsController.getToken(),
      filePath: _selectedFilePath,
    );
    final bool success = id != -1;
    Fluttertoast.showToast(
      msg: success ? 'تم تحميل الملف' : 'فشل تحميل الملف',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.grey[600],
      textColor: Colors.white,
      fontSize: 16.0,
    );
    if (success) setState(() => _fileId = id);
  }

  // ── Attachment download ──────────────────────────────────────────────────

  Future<void> _downloadAttachment(PatientAttachment attachment) async {
    try {
      HomeCareStyle.showLoadingDialog(context);

      // Build the full URL (adjust the base-url prefix as needed).
      final fullUrl =
          '${HomeCareApi.baseUrl}/${attachment.url}';

      // Resolve the system Downloads directory.
      final Directory downloadsDir;
      if (Platform.isAndroid) {
        // On Android the public Downloads folder is at a fixed path.
        downloadsDir = Directory('/storage/emulated/0/Download');
      } else {
        // iOS: use the application-documents directory (accessible via Files app).
        downloadsDir = await getApplicationDocumentsDirectory();
      }

      if (!downloadsDir.existsSync()) downloadsDir.createSync(recursive: true);

      final fileName = attachment.url.split('/').last;
      final savePath = '${downloadsDir.path}/$fileName';

      await Dio().download(fullUrl, savePath);

      if (mounted) {
        Navigator.pop(context); // dismiss loading dialog
        HomeCareStyle.showSnackBar(
          context,
          success: true,
          content: 'تم تنزيل الملف بنجاح',
          icon: Icons.download_done_rounded,
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        debugPrint('Download error: $e');
        HomeCareStyle.showSnackBar(
          context,
          content: 'فشل تنزيل الملف، يرجى المحاولة مرة أخرى.',
          icon: Icons.error_outline,
        );
      }
    }
  }

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: FutureBuilder<HealthRecordModel?>(
            future: _futureSession,
            builder: (context, snapshot) {
              // ── Loading ──────────────────────────────────────────────────
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: HCCPI(color: HomeCareTheme.primaryColor));
              }

              // ── Session terminated ───────────────────────────────────────
              if (sharedPrefsController.sessionTerminated()) {
                return ReLoginWidget(context);
              }

              // ── Error / no data ──────────────────────────────────────────
              if (snapshot.hasError || !snapshot.hasData) {
                return MessageWidget(
                  text: 'حدث خطأ أثناء جلب بيانات الجلسة',
                  errorOrWarning: true,
                );
              }

              final session = snapshot.data!;
              final bool isLabService = session.labTests.isNotEmpty;

              return Column(
                children: [
                  HeaderWidget(context, title: 'تفاصيل الزيارة'),
                  AnimatedToggleSwitch<int>.size(
                    textDirection: TextDirection.rtl,
                    current: value,
                    values: isLabService ? const [0] : const [0, 1],
                    iconOpacity: 1.0,
                    indicatorSize: const Size.fromWidth(150),
                    iconBuilder: (i) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: _textBuilder(i, value),
                    ),
                    borderWidth: 4.0,
                    iconAnimationType: AnimationType.onHover,
                    style: ToggleStyle(
                      borderColor: Colors.transparent,
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    styleBuilder: (i) =>
                        ToggleStyle(indicatorColor: _colorBuilder(i)),
                    onChanged: (i) {
                      if (i == value) return;
                      if (i > value) {
                        pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      } else {
                        pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                      setState(() => value = i);
                    },
                  ),
                  Expanded(
                    child: Directionality(
                      textDirection: TextDirection.rtl,
                      child: PageView(
                        controller: pageController,
                        onPageChanged: (i) => setState(() => value = i),
                        children: [
                          isLabService
                              ? _CurrentLabVisit(session)
                              : _CurrentVisit(session),
                          if (!isLabService) _PreviousVisit(session),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  // ── Current visit tab ────────────────────────────────────────────────────

  Widget _CurrentVisit(HealthRecordModel session) {
    final String location = session.geocodedAddress != null
        ? '${session.geocodedAddress!.governorateDto.name} ${session.geocodedAddress!.regionDto.name} ${session.geocodedAddress!.details}'
        : '(العنوان فارغ)';

    return Padding(
      padding: const EdgeInsets.only(top: 10.0, left: 10.0, right: 10.0),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BriefDetailsCard(
                serviceName: session.medicalServiceName,
                patientName: session.patientName,
                nurseName: session.nurseName,
                date: session.visitDate,
                location: location,
                caseDescription: session.caseDescription,
                visitDurationInHours: session.visitDurationInHours,
              ),

              // ── Vital signs ──────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 15.0),
                child: MenuText('المعالم الحيوية :'),
              ),
              VitalSignCard(context,
                  title: 'الضغط',
                  controller: bloodPressureFirstCtrl,
                  controller2: bloodPressureSecondCtrl,
                  forBloodPressure: true,
                  enabled: true,
                  validator: _requiredValidator),
              VitalSignCard(context,
                  title: 'السكر',
                  controller: bloodSugarCtrl,
                  enabled: true,
                  validator: _requiredValidator),
              VitalSignCard(context,
                  title: 'نبضات القلب',
                  controller: heartRateCtrl,
                  enabled: true,
                  validator: _requiredValidator),
              VitalSignCard(context,
                  title: 'الأكسجة',
                  controller: oxygenationCtrl,
                  enabled: true,
                  validator: _requiredValidator),

              // ── Case description ─────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: MenuText('وصف الحالة :'),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: CustomTextField(
                  context,
                  controller: caseDescription,
                  fontSize: 14.0,
                  maxLines: 1,
                  fillColor:
                  HomeCareTheme.primaryColor.withValues(alpha: 0.05),
                  enabled: true,
                  validator: _requiredValidator,
                ),
              ),

              // ── Patient attachments (read-only download) ─────────────────
              if (session.patientAttachments.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.only(top: 20.0, bottom: 10.0),
                  child: MenuText('المرفقات :'),
                ),
                ...session.patientAttachments.map(
                      (att) => _AttachmentDownloadTile(
                    attachment: att,
                    onDownload: () => _downloadAttachment(att),
                  ),
                ),
              ],

              // ── Nurse's extra file upload ────────────────────────────────
              Padding(
                padding: const EdgeInsets.only(top: 20.0, bottom: 10.0),
                child: MenuText('ملفات إضافية : (اختياري)'),
              ),
              UploadButton(
                onPressed: _pickFile,
                filePath: _selectedFilePath,
                fileName: _fileName,
                loading: _fileLoadingState,
                forFillSession: true,
              ),

              // ── Continue button ──────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: CustomButton(
                  width: HomeCareSize.width(context),
                  height: 50.0,
                  onPressed: _fileLoadingState
                      ? () {}
                      : () {
                    if (_formKey.currentState!.validate()) {
                      _showBillingSheet(session);
                    }
                  },
                  title: const Text('استمرار',
                      style:
                      TextStyle(fontSize: 16.0, color: Colors.white)),
                  backgroundColor: HomeCareTheme.primaryColorBold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Current lab-visit tab ────────────────────────────────────────────────

  Widget _CurrentLabVisit(HealthRecordModel session) {
    final String location = session.geocodedAddress != null
        ? '${session.geocodedAddress!.governorateDto.name} ${session.geocodedAddress!.regionDto.name} ${session.geocodedAddress!.details}'
        : '(العنوان فارغ)';

    return Padding(
      padding: const EdgeInsets.only(top: 10.0, left: 10.0, right: 10.0),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BriefDetailsCard(
                serviceName: session.medicalServiceName,
                patientName: session.patientName,
                nurseName: session.nurseName,
                date: session.visitDate,
                location: location,
                caseDescription: session.caseDescription,
              ),
              const SizedBox(height: 25.0),
              MenuText('التحاليل المخبرية:'),
              SizedBox(
                height: 180.0,
                child: Scrollbar(
                  thumbVisibility: true,
                  controller: scrollController,
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(10.0),
                    scrollDirection: Axis.horizontal,
                    controller: scrollController,
                    children: session.labTests
                        .map((t) => CustomItemCard(
                      id: t.id,
                      title: t.name,
                      value: t.price,
                      isSelected: false,
                      forLabTest: true,
                      imagePath: 'assets/icons/labTest.png',
                    ))
                        .toList(),
                  ),
                ),
              ),
              const SizedBox(height: 25.0),
              if (session.lab != null)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MenuText('المخبر الذي تم اختياره:'),
                    const Spacer(),
                    SizedBox(
                      height: 165.0,
                      child: CustomItemCard(
                        id: session.lab!.id,
                        title: session.lab!.name,
                        value: session.lab!.rate!,
                        isSelected: false,
                        forLabTest: false,
                        imagePath: 'assets/icons/lab.png',
                      ),
                    ),
                  ],
                ),

              // ── Patient attachments (read-only download) ─────────────────
              if (session.patientAttachments.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.only(top: 20.0, bottom: 10.0),
                  child: MenuText('المرفقات :'),
                ),
                ...session.patientAttachments.map(
                      (att) => _AttachmentDownloadTile(
                    attachment: att,
                    onDownload: () => _downloadAttachment(att),
                  ),
                ),
              ],

              Padding(
                padding: const EdgeInsets.all(20.0),
                child: CustomButton(
                  width: HomeCareSize.width(context),
                  height: 50.0,
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _showLabBillingSheet(session);
                    }
                  },
                  title: const Text('استمرار',
                      style:
                      TextStyle(fontSize: 16.0, color: Colors.white)),
                  backgroundColor: HomeCareTheme.primaryColorBold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Previous visit tab ───────────────────────────────────────────────────

  Widget _PreviousVisit(HealthRecordModel session) {
    final String location = session.geocodedAddress != null
        ? '${session.geocodedAddress!.governorateDto.name} ${session.geocodedAddress!.regionDto.name} ${session.geocodedAddress!.details}'
        : '(العنوان فارغ)';

    return Padding(
      padding: const EdgeInsets.only(top: 10.0, left: 10.0, right: 10.0),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: FutureBuilder<PreviousCase?>(
          future: _futurePreviousCase,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: HCCPI(color: HomeCareTheme.primaryColor));
            }
            if (sharedPrefsController.sessionTerminated()) {
              return ReLoginWidget(context);
            }
            if (snapshot.hasError) {
              return MessageWidget(
                  text: 'حدث خطأ أثناء جلب البيانات',
                  errorOrWarning: true);
            }
            if (!snapshot.hasData) {
              return MessageWidget(text: 'لا توجد زيارة سابقة');
            }

            final prev = snapshot.data!;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BriefDetailsCard(
                  serviceName: session.patientName,
                  patientName: session.patientName,
                  nurseName: session.nurseName,
                  date: prev.visitDate,
                  location: location,
                  caseDescription: session.caseDescription,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 15.0),
                  child: MenuText('المعالم الحيوية :'),
                ),
                VitalSignCard(context,
                    title: 'الضغط',
                    controller: TextEditingController(
                        text: prev.bloodPressureFirstValue),
                    controller2: TextEditingController(
                        text: prev.bloodPressureSecondValue),
                    forBloodPressure: true,
                    enabled: false),
                VitalSignCard(context,
                    title: 'السكر',
                    controller:
                    TextEditingController(text: prev.bloodSugar),
                    enabled: false),
                VitalSignCard(context,
                    title: 'نبضات القلب',
                    controller:
                    TextEditingController(text: prev.heartRate),
                    enabled: false),
                VitalSignCard(context,
                    title: 'الأكسجة',
                    controller:
                    TextEditingController(text: prev.oxygenation),
                    enabled: false),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: MenuText('وصف الحالة :'),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: CustomTextField(
                    context,
                    controller: TextEditingController(text: prev.notes),
                    fontSize: 14.0,
                    maxLines: 5,
                    fillColor:
                    HomeCareTheme.primaryColor.withValues(alpha: 0.05),
                    enabled: false,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: CustomButton(
                    width: HomeCareSize.width(context),
                    height: 50.0,
                    onPressed: () => pageController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    ),
                    title: const Text('رجوع',
                        style: TextStyle(
                            fontSize: 16.0, color: Colors.white)),
                    backgroundColor: HomeCareTheme.primaryColorBold,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ── Billing sheet helpers ────────────────────────────────────────────────

  void _showBillingSheet(HealthRecordModel session) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      showDragHandle: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: SingleChildScrollView(
          child: FillSessionModal(
            title: 'تفاصيل الفاتورة',
            price: (session.visitDurationInHours) != 0
                ? session.visitDurationInHours *
                _sessionBasePrice(session)
                : _sessionBasePrice(session),
            additionalServiceNameCtrl: additionalServiceNameController,
            additionalServicePriceCtrl: additionalServicePriceController,
            onPressed: () async {
              HomeCareStyle.showLoadingDialog(context);
              try {
                final result =
                await ConnectionController.fillSessionForm(
                  bioMarker1Value: bloodPressureFirstCtrl.text,
                  bioMarker2Value: bloodPressureSecondCtrl.text,
                  bioMarker3Value: bloodSugarCtrl.text,
                  bioMarker4Value: heartRateCtrl.text,
                  bioMarker5Value: oxygenationCtrl.text,
                  notes: caseDescription.text,
                  basicServicePrice: _sessionBasePrice(session),
                  descriptionAdditional:
                  additionalServiceNameController.text,
                  priceAdditional:
                  num.tryParse(additionalServicePriceController.text) ??
                      0,
                  token: sharedPrefsController.getToken(),
                  sessionId: widget.sessionId,
                  attachmentIds: [_fileId],
                );
                Navigator.pop(context);
                Navigator.pop(context);
                Navigator.pop(context);
                _handleSubmitResult(result);
              } catch (e) {
                Navigator.pop(context);
                debugPrint('Error: $e');
                HomeCareStyle.showSnackBar(context,
                    content:
                    'حدث خطأ أثناء إرسال البيانات. يرجى المحاولة مرة أخرى.',
                    icon: Icons.error_outline);
              }
            },
          ),
        ),
      ),
    );
  }

  void _showLabBillingSheet(HealthRecordModel session) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      showDragHandle: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: SingleChildScrollView(
          child: FillSessionModal(
            title: 'تفاصيل الفاتورة',
            price: _sessionBasePrice(session) + _finalLabPrice,
            additionalServiceNameCtrl: additionalServiceNameController,
            additionalServicePriceCtrl: additionalServicePriceController,
            onPressed: () async {
              HomeCareStyle.showLoadingDialog(context);
              try {
                final result =
                await ConnectionController.fillLabSessionForm(
                  notes: caseDescription.text,
                  basicServicePrice: _sessionBasePrice(session),
                  descriptionAdditional:
                  additionalServiceNameController.text,
                  priceAdditional:
                  num.tryParse(additionalServicePriceController.text) ??
                      0,
                  token: sharedPrefsController.getToken(),
                  sessionId: widget.sessionId,
                  attachmentIds: [_fileId],
                );
                Navigator.pop(context);
                Navigator.pop(context);
                Navigator.pop(context);
                _handleSubmitResult(result);
              } catch (e) {
                Navigator.pop(context);
                debugPrint('Error: $e');
                HomeCareStyle.showSnackBar(context,
                    content:
                    'حدث خطأ أثناء إرسال البيانات. يرجى المحاولة مرة أخرى.',
                    icon: Icons.error_outline);
              }
            },
          ),
        ),
      ),
    );
  }

  void _handleSubmitResult(bool result) {
    if (sharedPrefsController.sessionTerminated()) {
      HomeCareStyle.showReLoginDialog(context);
    } else if (result) {
      HomeCareStyle.showSnackBar(context,
          success: true,
          content: 'تم تسجيل الانتهاء بنجاح',
          icon: Icons.check_circle);
    } else {
      HomeCareStyle.showSnackBar(context,
          content: sharedPrefsController.getMSG(),
          icon: Icons.info_outline);
    }
  }

  /// Placeholder — replace with the actual field in HealthRecordModel
  /// that holds the base service price once your API returns it.
  num _sessionBasePrice(HealthRecordModel session) =>
      0; // TODO: replace with e.g. session.servicePrice

  // ── Toggle helpers ───────────────────────────────────────────────────────

  Color _colorBuilder(int _) => HomeCareTheme.primaryColor;

  Widget _textBuilder(int toggleValue, int currentValue) {
    final isSelected = toggleValue == currentValue;
    return Container(
      height: 30.0,
      width: 100.0,
      decoration: BoxDecoration(
        border: Border.all(
          color: isSelected ? Colors.transparent : _colorBuilder(toggleValue),
        ),
        borderRadius: BorderRadius.circular(8.0),
        color: isSelected ? _colorBuilder(toggleValue) : Colors.transparent,
      ),
      child: Center(
        child: Text(
          _textByValue(toggleValue),
          style: TextStyle(
            fontSize: 14.0,
            color: isSelected ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }

  String _textByValue(int? v) => switch (v) {
    0 => 'الزيارة الحالية',
    1 => 'الزيارة السابقة',
    _ => '',
  };

  // ── Validator ────────────────────────────────────────────────────────────

  String? _requiredValidator(String? value) =>
      (value == null || value.isEmpty) ? 'حقل مطلوب' : null;
}

// ── Attachment download tile ─────────────────────────────────────────────────

class _AttachmentDownloadTile extends StatelessWidget {
  final PatientAttachment attachment;
  final VoidCallback onDownload;

  const _AttachmentDownloadTile({
    required this.attachment,
    required this.onDownload,
  });

  @override
  Widget build(BuildContext context) {
    final fileName = attachment.url.split('/').last;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: HomeCareTheme.primaryColor.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: HomeCareTheme.primaryColor.withValues(alpha: 0.2),
        ),
      ),
      child: ListTile(
        leading: Icon(
          Icons.insert_drive_file_rounded,
          color: HomeCareTheme.primaryColor,
        ),
        title: Text(
          fileName,
          style: const TextStyle(fontSize: 13.0),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: IconButton(
          icon: Icon(
            Icons.download_rounded,
            color: HomeCareTheme.primaryColorBold,
          ),
          tooltip: 'تنزيل',
          onPressed: onDownload,
        ),
      ),
    );
  }
}
