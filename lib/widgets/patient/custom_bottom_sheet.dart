import 'package:flutter/material.dart';
import 'package:homecare/core/theme/themes.dart';
import 'package:homecare/core/utils/api.dart';
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
  bool _hasError = false;
  String completeImageUrl = '';

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: HomeCareSize.height(context) * 0.5,
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Stack(
          children: [
            _buildContent(context),
            if (!widget.isNutrition) _buildBottomActionBar(context),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Container(
      height: widget.isNutrition ? HomeCareSize.height(context) * 0.5 : HomeCareSize.height(context) * 0.3,
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
      child: SingleChildScrollView(
        padding: EdgeInsets.zero,
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderRow(),
            const SizedBox(height: 10.0),
            _buildDescriptionSection(),
            const SizedBox(height: 10.0),
            if (!widget.isNutrition) _buildPreConditionsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderRow() {
    return SizedBox(
      height: 90.0,
      child: Row(
        children: [
          _buildProfileImage(),
          const SizedBox(width: 10.0),
          _buildTitleAndCategory(),
        ],
      ),
    );
  }

  Widget _buildProfileImage() {
    return _buildImageDecoration();
  }

  Container _buildImageDecoration() {
    completeImageUrl = '${HomeCareApi.baseUrl}/${widget.imagePath}';
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.0),
        // boxShadow: const [BoxShadow(blurRadius: 1.0, spreadRadius: 1.0, color: HomeCareTheme.secondaryColor, offset: Offset(2.0, 2.0))],
      ),
      height: HomeCareSize.height(context),
      width: 90.0,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.0),
        child: _hasError || widget.imagePath.isEmpty
            ? Image.asset(
          'assets/images/temp_image.png',
          fit: BoxFit.cover,
        )
            : Image.network(
          completeImageUrl,
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
    );
  }

  Widget _buildTitleAndCategory() {
    return Padding(
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
              Text(widget.category, style: const TextStyle(color: Colors.black, fontSize: 14.0)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.isNutrition ? 'الوصف :' : 'وصف الخدمة :',
          style: const TextStyle(fontSize: 16.0, color: Colors.grey, decoration: TextDecoration.underline),
        ),
        Text(widget.description),
      ],
    );
  }

  Widget _buildPreConditionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'شروط تقديم الخدمة :',
          style: const TextStyle(fontSize: 16.0, color: Colors.grey, decoration: TextDecoration.underline),
        ),
        Text(widget.preConditions),
      ],
    );
  }

  Widget _buildBottomActionBar(BuildContext context) {
    return Positioned(
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
    );
  }
}