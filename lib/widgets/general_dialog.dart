import 'package:flutter/material.dart';
import 'package:homecare/core/theme/themes.dart';

class HomeCareDialog extends StatefulWidget {
  final String title;
  final String content;
  final String confirmButtonText;
  final String cancelButtonText;
  final Future<bool> Function() onConfirm;

  const HomeCareDialog({super.key,
    required this.title,
    required this.content,
    required this.confirmButtonText,
    required this.cancelButtonText,
    required this.onConfirm,
  });

  @override
  State<HomeCareDialog> createState() => _HomeCareDialogState();
}

class _HomeCareDialogState extends State<HomeCareDialog> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        title: isLoading
            ? Center(child: CircularProgressIndicator(color: HomeCareTheme.primaryColor))
            : Text(widget.title),
        content: Text(widget.content),
        actions: <Widget>[
          SizedBox(
            width: 120.0,
            child: IconButton(
              onPressed: () async {
                setState(() => isLoading = true);
                bool result = await widget.onConfirm();
                if (result) {
                  Navigator.of(context).pop(true);
                } else {
                  setState(() => isLoading = false);
                }
              },
              style: IconButton.styleFrom(
                elevation: 0.0,
                backgroundColor: Colors.green.withValues(alpha: 0.1),
              ),
              icon: Text(
                widget.confirmButtonText,
                style: TextStyle(color: Colors.green, fontSize: 14.0),
              ),
            ),
          ),
          SizedBox(
            width: 100.0,
            child: IconButton(
              onPressed: () => Navigator.of(context).pop(false),
              style: IconButton.styleFrom(
                elevation: 0.0,
                backgroundColor: HomeCareTheme.primaryColor.withValues(alpha: 0.1),
              ),
              icon: Text(
                widget.cancelButtonText,
                style: TextStyle(
                  color: HomeCareTheme.primaryColorBold,
                  fontSize: 14.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
