class Grade {
  final int? id;
  final int studentId;
  final int subjectId;
  final double gradeValue;

  Grade({
    this.id,
    required this.studentId,
    required this.subjectId,
    required this.gradeValue,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'studentId': studentId,
      'subjectId': subjectId,
      'gradeValue': gradeValue,
    };
  }

  factory Grade.fromMap(Map<String, dynamic> map) {
    return Grade(
      id: map['id'],
      studentId: map['studentId'],
      subjectId: map['subjectId'],
      gradeValue: map['gradeValue'],
    );
  }

  String get status => gradeValue >= 60 ? 'Passed' : 'Failed';
}
