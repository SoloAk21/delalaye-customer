// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:delalochu/domain/apiauthhelpers/apiauth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import 'package:delalochu/core/app_export.dart';

import '../../core/utils/progress_dialog_utils.dart';
import '../../widgets/app_bar/appbar_leading_image.dart';
import '../../widgets/app_bar/appbar_title.dart';
import '../../widgets/app_bar/custom_app_bar.dart';
import '../../widgets/custom_text_form_field.dart';
import '../homescreen_screen/models/connectionhistoryModel.dart';

class RateBrokerScreen extends StatefulWidget {
  final Connection connections;
  const RateBrokerScreen({
    Key? key,
    required this.connections,
  }) : super(key: key);

  @override
  State<RateBrokerScreen> createState() => _RateBrokerScreenState();
}

class _RateBrokerScreenState extends State<RateBrokerScreen> {
  var reviewController = TextEditingController();
  var titleController = TextEditingController();
  String title = "";
  String review = "";
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String newRateValue = '0';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        leadingWidth: 75.h,
        leading: AppbarLeadingImage(
            imagePath: ImageConstant.imgFiSsArrowSmallLeft,
            margin: EdgeInsets.only(left: 43.h, top: 11.v, bottom: 12.v),
            onTap: () {
              NavigatorService.goBack();
            }),
        centerTitle: true,
        title: AppbarTitle(text: "lbl_history".tr),
      ),
      body: Container(
        padding: EdgeInsets.only(left: 20, top: 20, right: 20),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomImageView(
                      imagePath: ImageConstant.imageNotFound,
                      height: 60.adaptSize,
                      width: 60.adaptSize,
                      border: Border.all(color: appTheme.orangeA200, width: 1),
                      radius: BorderRadius.circular(
                        30.h,
                      ),
                      margin: EdgeInsets.only(
                        top: 2.v,
                        bottom: 7.v,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        left: 19.h,
                        top: 2.v,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.connections.broker != null
                                ? widget.connections.broker!.fullName != null
                                    ? widget.connections.broker!.fullName!
                                    : ''
                                : '',
                            style: TextStyle(
                              color: appTheme.blueGray400,
                              fontSize: 20.fSize,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          SizedBox(height: 8.v),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                widget.connections.broker != null
                                    ? widget.connections.broker!
                                                .averageRating !=
                                            null
                                        ? widget
                                            .connections.broker!.averageRating!
                                            .round()
                                            .toString()
                                        : '0'
                                    : '0',
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 15,
                                ),
                              ),
                              RatingBar.builder(
                                initialRating: widget.connections.broker !=
                                            null &&
                                        widget.connections.broker!
                                                .averageRating !=
                                            null
                                    ? widget.connections.broker!.averageRating!
                                    : 0,
                                itemSize: 30,
                                minRating: 1,
                                direction: Axis.horizontal,
                                allowHalfRating: true,
                                itemCount: 5,
                                itemPadding: EdgeInsets.symmetric(
                                  horizontal: 4.0,
                                ),
                                itemBuilder: (context, _) => Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                ),
                                onRatingUpdate: (rating) {
                                  debugPrint(rating.toString());
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 30),
                // Padding(
                //   padding: const EdgeInsets.symmetric(horizontal: 30.0),
                //   child: Text(
                //     'A very experienced broker with a passion for the financial markets.',
                //     style: const TextStyle(
                //       fontSize: 16,
                //     ),
                //   ),
                // ),
                SizedBox(height: 20),
                Text(
                  'Rate',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 15,
                  ),
                ),
                RatingBar.builder(
                  initialRating: 0,
                  itemSize: 30,
                  minRating: 1,
                  direction: Axis.horizontal,
                  allowHalfRating: true,
                  itemCount: 5,
                  itemPadding: EdgeInsets.symmetric(
                    horizontal: 4.0,
                  ),
                  itemBuilder: (context, _) => Icon(
                    Icons.star,
                    color: Colors.amber,
                  ),
                  onRatingUpdate: (rating) {
                    setState(() {
                      newRateValue = rating.toString();
                    });
                    debugPrint(rating.toString());
                  },
                ),
                SizedBox(height: 30),
                Container(
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey, width: 1)),
                  child: CustomTextFormField(
                    controller: titleController,
                    hintText: "Title ",
                    onChanged: (p0) => title = p0,
                    hintStyle: TextStyle(
                      color: appTheme.blueGray400,
                    ),
                    textInputAction: TextInputAction.done,
                    textStyle: TextStyle(
                      color: appTheme.black900,
                    ),
                    maxLines: 1,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12.h,
                      vertical: 19.v,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey, width: 1)),
                  child: CustomTextFormField(
                    controller: reviewController,
                    hintText: "Review: ",
                    onChanged: (p0) => review = p0,
                    hintStyle: TextStyle(
                      color: appTheme.blueGray400,
                    ),
                    textInputAction: TextInputAction.done,
                    textStyle: TextStyle(
                      color: appTheme.black900,
                    ),
                    maxLines: 8,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12.h,
                      vertical: 19.v,
                    ),
                  ),
                ),
                SizedBox(height: 100),
                Center(child: _buildRatebutton(context)),
                // SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Section Widget
  Widget _buildRatebutton(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        if (review != "") {
          if (widget.connections.broker != null) {
            ProgressDialogUtils.showProgressDialog(
              context: context,
              isCancellable: false,
            );
            var res = await ApiAuthHelper.rateBroker(
                brokerId: widget.connections.broker!.id,
                comment: review,
                rateValue: newRateValue);
            if (res) {
              ProgressDialogUtils.hideProgressDialog();
              setState(() {
                titleController.clear();
                reviewController.clear();
              });
              ProgressDialogUtils.showSnackBar(
                context: context,
                message: 'You have successfully rated the Broker',
              );
            } else {
              ProgressDialogUtils.hideProgressDialog();
              ProgressDialogUtils.showSnackBar(
                context: context,
                message: 'You have failed to rate, please try again',
              );
            }
          }
        } else {
          ProgressDialogUtils.showSnackBar(
            context: context,
            message: 'Please write a comment for the Broker and try again',
          );
          return;
        }
      },
      child: Container(
        width: 343,
        height: 50,
        padding: const EdgeInsets.only(top: 10, bottom: 10),
        clipBehavior: Clip.antiAlias,
        decoration: ShapeDecoration(
          gradient: LinearGradient(
            begin: Alignment(0.79, 0.61),
            end: Alignment(-0.79, -0.61),
            colors: [Color(0xFFF06400), Color(0xFFFFA05B)],
          ),
          shape: RoundedRectangleBorder(
            side: BorderSide(width: 0.50, color: Colors.white),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          'Done',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w700,
            height: 0,
          ),
        ),
      ),
    );
  }
}
