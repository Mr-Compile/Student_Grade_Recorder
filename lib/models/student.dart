class Student {
  final int? id;
  final String fullName;
  final String section;
  final String yearLevel;

  Student({
    this.id,
    required this.fullName,
    required this.section,
    required this.yearLevel,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fullName': fullName,
      'section': section,
      'yearLevel': yearLevel,
    };
  }

  factory Student.fromMap(Map<String, dynamic> map) {
    return Student(
      id: map['id'],
      fullName: map['fullName'],
      section: map['section'],
      yearLevel: map['yearLevel'],
    );
  }
}
