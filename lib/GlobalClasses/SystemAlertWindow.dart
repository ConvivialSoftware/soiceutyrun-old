/*
import 'package:flutter/material.dart';
import 'package:system_alert_window/system_alert_window.dart';

class SystemAlertOverlayWindow{



  static void callBackFunction(String tag) {
    print(tag);
    switch (tag) {
      case "simple_button":
      case "updated_simple_button":
        SystemAlertWindow.closeSystemWindow(prefMode: SystemWindowPrefMode.OVERLAY);
        break;
      case "focus_button":
        print("Focus button has been called");
        break;
      default:
        print("OnClick event of $tag");
    }
  }

  static showOverLayWindow(bool _isShowingWindow,SystemWindowPrefMode prefMode){
    if (!_isShowingWindow) {
      SystemWindowHeader header = SystemWindowHeader(
          title: SystemWindowText(text: "Incoming Call", fontSize: 10, textColor: Colors.black45),
          padding: SystemWindowPadding.setSymmetricPadding(12, 12),
          subTitle: SystemWindowText(text: "9898989899", fontSize: 14, fontWeight: FontWeight.BOLD, textColor: Colors.black87),
          decoration: SystemWindowDecoration(startColor: Colors.grey[100]),
          button: SystemWindowButton(text: SystemWindowText(text: "Personal", fontSize: 10, textColor: Colors.black45), tag: "personal_btn"),
          buttonPosition: ButtonPosition.TRAILING);
      SystemWindowBody body = SystemWindowBody(
        rows: [
          EachRow(
            columns: [
              EachColumn(
                text: SystemWindowText(text: "Some body", fontSize: 12, textColor: Colors.black45),
              ),
            ],
            gravity: ContentGravity.CENTER,
          ),
          EachRow(columns: [
            EachColumn(
                text: SystemWindowText(text: "Long data of the body", fontSize: 12, textColor: Colors.black87, fontWeight: FontWeight.BOLD),
                padding: SystemWindowPadding.setSymmetricPadding(6, 8),
                decoration: SystemWindowDecoration(startColor: Colors.black12, borderRadius: 25.0),
                margin: SystemWindowMargin(top: 4)),
          ], gravity: ContentGravity.CENTER),
          EachRow(
            columns: [
              EachColumn(
                text: SystemWindowText(text: "Notes", fontSize: 10, textColor: Colors.black45),
              ),
            ],
            gravity: ContentGravity.LEFT,
            margin: SystemWindowMargin(top: 8),
          ),
          EachRow(
            columns: [
              EachColumn(
                text: SystemWindowText(text: "Some random notes.", fontSize: 13, textColor: Colors.black54, fontWeight: FontWeight.BOLD),
              ),
            ],
            gravity: ContentGravity.LEFT,
          ),
        ],
        padding: SystemWindowPadding(left: 16, right: 16, bottom: 12, top: 12),
      );
      SystemWindowFooter footer = SystemWindowFooter(
          buttons: [
            SystemWindowButton(
              text: SystemWindowText(text: "Simple button", fontSize: 12, textColor: Color.fromRGBO(250, 139, 97, 1)),
              tag: "simple_button",
              padding: SystemWindowPadding(left: 10, right: 10, bottom: 10, top: 10),
              width: 0,
              height: SystemWindowButton.WRAP_CONTENT,
              decoration: SystemWindowDecoration(startColor: Colors.white, endColor: Colors.white, borderWidth: 0, borderRadius: 0.0),
            ),
            SystemWindowButton(
              text: SystemWindowText(text: "Focus button", fontSize: 12, textColor: Colors.white),
              tag: "focus_button",
              width: 0,
              padding: SystemWindowPadding(left: 10, right: 10, bottom: 10, top: 10),
              height: SystemWindowButton.WRAP_CONTENT,
              decoration: SystemWindowDecoration(
                  startColor: Color.fromRGBO(250, 139, 97, 1), endColor: Color.fromRGBO(247, 28, 88, 1), borderWidth: 0, borderRadius: 30.0),
            )
          ],
          padding: SystemWindowPadding(left: 16, right: 16, bottom: 12),
          decoration: SystemWindowDecoration(startColor: Colors.white),
          buttonsPosition: ButtonPosition.CENTER);
      SystemAlertWindow.showSystemWindow(
          height: 230,
          header: header,
          body: body,
          footer: footer,
          margin: SystemWindowMargin(left: 8, right: 8, top: 200, bottom: 0),
          gravity: SystemWindowGravity.TOP,
          notificationTitle: "Incoming Call",
          notificationBody: "+1 646 980 4741",
          prefMode: prefMode
      );
    }
  }

}
*/
