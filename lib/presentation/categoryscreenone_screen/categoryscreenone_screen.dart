// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:delalochu/domain/apiauthhelpers/apiauth.dart';
import 'package:delalochu/presentation/signupscreen_screen/models/signupscreen_model.dart';
import 'package:flutter/material.dart';

import 'package:delalochu/core/app_export.dart';
import 'package:delalochu/widgets/custom_elevated_button.dart';
import 'package:delalochu/widgets/custom_text_form_field.dart';

import '../../core/utils/progress_dialog_utils.dart';
import '../../data/models/servicesModel/getServicesList.dart';
import 'provider/categoryscreenone_provider.dart';

class CategoryscreenoneScreen extends StatefulWidget {
  const CategoryscreenoneScreen({
    Key? key,
  }) : super(key: key);

  @override
  CategoryscreenoneScreenState createState() => CategoryscreenoneScreenState();

  static Widget builder(BuildContext context) {
    return ChangeNotifierProvider(
        create: (context) => CategoryscreenoneProvider(),
        child: CategoryscreenoneScreen());
  }

  static SignupscreenModel getArguments(BuildContext context) {
    final route = ModalRoute.of(context);
    if (route != null) {
      return route.settings.arguments as SignupscreenModel;
    }
    throw Exception("Arguments not found");
  }
}

class CategoryscreenoneScreenState extends State<CategoryscreenoneScreen> {
  bool iscarsaleclick = false;
  bool iscarrentclick = false;
  bool isHousesaleclick = false;
  bool isHouserentclick = false;
  bool isRealestateclick = false;
  bool ishousemaidclick = false;
  bool isSkilledWorkerclick = false;
  bool isUsedItemsclick = false;
  List<Service>? serviceList;
  List<dynamic> selectedservice = [];
  List<dynamic> listotherservice = [];
  TextEditingController typeAnythingController = TextEditingController();

