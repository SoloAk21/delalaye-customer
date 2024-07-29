/// This widget is customize from the place_picker - https://pub.dev/packages/place_picker
import 'dart:async';
import 'dart:convert';
import 'dart:math' show Random;

import 'package:delalochu/core/app_export.dart';
import 'package:delalochu/core/utils/progress_dialog_utils.dart';
import 'package:delalochu/domain/apiauthhelpers/apiauth.dart';
import 'package:delalochu/presentation/homescreen_screen/provider/homescreen_provider.dart';
import 'package:delalochu/presentation/map_view/model/broker_request_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:inspireui/extensions/string_extension.dart';
import 'package:location/location.dart';

import '../callToBroker_Page/call_to_broker_sreen.dart';
import '../../widgets/custom_dialog.dart';
import 'model/broker_info_model.dart';
import 'model/check_request_usingConnection.dart';
import 'package:html/parser.dart' show parse;
import 'dart:ui' as ui;

/// A UUID generator.
///
/// This will generate unique IDs in the format:
///
///     f47ac10b-58cc-4372-a567-0e02b2c3d479
///
/// The generated uuids are 128 bit numbers encoded in a specific string format.
/// For more information, see
/// [en.wikipedia.org/wiki/Universally_unique_identifier](http://en.wikipedia.org/wiki/Universally_unique_identifier).
class Uuid {
  final Random _random = Random();

  /// Generate a version 4 (random) uuid. This is a uuid scheme that only uses
  /// random numbers as the source of the generated uuid.
  String generateV4() {
    // Generate xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx / 8-4-4-4-12.
    var special = 8 + _random.nextInt(4);
    return '${_bitsDigits(16, 4)}${_bitsDigits(16, 4)}-'
        '${_bitsDigits(16, 4)}-'
        '4${_bitsDigits(12, 3)}-'
        '${_printDigits(special, 1)}${_bitsDigits(12, 3)}-'
        '${_bitsDigits(16, 4)}${_bitsDigits(16, 4)}${_bitsDigits(16, 4)}';
  }

  String _bitsDigits(int bitCount, int digitCount) =>
      _printDigits(_generateBits(bitCount), digitCount);

  int _generateBits(int bitCount) => _random.nextInt(1 << bitCount);

  String _printDigits(int value, int count) =>
      value.toRadixString(16).padLeft(count, '0');
}

/// The result returned after completing location selection.
class LocationResult {
  /// The human readable name of the location. This is primarily the
  /// name of the road. But in cases where the place was selected from Nearby
  /// places list, we use the <b>name</b> provided on the list item.
  String? name; // or road

  /// The human readable locality of the location.
  String? locality;

  /// Latitude/Longitude of the selected location.
  LatLng? latLng;

  String? street;

  String? country;

  String? state;

  String? city;

  String? zip;
}

/// Nearby place data will be deserialized into this model.
class NearbyPlace {
  /// The human-readable name of the location provided. This value is provided
  /// for [LocationResult.name] when the user selects this nearby place.
  String? name;

  /// The icon identifying the kind of place provided. Eg. lodging, chapel,
  /// hospital, etc.
  String? icon;

  // Latitude/Longitude of the provided location.
  LatLng? latLng;
}

/// Autocomplete results item returned from Google will be deserialized
/// into this model.
class AutoCompleteItem {
  /// The id of the place. This helps to fetch the lat,lng of the place.
  String? id;

  /// The text (name of place) displayed in the autocomplete suggestions list.
  String? text;

  /// Assistive index to begin highlight of matched part of the [text] with
  /// the original query
  int? offset;

  /// Length of matched part of the [text]
  int? length;
}

/// Place picker widget made with map widget from
/// [google_maps_flutter](https://github.com/flutter/plugins/tree/master/packages/google_maps_flutter)
/// and other API calls to [Google Places API](https://developers.google.com/places/web-service/intro)
///
/// API key provided should have `Maps SDK for Android`, `Maps SDK for iOS`
/// and `Places API`  enabled for it
class PlacePicker extends StatefulWidget {
  /// API key generated from Google Cloud Console. You can get an API key
  /// [here](https://cloud.google.com/maps-platform/)
  final String? apiKey;
  final String? selectedserviceId;

  const PlacePicker(this.apiKey, this.selectedserviceId);

  @override
  State<StatefulWidget> createState() {
    return PlacePickerState();
  }
}

/// Place picker state
class PlacePickerState extends State<PlacePicker> {
  /// Initial waiting location for the map before the current user location
  /// is fetched.
  static const LatLng initialTarget =
      LatLng(8.985006569390329, 38.792100691731214);
  static const LatLng brokerone = LatLng(8.987951878207243, 38.79145142522586);
  static const LatLng brokertwo = LatLng(8.985931242031489, 38.787802898826726);
  static const LatLng brokerthree =
      LatLng(8.988072591969365, 38.797204164542826);

  final Completer<GoogleMapController> mapController = Completer();
  Location location = Location();
  LocationData? currentLocation;
  static BitmapDescriptor cutomIcon = BitmapDescriptor.defaultMarker;

  /// Indicator for the selected location
  final Set<Marker> markers = <Marker>{}..add(
      const Marker(
        position: initialTarget,
        markerId: MarkerId('selected-location'),
      ),
    );
  late HomescreenProvider homescreenProvider;
  BitmapDescriptor? brokerIcon;
  BitmapDescriptor? userIcon;

  /// Result returned after user completes selection
  LocationResult? locationResult;

  /// Overlay to display autocomplete suggestions
  OverlayEntry? overlayEntry;

  List<NearbyPlace> nearbyPlaces = [];

  List<BrokerInfo> listofbrokers = [];
  List<Marker> marker = [];

  /// Session token required for autocomplete API call
  String sessionToken = Uuid().generateV4();

  GlobalKey appBarKey = GlobalKey();

  bool hasSearchTerm = false;

  String previousSearchTerm = '';

  bool isBrokerSelected = false;

  bool isCheckedtersm = false;

  bool isConnectiong = false;

  List<String> cancelreason = [
    'lbl_broker_too_far'.tr,
    'lbl_changed_my_mind'.tr,
    'lbl_just_trying_app'.tr,
    'lbl_long_waiting_time'.tr,
    'lbl_others'.tr
  ];

  bool isLoading = false;

  String fullname = '';
  dynamic rate;
  String phoneNumber = '';

  bool hasCar = false;

  String? selectedbrokerId;

  String? placeName = '';

  String? locationLatitude = '';
  int? connectionId;

  String? locationLongtude = '';
  //late SharedPreferences prefs;

  late StreamController<CheckForCustomerRequestModel> _requestStreamController;
  late Timer _timer;

  // constructor
  PlacePickerState();

  Future<void> onMapCreated(GoogleMapController controller) async {
    // prefs = await SharedPreferences.getInstance();
    mapController.complete(controller);
    moveToCurrentUserLocation();
  }

  Future<LocationData> getCurrentLocation() async {
    Location location = Location();
    return await location.getLocation();
  }

