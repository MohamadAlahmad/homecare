import 'package:flutter/material.dart';

Material SocialMediaCard({
  required String iconUrl,
  required VoidCallback onTap,
  required String title,
  bool isWhatsApp = false,
}) {
  return Material(
    color: Colors.transparent,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(25.0),
      side: BorderSide(
        width: isWhatsApp ? 2.0 : 0.5,
        color: isWhatsApp ? const Color(0xFF25D366) : Colors.grey,
      ),
    ),
    child: InkWell(
      borderRadius: BorderRadius.circular(25.0),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(15.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25.0),
          gradient: isWhatsApp
              ? LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              const Color(0xFF25D366).withValues(alpha: 0.1),
              const Color(0xFF25D366).withValues(alpha: 0.05),
            ],
          )
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          spacing: 15.0,
          children: [
            if (isWhatsApp)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0),
                decoration: BoxDecoration(
                  color: const Color(0xFF25D366),
                  borderRadius: BorderRadius.circular(20.0),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF25D366).withValues(alpha: 0.3),
                      blurRadius: 8.0,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  spacing: 8.0,
                  children: [
                    Text(
                      'راسلنا الآن',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 20.0,
                    ),
                  ],
                ),
              )
            else
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(fontSize: 18.0, color: Colors.black),
                  textAlign: TextAlign.right,
                ),
              ),
            const VerticalDivider(thickness: 1.0),
            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: isWhatsApp
                    ? const Color(0xFF25D366).withValues(alpha: 0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Image.asset(iconUrl, scale: 2.0),
            ),
          ],
        ),
      ),
    ),
  );
}