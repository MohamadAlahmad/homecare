import 'package:flutter/material.dart';
import 'package:homecare/core/theme/themes.dart';
import 'package:homecare/mvc/controller/shared_preferences_controller.dart';
import 'package:homecare/widgets/custom_circular_progress_indicator.dart';

class ProfileImageWidget extends StatefulWidget {
  final SharedPrefsController sharedPrefsController;
  final double width;
  final double height;

  const ProfileImageWidget({super.key, required this.sharedPrefsController, required this.width, required this.height});

  @override
  State<ProfileImageWidget> createState() => _ProfileImageWidgetState();
}

class _ProfileImageWidgetState extends State<ProfileImageWidget> {
  bool _hasError = false;

  @override
  void initState() {
    print('======= Gender now is -----> ${widget.sharedPrefsController.getGender()}');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: Future.value(widget.sharedPrefsController.getProfileImageUrl()),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return HCCPI(color: HomeCareTheme.primaryColor);
        } else if (snapshot.hasError) {
          print('FutureBuilder error: ${snapshot.error}');
          return Container(
            height: widget.height,
            width: widget.width,
            decoration: BoxDecoration(
              color: HomeCareTheme.secondaryColor,
              shape: BoxShape.circle,
              image: DecorationImage(
                image: AssetImage(
                  widget.sharedPrefsController.getUserType() != 3
                      ? widget.sharedPrefsController.getGender() == 0 || widget.sharedPrefsController.getGender() == 1
                      ? 'assets/images/person1_temp.png'
                      : 'assets/images/person2_temp.png'
                      : 'assets/images/nurse_temp.png',
                ),
                fit: BoxFit.cover,
              ),
            ),
          );
        } else if (_hasError) {
          return Container(
            height: widget.height,
            width: widget.width,
            decoration: BoxDecoration(
              color: HomeCareTheme.secondaryColor,
              shape: BoxShape.circle,
              image: DecorationImage(
                image: AssetImage(
                  widget.sharedPrefsController.getUserType() != 3
                      ? widget.sharedPrefsController.getGender() == 0 || widget.sharedPrefsController.getGender() == 1
                      ? 'assets/images/person1_temp.png'
                      : 'assets/images/person2_temp.png'
                      : 'assets/images/nurse_temp.png',
                ),
                fit: BoxFit.cover,
              ),
            ),
          );
        } else {
          String imageUrl = snapshot.data ?? '';
          return Container(
            height: widget.height,
            width: widget.width,
            decoration: BoxDecoration(
              color: HomeCareTheme.secondaryColor,
              shape: BoxShape.circle,
              image: DecorationImage(
                image: imageUrl.isNotEmpty
                    ? NetworkImage(imageUrl)
                    : AssetImage(
                  widget.sharedPrefsController.getUserType() != 3
                      ? widget.sharedPrefsController.getGender() == 0 || widget.sharedPrefsController.getGender() == 1
                      ? 'assets/images/person1_temp.png'
                      : 'assets/images/person2_temp.png'
                      : 'assets/images/nurse_temp.png',
                ) as ImageProvider,
                fit: BoxFit.cover,
                onError: (exception, stackTrace) {
                  print('Image loading error: $exception');
                  setState(() {
                    _hasError = true;
                  });
                },
              ),
            ),
          );
        }
      },
    );
  }
}
