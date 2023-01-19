import 'package:flutter/material.dart';

class UserCardPlaceHolder extends StatefulWidget {
  const UserCardPlaceHolder({Key? key}) : super(key: key);
  @override
  UserCardPlaceHolderState createState() => UserCardPlaceHolderState();
}

class UserCardPlaceHolderState extends State<UserCardPlaceHolder>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation _animation;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 2));
    _animation =
        ColorTween(begin: Colors.grey.withOpacity(0.1), end: Colors.white)
            .animate(_controller);
    _controller.addListener(() => setState(() {}));
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: 2,
      itemBuilder: (context, index) => Center(
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.7,
          height: 350,
          child: Card(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _animation.value,
                  ),
                ),
                const SizedBox(height: 25),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: _animation.value,
                  ),
                  width: 200,
                  height: 15,
                ),
                const SizedBox(height: 5),
                Container(
                  width: 150,
                  height: 15,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: _animation.value,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  width: 100,
                  height: 15,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: _animation.value,
                  ),
                ),
                const SizedBox(height: 5),
                Container(
                  width: 180,
                  height: 15,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: _animation.value,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  width: 120,
                  height: 15,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: _animation.value,
                  ),
                ),
                const SizedBox(height: 25),
                Container(
                  width: 60,
                  height: 30,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: _animation.value,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
