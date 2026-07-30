class Subject {
  final int? id;
  final String subjectName;
  final String subjectCode;

  Subject({
    this.id,
    required this.subjectName,
    required this.subjectCode,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'subjectName': subjectName,
      'subjectCode': subjectCode,
    };
  }

  factory Subject.fromMap(Map<String, dynamic> map) {
    return Subject(
      id: map['id'],
      subjectName: map['subjectName'],
      subjectCode: map['subjectCode'],
    );
  }
}
