import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:homecare/core/theme/themes.dart';
import 'package:homecare/core/utils/globals.dart';
import 'package:homecare/widgets/buttons.dart';
import 'package:homecare/widgets/custom_text_field.dart';
import 'package:homecare/widgets/expanded_list.dart';

class FillSessionModal extends StatefulWidget {
  final String title;
  final num price;
  final TextEditingController additionalServiceNameCtrl;
  final TextEditingController additionalServicePriceCtrl;
  final VoidCallback onPressed;

  const FillSessionModal({
    super.key,
    required this.title,
    required this.price,
    required this.onPressed,
    required this.additionalServiceNameCtrl,
    required this.additionalServicePriceCtrl,
  });

  @override
  State<FillSessionModal> createState() => _FillSessionModalState();
}

class _FillSessionModalState extends State<FillSessionModal> {
  bool hasError = false;
  bool clicked = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: SizedBox(
        height: HomeCareSize.height(context) * 0.47,
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Stack(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                child: SingleChildScrollView(
                  padding: EdgeInsets.zero,
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
                      ),
                      Container(
                        padding: EdgeInsets.all(10.0),
                        margin: const EdgeInsets.symmetric(vertical: 10.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15.0),
                          color: HomeCareTheme.primaryColor.withValues(alpha: 0.1),
                        ),
                        height: 60.0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('الخدمة', style: TextStyle(color: Colors.grey, fontSize: 14.0)),
                            Text('${widget.price} ل.س', style: TextStyle(color: Colors.black, fontSize: 14.0)),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              setState(() {
                                clicked = !clicked;
                              });
                            },
                            icon: Icon(CupertinoIcons.add_circled),
                          ),
                          Text('إضافة خدمة', style: TextStyle(color: Colors.grey, fontSize: 16.0)),
                        ],
                      ),
                      ExpandedSection(
                        expand: clicked,
                        height: 225.0,
                        forwardDuration: const Duration(milliseconds: 500),
                        reverseDuration: const Duration(milliseconds: 700),
                        child: Column(
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                CustomTextField(context, controller: widget.additionalServiceNameCtrl, fontSize: 14.0, hintText: 'اسم الخدمة', hintColor: Colors.grey, fillColor: HomeCareTheme.primaryColor.withValues(alpha: 0.1), maxLines: 2),
                                SizedBox(height: 10.0),
                                CustomTextField(context, controller: widget.additionalServicePriceCtrl, fontSize: 14.0, vital: true, hintText: 'السعر', hintColor: Colors.grey, fillColor: HomeCareTheme.primaryColor.withValues(alpha: 0.1)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 0.0,
                right: 0.0,
                bottom: 0.0,
                child: Container(
                  padding: const EdgeInsets.all(15.0),
                  color: Colors.white,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'السعر النهائي',
                            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14.0),
                          ),
                          Text(
                            widget.additionalServicePriceCtrl.text.isNotEmpty ? (widget.price + num.parse(widget.additionalServicePriceCtrl.text)).toString() : widget.price.toString(),
                            style: const TextStyle(color: HomeCareTheme.primaryColor, fontWeight: FontWeight.bold, fontSize: 16.0),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10.0),
                      CustomButton(
                        onPressed: () {
                          if(clicked && widget.additionalServiceNameCtrl.text.isEmpty && widget.additionalServicePriceCtrl.text.isEmpty) {

                          } else {
                            widget.onPressed();
                          }
                        },
                        title: const Text(
                          'تم',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        backgroundColor: HomeCareTheme.primaryColor,
                        width: HomeCareSize.width(context),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    widget.additionalServiceNameCtrl.clear();
    widget.additionalServicePriceCtrl.clear();
    super.dispose();
  }

}