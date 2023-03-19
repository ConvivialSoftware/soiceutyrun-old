//import 'package:amazon_cognito_identity_dart/cognito.dart';

//import 'package:amazon_cognito_identity_dart/sig_v4.dart';

/*
class AWSClient {
  String accessKeyId = 'AKIAX7HUJXO2LSCDTFL5'; // replace with your own access key
  String secretKeyId = 'Gk7VCniwnzmKwGPQAdILOlUf1Gu5qFDKNqxiybVX'; // replace with your own secret key
  String region = 'ap-south-1'; // replace with your account's region name
  String bucketname = "upload-download-image"; // replace with your S3's bucket name
  //String s3Endpoint = 'http://upload-download-image.s3-website.ap-south-1.amazonaws.com'; // update the endpoint url for your bucket
  String s3Endpoint = 'https://upload-download-image.s3.ap-south-1.amazonaws.com/'; // update the endpoint url for your bucket

  //String host = 's3.ap-southeast-1.amazonaws.com';
  String host = 'upload-download-image.s3.ap-south-1.amazonaws.com';
  String service = 's3';
  String serverName = 'amazonaws.com';
  String _localPath;

  String _awsUserPoolId = 'ap-south-1_Jkr5TwBYb';
  String _awsClientId = '6lelfipk8v6sj6anphnggm6hpv';

  String _identityPoolId = 'ap-south-1:7dbe6b7e-b49e-448e-b9a1-5130dbd3558f';

*/
/*
  final host = 's3.ap-southeast-1.amazonaws.com';
  final region = 'ap-southeast-1';
  final service = 's3';
  final key =
      'my-s3-bucket/ap-southeast-1:xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/squre-cinnamon.jpg';
  final payload = SigV4.hashCanonicalRequest('');
  final datetime = SigV4.generateDatetime();

*//*


//s3://upload-download-image/uploads/
  Future<dynamic> uploadData(String folderName, String fileName, Uint8List data) async {
    final length = data.length;

    print('data length : '+length.toString());
    final uri = Uri.parse(s3Endpoint);
    final req = http.MultipartRequest("POST", uri);
    final multipartFile = http.MultipartFile('file', http.ByteStream.fromBytes(data), length, filename: fileName);

    print('uri : '+ uri.toString());
    print('multipartFile : '+ multipartFile.toString());
    final policy = Policy.fromS3PresignedPost(folderName+'/'+fileName, bucketname, accessKeyId, 15, length, region: region);
    final key = SigV4.calculateSigningKey(secretKeyId, policy.datetime, region, 's3');
    final signature = SigV4.calculateSignature(key, policy.encode());
    print('signature : '+ signature.toString());
    req.files.add(multipartFile);
    req.fields['key'] = policy.key;
    req.fields['acl'] = 'public-read';
    req.fields['X-Amz-Credential'] = policy.credential;
    req.fields['X-Amz-Algorithm'] = 'AWS4-HMAC-SHA256';
    req.fields['X-Amz-Date'] = policy.datetime;
    req.fields['Policy'] = policy.encode();
    req.fields['X-Amz-Signature'] = signature;
    print('req.fields : '+ req.fields.toString());
    try {
      final res = await req.send();
      print('res : '+ res.toString());

      await for (var value in res.stream.transform(utf8.decoder)) {
        print(value.toString());

        return value;
      }
    } catch (e) {
      print(e.toString());

      return e;
    }
  }



  downloadData(String folderName,String fileName) async {
    getLocalPath();
    final _userPool = CognitoUserPool(_awsUserPoolId, _awsClientId);

    final _cognitoUser = CognitoUser('poonam.convivial@gmail.com', _userPool);
    final authDetails =
    AuthenticationDetails(username: 'poonam.convivial@gmail.com', password: 'Poonam7065');

    CognitoUserSession _session;
    try {
      _session = await _cognitoUser.authenticateUser(authDetails);
    } catch (e) {
      print(e);
      return;
    }

    final _credentials = CognitoCredentials(_identityPoolId, _userPool);
    await _credentials.getAwsCredentials(_session.getIdToken().getJwtToken());

   // final key = 'my-s3-bucket/'+_identityPoolId+'/uploads/NOC.pdf';
    final key = folderName+"/"+fileName;

    //https://upload-download-image.s3.ap-south-1.amazonaws.com/uploads/NOC.pdf

    final payload = SigV4.hashCanonicalRequest('');
    final datetime = SigV4.generateDatetime();
    final canonicalRequest = '''GET
${'/$key'.split('/').map((s) => Uri.encodeComponent(s)).join('/')}

host:$host
x-amz-content-sha256:$payload
x-amz-date:$datetime
x-amz-security-token:${_credentials.sessionToken}

host;x-amz-content-sha256;x-amz-date;x-amz-security-token
$payload''';
    final credentialScope =
    SigV4.buildCredentialScope(datetime, region, service);
    final stringToSign = SigV4.buildStringToSign(datetime, credentialScope,
        SigV4.hashCanonicalRequest(canonicalRequest));
    final signingKey = SigV4.calculateSigningKey(
        _credentials.secretAccessKey, datetime, region, service);
    final signature = SigV4.calculateSignature(signingKey, stringToSign);

    final authorization = [
      'AWS4-HMAC-SHA256 Credential=${_credentials.accessKeyId}/$credentialScope',
      'SignedHeaders=host;x-amz-content-sha256;x-amz-date;x-amz-security-token',
      'Signature=$signature',
    ].join(',');
//https://upload-download-image.s3.ap-south-1.amazonaws.com/uploads/NOC.pdf
    final uri = Uri.https(host, key);
    print(uri.toString());
    http.Response response;
    try {
      response = await http.get(uri, headers: {
        'Authorization': authorization,
        'x-amz-content-sha256': payload,
        'x-amz-date': datetime,
        'x-amz-security-token': _credentials.sessionToken,
      });
    } catch (e) {
      print(e);
      return;
    }

    File file = File(_localPath+'/'+fileName);

    try {
      await file.writeAsBytes(response.bodyBytes);
    } catch (e) {
      print(e.toString());
      return;
    }

    print('complete!');

  */
