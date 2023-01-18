import 'package:papayask_app/models/education.dart';
import 'package:papayask_app/models/experience.dart';
import 'package:papayask_app/models/favorites.dart';
import 'package:papayask_app/models/question.dart';
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
  Map<String, List<Question>> questions;
  dynamic advisorStatus;
  Map<String, dynamic> favorites;
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
    this.advisorStatus,
    this.favorites = const {},
  });

  //define a factory constructor to create a User object from a json object
  factory User.fromJson(Map<String, dynamic> json) {
    User user = User(
        id: json['_id'],
        name: json['name'] ?? '',
        createdAt: DateTime.parse(json['createdAt']),
        updatedAt: DateTime.parse(json['updatedAt']),
        confirmed: json['confirmed'],
        title: json['title'] ?? '',
        uid: json['uid'],
        reputation: json['reputation'] ?? 0,
        isSetUp: json['isSetUp'],
        bio: json['bio'] ?? '',
        picture: json['picture'],
        skills: json['skills'].map<Skill>((e) => Skill.fromJson(e)).toList(),
        experience: getExperience(json['experience']),
        education: getEducation(json['education']),
        languages: json['languages'],
        country: json['country'] ?? '',
        verified: json['verified'],
        requestSettings: json['request_settings'],
        questionsInstructions: json['questionsInstructions'],
        advisorStatus: json['advisorStatus'] ?? false,
        questions: {
          'sent': [],
          'received': [],
        },
        favorites: {
          'users': getUsersFromJson(json['favorites']['users'] ?? []),
          'questions':
              getQuestionsFromJson(json['favorites']['questions'] ?? []),
        });
    return user;
  }

  int get progress {
    int progress = 0;
    if (title != '') {
      progress += 5;
    }
    if (bio != '') {
      progress += 15;
    }
    if (picture != null) {
      progress += 15;
    }
    if (skills.isNotEmpty) {
      for (var i = 0; i < skills.length; i++) {
        if (skills[i].educations.isNotEmpty ||
            skills[i].experiences.isNotEmpty) {
          progress += 10;
        } else {
          progress += 5;
        }
      }
    }
    if (experience.isNotEmpty) {
      progress += experience.length * 5;
    }
    if (country != '') {
      progress += 5;
    }
    return progress;
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

List<FavoriteUser> getUsersFromJson(List users) {
  List<FavoriteUser> userList = [];
  for (var i = 0; i < users.length; i++) {
    userList.add(FavoriteUser.fromJson(users[i]));
  }
  return userList;
}

List<FavoriteQuestion> getQuestionsFromJson(List questions) {
  List<FavoriteQuestion> questionList = [];
  for (var i = 0; i < questions.length; i++) {
    questionList.add(FavoriteQuestion.fromJson(questions[i]));
  }
  return questionList;
}
