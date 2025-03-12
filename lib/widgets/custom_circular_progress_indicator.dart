// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:homecare/core/theme/themes.dart';

Center HCCPI({double? size = 20.0, Color? color = HomeCareTheme.secondaryColor}) {
  return Center(
    child: SizedBox(
      height: 50.0,
      width: 50.0,
      child: SpinKitThreeBounce(
        size: size!,
        //strokeWidth: 4.0,
        color: color,
      ),
    ),
  );
}
