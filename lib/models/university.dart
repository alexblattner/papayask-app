class University {
  String? id;
  String name;
  String? logo;
  String country;
  int rank;

  University({
    this.id,
    required this.name,
    required this.country,
    this.logo,
    this.rank = 1800,
  });

  factory University.fromJson(Map<String, dynamic> json) {
    return University(
      id: json['_id'],
      name: json['name'],
      rank: json['rank'],
      country: json['country'],
      logo: json['logo'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'rank': rank,
      'country': country,
      'logo': logo,
    };
  }
}
