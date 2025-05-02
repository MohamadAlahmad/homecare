// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:homecare/core/theme/themes.dart';
import 'package:homecare/core/utils/globals.dart';

class ServiceCard extends StatefulWidget {
  final String title;
  final String description;
  final String imageUrl;
  final VoidCallback onClick;
  final num price;
  final bool isNutrition;

  const ServiceCard({
    super.key,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.onClick,
    required this.price,
    this.isNutrition = false,
  });

  @override
  State<ServiceCard> createState() => _ServiceCardState();
}

class _ServiceCardState extends State<ServiceCard> {
  bool _hasError = false;
  late final String _completeImageUrl;

  @override
  void initState() {
    super.initState();
    const String baseUrl = 'http://185.158.94.162:8080/';
    _completeImageUrl = '$baseUrl${widget.imageUrl}';
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onClick,
      child: Container(
        padding: const EdgeInsets.all(10.0),
        height: 110.0,
        margin: const EdgeInsets.only(bottom: 10.0, left: 7.0, right: 7.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.0),
          color: Colors.white,
        ),
        child: Row(
          children: [
            RotatedBox(
              quarterTurns: 2,
              child: Image.asset(
                'assets/icons/back.png',
                scale: 3.0,
                color: HomeCareTheme.primaryColor,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: const TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.end,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        widget.description,
                        style: const TextStyle(
                          fontSize: 12.0,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.start,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Spacer(),
                      if (!widget.isNutrition)
                        Text('السعر ${widget.price} ألف ',
                          style: const TextStyle(
                            fontSize: 12.0,
                            fontWeight: FontWeight.bold,
                            color: HomeCareTheme.primaryColor,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.0),
                // boxShadow: const [BoxShadow(blurRadius: 1.0, spreadRadius: 1.0, color: HomeCareTheme.secondaryColor, offset: Offset(2.0, 2.0))],
              ),
              height: HomeCareSize.height(context),
              width: 90.0,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20.0),
                child: _hasError || widget.imageUrl.isEmpty
                    ? Image.asset(
                  'assets/images/temp_image.png',
                  fit: BoxFit.cover,
                )
                    : Image.network(
                  _completeImageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    if (!_hasError) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted) {
                          setState(() {
                            _hasError = true;
                          });
                        }
                      });
                    }
                    return Image.asset(
                      'assets/images/temp_image.png',
                      fit: BoxFit.cover,
                    );
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        color: HomeCareTheme.primaryColor,
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}