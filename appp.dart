import 'dart:convert';
// import 'dart:html_common';
import 'dart:io';
import 'package:path/path.dart' as p;

class Student{
  int id;
  String name;
  String phone;

  Student(this.id, this.name, this.phone);

  Map<String, dynamic> toJson(){
    return{
      'id' : id,
      'name': name,
      'phone': phone,
    };
  }
  static Student fromJson(Map<String,dynamic> json) {
    return Student(json['id'], json['name'], json['phone']);
  }

  @override
  String toString() {
    return 'ID: $id, Name: $name, Phone: $phone';
  }
}
void main() async{
  //DN thong tin file json
  const String fileName = 'students.json';
  final String directoryPath = p.join(Directory.current.path,'data');
  final Directory directory = Directory(directoryPath);

  if(!await directory.exists()){
    await directory.create(recursive: true);
  }
  final String filePath = p.join(directoryPath,fileName);
  List<Student> studentList = await loadStudents(filePath);

  while(true){
    print('''
        Menu:
        1. Thêm sinh viên 
        2. Hiển thị thông tin sinh viên 
        3. Thoát 
        Mời bạn chọn:
        ''');
    String? choice = stdin.readLineSync();

    switch(choice){
      case '1':
        await addStudent(filePath, studentList);
        break;
      case '2':
        displayStudent(studentList);
        break;
      case '3':
        print('Thoát chương trình');
        exit(0);
      default:
        print('Vui lòng chọn lại!');

    }
  }

}
Future<List<Student>> loadStudents(String filePath) async{
  if(!File(filePath).existsSync()){
    await File(filePath).create();
    await File(filePath).writeAsString(jsonEncode([]));
    return[];
  }

  String content = await File(filePath).readAsString();
  List<dynamic> jsonData = jsonDecode(content);

  return jsonData.map((json) => Student.fromJson(json)).toList();

}
Future<void> addStudent(String filePath, List<Student> studentList) async{
  //Tao dt sinh vien
  // Student student = Student(1, 'Hai', '09123456');
  print('Nhập tên sinh viên: ');
  String? name = stdin.readLineSync();
  if(name == null || name.isEmpty){
    print('Tên không hợp lệ');
    return;
  }
  print('Nhập phone sinh viên: ');
  String? phone = stdin.readLineSync();
  if(phone == null || phone.isEmpty){
    print('Số điện thoại không hợp lệ');
    return;
  }

  int id = studentList.isEmpty ? 1: studentList.last.id +1;
  Student student = Student(id, name, phone);

  //Them sv vao List
  studentList.add(student);
  //them List vao json file
  await saveStudents(filePath, studentList);

}

Future<void> saveStudents(String filePath, List<Student> studentList) async{
  String jsonContent = jsonEncode(studentList.map((s) => s.toJson()).toList());
  await File(filePath).writeAsString(jsonContent);//ghi vao file json;

}

void displayStudent(List<Student> studentList){
  if(studentList.isEmpty){
    print('Danh sách sinh viên trống: ');
  }else{
    print('Danh sách sinh viên: ');
    for(var student in studentList){
      print(student);
    }
  }
}