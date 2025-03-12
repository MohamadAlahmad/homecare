import 'package:flutter/material.dart';
import 'package:homecare/core/theme/themes.dart';
import 'package:homecare/core/utils/globals.dart';
import 'package:homecare/widgets/buttons.dart';

class ServiceModal extends StatefulWidget {
  final String title;
  final String description;
  final String preConditions;
  final String imagePath;
  final dynamic price;
  final VoidCallback onPressed;
  final String category;
  final bool isNutrition;

  const ServiceModal({
    super.key,
    required this.title,
    required this.description,
    required this.preConditions,
    required this.imagePath,
    required this.price,
    required this.onPressed,
    required this.category,
    required this.isNutrition,
  });

  @override
  State<ServiceModal> createState() => _ServiceModalState();
}

class _ServiceModalState extends State<ServiceModal> {
  bool hasError = false;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: HomeCareSize.height(context) * 0.5,
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Stack(
          children: [
            Container(
              height: widget.isNutrition ? HomeCareSize.height(context) * 0.5 : HomeCareSize.height(context) * 0.3,
              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
              child: SingleChildScrollView(
                padding: EdgeInsets.zero,
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 90.0,
                      child: Row(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(left: 10.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15.0),
                              image: DecorationImage(
                                image: widget.imagePath.isEmpty
                                    ? const AssetImage('assets/images/temp_image.png') as ImageProvider
                                    : (widget.imagePath.startsWith('http')
                                    ? NetworkImage(widget.imagePath)
                                    : const AssetImage('assets/images/temp_image.png') as ImageProvider),
                                fit: BoxFit.cover,
                                onError: (error, stackTrace) {
                                  setState(() {
                                    hasError = true;
                                  });
                                },
                              ),
                            ),
                            height: 90.0,
                            width: 90.0,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 15.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  widget.title,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
                                ),
                                Row(
                                  children: [
                                    const Text('الفئة : ', style: TextStyle(color: HomeCareTheme.primaryColor, fontSize: 14.0)),
                                    Text(widget.category, style: TextStyle(color: Colors.black, fontSize: 14.0)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    Text(
                      widget.isNutrition ? 'الوصف :' : 'وصف الخدمة :',
                      style: const TextStyle(fontSize: 16.0, color: Colors.grey, decoration: TextDecoration.underline),
                    ),
                    Text(widget.description),
                    const SizedBox(height: 10.0),
                    if(!widget.isNutrition) Text(
                      'شروط تقديم الخدمة :',
                      style: const TextStyle(fontSize: 16.0, color: Colors.grey, decoration: TextDecoration.underline),
                    ),
                    Text(widget.preConditions),
                  ],
                ),
              ),
            ),
            if(!widget.isNutrition) Positioned(
              left: 0.0,
              right: 0.0,
              bottom: 0.0,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(15.0),
                    height: HomeCareSize.height(context) * 0.2,
                    color: Colors.white,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'السعر',
                              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14.0),
                            ),
                            Text(
                              '${widget.price} ل.س',
                              style: const TextStyle(color: HomeCareTheme.primaryColor, fontWeight: FontWeight.bold, fontSize: 16.0),
                            ),
                          ],
                        ),
                        CustomButton(
                          onPressed: widget.onPressed,
                          title: const Text(
                            'حجز الخدمة',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                          backgroundColor: HomeCareTheme.primaryColor,
                          width: HomeCareSize.width(context),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
