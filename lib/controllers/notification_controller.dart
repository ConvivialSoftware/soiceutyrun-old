import 'package:get/get.dart';
import 'package:society_gatepass/society_gatepass.dart';
import 'package:societyrun/GlobalClasses/GlobalVariables.dart';

import '../GlobalClasses/GlobalFunctions.dart';

class AppNotificationController extends GetxController {
  RxBool isBusy = false.obs;

  bool shouldLogout = false;

  initGatepass() async {
    final username = await GlobalFunctions.getUserName();
    final block = await GlobalFunctions.getBlock();
    final flatNo = await GlobalFunctions.getFlat();
    final societyId = await GlobalFunctions.getSocietyId();
    final userId = await GlobalFunctions.getUserId();

    SocietyGatepass.initialize(
        theme: GatepassTheme(
          primaryColor: GlobalVariables.primaryColor,
          secondaryColor: GlobalVariables.primaryColor,
          accentColor: GlobalVariables.AccentColor,
        ),
        myGateOptions: MyGateOptions(
            block: block,
            flatNo: flatNo,
            societyId: societyId,
            userId: userId,
            username: username));
  }

  initGatepassNotifications() async {
    final username = await GlobalFunctions.getUserName();
    SocietyGatepass.initializeNotificationOptions(NotificationOptions(
        username: username,
        channelKey: "GatepassCallChannel",
        channelName: "GatepassCallChannel",
        channelGroupName: "GatepassCallChannel_group",
        channelGroupKey: "GatepassCallChannel_group",
        soundSourceDialog: "assets/audio/res_alert.mp3",
        soundSource: "resource://raw/res_alert"));
  }

  listenNotificationActions() async {
    await initGatepass();
    Get.find<GatepassController>().startListenNotificaionActions();
  }

  Future<void> updateFCMToken(String token) async {
    // Dio dio = Dio();
    // RestClient restClient = RestClient(dio);

    // String societyId = await GlobalFunctions.getSocietyId();
    // String userId = await GlobalFunctions.getUserId();

    // await restClient.updateGcmToken(societyId, userId, token);
  }

  showNotificationPermission() async {
    final bool isAllowed =
        await GlobalFunctions.isNotificationPermissionAllowed();

    if (!isAllowed) {
      Get.find<GatepassController>().showNotificationPermission(
          permissionAlertTitle:
              'Societyrun needs your permission to send notifications');
      await GlobalFunctions.setNotificationPermissionAllowed();
    }
  }

  refreshToken() {}

  showTestNotification() =>
      Get.find<GatepassController>().showTestNotification();

  goToMyGate() {
    initGatepass();
    final isAdmin = false;
    Get.to(() => MyGatePage(
        pageName: 'My Gate', isAdmin: isAdmin, type: 'helper', vid: '2548'));
  }

  goToStaffCategory(String roleName) {
    Get.put(MyGateController());
    Get.to(() => StaffCategoryPage(
          roleName: roleName,
        ));
  }

  goToStaffTab({String? type}) {
    initGatepass();
    final isAdmin = false;
    Get.to(() => MyGatePage(
        pageName: 'My Gate', isAdmin: isAdmin, type: type?? 'Helper', vid: '2548'));
    Get.put(MyGateController()).setSelectedTab(1);
  }

  goToStaffDetail(Staff staff) async {
    initGatepass();
    await Get.to(() => StaffDetailPage(
          staff: staff,
        ));
  }
}