  Future<void> _fetchUserRequests() async {
    //prefs = await SharedPreferences.getInstance();
    try {
      var token = PrefUtils.sharedPreferences!.getString('token') ?? '';
      var headers = {'x-auth-token': token};
      var request = http.Request(
          'GET',
          Uri.parse(
              '${ApiAuthHelper.prodomain}/api/users/request/$connectionId'));
      request.headers.addAll(headers);
      http.StreamedResponse response = await request.send();
      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        var jsonResponse = json.decode(responseData);
        if (jsonResponse['connectionRequests'] != null) {
          CheckForCustomerRequestModel res =
              CheckForCustomerRequestModel.fromJson(jsonResponse);
          if (res.connectionRequests != null &&
              res.connectionRequests!.status == "ACCEPTED") {
            _timer.cancel();
            setState(() {
              isConnectiong = false;
              PrefUtils.sharedPreferences!.setBool('isConnectiong', false);
              isBrokerSelected = false;
            });
            ProgressDialogUtils.showSnackBar(
              context: context,
              message: 'You request has been accepted',
            );
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AllBrokerInfo(
                  brokerId: selectedbrokerId.toString(),
                  fullName: fullname,
                  phoneNumber: phoneNumber,
                  connectionID: res.connectionRequests!.id ?? 1,
                ),
              ),
            );
          } else if (res.connectionRequests != null &&
              res.connectionRequests!.status == "CANCELLED") {
            _timer.cancel();
            setState(() {
              isConnectiong = false;
              PrefUtils.sharedPreferences!.setBool('isConnectiong', false);

              isBrokerSelected = false;
            });
            // ProgressDialogUtils.showSnackBar(
            //   context: context,
            //   message: 'You request has been cancelled',
            // );
          } else if (res.connectionRequests != null &&
              res.connectionRequests!.status == "DECLINED") {
            _timer.cancel();
            setState(() {
              isConnectiong = false;
              PrefUtils.sharedPreferences!.setBool('isConnectiong', false);

              isBrokerSelected = false;
            });
            ProgressDialogUtils.showSnackBar(
              context: context,
              message: 'You request has been rejected',
            );
          }
          _requestStreamController.add(res);
        } else {
          _requestStreamController.addError('');
        }
      } else {
        _requestStreamController.addError('');
      }
    } catch (e, s) {
      debugPrint(' _fetchUserRequests Error: $e StackTres => $s');
      return;
    }
  }

  getBrokers({latitude, longitude}) async {
    setState(() {
      PrefUtils.sharedPreferences!.setBool('isConnectiong', false);
      isConnectiong = false;
      isBrokerSelected = false;
    });
    getCurrentLocation().then((locationData) async {
      ProgressDialogUtils.showProgressDialog(
        context: context,
        isCancellable: false,
      );
      getPlaceId(
        latitude == '' ? locationData.latitude : latitude,
        longitude == '' ? locationData.longitude : longitude,
      ).then((placeId) {
        if (placeId != null) {
          decodeAndSelectPlaceForFirst(placeId);
        }
      });
      listofbrokers = await ApiAuthHelper.fetchBrokerData(
        latitude: latitude == '' ? locationData.latitude : latitude,
        longitude: longitude == '' ? locationData.longitude : longitude,
        serviceId: int.parse(
          widget.selectedserviceId ?? '1',
        ),
      );
      if (listofbrokers.isNotEmpty || listofbrokers.length > 0) {
        for (var i = 0; i < listofbrokers.length; i++) {
          marker.add(
            Marker(
              position: LatLng(
                listofbrokers[i].locationLatitude ?? 0.0,
                listofbrokers[i].locationLongtude ?? 0.0,
              ),
              icon: brokerIcon ??
                  await BitmapDescriptor.fromAssetImage(
                    ImageConfiguration(),
                    'assets/images/markerImage.png',
                  ),
              markerId: MarkerId('${listofbrokers[i].id}'),
              onTap: () {
                if (PrefUtils.sharedPreferences!.getBool('isConnectiong') ==
                    true) {
                  ProgressDialogUtils.showSnackBar(
                      context: context,
                      message:
                          "You have requested already. Please wait for the response or cancel the request");
                } else {
                  setState(() {
                    fullname = listofbrokers[i].fullName ?? "";
                    rate = listofbrokers[i].rate ?? 0;
                    hasCar = listofbrokers[i].hasCar ?? false;
                    selectedbrokerId = listofbrokers[i].id.toString();
                    phoneNumber = listofbrokers[i].phone ?? "";
                    isBrokerSelected = true;
                  });
                }
              },
              infoWindow: InfoWindow(
                title: '${listofbrokers[i].fullName}',
              ),
            ),
          );
        }
        ProgressDialogUtils.hideProgressDialog();
        PrefUtils.sharedPreferences!.setBool('isSearching', true);
        PrefUtils.sharedPreferences!.remove('description');
        PrefUtils.sharedPreferences!.setString('description',
            'There are ${listofbrokers.length} Brokers available around $placeName');
        if (!mounted) return;
        setState(() {});
      } else {
        ProgressDialogUtils.hideProgressDialog();
        PrefUtils.sharedPreferences!.setBool('isSearching', true);
        PrefUtils.sharedPreferences!.remove('description');
        PrefUtils.sharedPreferences!.setString('description',
            'There are no brokers available around $placeName. Please search another place!');
        if (!mounted) return;
        setState(() {});
      }
    }).catchError((e) {
      debugPrint('Error getting location: ====> $e');
      ProgressDialogUtils.hideProgressDialog();
      return;
    });
    Future.delayed(Duration.zero).then((value) {
      if (!mounted) return;
      setState(() {});
    });
  }

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  initMarker() async {
    final Uint8List userMarkerIcon =
        await getBytesFromAsset(ImageConstant.currentuserlocation, 300);
    final Uint8List markerIcon =
        await getBytesFromAsset('assets/images/markerImage.png', 300);
    setState(() {
      userIcon = BitmapDescriptor.fromBytes(userMarkerIcon);
      brokerIcon = BitmapDescriptor.fromBytes(markerIcon);
    });
    Future.delayed(Duration.zero).then((value) {
      if (!mounted) return;
      setState(() {});
    });
  }

  setMarkerForCustomer() {
    getCurrentLocation().then((value) async {
      marker.add(
        Marker(
          position: LatLng(
            value.latitude ?? 0.0,
            value.longitude ?? 0.0,
          ),
          icon: userIcon ??
              await BitmapDescriptor.fromAssetImage(
                ImageConfiguration(size: ui.Size.fromWidth(300)),
                ImageConstant.currentuserlocation,
              ),
          markerId: MarkerId('userId01'),
          infoWindow: InfoWindow(
            title: 'Your current location',
          ),
        ),
      );
      getPlaceId(
        value.latitude ?? 0.0,
        value.longitude ?? 0.0,
      ).then((placeId) {
        if (placeId != null) {
          decodeAndSelectPlaceForFirst(placeId);
        }
      });
    });
  }

  setInitialMarkersBasedOnBorkersLocations() async {
    marker.clear();
    setMarkerForCustomer();
    Future.delayed(Duration(seconds: 1)).then((value) {
      setMarkerForCustomer();
    });
    switch (widget.selectedserviceId ?? '1') {
      case '1':
        if (homescreenProvider.ishouseSaleBrokerInfoLoading) {
          ProgressDialogUtils.showProgressDialog(
            context: context,
            isCancellable: false,
          );
          Future.delayed(Duration(seconds: 1)).then((value) {
            setInitialMarkersBasedOnBorkersLocations();
          });
        } else {
          ProgressDialogUtils.hideProgressDialog();
          if (homescreenProvider.houseSaleBrokerInfo.isNotEmpty ||
              homescreenProvider.houseSaleBrokerInfo.length > 0) {
            for (var i = 0;
                i < homescreenProvider.houseSaleBrokerInfo.length;
                i++) {
              marker.add(
                Marker(
                  position: LatLng(
                    homescreenProvider
                            .houseSaleBrokerInfo[i].locationLatitude ??
                        0.0,
                    homescreenProvider
                            .houseSaleBrokerInfo[i].locationLongtude ??
                        0.0,
                  ),
                  icon: brokerIcon ??
                      await BitmapDescriptor.fromAssetImage(
                        ImageConfiguration(size: ui.Size.fromWidth(300)),
                        'assets/images/markerImage.png',
                      ),
                  markerId: MarkerId(
                      '${homescreenProvider.houseSaleBrokerInfo[i].id}'),
                  onTap: () {
                    if (PrefUtils.sharedPreferences!.getBool('isConnectiong') ==
                        true) {
                      ProgressDialogUtils.showSnackBar(
                          context: context,
                          message:
                              "You have requested already. Please wait for the response or cancel the request");
                    } else {
                      setState(() {
                        fullname = homescreenProvider
                                .houseSaleBrokerInfo[i].fullName ??
                            "";
                        rate =
                            homescreenProvider.houseSaleBrokerInfo[i].rate ?? 0;
                        hasCar =
                            homescreenProvider.houseSaleBrokerInfo[i].hasCar ??
                                false;
                        selectedbrokerId = homescreenProvider
                            .houseSaleBrokerInfo[i].id
                            .toString();
                        phoneNumber =
                            homescreenProvider.houseSaleBrokerInfo[i].phone ??
                                "";
                        isBrokerSelected = true;
                      });
                    }
                  },
                  infoWindow: InfoWindow(
                    title:
                        '${homescreenProvider.houseSaleBrokerInfo[i].fullName}',
                  ),
                ),
              );
            }
            ProgressDialogUtils.hideProgressDialog();
            PrefUtils.sharedPreferences!.setBool('isSearching', true);
            PrefUtils.sharedPreferences!.remove('description');
            PrefUtils.sharedPreferences!.setString('description',
                'There are ${homescreenProvider.houseSaleBrokerInfo.length} Brokers available around $placeName');
            if (!mounted) return;
            setState(() {});
          } else {
            ProgressDialogUtils.hideProgressDialog();
            PrefUtils.sharedPreferences!.setBool('isSearching', true);
            PrefUtils.sharedPreferences!.remove('description');
            PrefUtils.sharedPreferences!.setString('description',
                'There are no brokers available around $placeName. Please search another place!');
            if (!mounted) return;
            setState(() {});
          }
        }
        break;
      case '2':
        if (homescreenProvider.ishouseRantBrokerInfoLoading) {
          ProgressDialogUtils.showProgressDialog(
            context: context,
            isCancellable: false,
          );
          Future.delayed(Duration(seconds: 1)).then((value) {
            setInitialMarkersBasedOnBorkersLocations();
          });
        } else {
          ProgressDialogUtils.hideProgressDialog();
          if (homescreenProvider.houseRantBrokerInfo.isNotEmpty ||
              homescreenProvider.houseRantBrokerInfo.length > 0) {
            for (var i = 0;
                i < homescreenProvider.houseRantBrokerInfo.length;
                i++) {
              marker.add(
                Marker(
                  position: LatLng(
                    homescreenProvider
                            .houseRantBrokerInfo[i].locationLatitude ??
                        0.0,
                    homescreenProvider
                            .houseRantBrokerInfo[i].locationLongtude ??
                        0.0,
                  ),
                  icon: brokerIcon ??
                      await BitmapDescriptor.fromAssetImage(
                        ImageConfiguration(size: ui.Size.fromWidth(300)),
                        'assets/images/markerImage.png',
                      ),
                  markerId: MarkerId(
                      '${homescreenProvider.houseRantBrokerInfo[i].id}'),
                  onTap: () {
                    if (PrefUtils.sharedPreferences!.getBool('isConnectiong') ==
                        true) {
                      ProgressDialogUtils.showSnackBar(
                          context: context,
                          message:
                              "You have requested already. Please wait for the response or cancel the request");
                    } else {
                      setState(() {
                        fullname = homescreenProvider
                                .houseRantBrokerInfo[i].fullName ??
                            "";
                        rate =
                            homescreenProvider.houseRantBrokerInfo[i].rate ?? 0;
                        hasCar =
                            homescreenProvider.houseRantBrokerInfo[i].hasCar ??
                                false;
                        selectedbrokerId = homescreenProvider
                            .houseRantBrokerInfo[i].id
                            .toString();
                        phoneNumber =
                            homescreenProvider.houseRantBrokerInfo[i].phone ??
                                "";
                        isBrokerSelected = true;
                      });
                    }
                  },
                  infoWindow: InfoWindow(
                    title:
                        '${homescreenProvider.houseRantBrokerInfo[i].fullName}',
                  ),
                ),
              );
            }
            ProgressDialogUtils.hideProgressDialog();
            PrefUtils.sharedPreferences!.setBool('isSearching', true);
            PrefUtils.sharedPreferences!.remove('description');
            PrefUtils.sharedPreferences!.setString('description',
                'There are ${homescreenProvider.houseRantBrokerInfo.length} Brokers available around $placeName');
            if (!mounted) return;
            setState(() {});
          } else {
            ProgressDialogUtils.hideProgressDialog();
            PrefUtils.sharedPreferences!.setBool('isSearching', true);
            PrefUtils.sharedPreferences!.remove('description');
            PrefUtils.sharedPreferences!.setString('description',
                'There are no brokers available around $placeName. Please search another place!');
            if (!mounted) return;
            setState(() {});
          }
        }
        break;
      case '3':
        if (homescreenProvider.iscarSaleBrokerinfoLoading) {
          ProgressDialogUtils.showProgressDialog(
            context: context,
            isCancellable: false,
          );
          Future.delayed(Duration(seconds: 1)).then((value) {
            setInitialMarkersBasedOnBorkersLocations();
          });
        } else {
          ProgressDialogUtils.hideProgressDialog();
          if (homescreenProvider.carSaleBrokerinfo.isNotEmpty ||
              homescreenProvider.carSaleBrokerinfo.length > 0) {
            for (var i = 0;
                i < homescreenProvider.carSaleBrokerinfo.length;
                i++) {
              marker.add(
                Marker(
                  position: LatLng(
                    homescreenProvider.carSaleBrokerinfo[i].locationLatitude ??
                        0.0,
                    homescreenProvider.carSaleBrokerinfo[i].locationLongtude ??
                        0.0,
                  ),
                  icon: brokerIcon ??
                      await BitmapDescriptor.fromAssetImage(
                        ImageConfiguration(size: ui.Size.fromWidth(300)),
                        'assets/images/markerImage.png',
                      ),
                  markerId:
                      MarkerId('${homescreenProvider.carSaleBrokerinfo[i].id}'),
                  onTap: () {
                    if (PrefUtils.sharedPreferences!.getBool('isConnectiong') ==
                        true) {
                      ProgressDialogUtils.showSnackBar(
                          context: context,
                          message:
                              "You have requested already. Please wait for the response or cancel the request");
                    } else {
                      setState(() {
                        fullname =
                            homescreenProvider.carSaleBrokerinfo[i].fullName ??
                                "";
                        rate =
                            homescreenProvider.carSaleBrokerinfo[i].rate ?? 0;
                        hasCar =
                            homescreenProvider.carSaleBrokerinfo[i].hasCar ??
                                false;
                        selectedbrokerId = homescreenProvider
                            .carSaleBrokerinfo[i].id
                            .toString();
                        phoneNumber =
                            homescreenProvider.carSaleBrokerinfo[i].phone ?? "";
                        isBrokerSelected = true;
                      });
                    }
                  },
                  infoWindow: InfoWindow(
                    title:
                        '${homescreenProvider.carSaleBrokerinfo[i].fullName}',
                  ),
                ),
              );
            }
            ProgressDialogUtils.hideProgressDialog();
            PrefUtils.sharedPreferences!.setBool('isSearching', true);
            PrefUtils.sharedPreferences!.remove('description');
            PrefUtils.sharedPreferences!.setString('description',
                'There are ${homescreenProvider.carSaleBrokerinfo.length} Brokers available around $placeName');
            if (!mounted) return;
            setState(() {});
          } else {
            ProgressDialogUtils.hideProgressDialog();
            PrefUtils.sharedPreferences!.setBool('isSearching', true);
            PrefUtils.sharedPreferences!.remove('description');
            PrefUtils.sharedPreferences!.setString('description',
                'There are no brokers available around $placeName. Please search another place!');
            if (!mounted) return;
            setState(() {});
          }
        }
        break;
      case '4':
        if (homescreenProvider.iscarRentBrokerinfoLoading) {
          ProgressDialogUtils.showProgressDialog(
            context: context,
            isCancellable: false,
          );
          Future.delayed(Duration(seconds: 1)).then((value) {
            setInitialMarkersBasedOnBorkersLocations();
          });
        } else {
          ProgressDialogUtils.hideProgressDialog();
          if (homescreenProvider.carRentBrokerinfo.isNotEmpty ||
              homescreenProvider.carRentBrokerinfo.length > 0) {
            for (var i = 0;
                i < homescreenProvider.carRentBrokerinfo.length;
                i++) {
              marker.add(
                Marker(
                  position: LatLng(
                    homescreenProvider.carRentBrokerinfo[i].locationLatitude ??
                        0.0,
                    homescreenProvider.carRentBrokerinfo[i].locationLongtude ??
                        0.0,
                  ),
                  icon: brokerIcon ??
                      await BitmapDescriptor.fromAssetImage(
                        ImageConfiguration(size: ui.Size.fromWidth(300)),
                        'assets/images/markerImage.png',
                      ),
                  markerId:
                      MarkerId('${homescreenProvider.carRentBrokerinfo[i].id}'),
                  onTap: () {
                    if (PrefUtils.sharedPreferences!.getBool('isConnectiong') ==
                        true) {
                      ProgressDialogUtils.showSnackBar(
                          context: context,
                          message:
                              "You have requested already. Please wait for the response or cancel the request");
                    } else {
                      setState(() {
                        fullname =
                            homescreenProvider.carRentBrokerinfo[i].fullName ??
                                "";
                        rate =
                            homescreenProvider.carRentBrokerinfo[i].rate ?? 0;
                        hasCar =
                            homescreenProvider.carRentBrokerinfo[i].hasCar ??
                                false;
                        selectedbrokerId = homescreenProvider
                            .carRentBrokerinfo[i].id
                            .toString();
                        phoneNumber =
                            homescreenProvider.carRentBrokerinfo[i].phone ?? "";
                        isBrokerSelected = true;
                      });
                    }
                  },
                  infoWindow: InfoWindow(
                    title:
                        '${homescreenProvider.carRentBrokerinfo[i].fullName}',
                  ),
                ),
              );
            }
            ProgressDialogUtils.hideProgressDialog();
            PrefUtils.sharedPreferences!.setBool('isSearching', true);
            PrefUtils.sharedPreferences!.remove('description');
            PrefUtils.sharedPreferences!.setString('description',
                'There are ${homescreenProvider.carRentBrokerinfo.length} Brokers available around $placeName');
            if (!mounted) return;
            setState(() {});
          } else {
            ProgressDialogUtils.hideProgressDialog();
            PrefUtils.sharedPreferences!.setBool('isSearching', true);
            PrefUtils.sharedPreferences!.remove('description');
            PrefUtils.sharedPreferences!.setString('description',
                'There are no brokers available around $placeName. Please search another place!');
            if (!mounted) return;
            setState(() {});
          }
        }
        break;
      case '5':
        if (homescreenProvider.ishouseMaidBrokerInfoLoading) {
          ProgressDialogUtils.showProgressDialog(
            context: context,
            isCancellable: false,
          );
          Future.delayed(Duration(seconds: 1)).then((value) {
            setInitialMarkersBasedOnBorkersLocations();
          });
        } else {
          ProgressDialogUtils.hideProgressDialog();
          if (homescreenProvider.houseMaidBrokerInfo.isNotEmpty ||
              homescreenProvider.houseMaidBrokerInfo.length > 0) {
            for (var i = 0;
                i < homescreenProvider.houseMaidBrokerInfo.length;
                i++) {
              marker.add(
                Marker(
                  position: LatLng(
                    homescreenProvider
                            .houseMaidBrokerInfo[i].locationLatitude ??
                        0.0,
                    homescreenProvider
                            .houseMaidBrokerInfo[i].locationLongtude ??
                        0.0,
                  ),
                  icon: brokerIcon ??
                      await BitmapDescriptor.fromAssetImage(
                        ImageConfiguration(size: ui.Size.fromWidth(300)),
                        'assets/images/markerImage.png',
                      ),
                  markerId: MarkerId(
                      '${homescreenProvider.houseMaidBrokerInfo[i].id}'),
                  onTap: () {
                    if (PrefUtils.sharedPreferences!.getBool('isConnectiong') ==
                        true) {
                      ProgressDialogUtils.showSnackBar(
                          context: context,
                          message:
                              "You have requested already. Please wait for the response or cancel the request");
                    } else {
                      setState(() {
                        fullname = homescreenProvider
                                .houseMaidBrokerInfo[i].fullName ??
                            "";
                        rate =
                            homescreenProvider.houseMaidBrokerInfo[i].rate ?? 0;
                        hasCar =
                            homescreenProvider.houseMaidBrokerInfo[i].hasCar ??
                                false;
                        selectedbrokerId = homescreenProvider
                            .houseMaidBrokerInfo[i].id
                            .toString();
                        phoneNumber =
                            homescreenProvider.houseMaidBrokerInfo[i].phone ??
                                "";
                        isBrokerSelected = true;
                      });
                    }
                  },
                  infoWindow: InfoWindow(
                    title:
                        '${homescreenProvider.houseMaidBrokerInfo[i].fullName}',
                  ),
                ),
              );
            }
            ProgressDialogUtils.hideProgressDialog();
            PrefUtils.sharedPreferences!.setBool('isSearching', true);
            PrefUtils.sharedPreferences!.remove('description');
            PrefUtils.sharedPreferences!.setString('description',
                'There are ${homescreenProvider.houseMaidBrokerInfo.length} Brokers available around $placeName');
            if (!mounted) return;
            setState(() {});
          } else {
            ProgressDialogUtils.hideProgressDialog();
            PrefUtils.sharedPreferences!.setBool('isSearching', true);
            PrefUtils.sharedPreferences!.remove('description');
            PrefUtils.sharedPreferences!.setString('description',
                'There are no brokers available around $placeName. Please search another place!');
            if (!mounted) return;
            setState(() {});
          }
        }
        break;
      case '6':
        if (homescreenProvider.isusedItemBrokerInfoLoading) {
          ProgressDialogUtils.showProgressDialog(
            context: context,
            isCancellable: false,
          );
          Future.delayed(Duration(seconds: 1)).then((value) {
            setInitialMarkersBasedOnBorkersLocations();
          });
        } else {
          ProgressDialogUtils.hideProgressDialog();
          if (homescreenProvider.usedItemBrokerInfo.isNotEmpty ||
              homescreenProvider.usedItemBrokerInfo.length > 0) {
            for (var i = 0;
                i < homescreenProvider.usedItemBrokerInfo.length;
                i++) {
              marker.add(
                Marker(
                  position: LatLng(
                    homescreenProvider.usedItemBrokerInfo[i].locationLatitude ??
                        0.0,
                    homescreenProvider.usedItemBrokerInfo[i].locationLongtude ??
                        0.0,
                  ),
                  icon: brokerIcon ??
                      await BitmapDescriptor.fromAssetImage(
                        ImageConfiguration(size: ui.Size.fromWidth(300)),
                        'assets/images/markerImage.png',
                      ),
                  markerId: MarkerId(
                      '${homescreenProvider.usedItemBrokerInfo[i].id}'),
                  onTap: () {
                    if (PrefUtils.sharedPreferences!.getBool('isConnectiong') ==
                        true) {
                      ProgressDialogUtils.showSnackBar(
                          context: context,
                          message:
                              "You have requested already. Please wait for the response or cancel the request");
                    } else {
                      setState(() {
                        fullname =
                            homescreenProvider.usedItemBrokerInfo[i].fullName ??
                                "";
                        rate =
                            homescreenProvider.usedItemBrokerInfo[i].rate ?? 0;
                        hasCar =
                            homescreenProvider.usedItemBrokerInfo[i].hasCar ??
                                false;
                        selectedbrokerId = homescreenProvider
                            .usedItemBrokerInfo[i].id
                            .toString();
                        phoneNumber =
                            homescreenProvider.usedItemBrokerInfo[i].phone ??
                                "";
                        isBrokerSelected = true;
                      });
                    }
                  },
                  infoWindow: InfoWindow(
                    title:
                        '${homescreenProvider.usedItemBrokerInfo[i].fullName}',
                  ),
                ),
              );
            }
            ProgressDialogUtils.hideProgressDialog();
            PrefUtils.sharedPreferences!.setBool('isSearching', true);
            PrefUtils.sharedPreferences!.remove('description');
            PrefUtils.sharedPreferences!.setString('description',
                'There are ${homescreenProvider.usedItemBrokerInfo.length} Brokers available around $placeName');
            if (!mounted) return;
            setState(() {});
          } else {
            ProgressDialogUtils.hideProgressDialog();
            PrefUtils.sharedPreferences!.setBool('isSearching', true);
            PrefUtils.sharedPreferences!.remove('description');
            PrefUtils.sharedPreferences!.setString('description',
                'There are no brokers available around $placeName. Please search another place!');
            if (!mounted) return;
            setState(() {});
          }
        }
        break;
      default:
    }
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    super.initState();
    PrefUtils().init();
    _requestStreamController =
        StreamController<CheckForCustomerRequestModel>.broadcast();
    homescreenProvider =
        Provider.of<HomescreenProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      initMarker();
      setInitialMarkersBasedOnBorkersLocations();
    });
  }

  @override
  void dispose() {
    overlayEntry?.remove();
    _requestStreamController.close();
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (PrefUtils.sharedPreferences!.getBool('isConnectiong') == true) {
          ProgressDialogUtils.showSnackBar(
            context: context,
            message:
                "You have requested already. Please wait for the response or cancel the request",
          );
          return false;
        } else {
          return true;
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.background,
          key: appBarKey,
          title: SearchInput(searchPlace),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: appTheme.orangeA200,
              size: 20,
            ),
            color: Theme.of(context).colorScheme.secondary,
            onPressed: () {
              if (PrefUtils.sharedPreferences!.getBool('isConnectiong') ==
                  false) {
                PrefUtils.sharedPreferences!.remove('description');
                Navigator.pop(context); // Only pop if not waiting for response
              }
            },
          ),
          automaticallyImplyLeading: false,
        ),
        backgroundColor: Theme.of(context).colorScheme.background,
        body: Consumer<HomescreenProvider>(
          builder: (context, homePageProvider, child) => Stack(
            children: [
              Column(
                children: <Widget>[
                  Expanded(
                    child: PrefUtils.sharedPreferences!
                                .getBool('isConnectiong') ==
                            true
                        ? GoogleMap(
                            initialCameraPosition: CameraPosition(
                              target: initialTarget,
                              zoom: 15,
                              // bearing: 15,
                            ),
                            myLocationButtonEnabled: true,
                            myLocationEnabled: true,
                            onMapCreated: onMapCreated,
                            mapType: MapType.normal, // Make the map dark
                            gestureRecognizers: Set()
                              ..add(Factory<OneSequenceGestureRecognizer>(() =>
                                  EagerGestureRecognizer())), // Disable all gestures
                            markers: Set<Marker>.of(marker),
                            liteModeEnabled:
                                true, // Optionally enable lite mode
                          )
                        : GoogleMap(
                            initialCameraPosition: CameraPosition(
                              target: initialTarget,
                              zoom: 15,
                              // bearing: 50,
                            ),
                            myLocationButtonEnabled:
                                false, // Optionally enable my location button
                            myLocationEnabled:
                                false, // Optionally enable my location
                            mapToolbarEnabled:
                                false, // Optionally enable map toolbar
                            compassEnabled: false, // Optionally enable compass
                            onMapCreated: onMapCreated,
                            markers: Set<Marker>.of(marker),
                          ),
                  ),
                  if (PrefUtils.sharedPreferences!.getBool('isConnectiong') ==
                      false) ...[
                    hasSearchTerm
                        ? const SizedBox()
                        : isBrokerSelected
                            ? Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: ResponsiveExtension(15).h,
                                  vertical: 25.v,
                                ),
                                decoration: AppDecoration.outlineWhite.copyWith(
                                  borderRadius:
                                      BorderRadiusStyle.customBorderTL25,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: <Widget>[
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        CustomImageView(
                                          imagePath:
                                              ImageConstant.imageNotFound,
                                          border: Border.all(
                                            color: appTheme.orangeA200,
                                            width: 1,
                                          ),
                                          height: 60.adaptSize,
                                          width: 60.adaptSize,
                                          radius: BorderRadius.circular(
                                            30.h,
                                          ),
                                        ),
                                        SizedBox(width: 20),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceAround,
                                              children: [
                                                Text(
                                                  fullname,
                                                  style: const TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 15,
                                                  ),
                                                ),
                                                SizedBox(width: 20),
                                                hasCar
                                                    ? CustomImageView(
                                                        imagePath:
                                                            ImageConstant.car,
                                                        height: 14.adaptSize,
                                                        width: 19.adaptSize,
                                                      )
                                                    : SizedBox(),
                                              ],
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Text(
                                                  rate.toString(),
                                                  style: const TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 15,
                                                  ),
                                                ),
                                                RatingBar.builder(
                                                  initialRating:
                                                      rate.toDouble(),
                                                  itemSize: 30,
                                                  minRating: 1,
                                                  direction: Axis.horizontal,
                                                  allowHalfRating: true,
                                                  itemCount: 5,
                                                  itemPadding:
                                                      EdgeInsets.symmetric(
                                                    horizontal: 4.0,
                                                  ),
                                                  itemBuilder: (context, _) =>
                                                      Icon(
                                                    Icons.star,
                                                    color: Colors.amber,
                                                  ),
                                                  onRatingUpdate: (rating) {
                                                    debugPrint(
                                                        rating.toString());
                                                  },
                                                  ignoreGestures: true,
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 20),
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(left: 20.0),
                                      child: PrefUtils.sharedPreferences!
                                                  .getBool('isConnectiong') ==
                                              true
                                          ? StreamBuilder<
                                              CheckForCustomerRequestModel>(
                                              stream: _requestStreamController
                                                  .stream,
                                              builder: (context, snapshot) {
                                                if (snapshot.hasData &&
                                                    snapshot.data != null &&
                                                    snapshot.data!
                                                            .connectionRequests !=
                                                        null &&
                                                    snapshot
                                                            .data!
                                                            .connectionRequests!
                                                            .status ==
                                                        "REQUESTED") {
                                                  return Column(
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                          horizontal: 40.0,
                                                        ),
                                                        child: Text(
                                                          'Waiting for broker response...',
                                                          style: TextStyle(
                                                            color: appTheme
                                                                .orangeA200,
                                                            fontSize: 16,
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(height: 20),
                                                      _builCancelButton(
                                                        context,
                                                        snapshot,
                                                      ),
                                                    ],
                                                  );
                                                } else if (snapshot.hasData &&
                                                    snapshot.data != null &&
                                                    snapshot.data!
                                                            .connectionRequests !=
                                                        null &&
                                                    snapshot
                                                            .data!
                                                            .connectionRequests!
                                                            .status ==
                                                        "ACCEPTED") {
                                                  return SizedBox();
                                                } else if (snapshot.hasData &&
                                                    snapshot.data != null &&
                                                    snapshot.data!
                                                            .connectionRequests !=
                                                        null &&
                                                    snapshot
                                                            .data!
                                                            .connectionRequests!
                                                            .status ==
                                                        "CANCELLED") {
                                                  return SizedBox();
                                                } else if (snapshot.hasError) {
                                                  debugPrint(
                                                      'object snapshot error: ${snapshot.error}');
                                                  return SizedBox();
                                                } else if (snapshot
                                                            .connectionState ==
                                                        ConnectionState
                                                            .waiting ||
                                                    snapshot.connectionState ==
                                                        ConnectionState.none) {
                                                  return SizedBox();
                                                } else {
                                                  return SizedBox();
                                                }
                                              },
                                            )
                                          : InkWell(
                                              onTap: () {
                                                isCheckedtersm =
                                                    !isCheckedtersm;
                                                setState(() {});
                                              },
                                              child: Row(
                                                children: <Widget>[
                                                  Checkbox(
                                                    value: isCheckedtersm,
                                                    activeColor:
                                                        appTheme.orangeA200,
                                                    checkColor: Colors.white,
                                                    onChanged: (value) {
                                                      isCheckedtersm =
                                                          !isCheckedtersm;
                                                      setState(() {});
                                                    },
                                                  ),
                                                  RichText(
                                                    maxLines: 2,
                                                    text: TextSpan(
                                                      text: 'Accept',
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodyLarge,
                                                      children: <TextSpan>[
                                                        const TextSpan(
                                                            text: ' '),
                                                        TextSpan(
                                                          text:
                                                              'Term & condition',
                                                          style: TextStyle(
                                                              color: appTheme
                                                                  .orangeA200,
                                                              decoration:
                                                                  TextDecoration
                                                                      .underline),
                                                          recognizer:
                                                              TapGestureRecognizer()
                                                                ..onTap = () =>
                                                                    Navigator
                                                                        .push(
                                                                      context,
                                                                      MaterialPageRoute(
                                                                        builder:
                                                                            (context) =>
                                                                                const PrivacyTermScreen(),
                                                                      ),
                                                                    ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                    ),
                                    SizedBox(height: 20),
                                    PrefUtils.sharedPreferences!
                                                .getBool('isConnectiong') ==
                                            true
                                        ? SizedBox()
                                        : _builConnectButton(context),
                                  ],
                                ),
                              )
                            : SelectPlaceAction(getLocationName(), () {}),
                  ] else ...[
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: ResponsiveExtension(15).h,
                        vertical: 25.v,
                      ),
                      decoration: AppDecoration.outlineWhite.copyWith(
                        borderRadius: BorderRadiusStyle.customBorderTL25,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              CustomImageView(
                                imagePath: ImageConstant.imageNotFound,
                                border: Border.all(
                                  color: appTheme.orangeA200,
                                  width: 1,
                                ),
                                height: 60.adaptSize,
                                width: 60.adaptSize,
                                radius: BorderRadius.circular(
                                  30.h,
                                ),
                              ),
                              SizedBox(width: 20),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      Text(
                                        PrefUtils.sharedPreferences!
                                                .getString('fullname') ??
                                            "",
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 15,
                                        ),
                                      ),
                                      SizedBox(width: 20),
                                      hasCar
                                          ? CustomImageView(
                                              imagePath: ImageConstant.car,
                                              height: 14.adaptSize,
                                              width: 19.adaptSize,
                                            )
                                          : SizedBox(),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      PrefUtils.sharedPreferences!
                                                  .getDouble('rate') !=
                                              null
                                          ? Text(
                                              PrefUtils.sharedPreferences!
                                                  .getDouble('rate')!
                                                  .toString(),
                                              style: const TextStyle(
                                                color: Colors.grey,
                                                fontSize: 15,
                                              ),
                                            )
                                          : Text(0.0.toString()),
                                      RatingBar.builder(
                                        initialRating: PrefUtils
                                                    .sharedPreferences!
                                                    .getDouble('rate') ==
                                                null
                                            ? 0.0
                                            : PrefUtils.sharedPreferences!
                                                .getDouble('rate')!,
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
                                        ignoreGestures: true,
                                      ),
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10.0, vertical: 20),
                                    child: Text(
                                      'Waiting for broker response...',
                                      style: TextStyle(
                                        color: appTheme.orangeA200,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        barrierDismissible:
                                            false, // Prevent dialog from closing on outside tap
                                        builder: (context) => GestureDetector(
                                          behavior: HitTestBehavior.opaque,
                                          onTap:
                                              () {}, // Prevents taps from reaching underlying widgets
                                          child: CustomDialog(
                                            amount: '',
                                            color: appTheme.orangeA200,
                                            buttonLabel: 'Submit',
                                            cancelReasons: cancelreason,
                                            icon: Icons.done_all_rounded,
                                            message: '',
                                            onClick: (value) async {
                                              Navigator.pop(
                                                  context); // Dismiss the dialog programmatically
                                              ProgressDialogUtils
                                                  .showProgressDialog(
                                                context: context,
                                                isCancellable: false,
                                              );
                                              var respo = await ApiAuthHelper
                                                  .cancelBrokerRequest(
                                                cennectionId: PrefUtils
                                                    .sharedPreferences!
                                                    .getInt('connectionId'),
                                                reason: cancelreason[value],
                                              );
                                              setState(() {
                                                isConnectiong = false;
                                                PrefUtils.sharedPreferences!
                                                    .setBool(
                                                        'isConnectiong', false);

                                                isBrokerSelected = false;
                                                _timer.cancel();
                                              });
                                              if (respo) {
                                                ProgressDialogUtils
                                                    .hideProgressDialog();
                                                setState(() {
                                                  isConnectiong = false;
                                                  PrefUtils.sharedPreferences!
                                                      .setBool('isConnectiong',
                                                          false);

                                                  isBrokerSelected = false;
                                                  _timer.cancel();
                                                });
                                              } else {
                                                ProgressDialogUtils
                                                    .hideProgressDialog();
                                                ProgressDialogUtils
                                                    .showSnackBar(
                                                  context: context,
                                                  message:
                                                      'Something went wrong',
                                                );
                                              }
                                            },
                                            title: 'Cancel reason',
                                          ),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      width: 250,
                                      height: 50,
                                      alignment: Alignment.bottomCenter,
                                      padding: const EdgeInsets.only(
                                          top: 10, bottom: 10),
                                      clipBehavior: Clip.antiAlias,
                                      decoration: ShapeDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment(0.79, 0.61),
                                          end: Alignment(-0.79, -0.61),
                                          colors: [
                                            Color(0xFFF06400),
                                            Color(0xFFFFA05B)
                                          ],
                                        ),
                                        shape: RoundedRectangleBorder(
                                          side: BorderSide(
                                              width: 0.50, color: Colors.white),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          'Cancel',
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
                                    ),
                                  )
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                          SizedBox(height: 20),
                          PrefUtils.sharedPreferences!
                                      .containsKey('isConnectiong') &&
                                  PrefUtils.sharedPreferences!
                                          .getBool('isConnectiong') ==
                                      true
                              ? SizedBox()
                              : _builConnectButton(context),
                        ],
                      ),
                    )
                  ]
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Section Widget
  Widget _builCancelButton(BuildContext context,
      AsyncSnapshot<CheckForCustomerRequestModel> snapshot) {
    return ElevatedButton(
      onPressed: () async {
        Navigator.push(
          context,
          CupertinoDialogRoute(
            context: context,
            builder: (context) => CustomDialog(
              amount: '',
              color: appTheme.orangeA200,
              buttonLabel: 'Submit',
              cancelReasons: cancelreason,
              icon: Icons.done_all_rounded,
              message: '',
              onClick: (value) async {
                Navigator.pop(context);
                ProgressDialogUtils.showProgressDialog(
                  context: context,
                  isCancellable: false,
                );
                var respo = await ApiAuthHelper.cancelBrokerRequest(
                  cennectionId: connectionId,
                  reason: cancelreason[value],
                );
                if (respo) {
                  ProgressDialogUtils.hideProgressDialog();
                  setState(() {
                    isConnectiong = false;
                    PrefUtils.sharedPreferences!
                        .setBool('isConnectiong', false);

                    isBrokerSelected = false;
                    _timer.cancel();
                  });
                } else {
                  ProgressDialogUtils.hideProgressDialog();
                  ProgressDialogUtils.showSnackBar(
                    context: context,
                    message: 'Something went wrong',
                  );
                }
              },
              title: 'Cancel reason',
            ),
          ),
        );
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
        child: Center(
          child: Text(
            'Cancel',
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
      ),
    );
  }

  /// Section Widget
  Widget _builConnectButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        PrefUtils.sharedPreferences!.setString('fullname', fullname);
        PrefUtils.sharedPreferences!.setDouble('rate', rate.toDouble());
        if (isCheckedtersm) {
          ProgressDialogUtils.showProgressDialog(
            context: context,
            isCancellable: false,
          );
          List<BrokerRequestModel> response =
              await ApiAuthHelper.getBrokerDatastream(
            serviceId: widget.selectedserviceId,
            usreId: selectedbrokerId,
            locationName: placeName,
            locationLatitude: locationLatitude,
            locationLongtude: locationLongtude,
          );
          if (response.length > 0 && response[0].id != null) {
            connectionId = response[0].id;
            isConnectiong = true;
            PrefUtils.sharedPreferences!.setInt('connectionId', connectionId!);
            PrefUtils.sharedPreferences!.setBool('isConnectiong', true);
            setState(() {});
            _timer = Timer.periodic(Duration(seconds: 1), (timer) {
              _fetchUserRequests();
            });
            setState(() {});
            ProgressDialogUtils.hideProgressDialog();
          } else {
            ProgressDialogUtils.hideProgressDialog();
            return;
          }
        } else if (!isCheckedtersm) {
          ProgressDialogUtils.showSnackBar(
            context: context,
            message: 'Please accept our terms and conditions',
          );
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
        child: Center(
          child: Text(
            PrefUtils.sharedPreferences!.getBool('isConnectiong') == false
                ? 'lbl_connect'.tr
                : 'lbl_cancel'.tr,
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
      ),
    );
  }

  /// Hides the autocomplete overlay
  void clearOverlay() {
    if (overlayEntry != null) {
      overlayEntry!.remove();
      overlayEntry = null;
    }
  }

  /// Begins the search process by displaying a "wait" overlay then
  /// proceeds to fetch the autocomplete list. The bottom "dialog"
  /// is hidden so as to give more room and better experience for the
  /// autocomplete list overlay.
  void searchPlace(String place) {
    // on keyboard dismissal, the search was being triggered again
    // this is to cap that.
    if (place == previousSearchTerm) {
      return;
    } else {
      previousSearchTerm = place;
    }

    clearOverlay();

    setState(() {
      hasSearchTerm = place.isNotEmpty;
    });

    if (place.isEmpty) {
      return;
    }

    final renderBox = context.findRenderObject() as RenderBox;
    var size = renderBox.size;

    final appBarBox =
        appBarKey.currentContext!.findRenderObject() as RenderBox?;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: appBarBox!.size.height,
        width: size.width,
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 24,
          ),
          color: Theme.of(context).colorScheme.background,
          child: const Row(
            children: <Widget>[
              SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                ),
              ),
              SizedBox(
                width: 24,
              ),
            ],
          ),
        ),
      ),
    );

    Overlay.of(context).insert(overlayEntry!);

    autoCompleteSearch(context, place);
  }

  /// Fetches the place autocomplete list with the query [place].
  void autoCompleteSearch(context, String place) {
    place = place.replaceAll(' ', '+');
    var endpoint =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?'
        'key=${widget.apiKey}&'
        'input={$place}&sessiontoken=$sessionToken';

    if (locationResult != null) {
      endpoint += '&location=${locationResult!.latLng!.latitude},'
          '${locationResult!.latLng!.longitude}';
    }
    http.get(endpoint.toUri()!).then((response) {
      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
        var suggestions = <RichSuggestion>[];

        if (data['error_message'] == null) {
          List<dynamic> predictions = data['predictions'];

          if (predictions.isEmpty) {
            var aci = AutoCompleteItem();
            aci.text = 'noResultFound';
            aci.offset = 0;
            aci.length = 0;

            suggestions.add(RichSuggestion(aci, () {}));
          } else {
            for (dynamic t in predictions) {
              var aci = AutoCompleteItem();

              aci.id = t['place_id'];
              aci.text = t['description'];
              aci.offset = t['matched_substrings'][0]['offset'];
              aci.length = t['matched_substrings'][0]['length'];

              suggestions.add(RichSuggestion(aci, () {
                FocusScope.of(context).requestFocus(FocusNode());
                decodeAndSelectPlace(aci.id);
              }));
            }
          }
        } else {
          var aci = AutoCompleteItem();
          aci.text = data['error_message'];
          aci.offset = 0;
          aci.length = 0;
          suggestions.add(RichSuggestion(aci, () {}));
        }
        displayAutoCompleteSuggestions(suggestions);
      }
    }).catchError((print) {});
  }

  ///to get the palceId by using latitude and longitude
  Future<String?> getPlaceId(double latitude, double longitude) async {
    String endpoint =
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=$latitude,$longitude&key=${widget.apiKey}';
    http.Response response = await http.get(Uri.parse(endpoint));
    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);
      if (data['status'] == 'OK' && data['results'].isNotEmpty) {
        // Extract place ID from the first result
        return data['results'][0]['place_id'];
      }
    }
    return null;
  }

  /// To navigate to the selected place from the autocomplete list to the map,
  /// the lat,lng is required. This method fetches the lat,lng of the place and
  /// proceeds to moving the map to that location.
  void decodeAndSelectPlace(String? placeId) {
    clearOverlay();
    var endpoint =
        'https://maps.googleapis.com/maps/api/place/details/json?key=${widget.apiKey}'
        '&placeid=$placeId';

    http.get(endpoint.toUri()!).then((response) {
      if (response.statusCode == 200) {
        Map<String, dynamic> location =
            jsonDecode(response.body)['result']['geometry']['location'];
        var latLng = LatLng(location['lat'], location['lng']);
        // here you need to request for new list of Broker information
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['status'] == 'OK' && responseData['result'] != null) {
          // Extract the full name of the place from the response
          setState(() {
            placeName = responseData['result']['name'];
          });
          // Return the full name of the place
        }
        setState(() {
          locationLatitude = location['lat'].toString();
          locationLongtude = location['lng'].toString();
        });
        getBrokers(latitude: location['lat'], longitude: location['lng']);
        moveToLocation(latLng);
      }
    });
  }

  /// To navigate to the selected place from the autocomplete list to the map,
  /// the lat,lng is required. This method fetches the lat,lng of the place and
  /// proceeds to moving the map to that location.
  void decodeAndSelectPlaceForFirst(String? placeId) {
    clearOverlay();
    try {
      var endpoint =
          'https://maps.googleapis.com/maps/api/place/details/json?key=${widget.apiKey}'
          '&placeid=$placeId';
      http.get(endpoint.toUri()!).then((response) {
        if (response.statusCode == 200) {
          Map<String, dynamic> location =
              jsonDecode(response.body)['result']['geometry']['location'];
          var latLng = LatLng(location['lat'], location['lng']);
          final Map<String, dynamic> responseData = json.decode(response.body);
          if (responseData['status'] == 'OK' &&
              responseData['result'] != null) {
            setState(() {
              placeName = responseData['result']['name'];
            });
          }
          setState(() {
            locationLatitude = location['lat'].toString();
            locationLongtude = location['lng'].toString();
          });
          moveToLocation(latLng);
        }
      });
    } catch (e) {
      return;
    }
  }

  /// Display autocomplete suggestions with the overlay.
  void displayAutoCompleteSuggestions(List<RichSuggestion> suggestions) {
    final renderBox = context.findRenderObject() as RenderBox;
    var size = renderBox.size;

    final appBarBox =
        appBarKey.currentContext!.findRenderObject() as RenderBox?;

    clearOverlay();

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: size.width,
        top: appBarBox!.size.height,
        child: Container(
          color: Theme.of(context).colorScheme.background,
          child: Column(
            children: suggestions,
          ),
        ),
      ),
    );

    Overlay.of(context).insert(overlayEntry!);
  }

  /// Utility function to get clean readable name of a location. First checks
  /// for a human-readable name from the nearby list. This helps in the cases
  /// that the user selects from the nearby list (and expects to see that as a
  /// result, instead of road name). If no name is found from the nearby list,
  /// then the road name returned is used instead.
  String? getLocationName() {
    if (locationResult == null || (locationResult!.name?.isEmpty ?? true)) {
      return 'Unnamed location';
    }

    for (var np in nearbyPlaces) {
      if (np.latLng == locationResult!.latLng) {
        locationResult!.name = np.name;
        return np.name;
      }
    }

    return '${locationResult!.name}, ${locationResult!.locality}';
  }

  /// Moves the marker to the indicated lat,lng
  void setMarker(LatLng latLng) {
    markers.clear();
    markers.add(
      Marker(
        markerId: const MarkerId('selected-location'),
        position: latLng,
      ),
    );
    setState(() {});
  }

  /// Fetches and updates the nearby places to the provided lat,lng
  void getNearbyPlaces(LatLng latLng) {
    http
        .get('https://maps.googleapis.com/maps/api/place/nearbysearch/json?'
                'key=${widget.apiKey}&'
                'location=${latLng.latitude},${latLng.longitude}&radius=150'
            .toUri()!)
        .then((response) {
      if (response.statusCode == 200) {
        nearbyPlaces.clear();
        for (Map<String, dynamic> item
            in jsonDecode(response.body)['results']) {
          var nearbyPlace = NearbyPlace();

          nearbyPlace.name = item['name'];
          nearbyPlace.icon = item['icon'];
          double latitude = item['geometry']['location']['lat'];
          double longitude = item['geometry']['location']['lng'];

          var latLng = LatLng(latitude, longitude);

          nearbyPlace.latLng = latLng;

          nearbyPlaces.add(nearbyPlace);
        }
      }

      // to update the nearby places
      setState(() {
        // this is to require the result to show
        hasSearchTerm = false;
      });
    }).catchError((error) {});
  }

  /// This method gets the human readable name of the location. Mostly appears
  /// to be the road name and the locality.
  void reverseGeocodeLatLng(LatLng latLng) {
    http
        .get(
            'https://maps.googleapis.com/maps/api/geocode/json?latlng=${latLng.latitude},${latLng.longitude}&key=${widget.apiKey}'
                .toUri()!)
        .then((response) {
      Map<String, dynamic> responseJson = jsonDecode(response.body);
      if (response.statusCode == 200 &&
          responseJson['results'] is List &&
          List.from(responseJson['results']).isNotEmpty) {
        String? road = '';
        String? locality = '';

        String? number = '';
        String? street = '';
        String? state = '';

        String? city = '';
        String? country = '';
        String? zip = '';

        List components = responseJson['results'][0]['address_components'];
        for (var i = 0; i < components.length; i++) {
          final item = components[i];
          List types = item['types'];
          if (types.contains('street_number') ||
              types.contains('premise') ||
              types.contains('sublocality') ||
              types.contains('sublocality_level_2')) {
            if (number!.isEmpty) {
              number = item['long_name'];
            }
          }
          if (types.contains('route') || types.contains('neighborhood')) {
            if (street!.isEmpty) {
              street = item['long_name'];
            }
          }
          if (types.contains('administrative_area_level_1')) {
            state = item['short_name'];
          }
          if (types.contains('administrative_area_level_2') ||
              types.contains('administrative_area_level_3')) {
            if (city!.isEmpty) {
              city = item['long_name'];
            }
          }
          if (types.contains('locality')) {
            if (locality!.isEmpty) {
              locality = item['short_name'];
            }
          }
          if (types.contains('route')) {
            if (road!.isEmpty) {
              road = item['long_name'];
            }
          }
          if (types.contains('country')) {
            country = item['short_name'];
            if (types.contains('postal_code')) {
              if (zip!.isEmpty) {
                zip = item['long_name'];
              }
            }
          }

          setState(() {
            locationResult = LocationResult();
            locationResult!.name = road;
            locationResult!.locality = locality;
            locationResult!.latLng = latLng;
            locationResult!.street = '$number $street';
            locationResult!.state = state;
            locationResult!.city = city;
            locationResult!.country = country;
            locationResult!.zip = zip;
          });
        }
      } else {
        setState(() {
          locationResult = LocationResult();
          locationResult!.name = '';
          locationResult!.latLng = latLng;
          locationResult!.street = '';
          locationResult!.state = '';
          locationResult!.city = '';
          locationResult!.country = '';
          locationResult!.zip = '';
        });
      }
    });
  }

  /// Moves the camera to the provided location and updates other UI features to
  /// match the location.
  void moveToLocation(LatLng latLng) {
    mapController.future.then((controller) {
      controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: latLng,
            zoom: 15.0,
          ),
        ),
      );
    });

    setMarker(latLng);

    reverseGeocodeLatLng(latLng);

    getNearbyPlaces(latLng);
  }

  void moveToCurrentUserLocation() {
    var location = Location();
    location.getLocation().then((locationData) {
      var target = LatLng(locationData.latitude!, locationData.longitude!);
      moveToLocation(target);
    });
  }
}

