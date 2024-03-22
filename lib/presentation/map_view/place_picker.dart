/// This widget is customize from the place_picker - https://pub.dev/packages/place_picker
import 'dart:async';
import 'dart:convert';
import 'dart:math' show Random;

import 'package:delalochu/core/utils/image_constant.dart';
import 'package:delalochu/core/utils/progress_dialog_utils.dart';
import 'package:delalochu/core/utils/size_utils.dart';
import 'package:delalochu/domain/apiauthhelpers/apiauth.dart';
import 'package:delalochu/presentation/map_view/model/broker_request_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:inspireui/extensions/string_extension.dart';
import 'package:location/location.dart';

import '../../core/utils/pref_utils.dart';
import '../callToBroker_Page/call_to_broker_sreen.dart';
import '../../theme/app_decoration.dart';
import '../../theme/theme_helper.dart';
import '../../widgets/custom_dialog.dart';
import '../../widgets/custom_image_view.dart';
import 'model/broker_info_model.dart';
import 'model/check_request_usingConnection.dart';

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
    'Broker too far',
    'Changed my mind',
    'Just trying the app',
    'Long waiting time',
    'Others'
  ];

  bool isLoading = false;

  String fullname = '';
  String phoneNumber = '';

  bool hasCar = false;

  String? selectedbrokerId;

  String? placeName = '';

  String? locationLatitude = '';
  int? connectionId;

  String? locationLongtude = '';

  late StreamController<CheckForCustomerRequestModel> _requestStreamController;
  late Timer _timer;

  // constructor
  PlacePickerState();

  void onMapCreated(GoogleMapController controller) {
    mapController.complete(controller);
    moveToCurrentUserLocation();
  }

  Future<LocationData> getCurrentLocation() async {
    Location location = Location();
    return await location.getLocation();
  }

  Future<void> _fetchUserRequests() async {
    try {
      print('=================================> _fetchUserRequests() called');
      print('============connectionId=====================> $connectionId');
      print('=================================> _fetchUserRequests() called');
      var token = PrefUtils.sharedPreferences!.getString('token') ?? '';
      var headers = {'x-auth-token': token};
      var request = http.Request(
          'GET',
          Uri.parse(
              'https://api.delalaye.com/api/users/request/$connectionId'));
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
              isBrokerSelected = false;
            });
            ProgressDialogUtils.showSnackBar(
              context: context,
              message: 'You request has been cancelled',
            );
          } else if (res.connectionRequests != null &&
              res.connectionRequests!.status == "DECLINED") {
            _timer.cancel();
            setState(() {
              isConnectiong = false;
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
      print(' _fetchUserRequests Error: $e StackTres => $s');
      return;
    }
  }

  getBrokers({latitude, longitude}) {
    print('ServiceId => ${widget.selectedserviceId} $latitude $longitude');
    setState(() {
      isConnectiong = false;
      isBrokerSelected = false;
    });
    getCurrentLocation().then((locationData) async {
      ProgressDialogUtils.showProgressDialog(
        context: context,
        isCancellable: false,
      );
      listofbrokers = await ApiAuthHelper.fetchBrokerData(
        latitude: latitude == '' ? locationData.latitude : latitude,
        longitude: longitude == '' ? locationData.longitude : longitude,
        serviceId: int.parse(widget.selectedserviceId ?? '1'),
      );
      if (listofbrokers.length > 0) {
        for (var i = 0; i < listofbrokers.length; i++) {
          // here you must check the broker is online or not,then add it to the list
          if (listofbrokers[i].avilableForWork == true) {
            marker.add(Marker(
              position: LatLng(
                listofbrokers[i].locationLatitude ?? 0.0,
                listofbrokers[i].locationLongtude ?? 0.0,
              ),
              icon: await BitmapDescriptor.fromAssetImage(
                ImageConfiguration(),
                'assets/images/markerImage.png',
              ),
              markerId: MarkerId('${listofbrokers[i].id}'),
              onTap: () {
                setState(() {
                  fullname = listofbrokers[i].fullName ?? "";
                  hasCar = listofbrokers[i].hasCar ?? false;
                  selectedbrokerId = listofbrokers[i].id.toString();
                  phoneNumber = listofbrokers[i].phone ?? "";
                  isBrokerSelected = true;
                });
              },
              infoWindow: InfoWindow(
                title: '${listofbrokers[i].fullName}',
              ),
            ));
          }
        }
        ProgressDialogUtils.hideProgressDialog();
        ProgressDialogUtils.showSnackBar(
          context: context,
          message:
              'There are ${listofbrokers.length} Brokers are available around $placeName',
        );
      } else {
        ProgressDialogUtils.hideProgressDialog();
        ProgressDialogUtils.showSnackBar(
          context: context,
          message:
              'There is no brokers available around $placeName. Please search another place',
        );
      }
    }).catchError((e) {
      print('Error getting location: $e');
      ProgressDialogUtils.hideProgressDialog();
      return;
    });
    setState(() {});
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    getBrokers(
      latitude: '',
      longitude: '',
    );
    _requestStreamController =
        StreamController<CheckForCustomerRequestModel>.broadcast();
    super.initState();
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
    return Scaffold(
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
            Navigator.pop(context);
          },
        ),
        automaticallyImplyLeading: false,
      ),
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Stack(
        children: [
          Column(
            children: <Widget>[
              Expanded(
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: initialTarget,
                    zoom: 19,
                    bearing: 50,
                  ),
                  myLocationButtonEnabled: true,
                  myLocationEnabled: true,
                  onMapCreated: onMapCreated,
                  // onTap: (latLng) {
                  //   clearOverlay();
                  //   moveToLocation(latLng);
                  // },
                  markers: Set<Marker>.of(marker),
                ),
              ),
              hasSearchTerm
                  ? const SizedBox()
                  : isBrokerSelected
                      ? Container(
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
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
                                                  imagePath: ImageConstant.car,
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
                                            '3.0',
                                            style: const TextStyle(
                                              color: Colors.grey,
                                              fontSize: 15,
                                            ),
                                          ),
                                          RatingBar.builder(
                                            initialRating: 3,
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
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(height: 20),
                              Padding(
                                padding: const EdgeInsets.only(left: 20.0),
                                child: isConnectiong
                                    ? StreamBuilder<
                                        CheckForCustomerRequestModel>(
                                        stream: _requestStreamController.stream,
                                        builder: (context, snapshot) {
                                          if (snapshot.hasData &&
                                              snapshot.data != null &&
                                              snapshot.data!
                                                      .connectionRequests !=
                                                  null &&
                                              snapshot.data!.connectionRequests!
                                                      .status ==
                                                  "REQUESTED") {
                                            return Column(
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    horizontal: 40.0,
                                                  ),
                                                  child: Text(
                                                    'Waiting for broker response...',
                                                    style: TextStyle(
                                                      color:
                                                          appTheme.orangeA200,
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
                                              snapshot.data!.connectionRequests!
                                                      .status ==
                                                  "ACCEPTED") {
                                            return SizedBox();
                                          } else if (snapshot
                                                  .hasData &&
                                              snapshot.data != null &&
                                              snapshot.data!
                                                      .connectionRequests !=
                                                  null &&
                                              snapshot.data!.connectionRequests!
                                                      .status ==
                                                  "CANCELLED") {
                                            return SizedBox();
                                          } else if (snapshot.hasError) {
                                            print(
                                                'object snapshot error: ${snapshot.error}');
                                            return SizedBox();
                                          } else if (snapshot.connectionState ==
                                                  ConnectionState.waiting ||
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
                                          isCheckedtersm = !isCheckedtersm;
                                          setState(() {});
                                        },
                                        child: Row(
                                          children: <Widget>[
                                            Checkbox(
                                              value: isCheckedtersm,
                                              activeColor: appTheme.orangeA200,
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
                                                  const TextSpan(text: ' '),
                                                  TextSpan(
                                                    text: 'Term & condition',
                                                    style: TextStyle(
                                                        color:
                                                            appTheme.orangeA200,
                                                        decoration:
                                                            TextDecoration
                                                                .underline),
                                                    recognizer:
                                                        TapGestureRecognizer()
                                                          ..onTap = () =>
                                                              Navigator.push(
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
                              isConnectiong
                                  ? SizedBox()
                                  : _builConnectButton(context),
                            ],
                          ),
                        )
                      : SelectPlaceAction(getLocationName(), () {}),
            ],
          ),
        ],
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
              buttonLable: 'Submit',
              cancelreason: cancelreason,
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
            print('================================');
            print('Connection Id is not null');
            print('================================');
            setState(() {
              connectionId = response[0].id;
              isConnectiong = true;
            });
            _timer = Timer.periodic(Duration(seconds: 3), (timer) {
              _fetchUserRequests();
            });
            setState(() {});
            ProgressDialogUtils.hideProgressDialog();
          } else {
            print('================================');
            print('Connection Id is => null');
            print('================================');
            ProgressDialogUtils.hideProgressDialog();
            return;
          }
        } else {
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
            !isConnectiong ? 'Connect' : 'Cancel',
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
    // markers.clear();
    setState(() {
      markers.clear();
      markers.add(
        Marker(
          markerId: const MarkerId('selected-location'),
          position: latLng,
        ),
      );
    });
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Our term and condition'),
      ),
      body: Container(
        child: RichText(
          text: TextSpan(
            text: 'By ',
            children: [
              TextSpan(
                text:
                    'By downloading and using the broker app, you acknowledge and agree to comply with these terms and conditions.',
              )
            ],
          ),
        ),
      ),
    );
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

  @override
  void initState() {
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
      child: Row(
        children: <Widget>[
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search Place',
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
      ),
    );
  }
}

class SelectPlaceAction extends StatelessWidget {
  final String? locationName;
  final VoidCallback onTap;

  const SelectPlaceAction(this.locationName, this.onTap);

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
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
                    'Please tap on the nearest delala',
                    style: const TextStyle(
                      color: Colors.grey,
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
