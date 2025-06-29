// ignore_for_file: non_constant_identifier_names

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:homecare/core/theme/themes.dart';

Container CustomItemCard({
  required int id,
  required String title,
  required num value,
  required bool isSelected,
  bool forLabTest = false,
  bool disableStars = false,
  required String imagePath,
}) {
  return Container(
    margin: EdgeInsets.only(left: 10.0, top: 10.0, bottom: 10.0, right: 5.0),
    padding: EdgeInsets.all(10.0),
    width: 100.0,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(20.0),
      color: isSelected ? HomeCareTheme.primaryColorLight : Colors.white,
      boxShadow: const [BoxShadow(blurRadius: 5.0, spreadRadius: 1.0, color: HomeCareTheme.secondaryColor)],
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          height: 75.0,
          width: 85.0,
          decoration: BoxDecoration(
            color: HomeCareTheme.secondaryColor,
            borderRadius: BorderRadius.circular(20.0),
            image: imagePath.isNotEmpty ? DecorationImage(
              image: AssetImage(imagePath),
              fit: BoxFit.cover,
            ) : null,
            boxShadow: imagePath.isNotEmpty ? [BoxShadow(blurRadius: 10.0, spreadRadius: 1.0, color: HomeCareTheme.secondaryColor)] : null,
          ),
        ),
        AutoSizeText(title, style: TextStyle(color: isSelected ? Colors.white : Colors.black, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal), maxLines: 1, overflow: TextOverflow.ellipsis, minFontSize: 8.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if(!forLabTest) Expanded(child: Center()),
            disableStars ? Center() : Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 3.0),
                  child: AutoSizeText(value.toString(), style: TextStyle(fontSize: isSelected ? 16.0 : 14.0, color: isSelected ? Colors.white : Colors.black, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal), maxLines: 1, minFontSize: 8.0, maxFontSize: 18.0),
                ),
              ),
            ),
            //const SizedBox(width: 5.0),
            forLabTest? Text('ل.س', style: TextStyle(fontSize: 12.0, color: isSelected ? Colors.white : Colors.black)) : disableStars ? Center() : Expanded(child: Icon(Icons.star, color: Colors.amberAccent, size: isSelected ? 15.0 : 13.0)),
          ],
        ),
      ],
    ),
  );
}