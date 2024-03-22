import 'package:delalochu/core/app_export.dart';
import 'package:flutter/material.dart';

import '../core/utils/progress_dialog_utils.dart';

class CustomDialog extends StatelessWidget {
  const CustomDialog(
      {Key? key,
      required this.color,
      required this.title,
      required this.buttonLable,
      required this.message,
      required this.cancelreason,
      required this.amount,
      required this.onClick,
      required this.icon})
      : super(key: key);

  final Color color;
  final String title, message, buttonLable, amount;
  final IconData icon;
  final List<String> cancelreason;
  final void Function(int selectedIndex) onClick;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: _buildChild(
        context: context,
        color: color,
        title: title,
        amount: amount,
        message: message,
        cancelreason: cancelreason,
        buttonLable: buttonLable,
        onClick: onClick,
        icon: icon,
      ),
    );
  }
}

StatefulBuilder _buildChild(
    {required BuildContext context,
    required Color color,
    required String title,
    required String message,
    required List<String> cancelreason,
    required String amount,
    required String buttonLable,
    required IconData icon,
    required void Function(int selectedIndex) onClick}) {
  int? selectedreasonindex;
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  return StatefulBuilder(
    builder: (context, setState) => Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                height: 40.0,
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    margin: EdgeInsets.only(right: 16.h, top: 14.v),
                    child: CustomImageView(
                      imagePath: ImageConstant.imgX,
                      color: Color(0xFFFFA05B),
                      height: 26.adaptSize,
                      width: 26.adaptSize,
                    ),
                  ),
                ),
              ),
            ),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontFamily: 'poppins',
                fontSize: 20,
              ),
            ),
            SizedBox(height: 10),
            for (int i = 0; i < cancelreason.length; i++) ...[
              InkWell(
                onTap: () {
                  setState(
                    () {
                      selectedreasonindex = i;
                    },
                  );
                },
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  height: 60.77,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: selectedreasonindex == i
                        ? appTheme.orangeA200
                        : appTheme.whiteA700,
                    border: Border.all(color: Colors.grey, width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: appTheme.black900.withOpacity(0.25),
                        spreadRadius: 1.h,
                        blurRadius: 1.h,
                        offset: Offset(
                          0,
                          0,
                        ),
                      ),
                    ],
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20.0),
                      child: Text(
                        cancelreason[i],
                        style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontFamily: 'poppins',
                            color:
                                selectedreasonindex == i ? Colors.black : null,
                            fontSize: 18),
                      ),
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 10.0),
            GestureDetector(
              onTap: () async {
                if (selectedreasonindex != null) {
                  onClick(selectedreasonindex ?? 0);
                } else {
                  ProgressDialogUtils.showSnackBar(
                    context: context,
                    message: 'Please select a reason for cancellation',
                  );
                }
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  color: color,
                  gradient: LinearGradient(
                    begin: Alignment(0.79, 0.61),
                    end: Alignment(-0.79, -0.61),
                    colors: [Color(0xFFF06400), Color(0xFFFFA05B)],
                  ),
                  shape: BoxShape.rectangle,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(16.0),
                    bottomRight: Radius.circular(16.0),
                  ),
                ),
                child: Center(
                  child: Text(
                    buttonLable,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontFamily: 'poppins',
                        color: Colors.white,
                        fontSize: 17),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    ),
  );
}
