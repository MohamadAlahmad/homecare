import 'package:flutter/material.dart';
import 'package:homecare/core/theme/themes.dart';
import 'package:homecare/core/utils/globals.dart';
import 'package:homecare/widgets/custom_circular_progress_indicator.dart';
import 'package:homecare/widgets/dashed_border.dart';

class UploadButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String? filePath;
  final String? fileName;
  final bool loading;
  bool? forFillSession;

  UploadButton({
    super.key,
    required this.onPressed,
    this.filePath,
    this.fileName,
    this.loading = false,
    this.forFillSession = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(10.0),
      child: MaterialButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        padding: EdgeInsets.zero,
        onPressed: onPressed,
        child: SizedBox(
          height: 100.0,
          width: forFillSession! ? HomeCareSize.width(context) : HomeCareSize.width(context) * 0.25,
          child: filePath == null || filePath!.isEmpty
              ? DashedBorder(
            child: Center(
              child: loading
                  ? HCCPI(color: HomeCareTheme.primaryColor)
                  : Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Image.asset('assets/icons/export.png', scale: 3.0),
                  Text('رفع ملف', style: TextStyle(fontSize: 14.0, color: Colors.grey[600])),
                ],
              ),
            ),
          ) : DashedBorder(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 5.0),
              child: Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20.0),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      _buildFileIcon(filePath!),
                      if (loading)
                        Center(child: HCCPI(color: Colors.white)),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Text(
                          fileName ?? '',
                          style: TextStyle(fontSize: 10.0, color: Colors.black),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFileIcon(String filePath) {
    final fileExtension = filePath.split('.').last.toLowerCase();
    if (['png', 'jpg', 'jpeg', 'gif'].contains(fileExtension)) {
      return Icon(Icons.image, size: 50.0, color: Colors.blue);
    } else if (['pdf'].contains(fileExtension)) {
      return Icon(Icons.picture_as_pdf, size: 50.0, color: Colors.red);
    } else if (['doc', 'docx'].contains(fileExtension)) {
      return Icon(Icons.description, size: 50.0, color: Colors.blue);
    } else if (['xls', 'xlsx'].contains(fileExtension)) {
      return Icon(Icons.table_chart, size: 50.0, color: Colors.green);
    } else {
      return Icon(Icons.insert_drive_file, size: 50.0, color: Colors.grey);
    }
  }
}
