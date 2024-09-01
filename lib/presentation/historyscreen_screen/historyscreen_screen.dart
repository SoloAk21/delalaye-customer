import '../historyscreen_screen/widgets/userprofile_item_widget.dart';
import 'package:delalochu/core/app_export.dart';
import 'package:delalochu/widgets/app_bar/appbar_leading_image.dart';
import 'package:delalochu/widgets/app_bar/appbar_title.dart';
import 'package:delalochu/widgets/app_bar/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'provider/historyscreen_provider.dart';

class HistoryscreenScreen extends StatefulWidget {
  const HistoryscreenScreen({Key? key}) : super(key: key);

  @override
  HistoryscreenScreenState createState() => HistoryscreenScreenState();

  static Widget builder(BuildContext context) {
    return ChangeNotifierProvider(
        create: (context) => HistoryscreenProvider(),
        child: HistoryscreenScreen());
  }
}

class HistoryscreenScreenState extends State<HistoryscreenScreen> {
  HistoryscreenProvider? historyProvider;

  bool isloading = false;
  getBrokerData() async {
    historyProvider =
        Provider.of<HistoryscreenProvider>(context, listen: false);
    setState(() {
      isloading = true;
    });
    await historyProvider!.getBroker();
    setState(() {
      isloading = false;
    });
  }

  @override
  void initState() {
    getBrokerData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: isloading
          ? Center(child: CircularProgressIndicator())
          : SizedBox(
              width: SizeUtils.width,
              child: SingleChildScrollView(
                padding: EdgeInsets.only(top: 16.v, bottom: 16.v),
                child: _buildUserProfile(context),
              ),
            ),
    );
  }

  /// Section Widget
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return CustomAppBar(
      leadingWidth: 75.h,
      leading: AppbarLeadingImage(
          imagePath: ImageConstant.imgFiSsArrowSmallLeft,
          margin: EdgeInsets.only(left: 43.h, top: 11.v, bottom: 12.v),
          onTap: () {
            onTapFiSsArrowSmallLeft(context);
          }),
      centerTitle: true,
      title: AppbarTitle(text: "lbl_history".tr),
    );
  }

  /// Section Widget
  Widget _buildUserProfile(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 23.h),
      child: Consumer<HistoryscreenProvider>(
        builder: (context, provider, child) {
          if (provider.connectionData.length == 0) {
            return Center(
              child: Text(
                'No history',
                style: TextStyle(
                  color: appTheme.blueGray400,
                  fontSize: 20.fSize,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w400,
                ),
              ),
            );
          } else {
            return ListView.separated(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                separatorBuilder: (context, index) {
                  return SizedBox(height: 17.v);
                },
                itemCount: provider.connectionData.length,
                itemBuilder: (context, index) {
                  return UserprofileItemWidget(
                    historyProvider!.connectionData[index],
                  );
                });
          }
        },
      ),
    );
  }

  /// Navigates to the homescreenScreen when the action is triggered.
  onTapFiSsArrowSmallLeft(BuildContext context) {
    NavigatorService.pushNamed(
      AppRoutes.homescreenScreens,
    );
  }
}
