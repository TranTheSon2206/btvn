import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;

class Student {
  int id;
  String name;
  String phone;

  Student(this.id, this.name, this.phone);

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
    };
  }

  static Student fromJson(Map<String, dynamic> json) {
    return Student(json['id'], json['name'], json['phone']);
  }

  @override
  String toString() {
    return 'ID: $id, Name: $name, Phone: $phone';
  }
}

void main() async {
  // Định nghĩa thông tin file json
  const String fileName = 'students.json';
  final String directoryPath = p.join(Directory.current.path, 'data');
  final Directory directory = Directory(directoryPath);

  if (!await directory.exists()) {
    await directory.create(recursive: true);
  }
  final String filePath = p.join(directoryPath, fileName);
  List<Student> studentList = await loadStudents(filePath);

  while (true) {
    print('''
        Menu:
        1. Thêm sinh viên 
        2. Hiển thị thông tin sinh viên 
        3. Sửa thông tin sinh viên
        4. Xóa sinh viên
        5. Thoát 
        Mời bạn chọn:
        ''');
    String? choice = stdin.readLineSync();

    switch (choice) {
      case '1':
        await addStudent(filePath, studentList);
        break;
      case '2':
        displayStudent(studentList);
        break;
      case '3':
        await editStudent(filePath, studentList);
        break;
      case '4':
        await deleteStudent(filePath, studentList);
        break;
      case '5':
        print('Thoát chương trình');
        exit(0);
      default:
        print('Vui lòng chọn lại!');
    }
  }
}

Future<List<Student>> loadStudents(String filePath) async {
  if (!File(filePath).existsSync()) {
    await File(filePath).create();
    await File(filePath).writeAsString(jsonEncode([]));
    return [];
  }

  String content = await File(filePath).readAsString();
  List<dynamic> jsonData = jsonDecode(content);

  return jsonData.map((json) => Student.fromJson(json)).toList();
}

Future<void> addStudent(String filePath, List<Student> studentList) async {
  print('Nhập tên sinh viên: ');
  String? name = stdin.readLineSync();
  if (name == null || name.isEmpty) {
    print('Tên không hợp lệ');
    return;
  }
  print('Nhập phone sinh viên: ');
  String? phone = stdin.readLineSync();
  if (phone == null || phone.isEmpty) {
    print('Số điện thoại không hợp lệ');
    return;
  }

  int id = studentList.isEmpty ? 1 : studentList.last.id + 1;
  Student student = Student(id, name, phone);

  studentList.add(student);
  await saveStudents(filePath, studentList);
}

Future<void> editStudent(String filePath, List<Student> studentList) async {
  print('Nhập ID sinh viên cần sửa: ');
  String? idStr = stdin.readLineSync();
  if (idStr == null || idStr.isEmpty || int.tryParse(idStr) == null) {
    print('ID không hợp lệ');
    return;
  }
  int id = int.parse(idStr);
  Student? student = studentList.firstWhere((s) => s.id == id, orElse: () => null);

  if (student == null) {
    print('Không tìm thấy sinh viên với ID này');
    return;
  }

  print('Nhập tên mới (để trống để giữ nguyên): ');
  String? name = stdin.readLineSync();
  if (name != null && name.isNotEmpty) {
    student.name = name;
  }

  print('Nhập phone mới (để trống để giữ nguyên): ');
  String? phone = stdin.readLineSync();
  if (phone != null && phone.isNotEmpty) {
    student.phone = phone;
  }

  await saveStudents(filePath, studentList);
}

Future<void> deleteStudent(String filePath, List<Student> studentList) async {
  print('Nhập ID sinh viên cần xóa: ');
  String? idStr = stdin.readLineSync();
  if (idStr == null || idStr.isEmpty || int.tryParse(idStr) == null) {
    print('ID không hợp lệ');
    return;
  }
  int id = int.parse(idStr);
  studentList.removeWhere((s) => s.id == id);

  await saveStudents(filePath, studentList);
}

Future<void> saveStudents(String filePath, List<Student> studentList) async {
  String jsonContent = jsonEncode(studentList.map((s) => s.toJson()).toList());
  await File(filePath).writeAsString(jsonContent);
}

void displayStudent(List<Student> studentList) {
  if (studentList.isEmpty) {
    print('Danh sách sinh viên trống');
  } else {
    print('Danh sách sinh viên: ');
    for (var student in studentList) {
      print(student);
    }
  }
}
