class Skill {
  String name;
  List<Map<String, dynamic>> educations;
  List<Map<String, dynamic>> experiences;

  Skill({
    required this.name,
    this.educations = const [],
    this.experiences = const [],
  });

  factory Skill.fromJson(Map<String, dynamic> json) {
    Skill skill = Skill(
      name: json['name'],
      educations: json['educations']
          .map<Map<String, dynamic>>((e) => e as Map<String, dynamic>)
          .toList(),
      experiences: json['experiences']
          .map<Map<String, dynamic>>((e) => e as Map<String, dynamic>)
          .toList(),
    );
    return skill;
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'educations': educations,
      'experiences': experiences,
    };
  }
}
