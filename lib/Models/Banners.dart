import 'package:json_annotation/json_annotation.dart';

@JsonSerializable(
)
class Banners {
  String? IMAGE;
  String? Url;

  Banners({this.IMAGE, this.Url});


  factory Banners.fromJson(Map<String, dynamic> json){

    return Banners(
        IMAGE: json['IMAGE'],
        Url: json['Url']
    );
  }


}
