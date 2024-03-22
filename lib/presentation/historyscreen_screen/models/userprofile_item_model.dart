import '../../../core/app_export.dart';

/// This class is used in the [userprofile_item_widget] screen.
class UserprofileItemModel {
  UserprofileItemModel({
    this.userImage,
    this.userName,
    this.userPhoneNumber,
    this.id,
  }) {
    userImage = userImage ?? ImageConstant.imgEllipse3;
    userName = userName ?? "Abebe Kebede";
    userPhoneNumber = userPhoneNumber ?? "+ 25191235678";
    id = id ?? "";
  }

  String? userImage;

  String? userName;

  String? userPhoneNumber;

  String? id;
}
