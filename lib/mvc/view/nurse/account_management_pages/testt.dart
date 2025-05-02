import 'package:flutter/material.dart';

class ProfileImageProgressIndicator extends StatelessWidget {
  final double progress;
  final bool isError;

  const ProfileImageProgressIndicator({
    required this.progress,
    this.isError = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        CircularProgressIndicator(
          value: progress,
          valueColor: AlwaysStoppedAnimation<Color>(
            isError ? Colors.red : (progress == 1.0 ? Colors.green : Colors.grey),
          ),
          backgroundColor: Colors.grey[300],
          strokeWidth: 4.0,
        ),
        if (isError)
          const Icon(
            Icons.error,
            color: Colors.red,
            size: 24.0,
          ),
      ],
    );
  }
}
