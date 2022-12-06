class User {
  String id;
  String name;
  bool confirmed;
  DateTime createdAt;
  DateTime updatedAt;
  String title;
  String uid;
  int reputation;
  bool isSetUp;
  String bio;
  String? picture;
  List<dynamic> skills;
  List experience;
  List education;
  List<dynamic> languages;
  String country;
  bool verified;
  Map<String, dynamic> requestSettings;
  String questionsInstructions;
  Map<String, dynamic> questions;
  int newQuestionsCount;
  User({
    required this.id,
    required this.name,
    required this.confirmed,
    required this.createdAt,
    required this.updatedAt,
    required this.title,
    required this.uid,
    required this.reputation,
    required this.isSetUp,
    required this.bio,
    this.picture,
    required this.skills,
    required this.experience,
    required this.education,
    required this.languages,
    required this.country,
    required this.verified,
    required this.requestSettings,
    required this.questionsInstructions,
    required this.questions,
    required this.newQuestionsCount,
  });

  //define a factory constructor to create a User object from a json object
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'],
      name: json['name'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      confirmed: json['confirmed'],
      title: json['title'],
      uid: json['uid'],
      reputation: json['reputation'] ?? 0,
      isSetUp: json['isSetUp'],
      bio: json['bio'],
      picture: json['picture'],
      skills: json['skills'],
      experience: json['experience'],
      education: json['education'],
      languages: json['languages'],
      country: json['country'],
      verified: json['verified'],
      requestSettings: json['request_settings'],
      questionsInstructions: json['questionsInstructions'],
      questions: json['questions'],
      newQuestionsCount: json['newQuestionsCount'] ?? 0,
    );
  }
}
