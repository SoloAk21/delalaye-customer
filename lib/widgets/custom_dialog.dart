import 'package:delalochu/core/app_export.dart';
import 'package:flutter/material.dart';
import '../core/utils/progress_dialog_utils.dart';

class CustomDialog extends StatelessWidget {
  const CustomDialog({
    Key? key,
    required this.color,
    required this.title,
    required this.buttonLabel,
    required this.message,
    required this.cancelReasons,
    required this.amount,
    required this.onClick,
    required this.icon,
  }) : super(key: key);

  final Color color;
  final String title, message, buttonLabel, amount;
  final IconData icon;
  final List<String> cancelReasons;
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
        context,
        color,
        title,
        message,
        cancelReasons,
        amount,
        buttonLabel,
        onClick,
        icon,
      ),
    );
  }
}

StatefulBuilder _buildChild(
  BuildContext context,
  Color color,
  String title,
  String message,
  List<String> cancelReasons,
  String amount,
  String buttonLabel,
  void Function(int selectedIndex) onClick,
  IconData icon,
) {
  int? selectedReasonIndex;
  return StatefulBuilder(
    builder: (context, setState) {
      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(16.0),
        ),
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
                    child: Icon(
                      Icons.close,
                      color: const Color(0xFFFFA05B),
                      size: 26,
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
            for (int i = 0; i < cancelReasons.length; i++) ...[
              InkWell(
                onTap: () {
                  setState(() {
                    selectedReasonIndex = i;
                  });
                },
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  height: 60.77,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color:
                        selectedReasonIndex == i ? color : Colors.transparent,
                    border: Border.all(
                      color: Colors.grey,
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.25),
                        spreadRadius: 1,
                        blurRadius: 1,
                        offset: const Offset(0, 0),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        cancelReasons[i],
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontFamily: 'poppins',
                          color: selectedReasonIndex == i ? Colors.black : null,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 10.0),
            GestureDetector(
              onTap: () async {
                if (selectedReasonIndex != null) {
                  onClick(selectedReasonIndex!);
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
                  gradient: const LinearGradient(
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
                    buttonLabel,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontFamily: 'poppins',
                      color: Colors.white,
                      fontSize: 17,
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      );
    },
  );
}
