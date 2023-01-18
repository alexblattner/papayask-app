import 'package:flutter/material.dart';
import 'package:papayask_app/main/user_card.dart';
import 'package:papayask_app/models/user.dart';

class UsersCarousel extends StatefulWidget {
  final List<User> users;
  const UsersCarousel({super.key, required this.users});

  @override
  State<UsersCarousel> createState() => _UsersCarouselState();
}

class _UsersCarouselState extends State<UsersCarousel> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: widget.users.length,
      itemBuilder: (context, index) => 
       UserCard(user: widget.users[index],),
    );
  }
}