class PrivacyTermScreen extends StatefulWidget {
  const PrivacyTermScreen();

  @override
  State<StatefulWidget> createState() {
    return PrivacyTermScreenState();
  }
}

class PrivacyTermScreenState extends State<PrivacyTermScreen> {
  List<String> orotermsAndCondtion = [
    'Appii Dallaalaa buufachuu fi itti fayyadamuudhaan, haalawwanii fi dambiiwwan kana akka eegdu beekta, akkasumas walii galtee qabda.',
    'Appiin Dallaalaa odeeffannoo qofaaf kan kenname yoo ta’u, odeeffannoon kenname akka gorsa faayinaansiitti ilaalamuu hin qabu. Fayyadamtoonni murtii invastimantii isaaniif itti gaafatamummaa qofa kan qaban yoo ta’u, yeroo barbaachisaa ta’etti gorsa ogeessaa barbaaduu qabu.',
    'Appiin Dallaalaa tajaajila faayinaansii fi waltajjiiwwan qaama sadaffaa fayyadamuu ni danda’a. Sirrummaa, amanamummaa, ykn mijachuu tajaajila qaama sadaffaa kamiyyuu hin raggaasifnu ykn hin mirkaneessinu. Fayyadamtoonni tajaajila qaama sadaffaa akkasii fayyadamuu isaanii dura haalawwanii fi dambiiwwan akka ilaalanii fi fudhatan gorfama.',
    'Nageenyi mirkaneessitoota akkaawuntii fayyadamaa kan akka maqaa fayyadamaa fi jechoota icciitii itti gaafatamummaa fayyadamaati. odeeffannoo herrega isaanii eeguu Fayyadamtoonni tarkaanfiiwwan sirriitti fudhachuu qabu, akkasumas f hayyama malee seenamuu ykn sochii shakkisiisaa kamiyyuu hatattamaan gabaasuu.',
    'Appiin Dallaalaa muuxannoo fayyadamaa guddisuu fi odeeffannoo dhuunfaa hin taane walitti qabuuf cookies ykn teeknooloojiiwwan kana fakkaatan fayyadamuu ni danda’a. Appicha fayyadamuudhaan, akkaataa Imaammata Dhuunfaa keenya keessatti ibsametti kukiiwwanii fi teeknooloojiiwwan akkasii akka fayyadamaniif hayyama kenniteetta.',
  ];
  List<String> entermsAndCondtion = [
    'By downloading and using the broker app, you acknowledge and agree to comply with these terms and conditions.',
    'The broker app is provided for informational purposes only, and the information provided should not be considered as financial advice. Users are solely responsible for their investment decisions and should seek professional advice when needed.',
    'The broker app may provide access to third-party financial services and platforms. We do not endorse or guarantee the accuracy, reliability, or suitability of any third-party services or platforms. Users are advised to review and accept the terms and conditions of such third-party services before using them.',
    'The security of user account credentials, such as usernames and passwords, is the user\'s responsibility. Users must take appropriate measures to protect their account information and promptly report any unauthorized access or suspicious activities.',
    'The broker app may use cookies or similar technologies to enhance user experience and collect non-personal information. By using the app, you consent to the use of such cookies and technologies as outlined in our Privacy Policy.',
  ];
  List<String> amtermsAndCondtion = [
    'የደላላዬ አፕ በማውረድ እና በመጠቀም እነዚህን የውል ሁኔታዎች እና ድንጋጌዎች ለማክበር መስማማትዎን ያረጋግጣሉ፡፡',
    'የደላላዬ አፕ ለመረጃ ዓላማ ብቻ የቀረበ ሲሆን የቀረበው መረጃ እንደ ፋይናንስ ነክ ምክር ተደርጎ ሊቆጠር አይገባም ተጠቃሚዎች ለኢንቨስትመንት ውሳኔዎቻቸው ብቻ ኃላፊነት የሚወስዱ ከመሆናቸው ባሻገር እንደየአስፈካጊነቱ የሙያተኛ ምክር ሊጠይቁ ይገባል፡፡',
    'የደላላዬ አፕ ከ3ኛ ወገን የፋይናንስ አገልግሎቶች እና አውታሮች ጋር ሊገናኙት  ይችላል፡፡ የ3ኛ ወገን  የፋይናንስ አገልግሎቶች እና አውታሮችን በሚመለከት ስለ ትክክለኛነታቸው፣ ስለአስተማማኝታቸው እና ስለተገቢነታቸቸው ማረጋገጫ አንሰጥም፡፡ ተጠቃሚዎች የ3ኛ ወገን አገልግሎቶችን ከመጠቀማቸው አስቀድመው የውል ሁኔታዎችን  እና ድንጋጌዎችን ማንበብ እና መቀበላቸው ማረጋገጥ ይጠበቅባቸዋል፡፡',
    'እንደ ተጠቃሚ ስም እና ሚስጥራዊ ቁጥር ያሉ የተጠቃሚ አካውንት መረጃዎ የተጠቃሚው ኃላፊነት ናቸው ተጠቃሚዎች የአካውንቶቻቸውን መረጃ ለመጠበቅ ጥንቃቅ ማድረግ እና ያለፈቃድ የሚደረጉ መግባቶች ሲኖሩ ወይም አጠራጣሪ ተግባራት ሲያጋጥሙ ወዲያውኑ ሪፖርት ማድረግና እርምጃ መውሰድ ይኖርባቸዋል፤',
    'የደላላዬ አፕ የተለያዩ የግንኙነት መራ (ኮኪ) ወይም ተመሳሳይ ቴክኖሎጂዎችን በመጠቀም የደንበኛችን ግላዊ ያልሆኑ መረጃዎችን ጥቅም ላይ በማዋል አገልግሎቱን ያሳልጣል፡፡ የደላላዬ አፕ በመጠቀምዎ የቴክኖሎጂ አጠቃቀም እና የግላዊ መረጃ ፖሊሲችንን ለማክበር መስማማቱን ያረጋግጣሉ፡፡ ',
  ];
  @override
  Widget build(BuildContext context) {
    int number = 1;
    debugPrint(
        "PrefUtils.sharedPreferences!.getString('language_code')  ==> ${PrefUtils.sharedPreferences!.getString('language_code')}");
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            NavigatorService.goBack();
          },
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
        ),
        title: Text(
          PrefUtils.sharedPreferences!.getString('language_code') == 'en'
              ? 'Our term and condition'
              : PrefUtils.sharedPreferences!.getString('language_code') == 'am'
                  ? 'የውል ሁኔታዎ እና ድንጋጌዎች'
                  : 'Haalawwanii fi Dambiiwwan keenya',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        backgroundColor: appTheme.orangeA200,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Container(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            child: Column(
              children: [
                for (int i = 0; i < entermsAndCondtion.length; i++) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${number++}.",
                        style: theme.textTheme.bodyLarge!.copyWith(
                          fontWeight: FontWeight.w500,
                          color: Colors.black54,
                        ),
                      ),
                      SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          PrefUtils.sharedPreferences!
                                      .getString('language_code') ==
                                  null
                              ? entermsAndCondtion[i]
                              : PrefUtils.sharedPreferences!
                                          .getString('language_code') ==
                                      'en'
                                  ? entermsAndCondtion[i]
                                  : PrefUtils.sharedPreferences!
                                              .getString('language_code') ==
                                          'am'
                                      ? amtermsAndCondtion[i]
                                      : orotermsAndCondtion[i],
                          style: theme.textTheme.bodyLarge!.copyWith(
                            fontWeight: FontWeight.w500,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 15),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  //Convert Html to simple String
  static String parseHtmlString(String htmlString) {
    final document = parse(htmlString);
    final String parsedString =
        parse(document.body!.text).documentElement!.text;

    return parsedString;
  }
}

/// Custom Search input field, showing the search and clear icons.
class SearchInput extends StatefulWidget {
  final ValueChanged<String> onSearchInput;

  const SearchInput(this.onSearchInput);

  @override
  State<StatefulWidget> createState() {
    return SearchInputState();
  }
}

class SearchInputState extends State<SearchInput> {
  TextEditingController editController = TextEditingController();

  Timer? debouncer;

  bool hasSearchEntry = false;

  SearchInputState();

  bool initialized = false;
  bool isSearchng = false;
//  SharedPreferences? tryu;

  @override
  void initState() {
    //initPrefs();
    PrefUtils().init();
    super.initState();
    editController.addListener(onSearchInputChange);
  }

  @override
  void dispose() {
    editController.removeListener(onSearchInputChange);
    editController.dispose();

    super.dispose();
  }

  void onSearchInputChange() {
    if (editController.text.isEmpty) {
      debouncer?.cancel();
      widget.onSearchInput(editController.text);
      return;
    }

    if (debouncer?.isActive ?? false) {
      debouncer!.cancel();
    }

    debouncer = Timer(const Duration(milliseconds: 500), () {
      widget.onSearchInput(editController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 6,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          color: appTheme.gray40001,
        ),
        child: PrefUtils.sharedPreferences!.getBool('isConnectiong') == false ||
                !PrefUtils.sharedPreferences!.containsKey('isConnectiong')
            ? Row(
                children: <Widget>[
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'lbl_search_place'.tr,
                        border: InputBorder.none,
                      ),
                      style: TextStyle(color: Colors.black),
                      controller: editController,
                      onChanged: (value) {
                        setState(() {
                          hasSearchEntry = value.isNotEmpty;
                        });
                      },
                    ),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  hasSearchEntry
                      ? GestureDetector(
                          onTap: () {
                            editController.clear();
                            setState(() {
                              hasSearchEntry = false;
                            });
                          },
                          child: const Icon(
                            Icons.clear,
                            color: Colors.grey,
                          ),
                        )
                      : const SizedBox(),
                ],
              )
            : SizedBox.shrink()
        // : SizedBox.shrink(),
        );
  }
}

class SelectPlaceAction extends StatefulWidget {
  final String? locationName;
  final VoidCallback onTap;

  const SelectPlaceAction(this.locationName, this.onTap);

  @override
  State<SelectPlaceAction> createState() => _SelectPlaceActionState();
}

class _SelectPlaceActionState extends State<SelectPlaceAction> {
  // SharedPreferences? prefs;
  bool initialized = false;

  @override
  void initState() {
    PrefUtils().init();
    super.initState();
    // initPref();
  }

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: widget.onTap,
      child: Container(
        decoration: AppDecoration.outlineWhite.copyWith(
          borderRadius: BorderRadiusStyle.customBorderTL25,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 5,
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  CustomImageView(
                    imagePath: 'assets/images/markerImage.png',
                    width: 100.h,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    PrefUtils.sharedPreferences!.getBool('isSearching') == true
                        ? PrefUtils.sharedPreferences!
                                .getString('description') ??
                            ''
                        : 'lbl_please_tap_on_the_nearest_delala'.tr,
                    style: TextStyle(
                      color:
                          PrefUtils.sharedPreferences!.getBool('isSearching') ==
                                  true
                              ? Colors.black
                              : Colors.grey,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NearbyPlaceItem extends StatelessWidget {
  final NearbyPlace nearbyPlace;
  final VoidCallback onTap;

  const NearbyPlaceItem(this.nearbyPlace, this.onTap);

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 16,
        ),
        child: Row(
          children: <Widget>[
            Image.network(
              nearbyPlace.icon!,
              width: 16,
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Text(
                nearbyPlace.name.toString(),
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class RichSuggestion extends StatelessWidget {
  final VoidCallback onTap;
  final AutoCompleteItem autoCompleteItem;

  const RichSuggestion(this.autoCompleteItem, this.onTap);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 16,
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: RichText(
                text: TextSpan(children: getStyledTexts(context)),
              ),
            )
          ],
        ),
      ),
    );
  }

  List<TextSpan> getStyledTexts(BuildContext context) {
    final result = <TextSpan>[];

    final startText =
        autoCompleteItem.text!.substring(0, autoCompleteItem.offset);
    if (startText.isNotEmpty) {
      result.add(
        TextSpan(
          text: startText,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 15,
          ),
        ),
      );
    }

    final boldText = autoCompleteItem.text!.substring(autoCompleteItem.offset!,
        autoCompleteItem.offset! + autoCompleteItem.length!);

    result.add(TextSpan(
      text: boldText,
      style: TextStyle(
        color: Theme.of(context).colorScheme.secondary,
        fontSize: 15,
      ),
    ));

    var remainingText = autoCompleteItem.text!
        .substring(autoCompleteItem.offset! + autoCompleteItem.length!);
    result.add(
      TextSpan(
        text: remainingText,
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 15,
        ),
      ),
    );

    return result;
  }
}
