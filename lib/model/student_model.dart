class Student {
  int? id;
  final String name;
  final int age;
  Student({
    this.id,
    required this.name,
    required this.age,
  });

  static Student fromMap(Map<String, dynamic> map) {
    return Student(
      id: map["id"],
      name: map["name"],
      age: map["age"],
    );
  }
}
