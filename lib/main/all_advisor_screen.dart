import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:papayask_app/main/filters_screen.dart';
import 'package:papayask_app/main/advisor_service.dart';
import 'package:papayask_app/main/user_card.dart';
import 'package:papayask_app/models/user.dart';
import 'package:papayask_app/theme/colors.dart';

class AllAdvisorScreen extends StatefulWidget {
  static const String routeName = '/all-advisor';
  const AllAdvisorScreen({super.key});

  @override
  State<AllAdvisorScreen> createState() => _AllAdvisorScreenState();
}

class _AllAdvisorScreenState extends State<AllAdvisorScreen> {
  @override
  Widget build(BuildContext context) {
    final advisorService = Provider.of<AdvisorService>(context);
    List<User> users = advisorService.filteredUsers;
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Advisors'),
      ),
      body: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(8.0),
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: MediaQuery.of(context).size.width * 0.5 / 300,
              ),
              itemCount: users.length,
              itemBuilder: (context, index) => SizedBox(
                height: 350,
                child: UserCard(user: users[index]),
              ),
            ),
          ),
          Positioned(
            bottom: 32,
            left: 100,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton.extended(
                  heroTag: 'sort',
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      bottomLeft: Radius.circular(30),
                    ),
                  ),
                  onPressed: () {
                    showModalBottomSheet(
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(15),
                          topRight: Radius.circular(15),
                        ),
                      ),
                      context: context,
                      builder: ((context) {
                        return Container(
                          padding: const EdgeInsets.all(8.0),
                          height: 300,
                          child: Column(
                            children: [
                              const Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Sort by:',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              RadioListTile<SortBy>(
                                value: SortBy.skills,
                                groupValue: advisorService.sortBy,
                                onChanged: (value) {
                                  advisorService
                                      .setSortByValue(value as SortBy);
                                  Navigator.pop(context);
                                },
                                title: const Text('Set of skills'),
                              ),
                              RadioListTile<SortBy>(
                                value: SortBy.experience,
                                groupValue: advisorService.sortBy,
                                onChanged: (value) {
                                  advisorService
                                      .setSortByValue(value as SortBy);
                                  Navigator.pop(context);
                                },
                                title: const Text('Years of experience'),
                              ),
                              RadioListTile<SortBy>(
                                value: SortBy.costUp,
                                groupValue: advisorService.sortBy,
                                onChanged: (value) {
                                  advisorService
                                      .setSortByValue(value as SortBy);
                                  Navigator.pop(context);
                                },
                                title: const Text('Price (low to high)'),
                              ),
                              RadioListTile<SortBy>(
                                value: SortBy.costDown,
                                groupValue: advisorService.sortBy,
                                onChanged: (value) {
                                  advisorService
                                      .setSortByValue(value as SortBy);
                                  Navigator.pop(context);
                                },
                                title: const Text('Price (high to low)'),
                              ),
                            ],
                          ),
                        );
                      }),
                    );
                  },
                  icon: const Icon(Icons.sort),
                  label: const Text('Sort'),
                ),
                FloatingActionButton.extended(
                  heroTag: 'filter',
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                  onPressed: () {
                    showGeneralDialog(
                      context: context,
                      barrierDismissible: true,
                      barrierLabel: MaterialLocalizations.of(context)
                          .modalBarrierDismissLabel,
                      barrierColor: Colors.black45,
                      transitionDuration: const Duration(milliseconds: 300),
                      pageBuilder: (BuildContext buildContext,
                          Animation animation, Animation secondaryAnimation) {
                        return const Align(
                          alignment: Alignment.bottomCenter,
                          child: FiltersScreen(),
                        );
                      },
                      transitionBuilder: (BuildContext context,
                          Animation<double> animation,
                          Animation<double> secondaryAnimation,
                          Widget child) {
                        return SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 1),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        );
                      },
                    );
                  },
                  icon: advisorService.filters.isEmpty
                      ? const Icon(Icons.filter_alt_outlined)
                      : Container(
                          padding: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primaryColor,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '${advisorService.filters.length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                  label: const Text('Filter'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
