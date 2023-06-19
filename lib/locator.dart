import 'package:get/get.dart';
import 'package:get_it/get_it.dart';

import 'controllers/notification_controller.dart';

GetIt locator = GetIt.instance;

Future setupLocator() async {

  Get.put(AppNotificationController(), permanent: true);
}
