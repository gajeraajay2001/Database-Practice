import 'package:database_practice_lite/model/student_model.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DBHelper {
  DBHelper._();
  // ignore: non_constant_identifier_names
  String TABLE = "student";
  var database;

  Future<Database> initDB() async {
    if (database == null) {
      database = openDatabase(
        join(await getDatabasesPath(), "student_db02.db"),
        version: 1,
        onCreate: (db, version) {
          String sql =
              "CREATE TABLE $TABLE(id INTEGER, name TEXT, age INTEGER,PRIMARY KEY('id' AUTOINCREMENT))";
          return db.execute(sql);
        },
      );
      return database;
    }
    return database;
  }

  Future<int> insertData(Student s) async {
    var db = await initDB();
    String sql = "INSERT INTO $TABLE(name,age)VALUES('${s.name}',${s.age})";
    return await db.rawInsert(sql);
  }

  Future<List<Student>> getAllStudents() async {
    var db = await initDB();
    String sql = "SELECT * FROM $TABLE";
    List<Map<String, dynamic>> res = await db.rawQuery(sql);
    List<Student> response =
        res.map((record) => Student.fromMap(record)).toList();
    return response;
  }

  Future<int> deleteStudent(int? id) async {
    var db = await initDB();
    String query = "DELETE FROM $TABLE WHERE id=$id";
    int deletedId = await db.rawDelete(query);
    return deletedId;
  }

  // Future<int> updateStudent(int id, Student s) async {
  //   var db = await initDB();
  //
  //   String query =
  //       "UPDATE $TABLE SET name=${s.name}, age=${s.age} WHERE id=$id";
  //   int updatedId = await db.rawUpdate(query);
  //   return updatedId;
  // }

  Future<int> updateStudent(
      {required String? name, required int? age, required int? id}) async {
    var db = await initDB();
    String sql = "UPDATE $TABLE SET name = '$name', age = $age WHERE id = $id";
    return db.rawUpdate(sql);
  }

  Future<List<Student>> getStudentBuName({required String? data}) async {
    var db = await initDB();
    String sql =
        "SELECT * FROM $TABLE WHERE name LIKE '%$data%' OR age LIKE '%$data%'";
    List<Map<String, dynamic>> res = await db.rawQuery(sql);
    List<Student> response =
        res.map((record) => Student.fromMap(record)).toList();
    return response;
  }
}

DBHelper dbh = DBHelper._();
