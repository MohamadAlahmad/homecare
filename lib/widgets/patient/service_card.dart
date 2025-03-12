// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:homecare/core/theme/themes.dart';
import 'package:homecare/core/utils/globals.dart';

Widget ServiceCard(
    BuildContext context, {
      required String title,
      required String description,
      required String imagePath,
      required VoidCallback onClick,
      required num price,
      bool isNutrition = false,
    }) {
  return InkWell(
    onTap: () {
      onClick();
    },
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
                      title,
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
                      description,
                      style: const TextStyle(
                        fontSize: 12.0,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.start,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    if(!isNutrition) Text('السعر $price ألف ',
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
            ),
            height: HomeCareSize.height(context),
            width: 90.0,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20.0),
              child: imagePath.startsWith('http') // Check if it's a URL
                  ? Image.network(
                imagePath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Image.asset(
                    'assets/images/temp_image.png',
                    fit: BoxFit.cover,
                  );
                },
              ) : Image.asset(
                'assets/images/temp_image.png', // Load as asset if not a URL
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
