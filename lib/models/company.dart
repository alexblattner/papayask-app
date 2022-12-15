class Company {
  String name;

  Company({required this.name});

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
    };
  }
}
