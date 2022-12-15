class Education {
  String? id;
  Map<String, dynamic> university;
  String name;
  String level;
  DateTime startDate;
  DateTime? endDate;

  Education({
    this.id,
    required this.university,
    required this.name,
    required this.level,
    required this.startDate,
    this.endDate,
  });

  factory Education.fromJson(Map<String, dynamic> json) {
    return Education(
      id: json['_id'],
      university: json['university'],
      name: json['name'],
      level: json['level'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.tryParse(json['endDate']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'university': university,
      'name': name,
      'level': level,
      'startDate': startDate,
      'endDate': endDate,
    };
  }

  @override
  String toString() {
    return 'Education{id: $id, university: $university, name: $name, level: $level, startDate: $startDate, endDate: $endDate}';
  }

  bool isEqual(Education education) {
    return education.toString() == toString();
  }
}
