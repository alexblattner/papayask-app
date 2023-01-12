class FavoriteUser {
  String id;
  String name;
  String title;
  String picture;


  FavoriteUser({
    required this.id,
    required this.name,
    required this.title,
    required this.picture,
    
  });

  factory FavoriteUser.fromJson(Map<String, dynamic> json) {
    return FavoriteUser(
      id: json['id'],
      name: json['name'],
      title: json['title'] ?? '',
      picture: json['picture'] ?? '',
      
    );
  }
}

class FavoriteQuestion {
  String id;
  String description;
  String senderPicture;
  String senderName;
    DateTime createdAt;
  Map<String, dynamic> status;
  DateTime endAnswerTime;

  FavoriteQuestion({
    required this.id,
    required this.description,
    required this.senderPicture,
    required this.senderName,
    required this.createdAt,
    required this.status,
    required this.endAnswerTime,
  });

  factory FavoriteQuestion.fromJson(Map<String, dynamic> json) {
    return FavoriteQuestion(
      id: json['id'],
      description: json['description'] ?? '',
      senderPicture: json['picture'] ?? '',
      senderName: json['senderName'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      status: json['status'] ?? {},
      endAnswerTime: DateTime.parse(json['endAnswerTime']),
    );
  }
}
