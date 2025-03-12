/*



Align(
              alignment: Alignment.topRight,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text('تأكيد الرقم', style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold, color: Colors.black)),
                  CustomBackButton(
                    onBack: () {
                      FocusScope.of(context).unfocus();
                      GlobalPageController.registerController.previousPage(
                        duration: const Duration(milliseconds: 800),
                        curve: Curves.easeInOut,
                      );

                    },
                  ),
                ],
              ),
            ),






       Positioned(
              left: 0,
              right: 0,
              child: Image.asset('assets/images/ALB.png', scale: 2.0),
            ),















*/

