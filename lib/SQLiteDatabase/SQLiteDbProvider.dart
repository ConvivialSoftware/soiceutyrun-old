import 'dart:async';
import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:societyrun/GlobalClasses/GlobalFunctions.dart';
import 'package:societyrun/GlobalClasses/GlobalVariables.dart';
import 'package:societyrun/Models/DBNotificatioPayload.dart';
import 'package:sqflite/sqflite.dart';

class SQLiteDbProvider {
  SQLiteDbProvider._();

  static final SQLiteDbProvider db = SQLiteDbProvider._();
  static Database? _database;
  static final _databaseName = "SocietyRun.db";
  static final _databaseVersion = 1;
  static final _notificationTableName = 'Notification';

  Future<Database> get getDatabase async {
    if (_database != null) return _database!;
    _database = await initDataBase();
    print('DB : ' + 'created');
    return _database!;
  }

  Future<void> getDataBaseInstance() async {
    print('DB : ' + 'Call to create Instance Variable of database');
    await SQLiteDbProvider.db.getDatabase;
    deleteNotificationTableAfter60Days();
  }

  initDataBase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    print('DB : ' + 'get Database Path');
    String path = join(documentsDirectory.path, _databaseName);
    print('DB Path >>>> ' + path);
    return await openDatabase(path,
        version: _databaseVersion, onOpen: (db) {}, onCreate: _onCreate);
  }

  FutureOr<void> _onCreate(Database db, int version) async {
    print('DB : ' + _notificationTableName + ' table creation');
    await db.execute("CREATE TABLE " +
        _notificationTableName +
        "  (nid TEXT PRIMARY KEY,"
            "ID TEXT,"
            "uid TEXT,"
            "TYPE TEXT,"
            "Visitor_type TEXT,"
            "DATE_TIME TEXT,"
            "FROM_VISITOR TEXT,"
            "IMAGE TEXT,"
            "VID TEXT,"
            "VISITOR_NAME TEXT,"
            "body TEXT,"
            "title TEXT,"
            "CONTACT TEXT,"
            "read INTEGER)");
  }

  getUnReadNotification(String userId) async {
    final db = await getDatabase;
    List<Map> result = await db.query(_notificationTableName,
        columns: [
          'nid',
          'ID',
          'uid',
          'TYPE',
          'Visitor_type',
          'DATE_TIME',
          'FROM_VISITOR',
          'IMAGE',
          'VISITOR_NAME',
          'body',
          'title',
          'CONTACT',
          'read',
          'VID',
        ],
        where: 'uid='+"'"+userId+"'", orderBy: 'DATE_TIME DESC');
    if (result.length > 0) {
      print('DB : '+result.toString());
      return result;
    }
    return null;
  }

  insertUnReadNotification(DBNotificationPayload _dbNotificationPayload) async {
    print('DB : _dbNotificationPayload >>>> ' + _dbNotificationPayload.toJson().toString());
    //String userId = await GlobalFunctions.getUserId();
    GlobalFunctions.getUserId().then((value) async{
      _dbNotificationPayload.uid=value;
      print('DB : getUserId >>>> ' + value.toString());
      print('DB : DBNotificationPayload >>>> ' + _dbNotificationPayload.toJson().toString());
      final db = await getDatabase;
      var result = await db.insert(
        _notificationTableName,
        _dbNotificationPayload.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      print('DB : ' + result.toString());
      print('DB : ' + 'Inserted Successfully');

      getNotificationTableCount(value);
      return result;
    });

   /* print('DB : userId >>>> ' + userId.toString());
    _dbNotificationPayload.uid=userId;
    print('DB : DBNotificationPayload >>>> ' + _dbNotificationPayload.toJson().toString());
    final db = await getDatabase;
    *//*var result = await db.rawInsert(
        "INSERT Into "+_notificationTableName+" (ID,TYPE, Visitor_type, DATE_TIME, FROM_VISITOR, IMAGE,"
            "VID,VISITOR_NAME,body,title,CONTACT,read)"
            " VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
        [_dbNotificationPayload.ID,_dbNotificationPayload.TYPE,_dbNotificationPayload.Visitor_type,
        _dbNotificationPayload.DATE_TIME,_dbNotificationPayload.FROM_VISITOR,_dbNotificationPayload.IMAGE,
        _dbNotificationPayload.VISITOR_NAME,_dbNotificationPayload.body,_dbNotificationPayload.title,
        _dbNotificationPayload.CONTACT,_dbNotificationPayload.read]
    );*//*
   */
  }

  getNotificationTableCount(String userId) async {
    final db = await getDatabase;
    int? count = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM ' + _notificationTableName+' WHERE read=0 and uid='+"'"+userId+"'"));
    print('Count : ' + count.toString());
    GlobalVariables.notificationCounterValueNotifer.value = count!;
    GlobalVariables.notificationCounterValueNotifer.notifyListeners();
    print('notificationCounterValueNotifer : ' +
        GlobalVariables.notificationCounterValueNotifer.value.toString());
    return count;
  }

  deleteFromNotificationTable(String uuid) async {
    final db = await getDatabase;
    int result = await db.rawDelete("DELETE FROM "+_notificationTableName+" WHERE nid = ?", [uuid]);
    print('DB : ' + result.toString());
    print('DB : ' + 'Delete Successfully');
    String userId = await GlobalFunctions.getUserId();
    getNotificationTableCount(userId);
    return result;
  }

  deleteNotificationTableAfter60Days() async {
    final db = await getDatabase;
    int result = await db.rawDelete("DELETE FROM "+_notificationTableName+" WHERE DATE_TIME <= date('now','-60 day')");
    print('DB : ' + result.toString());
    print('DB : ' + 'Delete Successfully');
    String userId = await GlobalFunctions.getUserId();
    getNotificationTableCount(userId);
    return result;
  }

  updateReadNotification(DBNotificationPayload dbNotificationPayload) async {
    final db = await getDatabase;
    var result = await db.update(
        _notificationTableName, dbNotificationPayload.toJson(), where: "nid = ?", whereArgs: [dbNotificationPayload.nid]
    );
    String userId = await GlobalFunctions.getUserId();
    getNotificationTableCount(userId);
    return result;
  }

  updateUnReadNotification() async {
    final db = await getDatabase;
    print('updateUnReadNotification');
    var result = await db.rawUpdate("UPDATE "+_notificationTableName+" SET read = 1 ");
    String userId = await GlobalFunctions.getUserId();
    getNotificationTableCount(userId);
    print('success read 1');
    return result;
  }

}
