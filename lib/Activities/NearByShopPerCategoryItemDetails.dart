import 'package:cached_network_image/cached_network_image.dart';
import 'package:clipboard/clipboard.dart';
//import 'package:clipboard_manager/clipboard_manager.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:societyrun/GlobalClasses/AppLocalizations.dart';
import 'package:societyrun/GlobalClasses/CustomAppBar.dart';
import 'package:societyrun/GlobalClasses/GlobalFunctions.dart';
import 'package:societyrun/GlobalClasses/GlobalVariables.dart';
import 'package:societyrun/Models/NearByShopResponse.dart';
import 'package:societyrun/Widgets/AppButton.dart';
import 'package:societyrun/Widgets/AppImage.dart';
import 'package:societyrun/Widgets/AppWidget.dart';
import 'package:url_launcher/url_launcher.dart';

class NearByShopPerCategoryItemDetails extends StatefulWidget {
  NearByShop nearByShopList;
  NearByShopPerCategoryItemDetails(this.nearByShopList);

  @override
  NearByShopPerCategoryItemDetailsState createState() =>
      NearByShopPerCategoryItemDetailsState();
}

class NearByShopPerCategoryItemDetailsState
    extends State<NearByShopPerCategoryItemDetails> {
  var width, height;

  List<NearByShopOfferDetails> offerDetailsList = <NearByShopOfferDetails>[];
  List<NearByShopTermsCondition> termsConditionList =
      <NearByShopTermsCondition>[];

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    offerDetailsList = List<NearByShopOfferDetails>.from(widget
        .nearByShopList.offer_details
        .map((i) => NearByShopOfferDetails.fromJson(i)));
    termsConditionList = List<NearByShopTermsCondition>.from(widget
        .nearByShopList.terms_condition
        .map((i) => NearByShopTermsCondition.fromJson(i)));
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    GlobalFunctions.changeStatusColor(GlobalVariables.transparent);
    return Builder(
      builder: (context) => Scaffold(
        //resizeToAvoidBottomPadding: false,
        appBar: CustomAppBar(
          title: 'Offer Details',
        ),
        body: getBaseLayout(),
      ),
    );
  }

  getBaseLayout() {
    return Container(
      decoration: BoxDecoration(
        color: Color(int.parse(widget.nearByShopList.card_bg!)),
      ),
      child: Column(
        children: [
          Flexible(
            child: Stack(
              children: [
                Container(
                  padding: EdgeInsets.all(16.0),
                  color: Color(int.parse(widget.nearByShopList.card_bg!)),
                  height: double.infinity,
                  //padding: EdgeInsets.only(left: 8,right: 8,top: 8),
                  child: SingleChildScrollView(
                    child: Stack(
                      children: [
                        Column(
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Container(
                                  alignment: Alignment.topRight,
                                  margin: EdgeInsets.only(
                                    top: 16,
                                  ),
                                  padding: EdgeInsets.only(
                                      left: 10, right: 10, top: 2, bottom: 2),
                                  decoration: boxDecoration(
                                      bgColor: GlobalVariables.white,
                                      radius: 5),
                                  child: text(
                                    'Till ' +
                                        GlobalFunctions.convertDateFormat(
                                            widget.nearByShopList.exp_date!,
                                            'dd-MMM-yyyy'),
                                    fontSize: GlobalVariables.textSizeSmall,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              margin: EdgeInsets.only(top: 8),
                              // padding: ,
                              child: AppNetworkImage(
                                widget.nearByShopList.Img_Name,
                                imageWidth: width,
                                imageHeight: width * 0.6,
                                //fit: BoxFit.fill,
                                shape: BoxShape.rectangle,
                                borderColor: GlobalVariables.transparent,
                              ),
                            ),
                            SizedBox(
                              height: 60,
                            ),
                            Container(
                              width: double.infinity,
                              decoration: boxDecoration(
                                  radius: 10, bgColor: GlobalVariables.white),
                              padding: EdgeInsets.all(16),
                              child: Stack(
                                children: <Widget>[
                                  Container(
                                    margin: EdgeInsets.only(top: 30),
                                    child: Column(
                                      children: [
                                        Container(
                                          //color: GlobalVariables.grey,
                                          padding: EdgeInsets.only(
                                              top: 8 /*,left: 16*/),
                                          alignment: Alignment.center,
                                          child: primaryText(
                                            widget.nearByShopList.vendor_shop,
                                            /* textColor:
                                                  GlobalVariables.black,
                                              fontWeight: FontWeight.w500,
                                              fontSize: GlobalVariables
                                                  .textSizeLargeMedium,
                                              maxLine: 2*/
                                          ),
                                        ),
                                        Divider(),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: primaryText(
                                                widget.nearByShopList.Title,
                                                /*textColor:
                                                      GlobalVariables
                                                          .green,
                                                  fontWeight:
                                                      FontWeight.w500,
                                                  fontSize:
                                                      GlobalVariables
                                                          .textSizeMedium,
                                                  maxLine: 4*/
                                              ),
                                            ),
                                            SizedBox(
                                              width: 16,
                                            ),
                                            InkWell(
                                              onTap: () {
                                                launch("tel://" +
                                                    widget.nearByShopList
                                                        .vendor_mobile!);
                                              },
                                              child: Container(
                                                margin: EdgeInsets.only(top: 8),
                                                child: AppIcon(
                                                  Icons.call,
                                                  iconSize: GlobalVariables
                                                      .textSizeNormal,
                                                  iconColor: GlobalVariables
                                                      .primaryColor,
                                                ),
                                              ),
                                            ),
                                            /* SizedBox(
                                              width: 16,
                                            ),*/
                                            /* Container(
                                              margin:
                                                  EdgeInsets.only(top: 8),
                                              child: Icon(
                                                Icons.favorite,
                                                size: 24,
                                                color:
                                                    GlobalVariables.red,
                                              ),
                                            ),*/
                                            SizedBox(
                                              width: 8,
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          height: 8,
                                        ),
                                        secondaryText(
                                          widget
                                              .nearByShopList.short_description,
                                        ),
                                        SizedBox(
                                          height: 16,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                                child: Container(
                                              child: Row(
                                                children: [
                                                  AppIcon(
                                                    Icons.location_on,
                                                  ),
                                                  SizedBox(
                                                    width: 8,
                                                  ),
                                                  Flexible(
                                                      child: secondaryText(
                                                    widget.nearByShopList
                                                        .Location,
                                                  )),
                                                  SizedBox(
                                                    width: 8,
                                                  ),
                                                ],
                                              ),
                                            )),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(top: 30),
                                    alignment: Alignment.center,
                                    transform: Matrix4.translationValues(
                                        0.0, -100.0, 0.0),
                                    decoration: BoxDecoration(
                                        color: GlobalVariables.white,
                                        border: Border.all(
                                            color: GlobalVariables.lightGray,
                                            width: 2.0),
                                        shape: BoxShape.circle),
                                    child: new CircleAvatar(
                                      backgroundColor: Color(int.parse(widget
                                          .nearByShopList.vendor_logo_bg!)),
                                      child: Container(
                                          //margin: EdgeInsets.only(top: 8),
                                          alignment: Alignment.center,
                                          padding: EdgeInsets.only(
                                              left: 16, right: 16, top: 16),
                                          child: CachedNetworkImage(
                                            imageUrl: widget
                                                .nearByShopList.vendor_logo!,
                                          )),
                                      radius: 50,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 16,
                            ),
                            offerDetailsList.length > 0
                                ? Container(
                                    decoration: boxDecoration(radius: 10),
                                    padding: EdgeInsets.all(16),
                                    child: Column(
                                      children: <Widget>[
                                        Container(
                                          child: primaryText(
                                            AppLocalizations.of(context)
                                                .translate('offer_details'),
                                            /* textColor: GlobalVariables.green,
                                      fontWeight: FontWeight.w500,
                                      fontSize:«
                                          GlobalVariables.textSizeMedium,*/
                                          ),
                                          alignment: Alignment.topLeft,
                                        ),
                                        SizedBox(
                                          height: 8,
                                        ),
                                        /*Container(
                                   // margin: EdgeInsets.only(left: 10),
                                    child: htmlText("""
    <!--For a much more extensive example, look at example/main.dart-->
   <ul><li>Tata Sky Binge+ is a Set Top Box that enables subscribers to watch both live TV and OTT content (when connected to internet) on one device, without switching between multiple HDMI ports.\r\n</li><li>OTT content that the user can watch on this Set Top Box includes VOD, 7 days catchup shows from Tata Sky and content from Apps like Hotstar, Hungama Zee5 etc.</li>\r\n<li>This offering provides the best of both worlds on one Set Top Box.\r\n</li></ul>
  """,
                                        fontSize:
                                            GlobalVariables.textSizeSMedium,
                                        maxLine: 99,
                                        textColor: GlobalVariables.grey),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(left: 10),
                                    child: htmlText(
                                        widget
                                            .nearByShopList.offer_details,
                                        fontSize: GlobalVariables
                                            .textSizeSMedium,
                                        maxLine: 99,
                                        textColor: GlobalVariables.grey),
                                  ),*/
                                        Builder(
                                            builder:
                                                (context) => ListView.builder(
                                                      physics:
                                                          const NeverScrollableScrollPhysics(),
                                                      itemCount:
                                                          offerDetailsList
                                                              .length,
                                                      itemBuilder:
                                                          (context, position) {
                                                        return Container(
                                                          margin:
                                                              EdgeInsets.only(
                                                                  left: 10),
                                                          child: Column(
                                                            children: [
                                                              Row(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Container(
                                                                    margin: EdgeInsets
                                                                        .only(
                                                                            top:
                                                                                8),
                                                                    width: 8,
                                                                    height: 8,
                                                                    decoration: BoxDecoration(
                                                                        color: GlobalVariables
                                                                            .primaryColor,
                                                                        shape: BoxShape
                                                                            .circle),
                                                                  ),
                                                                  SizedBox(
                                                                    width: 8,
                                                                  ),
                                                                  Flexible(
                                                                      child: Container(
                                                                          child: text(
                                                                              offerDetailsList[position].Description,
                                                                              fontSize: GlobalVariables.textSizeSMedium,
                                                                              maxLine: 99,
                                                                              textColor: GlobalVariables.grey))),
                                                                ],
                                                              ),
                                                              SizedBox(
                                                                height: 32,
                                                              ),
                                                            ],
                                                          ),
                                                        );
                                                      },
                                                      //  scrollDirection: Axis.vertical,
                                                      shrinkWrap: true,
                                                    )),
                                      ],
                                    ),
                                  )
                                : SizedBox(),
                            SizedBox(
                              height: 16,
                            ),
                            termsConditionList.length > 0
                                ? Container(
                                    decoration: boxDecoration(radius: 10),
                                    padding: EdgeInsets.all(16),
                                    child: Column(
                                      children: <Widget>[
                                        Container(
                                          child: primaryText(
                                            AppLocalizations.of(context)
                                                .translate('terms_conn'),
                                          ),
                                          alignment: Alignment.topLeft,
                                        ),
                                        SizedBox(
                                          height: 8,
                                        ),
                                        Builder(
                                            builder:
                                                (context) => ListView.builder(
                                                      physics:
                                                          const NeverScrollableScrollPhysics(),
                                                      itemCount:
                                                          termsConditionList
                                                              .length,
                                                      itemBuilder:
                                                          (context, position) {
                                                        return Container(
                                                          margin:
                                                              EdgeInsets.only(
                                                                  left: 10),
                                                          child: Column(
                                                            children: [
                                                              Row(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Container(
                                                                    margin: EdgeInsets
                                                                        .only(
                                                                            top:
                                                                                8),
                                                                    width: 8,
                                                                    height: 8,
                                                                    decoration: BoxDecoration(
                                                                        color: GlobalVariables
                                                                            .primaryColor,
                                                                        shape: BoxShape
                                                                            .circle),
                                                                  ),
                                                                  SizedBox(
                                                                    width: 8,
                                                                  ),
                                                                  Flexible(
                                                                      child: Container(
                                                                          child: text(
                                                                              termsConditionList[position].Description,
                                                                              fontSize: GlobalVariables.textSizeSMedium,
                                                                              maxLine: 99,
                                                                              textColor: GlobalVariables.grey))),
                                                                ],
                                                              ),
                                                              SizedBox(
                                                                height: 32,
                                                              ),
                                                            ],
                                                          ),
                                                        );
                                                      },
                                                      //  scrollDirection: Axis.vertical,
                                                      shrinkWrap: true,
                                                    )),
                                      ],
                                    ),
                                  )
                                : SizedBox(),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: width,
              margin: EdgeInsets.only(left: 16, right: 16, top: 4, bottom: 4),
              child: AppButton(
                textContent: widget.nearByShopList.Offer_Code!.isNotEmpty
                    ? "Get Code"
                    : "Enquiry Now",
                onPressed: () {
                  insertUserInfoOnExclusiveGetCode();
                  if (widget.nearByShopList.Offer_Code!.isNotEmpty) {
                    showBottomSheet();
                  } else {
                    launch(widget.nearByShopList.redeem!);
                  }
                },
                textColor: GlobalVariables.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  showBottomSheet() {
    return showModalBottomSheet(
        backgroundColor: Colors.transparent,
        context: context,
        builder: (BuildContext context) {
          return Stack(
            alignment: Alignment.topCenter,
            children: <Widget>[
              Container(
                width: 50,
                height: 10,
                decoration: boxDecoration(
                    color: GlobalVariables.transparent,
                    radius: 16,
                    bgColor: GlobalVariables.lightGray),
              ),
              SingleChildScrollView(
                child: Container(
                  margin: EdgeInsets.only(top: 30),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30)),
                      color: GlobalVariables.white),
                  // height: MediaQuery.of(context).size.width * 1.0,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(
                          height: 16,
                        ),
                        text(
                          widget.nearByShopList.Title,
                          fontSize: GlobalVariables.textSizeLargeMedium,
                          textColor: GlobalVariables.primaryColor,
                          maxLine: 3,
                          fontWeight: FontWeight.w500,
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        longText(widget.nearByShopList.short_description,
                            islongTxt: true,
                            textColor: GlobalVariables.grey,
                            fontSize: GlobalVariables.textSizeSMedium),
                        SizedBox(
                          height: 16,
                        ),
                        widget.nearByShopList.Offer_Code!.isNotEmpty
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Flexible(
                                    flex: 6,
                                    child: DottedBorder(
                                      child: Container(
                                        //decoration: boxDecoration(radius: 1.0,color: GlobalVariables.lightGray),
                                        padding: EdgeInsets.all(8.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Container(
                                                  padding: EdgeInsets.all(8),
                                                  child: text(
                                                      widget.nearByShopList
                                                          .Offer_Code,
                                                      textColor:
                                                          GlobalVariables.black,
                                                      fontSize: GlobalVariables
                                                          .textSizeSMedium,
                                                      maxLine: 1,
                                                      fontWeight:
                                                          FontWeight.w500)),
                                            ),
                                            SizedBox(
                                              width: 16,
                                            ),
                                            InkWell(
                                                onTap: () {
                                                  FlutterClipboard.copy(widget
                                                          .nearByShopList
                                                          .Offer_Code!)
                                                      .then((value) {
                                                    GlobalFunctions.showToast(
                                                        "Copied to Clipboard");
                                                  });
                                                },
                                                child: AppIcon(
                                                  Icons.content_copy,
                                                  iconColor:
                                                      GlobalVariables.skyBlue,
                                                  iconSize: 24,
                                                ))
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  /*Flexible(
                                flex: 2,
                                child: text('Copy',textColor: GlobalVariables.skyBlue,fontWeight: FontWeight.w500,fontSize: GlobalVariables.textSizeMedium)
                            )*/
                                ],
                              )
                            : SizedBox(),
                        SizedBox(
                          height: 16,
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width,
                          child: TextButton(
                              onPressed: () {
                                launch(widget.nearByShopList.redeem!);
                              },
                             
                              child: text('Redeem',
                                  textColor: GlobalVariables.white,
                                  fontSize: GlobalVariables.textSizeSMedium,
                                  fontWeight: FontWeight.w500)),
                        )
                      ],
                    ),
                  ),
                ),
              )
            ],
          );
        });
  }

  Future<void> insertUserInfoOnExclusiveGetCode() async {
    String userName = await GlobalFunctions.getDisplayName();
    String societyId = await GlobalFunctions.getSocietyId();
    String societyName = await GlobalFunctions.getSocietyName();
    String block = await GlobalFunctions.getBlock();
    String flat = await GlobalFunctions.getFlat();
    String mobile = await GlobalFunctions.getMobile();
    String address = await GlobalFunctions.getSocietyAddress();

    Provider.of<NearByShopResponse>(context, listen: false)
        .insertUserInfoOnExclusiveGetCode(societyName, block + ' ' + flat,
            mobile, address, userName, societyId, widget.nearByShopList.Id);
  }
}
