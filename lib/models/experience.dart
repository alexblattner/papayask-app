import 'package:papayask_app/models/company.dart';

class Experience {
  String? id;
  String name;
  String type;
  Company company;
  List<String> geographicSpecialization;
  DateTime startDate;
  DateTime? endDate;

  Experience({
    this.id,
    required this.name,
    required this.type,
    required this.company,
    required this.geographicSpecialization,
    required this.startDate,
    this.endDate,
  });

  factory Experience.fromJson(Map<String, dynamic> json) {
    return Experience(
      id: json['_id'],
      name: json['name'],
      type: json['type'],
      company: Company.fromJson(json['company']),
      geographicSpecialization:
          List<String>.from(json['geographic_specialization']),
      startDate: DateTime.parse(json['startDate']),
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type,
      'company': company,
      'geographicSpecialization': geographicSpecialization,
      'startDate': startDate,
      'endDate': endDate,
    };
  }

  @override
  String toString() {
    return 'Experience{id: $id, name: $name, type: $type, company: $company, geographicSpecialization: $geographicSpecialization, startDate: $startDate, endDate: $endDate}';
  }

  bool isEqual(Experience experience) {
    return experience.toString() == toString();
  }
}
