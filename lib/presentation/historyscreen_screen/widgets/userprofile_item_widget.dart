import 'package:delalochu/presentation/historyscreen_screen/rate_broker.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import '../../homescreen_screen/models/connectionhistoryModel.dart';
import 'package:delalochu/core/app_export.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class UserprofileItemWidget extends StatelessWidget {
  UserprofileItemWidget(
    // this.userprofileItemModelObj,
    this.connections, {
    Key? key,
  }) : super(
          key: key,
        );

  // UserprofileItemModel userprofileItemModelObj;
  Connection connections;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 19.h,
        vertical: 21.v,
      ),
      decoration: AppDecoration.outlineBlack900,
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RateBrokerScreen(connections: connections),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomImageView(
              imagePath: ImageConstant.imageNotFound,
              height: 60.adaptSize,
              width: 60.adaptSize,
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
                    connections.broker != null
                        ? connections.broker!.fullName != null
                            ? connections.broker!.fullName!
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
                  Text(
                    connections.broker != null
                        ? connections.broker!.phone != null
                            ? connections.broker!.phone!
                            : ''
                        : '',
                    style: TextStyle(
                      color: appTheme.blueGray400,
                      fontSize: 20.fSize,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  RatingBar.builder(
                    initialRating: connections.broker != null &&
                            connections.broker!.averageRating != null
                        ? connections.broker!.averageRating!
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
                      print(rating);
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Status:",
                        style: TextStyle(
                          color: appTheme.blueGray400,
                          fontSize: 20.fSize,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      SizedBox(width: 10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          connections.status != null ? connections.status! : '',
                          style: TextStyle(
                            color: appTheme.blueGray400,
                            fontSize: 20.fSize,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Created Date:",
                        style: TextStyle(
                          color: appTheme.blueGray400,
                          fontSize: 20.fSize,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      SizedBox(width: 10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          connections.createdAt != null
                              ? '${connections.broker!.createdAt!.year.toString()}-${connections.broker!.createdAt!.month.toString()}-${connections.broker!.createdAt!.day.toString()}'
                              : '',
                          style: TextStyle(
                            color: appTheme.blueGray400,
                            fontSize: 20.fSize,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
