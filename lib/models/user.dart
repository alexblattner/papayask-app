import 'package:papayask_app/models/education.dart';
import 'package:papayask_app/models/experience.dart';
import 'package:papayask_app/models/skill.dart';

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
  List<Skill> skills;
  List<Experience> experience;
  List<Education> education;
  List<dynamic> languages;
  String country;
  bool verified;
  Map<String, dynamic>? requestSettings;
  String? questionsInstructions;
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
    this.requestSettings,
    this.questionsInstructions,
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
      skills: json['skills'].map<Skill>((e) => Skill.fromJson(e)).toList(),
      experience: getExperience(json['experience']),
      education: getEducation(json['education']),
      languages: json['languages'],
      country: json['country'],
      verified: json['verified'],
      requestSettings: json['request_settings'],
      questionsInstructions: json['questionsInstructions'],
      questions: json['questions'] ??
          {
            'sent': [],
            'received': [],
          },
      newQuestionsCount: json['newQuestionsCount'] ?? 0,
    );
  }
}

List<Education> getEducation(List education) {
  List<Education> educationList = [];
  for (var i = 0; i < education.length; i++) {
    educationList.add(Education.fromJson(education[i]));
  }
  return educationList;
}

List<Experience> getExperience(List experience) {
  List<Experience> experienceList = [];
  for (var i = 0; i < experience.length; i++) {
    experienceList.add(Experience.fromJson(experience[i]));
  }
  return experienceList;
}