  String otherService = '';
// Use the serviceList as needed

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.endOfFrame.then((value) async {
      serviceList = await ApiAuthHelper.getservice();
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          padding: EdgeInsets.only(left: 10),
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(
            Icons.arrow_back_ios_outlined,
          ),
        ),
        centerTitle: true,
        title: Text(
          "Select your Services",
          style: TextStyle(
            color: appTheme.black900,
            fontSize: 24.fSize,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: Container(
        width: double.maxFinite,
        padding: EdgeInsets.symmetric(vertical: 5.v),
        child: Column(
          children: [
            SizedBox(height: 12.v),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding:
                      EdgeInsets.only(left: 36.h, right: 36.h, bottom: 5.v),
                  child: Column(
                    children: [
                      if (serviceList != [] &&
                          serviceList != null &&
                          serviceList!.isNotEmpty &&
                          serviceList!.length > 0) ...[
                        GridView.builder(
                          itemCount: serviceList!.length,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisExtent: 80,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                          ),
                          itemBuilder: (context, index) {
                            return Expanded(
                              child: CustomElevatedButton(
                                text: serviceList![index].name ?? '',
                                buttonStyle: selectedservice.contains(
                                            '${serviceList![index].id!}') ==
                                        true
                                    ? CustomButtonStyles.outlineBlackTL5
                                    : CustomButtonStyles.none,
                                onPressed: () {
                                  setState(() {
                                    if (!selectedservice.contains(
                                        '${serviceList![index].id!}')) {
                                      selectedservice
                                          .add('${serviceList![index].id!}');
                                    } else {
                                      selectedservice
                                          .remove('${serviceList![index].id!}');
                                    }
                                  });
                                },
                              ),
                            );
                          },
                        ),
                      ],
                      SizedBox(height: 14.v),
                      _buildFortyNine(context),
                      SizedBox(height: 14.v),
                      _buildContinueButton(context)
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  /// Section Widget
  Widget _buildOtherService(BuildContext context) {
    return Container(
      width: 358.h,
      padding: EdgeInsets.symmetric(horizontal: 9.h, vertical: 7.v),
      decoration: AppDecoration.outlineGray
          .copyWith(borderRadius: BorderRadiusStyle.roundedBorder5),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int i = 0; i < listotherservice.length; i++) ...[
            Container(
              // width: 130.85,
              height: 40,
              padding: EdgeInsets.symmetric(horizontal: 9.h, vertical: 7.v),
              margin: EdgeInsets.symmetric(horizontal: 19.h, vertical: 7.v),
              decoration: ShapeDecoration(
                shape: RoundedRectangleBorder(
                  side: BorderSide(width: 1, color: Color(0xFFC4C4C4)),
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                      child: Text(
                    listotherservice[i],
                    style: TextStyle(color: Colors.black),
                  )),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        listotherservice.remove(listotherservice[i]);
                      });
                    },
                    child: Container(
                      margin: EdgeInsets.only(left: 14.h),
                      child: CustomImageView(
                        imagePath: ImageConstant.imgX,
                        color: Color(0xFFFFA05B),
                        height: 16.adaptSize,
                        width: 16.adaptSize,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 14.v),
          ],
        ],
      ),
    );
  }

  /// Section Widget
  Widget _buildFortyNine(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 10.h),
          child: Text(
            "lbl_others".tr,
            style: TextStyle(
              color: appTheme.black900,
              fontSize: 15.fSize,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w300,
            ),
          ),
        ),
        if (listotherservice.isNotEmpty && otherService != '') ...[
          _buildOtherService(context),
        ],
        SizedBox(height: 14.v),
        Selector<CategoryscreenoneProvider, TextEditingController?>(
          selector: (context, provider) => provider.typeAnythingController,
          builder: (context, typeAnythingController, child) {
            this.typeAnythingController = typeAnythingController!;
            return CustomTextFormField(
              controller: this.typeAnythingController,
              hintText: "msg_type_anything".tr,
              onChanged: (p0) => otherService = p0,
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
            );
          },
        ),
        SizedBox(height: 14.v),
        Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton(
            onPressed: () {
              if (otherService != '') {
                setState(() {
                  listotherservice.add(otherService);
                  this.typeAnythingController.clear();
                });
              }
            },
            child: Container(
                width: 53,
                height: 50,
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
                child: Icon(
                  Icons.add,
                  color: Colors.white,
                )),
          ),
        ),
      ],
    );
  }

  /// Section Widget
  Widget _buildContinueButton(BuildContext context) {
    final SignupscreenModel signupModel =
        CategoryscreenoneScreen.getArguments(context);
    return Padding(
      padding: EdgeInsets.only(left: 1.h, right: 1.h, top: 22.v, bottom: 22.v),
      child: ElevatedButton(
        onPressed: () async {
          if (selectedservice != []) {
            setState(() {
              if (listotherservice != []) {
                for (var i = 0; i < listotherservice.length; i++) {
                  selectedservice.add(listotherservice[i]);
                }
              }
            });
            ProgressDialogUtils.showProgressDialog(
              context: context,
              isCancellable: false,
            );
            var res = await ApiAuthHelper.signUp(
                userName: signupModel.userName,
                password: signupModel.password,
                phoneNumber: signupModel.phoneNumber);
            if (res == 'true') {
              ProgressDialogUtils.hideProgressDialog();
              onTapContinueButton(context);
              ProgressDialogUtils.showSnackBar(
                  context: context, message: 'You have successfully signed up');
            } else {
              ProgressDialogUtils.hideProgressDialog();
              ProgressDialogUtils.showSnackBar(
                context: context,
                message: '$res',
              );
              return;
            }
          } else {
            ProgressDialogUtils.showSnackBar(
                context: context,
                message: 'Please select a service, at least one!');
          }
        },
        child: Container(
          width: 343,
          height: 50,
          padding: const EdgeInsets.only(top: 16, bottom: 10),
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
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "lbl_continue".tr,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w700,
                  height: 0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Navigates to the homescreenScreen when the action is triggered.
  onTapContinueButton(BuildContext context) {
    NavigatorService.pushNamedAndRemoveUntil(
      AppRoutes.homescreenScreens,
    );
  }
}