/*
   // final key = https://upload-download-image.s3.ap-south-1.amazonaws.com/uploads/NOC.pdf;
    //final key = bucketname+'/'+host+'/'+folderName+'/'+fileName;

    final key = folderName+'/'+fileName;
    print('Key : '+key.toString());
    final payload = SigV4.hashCanonicalRequest('');
    final datetime = SigV4.generateDatetime();
    final canonicalRequest = '''GET
            ${'/$key'.split('/').map((s) => Uri.encodeComponent(s)).join('/')}
            host:$host
            x-amz-content-sha256:$payload
            x-amz-date:$datetime
            host;x-amz-content-sha256;x-amz-date;x-amz-security-token
            $payload''';

    final credentialScope =
    SigV4.buildCredentialScope(datetime, region, service);
    final stringToSign = SigV4.buildStringToSign(datetime, credentialScope,
        SigV4.hashCanonicalRequest(canonicalRequest));
    final signingKey = SigV4.calculateSigningKey(
        secretKeyId, datetime, region, service);
    final signature = SigV4.calculateSignature(signingKey, stringToSign);

    final authorization = [
      'AWS4-HMAC-SHA256 Credential=$accessKeyId/$credentialScope',
      'SignedHeaders=host;x-amz-content-sha256;x-amz-date;x-amz-security-token',
      'Signature=$signature',
    ].join(',');


    final uri = Uri.https(bucketname+"."+host, key);
    http.Response response;
    try {
      response = await http.get(uri, headers: {
        'Authorization': authorization,
        'x-amz-content-sha256': payload,
        'x-amz-date': datetime,
        //'x-amz-security-token': _credentials.sessionToken,
      });

      File file = File(path.join(_localPath,fileName));

      await file.writeAsBytes(response.bodyBytes);

      print('successfully write objects');

    } catch (e) {
      print(e);
      return;
    }*//*


  }

  void getLocalPath() {
    GlobalFunctions.localPath().then((value) {
      print("localPath : " + value.toString());
      _localPath = value;
    });
  }
}


*/


/*

class Policy {
  String expiration;
  String region;
  String bucket;
  String key;
  String credential;
  String datetime;
  int maxFileSize;

  Policy(this.key, this.bucket, this.datetime, this.expiration, this.credential,
      this.maxFileSize,
      {this.region = 'us-east-1'});

  factory Policy.fromS3PresignedPost(
      String key,
      String bucket,
      String accessKeyId,
      int expiryMinutes,
      int maxFileSize, {
        String region,
      }) {
    final datetime = SigV4.generateDatetime();
    final expiration = (DateTime.now())
        .add(Duration(minutes: expiryMinutes))
        .toUtc()
        .toString()
        .split(' ')
        .join('T');
    final cred =
        '$accessKeyId/${SigV4.buildCredentialScope(datetime, region, 's3')}';
    final p = Policy(key, bucket, datetime, expiration, cred, maxFileSize,
        region: region);
    return p;
  }

  String encode() {
    final bytes = utf8.encode(toString());
    return base64.encode(bytes);
  }

  @override
  String toString() {

    print('''
{ "expiration": "${this.expiration}",
  "conditions": [
    {"bucket": "${this.bucket}"},
    ["starts-with", "\$key", "${this.key}"],
    {"acl": "public-read"},
    ["content-length-range", 1, ${this.maxFileSize}],
    {"x-amz-credential": "${this.credential}"},
    {"x-amz-algorithm": "AWS4-HMAC-SHA256"},
    {"x-amz-date": "${this.datetime}" }
  ]
}
''');

    return '''
{ "expiration": "${this.expiration}",
  "conditions": [
    {"bucket": "${this.bucket}"},
    ["starts-with", "\$key", "${this.key}"],
    {"acl": "public-read"},
    ["content-length-range", 1, ${this.maxFileSize}],
    {"x-amz-credential": "${this.credential}"},
    {"x-amz-algorithm": "AWS4-HMAC-SHA256"},
    {"x-amz-date": "${this.datetime}" }
  ]
}
''';
  }
}*/
