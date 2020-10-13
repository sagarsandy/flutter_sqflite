class Student {
  int id;
  String name;
  int age;
  String bio;

  Student(
    this.id,
    this.name,
    this.age,
    this.bio,
  );

  Map<dynamic, dynamic> toMap() {
    var map = <String, dynamic>{
      'id': id,
      'name': name,
      'age': age,
      'bio': bio,
    };

    return map;
  }

  Student.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    name = map['name'];
    age = map['age'];
    bio = map['bio'];
  }
}
