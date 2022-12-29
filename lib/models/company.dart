class Company {
  String? id;
  String name;
  String? logo;

  Company({required this.name, this.logo, this.id});

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      id: json['_id'],
      name: json['name'],
      logo: json['logo'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'logo': logo,
    };
  }
}
