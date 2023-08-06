import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:societyrun/Activities/AddNearByShop.dart';
import 'package:societyrun/Activities/AddNewMember.dart';
import 'package:societyrun/Activities/AddSociety.dart';
import 'package:societyrun/Activities/BanquetBooking.dart';
import 'package:societyrun/Activities/Cab.dart';
import 'package:societyrun/Activities/Delivery.dart';
import 'package:societyrun/Activities/Discover.dart';
import 'package:societyrun/Activities/ExpectedVisitor.dart';
import 'package:societyrun/Activities/Facilities.dart';
import 'package:societyrun/Activities/GuestOthers.dart';
import 'package:societyrun/Activities/HelpDesk.dart';
import 'package:societyrun/Activities/HomeService.dart';
import 'package:societyrun/Activities/Ledger.dart';
import 'package:societyrun/Activities/MyComplex.dart';
import 'package:societyrun/Activities/MyGate.dart';
import 'package:societyrun/Activities/MyUnit.dart';
import 'package:societyrun/Activities/OtpWithMobile.dart';
import 'package:societyrun/Activities/RaiseNewTicket.dart';
import 'package:societyrun/Activities/Register.dart';
import 'package:societyrun/Activities/ViewBill.dart';
import 'package:societyrun/GlobalClasses/GlobalVariables.dart';
import 'AppLanguage.dart';

class ChangeLanguageNotifier extends StatelessWidget {

   String? title,name;

  ChangeLanguageNotifier.title(this.title);

  ChangeLanguageNotifier.titleName(this.title,this.name);

  @override
  Widget build(BuildContext context) {
    // GlobalFunctions.showToast("ChangeLanguageNotifier page");
    AppLanguage appLanguage = AppLanguage();
    return Builder(
      builder: (context) => ChangeNotifierProvider<AppLanguage>(
          //builder : (BuildContext context) => appLanguage,
          create: (BuildContext context) => appLanguage,
          child: Consumer<AppLanguage>(builder: (context, model, child) {
            print('model:' + model.toString());
            print('model applocale:' + model.appLocal.toString());
            return Container(
              child: Builder(builder: (context) => ChangeActivity(title,name)));
                //  home: ChangeActivity(title),
          })),
    );
  }
}

getIconButton(title, BuildContext context) {
  if (title != GlobalVariables.DashBoardPage) {
    return IconButton(
      icon: Icon(Icons.arrow_back, color: GlobalVariables.white),
      onPressed: () => Navigator.of(context).pop(),
    );
  } else {
    return;
  }
}

class ChangeActivity extends StatelessWidget {
  var title,name;

  ChangeActivity(this.title, this.name);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    //  GlobalFunctions.showToast("ChangeActivity page");
    return getWidget(title,name);
  }
}

getWidget(String title,String name) {
//  GlobalFunctions.showToast("getWidget page");
  switch (title) {
   /* case GlobalVariables.OTPPage:
      {
        return BaseOtp();
      }
      break;*/
     case GlobalVariables.OtpWithMobilePage:
      {
        return BaseOtpWithMobile();
      }
      break;
    /*case GlobalVariables.DashBoardPage:
      {
        return BaseDashBoard();
      }
      break;*/
    case GlobalVariables.RegisterPage:
      {
        return BaseRegister();
      }
      break;
    case GlobalVariables.AddSocietyPage:
      {
        return BaseAddSociety();
      }
      break;
    case GlobalVariables.MyUnitPage:
      {
        return BaseMyUnit(null);
      }
      break;
    case GlobalVariables.MyComplexPage:
      {
        return BaseMyComplex(null);
      }
      break;
    case GlobalVariables.MyDiscoverPage:
      {
        return BaseDiscover(null);
      }
      break;
    case GlobalVariables.CreateClassifiedListingPage:
      {
        return null;
      }
      break;

    case GlobalVariables.AddNearByShopPage:
      {
        return BaseAddNearByShop();
      }
      break;
    case GlobalVariables.MyFacilitiesPage:
      {
        return BaseFacilities();
      }
      break;
    case GlobalVariables.BanquetBookingPage:
      {
        return BaseBanquetBooking();
      }
      break;
    case GlobalVariables.MyGatePage:
      {
        return BaseMyGate(null,null);
      }
      break;
    case GlobalVariables.HelpDeskPage:
      {
        return BaseHelpDesk(false);
      }
      break;
    case GlobalVariables.RaiseNewTicketPage:
      {
        return BaseRaiseNewTicket();
      }
      break;
    case GlobalVariables.AdminPage:
      {
        return BaseMyUnit(null);
      }
      break;
    case GlobalVariables.MorePage:
      {
        return BaseMyUnit(null);
      }
      break;
    case GlobalVariables.ExpectedVisitorPage:
      {
        return BaseExpectedVisitor();
      }
      break;
    case GlobalVariables.CabPage:
      {
        return BaseCab();
      }
      break;
    case GlobalVariables.DeliveryPage:
      {
        return BaseDelivery();
      }
      break;
    case GlobalVariables.HomeServicePage:
      {
        return BaseHomeService();
      }
      break;
    case GlobalVariables.ListOfHomeServicePage:
      {
        return null;
      }
      break;

    case GlobalVariables.DescriptionOfHomeServicePage:
      {
        return null;
      }
      break;
    case GlobalVariables.GuestOthersPage:
      {
        return BaseGuestOthers();
      }
      break;
    case GlobalVariables.AddNewMemberPage:
      {
        return BaseAddNewMember(name);
      }
      break;
    case GlobalVariables.LedgerPage:
      {
        return BaseLedger(null,null);
      }
      break;
    case GlobalVariables.ViewBillPage:
      {
        return BaseViewBill(null,null,null,null,null);
      }
      break;
    /*default:
      {
        return BaseDashBoard();
      }*/
  }
}
