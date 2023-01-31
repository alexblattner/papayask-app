import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_config/flutter_config.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

import 'package:papayask_app/models/experience.dart';
import 'package:papayask_app/models/education.dart';
import 'package:papayask_app/models/user.dart' as user_model;

enum SortBy { none, costUp, costDown, experience, skills }

enum Filter { experience, budget, country, language, education }

enum EducationList { universities, degrees, fieldsOfStudy, all }

class AdvisorService with ChangeNotifier {
  final List<user_model.User> _users = []; //all advisors
  final List<user_model.User> _filteredUsers =
      []; //filtered advisors shown on screen
  final List<user_model.User> _tmpFilteredUsers =
      []; //filtered advisors before applying filters
  final _auth = FirebaseAuth.instance;
  SortBy sortBy = SortBy.none;

  List<user_model.User> get users => [..._users];

  List<user_model.User> get filteredUsers {
    if (_filteredUsers.isEmpty && filters.isEmpty) {
      return [..._users];
    }
    return [..._filteredUsers];
  }

  List<user_model.User> get tmpFilteredUsers {
    if (filters.isNotEmpty) {
      // if there are filters applied, show the filtered list
      _tmpFilteredUsers.clear();
      _tmpFilteredUsers.addAll(filterList(_users, false));
    }
    if (_tmpFilteredUsers.isEmpty && filters.isEmpty) {
      // if there are no filters applied, show all advisors
      return [..._users];
    }

    return [..._tmpFilteredUsers];
  }

  int get tmpFilteredCount {
    return filterList(_users, true).length;
  }

  List<Filter> filters = []; //list of filters to apply

  //takes a list of users and filters them according to the filters list
  List<user_model.User> filterList(
    List<user_model.User> listToFilter,
    bool finalFilter,
  ) {
    List<user_model.User> filtered = [...listToFilter];
    for (Filter filter in filters) {
      switch (filter) {
        case Filter.experience:
          if (yearsOfExperienceFilters['positions'].isNotEmpty) {
            filtered = filtered.where((user) {
              return yearsOfExperienceFilters['positions']
                  .toSet()
                  .intersection(
                    user.experience.map((e) => e.name).toSet(),
                  )
                  .isNotEmpty;
            }).toList();
          }
          if (yearsOfExperienceFilters['min'] != null &&
              yearsOfExperienceFilters['max'] != null) {
            filtered = filtered.where((user) {
              double yearsOfExperience = countYearsOfExperience(user);
              return yearsOfExperience >= yearsOfExperienceFilters['min'] &&
                  yearsOfExperience <= yearsOfExperienceFilters['max'];
            }).toList();
          }
          break;
        case Filter.budget:
          var min = budgetFilters['min'] ?? 0;
          var max = budgetFilters['max'] ?? 1000000;
          filtered = filtered.where((user) {
            return user.requestSettings!['cost'] >= min &&
                user.requestSettings!['cost'] <= max;
          }).toList();
          break;
        case Filter.country:
          if (finalFilter) {
            filtered = filtered.where((user) {
              return locationFilters['countries'].contains(user.country);
            }).toList();
          }
          break;
        case Filter.language:
          if (finalFilter) {
            filtered = filtered.where((user) {
              return locationFilters['languages']
                  .toSet()
                  .intersection(
                    user.languages.toSet(),
                  )
                  .isNotEmpty;
            }).toList();
          }
          break;
        case Filter.education:
          if (finalFilter) {
            filtered = filtered.where((user) {
              bool universitiesMatch = true;
              bool degreesMatch = true;
              bool fieldsOfStudyMatch = true;
              if (educationFilters['universities'].isNotEmpty) {
                universitiesMatch = educationFilters['universities']
                    .toSet()
                    .intersection(
                      user.education.map((e) => e.university.name).toSet(),
                    )
                    .isNotEmpty;
              }
              if (educationFilters['degrees'].isNotEmpty) {
                degreesMatch = educationFilters['degrees']
                    .toSet()
                    .intersection(
                      user.education.map((e) => e.level).toSet(),
                    )
                    .isNotEmpty;
              }
              if (educationFilters['fieldsOfStudy'].isNotEmpty) {
                fieldsOfStudyMatch = educationFilters['fieldsOfStudy']
                    .toSet()
                    .intersection(
                      user.education.map((e) => e.name).toSet(),
                    )
                    .isNotEmpty;
              }
              return universitiesMatch && degreesMatch && fieldsOfStudyMatch;
            }).toList();
          }
          break;
        default:
          break;
      }
    }
    return filtered;
  }

  //takes a filter and a value and applies the filter
  void applyFilter(Filter filter, dynamic value) {
    if (!filters.contains(filter)) {
      filters.add(filter);
    }
    switch (filter) {
      case Filter.experience:
        if (value['positions'] != null) {
          yearsOfExperienceFilters['positions'] = value['positions'];
          setYearsOfExperienceSliderValues();
        }
        if (value['min'] != null && value['max'] != null) {
          yearsOfExperienceFilters['min'] = value['min'];
          yearsOfExperienceFilters['max'] = value['max'];
          setYearsOfExperiencePerPositionValues();
          setYearsOfExperienceSliderRangeValues(value['min'], value['max']);
        }
        if ((value['min'] == yearsOfExperienceSliderValues.first &&
                    value['max'] == yearsOfExperienceSliderValues.last ||
                value['min'] == null && value['max'] == null) &&
            (value['positions'] == null || value['positions'].isEmpty)) {
          removeFilter(Filter.experience);
        }

        createCountriesAvailable();
        createLanguagesAvailable();
        createEducationLists([EducationList.all]);
        break;
      case Filter.budget:
        budgetFilters['min'] = value['min'];
        budgetFilters['max'] = value['max'];
        budgetMinMaxValues = [value['min'], value['max']];
        if (value['min'] == null && value['max'] == null) {
          removeFilter(Filter.budget);
        }
        createCountriesAvailable();
        createLanguagesAvailable();
        setYearsOfExperiencePerPositionValues();
        createEducationLists([EducationList.all]);
        break;
      case Filter.country:
        locationFilters['countries'] = value['countries'];
        if (value['countries'].isEmpty) {
          removeFilter(Filter.country);
        }
        setYearsOfExperiencePerPositionValues();
        break;
      case Filter.language:
        locationFilters['languages'] = value['languages'];
        if (value['languages'].isEmpty) {
          removeFilter(Filter.language);
        }
        setYearsOfExperiencePerPositionValues();
        break;
      case Filter.education:
        if (value['universities'] != null) {
          educationFilters['universities'] = value['universities'];
          createEducationLists(
              [EducationList.degrees, EducationList.fieldsOfStudy]);
        }
        if (value['degrees'] != null) {
          educationFilters['degrees'] = value['degrees'];
          createEducationLists(
              [EducationList.fieldsOfStudy, EducationList.universities]);
        }
        if (value['fieldsOfStudy'] != null) {
          educationFilters['fieldsOfStudy'] = value['fieldsOfStudy'];
          createEducationLists(
              [EducationList.degrees, EducationList.universities]);
        }
        if (educationFilters['universities'].isEmpty &&
            educationFilters['degrees'].isEmpty &&
            educationFilters['fieldsOfStudy'].isEmpty) {
          removeFilter(Filter.education);
        }
        setYearsOfExperiencePerPositionValues();
        break;
      default:
        break;
    }

    notifyListeners();
  }

  //takes a filter and removes it from the filters list
  void removeFilter(Filter filter) {
    filters.remove(filter);
    switch (filter) {
      case Filter.experience:
        yearsOfExperienceFilters['min'] = null;
        yearsOfExperienceFilters['max'] = null;
        yearsOfExperienceFilters['positions'] = [];
        for (var position in positionsAvailable) {
          position['selected'] = false;
        }
        setYearsOfExperienceSliderRangeValues(
            yearsOfExperienceSliderValues.first,
            yearsOfExperienceSliderValues.last);
        break;
      case Filter.budget:
        budgetFilters['min'] = null;
        budgetFilters['max'] = null;
        budgetMinMaxValues = [null, null];
        break;
      case Filter.country:
        locationFilters['countries'] = [];
        for (var country in countriesAvailable) {
          country['selected'] = false;
        }
        break;
      case Filter.language:
        locationFilters['languages'] = [];
        for (var language in languagesAvailable) {
          language['selected'] = false;
        }
        break;
      case Filter.education:
        educationFilters['universities'] = [];
        educationFilters['degrees'] = [];
        educationFilters['fieldsOfStudy'] = [];
        for (var university in universitiesAvailable) {
          university['selected'] = false;
        }
        for (var degree in degreesAvailable) {
          degree['selected'] = false;
        }
        for (var fieldOfStudy in fieldsOfStudyAvailable) {
          fieldOfStudy['selected'] = false;
        }
        break;
      default:
        break;
    }
    _tmpFilteredUsers.clear();
    _tmpFilteredUsers.addAll(filterList(_users, false));
    createCountriesAvailable();
    createLanguagesAvailable();
    setYearsOfExperiencePerPositionValues();
    createEducationLists([EducationList.all]);
    notifyListeners();
  }

  //applies all filters to the users list shown in the advisors page
  void setFilters() {
    _filteredUsers.clear();
    _filteredUsers.addAll(filterList(_users, true));
    notifyListeners();
  }

  //removes all filters
  void clearFilters() {
    filters.clear();
    _tmpFilteredUsers.clear();
    _filteredUsers.clear();
    _filteredUsers.addAll(_users);
    yearsOfExperienceFilters['min'] = null;
    yearsOfExperienceFilters['max'] = null;
    yearsOfExperienceFilters['positions'] = [];
    setYearsOfExperienceSliderRangeValues(yearsOfExperienceSliderValues.first,
        yearsOfExperienceSliderValues.last);
    budgetFilters['min'] = null;
    budgetFilters['max'] = null;
    budgetMinMaxValues = [null, null];
    locationFilters['countries'] = [];
    locationFilters['languages'] = [];
    educationFilters['universities'] = [];
    educationFilters['degrees'] = [];
    educationFilters['fieldsOfStudy'] = [];
    for (var position in positionsAvailable) {
      position['selected'] = false;
    }
    for (var country in countriesAvailable) {
      country['selected'] = false;
    }
    for (var language in languagesAvailable) {
      language['selected'] = false;
    }
    for (var university in universitiesAvailable) {
      university['selected'] = false;
    }
    for (var degree in degreesAvailable) {
      degree['selected'] = false;
    }
    for (var fieldOfStudy in fieldsOfStudyAvailable) {
      fieldOfStudy['selected'] = false;
    }

    createEducationLists([EducationList.all]);
    notifyListeners();
  }

  //fecthes all users from the database
  Future<void> fetchUsers() async {
    final token = await _auth.currentUser?.getIdToken(true);
    if (token is! String) {
      return;
    }

    try {
      final res = await http.get(
        Uri.parse('${FlutterConfig.get('API_URL')}/user'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      if (res.statusCode == 200) {
        final decodedData = jsonDecode(res.body) as List<dynamic>;
        final users =
            decodedData.map((e) => user_model.User.fromJson(e)).toList();
        _users.clear();
        _users.addAll(users);
        notifyListeners();
        setYearsOfExperienceSliderValues();
        setYearsOfExperiencePerPositionValues();
        createCountriesAvailable();
        createLanguagesAvailable();
        createEducationLists([EducationList.all]);
      }
    } catch (e) {
      print(e);
    }
  }

  //set the sort value
  void setSortByValue(SortBy value) {
    sortBy = value;
    sortUsers(_filteredUsers);
    sortUsers(_users);
    notifyListeners();
  }

  //sorts the users list by the given sortBy parameter
  void sortUsers(List<user_model.User> usersToSort) {
    switch (sortBy) {
      case SortBy.costUp:
        usersToSort.sort((a, b) =>
            a.requestSettings!['cost'].compareTo(b.requestSettings!['cost']));
        break;
      case SortBy.costDown:
        usersToSort.sort((a, b) =>
            b.requestSettings!['cost'].compareTo(a.requestSettings!['cost']));
        break;
      case SortBy.experience:
        usersToSort.sort((a, b) {
          final aExp = countYearsOfExperience(a);
          final bExp = countYearsOfExperience(b);
          return bExp.compareTo(aExp);
        });
        break;
      case SortBy.skills:
        usersToSort.sort((a, b) => b.skills.length.compareTo(a.skills.length));
        break;
      default:
        break;
    }
    notifyListeners();
  }

  //Years of experience filters

  //counts the total years of experience of a user
  double countYearsOfExperience(user_model.User user) {
    double totalYears = 0;
    for (var exp in user.experience) {
      DateTime start = exp.startDate;
      DateTime end = exp.endDate ?? DateTime.now();
      totalYears += end.difference(start).inDays / 365;
    }
    return totalYears;
  }

  //count individual years of experience per position
  double countExperienceYears(Experience experience) {
    DateTime start = experience.startDate;
    DateTime end = experience.endDate ?? DateTime.now();
    return end.difference(start).inDays / 365;
  }

  //sets the years of experience filters values
  Map<String, dynamic> yearsOfExperienceFilters = {
    'min': null,
    'max': null,
    'positions': [],
  };

  //list of all the years of experience values of the users
  List<double> yearsOfExperienceSliderValues = [];

  //map all the years of experience per position
  Map<String, Map<String, double>> yearsOfExperiencePerPositionValues = {};

  //list of all the positions available
  List<Map<String, dynamic>> positionsAvailable = [];

  //range values of the years of experience slider
  SfRangeValues yearsOfExperienceSliderRangeValues =
      const SfRangeValues(0.0, 0.0);

  //fill the yearsOfExperienceSliderValues list and set the range values
  void setYearsOfExperienceSliderValues() {
    if (yearsOfExperienceFilters['positions'].isNotEmpty) {
      double minValue = yearsOfExperiencePerPositionValues[
          yearsOfExperienceFilters['positions'][0]]!['min']!;
      double maxValue = yearsOfExperiencePerPositionValues[
          yearsOfExperienceFilters['positions'][0]]!['max']!;
      yearsOfExperiencePerPositionValues.forEach((key, value) {
        if (yearsOfExperienceFilters['positions'].contains(key)) {
          if (value['min']! < minValue) {
            minValue = value['min']!;
          }
          if (value['max']! > maxValue) {
            maxValue = value['max']!;
          }
        }
      });
      minValue = minValue.floor().toDouble();
      maxValue = maxValue.ceil().toDouble();
      yearsOfExperienceSliderValues = [minValue, maxValue];
      setYearsOfExperienceSliderRangeValues(minValue, maxValue);
      return;
    }

    List<double> values = [];

    for (var user in _users) {
      double yearsOfExperience = countYearsOfExperience(user);
      values.add(yearsOfExperience);
    }

    values.sort();
    var uniqueRoundedValues = values
        .map((v) {
          if (v == values.last) {
            return v.ceil().toDouble();
          } else {
            return v.floor().toDouble();
          }
        })
        .toSet()
        .toList();
    double minValue = uniqueRoundedValues[0];
    double maxValue = uniqueRoundedValues[uniqueRoundedValues.length - 1];
    yearsOfExperienceSliderValues = [minValue, maxValue];
    setYearsOfExperienceSliderRangeValues(minValue, maxValue);
  }

  //sets the range values of the years of experience slider
  void setYearsOfExperienceSliderRangeValues(double min, double max) {
    yearsOfExperienceSliderRangeValues = SfRangeValues(min, max);
    notifyListeners();
  }

  //sets the years of experience per position values
  void setYearsOfExperiencePerPositionValues() {
    yearsOfExperiencePerPositionValues = {};
    List<user_model.User> users = filterList(_users, true);
    for (var user in users) {
      for (var exp in user.experience) {
        if (yearsOfExperiencePerPositionValues[exp.name] == null) {
          yearsOfExperiencePerPositionValues[exp.name] = {
            'min': countExperienceYears(exp),
            'max': countExperienceYears(exp),
          };
        } else {
          if (countExperienceYears(exp) <
              yearsOfExperiencePerPositionValues[exp.name]!['min']!) {
            yearsOfExperiencePerPositionValues[exp.name]!['min'] =
                countExperienceYears(exp);
          }
          if (countExperienceYears(exp) >
              yearsOfExperiencePerPositionValues[exp.name]!['max']!) {
            yearsOfExperiencePerPositionValues[exp.name]!['max'] =
                countExperienceYears(exp);
          }
        }
      }
    }
    notifyListeners();
    createPositionsAvailable();
  }

  //sets positions available
  void createPositionsAvailable() {
    positionsAvailable.clear();
    yearsOfExperiencePerPositionValues.forEach((key, value) {
      positionsAvailable.add({
        'name': key,
        'selected': false,
      });
    });
    notifyListeners();
  }

  //toggle the selected value of a position
  void togglePositionSelected(String position) {
    for (var pos in positionsAvailable) {
      if (pos['name'] == position) {
        pos['selected'] = !pos['selected'];
      }
    }
    notifyListeners();
  }

  //budget filters

  //sets the budget filters values
  Map<String, dynamic> budgetFilters = {
    'min': null,
    'max': null,
  };

  //first value is the min value and the second value is the max value
  List<double?> budgetMinMaxValues = [null, null];

  //Location filters

  //takes name of the country and return bool if it is selected
  bool isCountrySelected(String country) {
    if (locationFilters['countries'].contains(country)) {
      return true;
    }
    return false;
  }

  //takes name of the language and return bool if it is selected
  bool isLanguageSelected(String language) {
    if (locationFilters['languages'].contains(language)) {
      return true;
    }
    return false;
  }

  //list of all the countries, the count of the users from that country and if it is selected
  void createCountriesAvailable() {
    List<String> countriesList = [];
    for (var user in tmpFilteredUsers) {
      countriesList.add(user.country);
    }
    List<Map<String, dynamic>> countries = [];
    for (var country in countriesList) {
      if (countries.isEmpty) {
        countries.add({
          'name': country,
          'selected': isCountrySelected(country),
          'count': 1
        });
      } else {
        bool countryExists = false;
        for (var i = 0; i < countries.length; i++) {
          if (countries[i]['name'] == country) {
            countries[i]['count']++;
            countryExists = true;
            break;
          }
        }
        if (!countryExists) {
          countries.add({
            'name': country,
            'selected': isCountrySelected(country),
            'count': 1
          });
        }
      }
    }
    countries.sort((a, b) => b['count'].compareTo(a['count']));
    countriesAvailable.clear();
    countriesAvailable.addAll(countries);
    notifyListeners();
  }

  //list of all the languages, the count of the users that speak that language and if it is selected
  void createLanguagesAvailable() {
    List<String> languagesList = [];
    for (var user in tmpFilteredUsers) {
      languagesList.addAll([...user.languages]);
    }
    List<Map<String, dynamic>> languages = [];
    for (var language in languagesList) {
      if (languages.isEmpty) {
        languages.add({
          'name': language,
          'selected': isLanguageSelected(language),
          'count': 1
        });
      } else {
        bool languageExists = false;
        for (var i = 0; i < languages.length; i++) {
          if (languages[i]['name'] == language) {
            languages[i]['count']++;
            languageExists = true;
            break;
          }
        }
        if (!languageExists) {
          languages.add({
            'name': language,
            'selected': isLanguageSelected(language),
            'count': 1
          });
        }
      }
    }
    languages.sort((a, b) => b['count'].compareTo(a['count']));
    languagesAvailable.clear();
    languagesAvailable.addAll(languages);
    notifyListeners();
  }

  //sets the location filters values
  Map<String, dynamic> locationFilters = {
    'countries': [],
    'languages': [],
  };

  List<Map<String, dynamic>> countriesAvailable = [];
  List<Map<String, dynamic>> languagesAvailable = [];

  //toggles the selection of a country
  void toggleCountrySelection(String country) {
    for (var i = 0; i < countriesAvailable.length; i++) {
      if (countriesAvailable[i]['name'] == country) {
        countriesAvailable[i]['selected'] = !countriesAvailable[i]['selected'];
        break;
      }
    }
    notifyListeners();
  }

  //toggles the selection of a language
  void toggleLanguageSelection(String language) {
    for (var i = 0; i < languagesAvailable.length; i++) {
      if (languagesAvailable[i]['name'] == language) {
        languagesAvailable[i]['selected'] = !languagesAvailable[i]['selected'];
        break;
      }
    }
    notifyListeners();
  }

  //Education filters

  //sets the education filters values
  Map<String, dynamic> educationFilters = {
    'universities': [],
    'fieldsOfStudy': [],
    'degrees': [],
  };

  //list of all the universities, the count of the users that study in that university and if it is selected
  List<Map<String, dynamic>> universitiesAvailable = [];

  //list of all the fields of study, the count of the users that study that field of study and if it is selected
  List<Map<String, dynamic>> fieldsOfStudyAvailable = [];

  //list of all the degrees, the count of the users that have that degree and if it is selected
  List<Map<String, dynamic>> degreesAvailable = [];

  //create list of available universities
  void createAvailableUniversities() {
    List<String> universitiesList = [];
    for (var user in tmpFilteredUsers) {
      for (Education education in user.education) {
        if (educationFilters['degrees'].isNotEmpty &&
            !educationFilters['degrees'].contains(education.level)) {
          continue;
        }
        if (educationFilters['fieldsOfStudy'].isNotEmpty &&
            !educationFilters['fieldsOfStudy'].contains(education.name)) {
          continue;
        }
        universitiesList.add(education.university.name);
      }
    }
    List<Map<String, dynamic>> universities = [];
    for (var university in universitiesList) {
      if (universities.isEmpty) {
        universities.add({
          'name': university,
          'selected': educationFilters['universities'].contains(university),
          'count': 1
        });
      } else {
        bool universityExists = false;
        for (var i = 0; i < universities.length; i++) {
          if (universities[i]['name'] == university) {
            universities[i]['count']++;
            universityExists = true;
            break;
          }
        }
        if (!universityExists) {
          universities.add({
            'name': university,
            'selected': educationFilters['universities'].contains(university),
            'count': 1
          });
        }
      }
    }
    universities.sort((a, b) => b['count'].compareTo(a['count']));
    universitiesAvailable.clear();
    universitiesAvailable.addAll(universities);
    notifyListeners();
  }

  //create list of available fields of study
  void createAvailableFieldsOfStudy() {
    List<String> fieldsOfStudyList = [];
    for (var user in tmpFilteredUsers) {
      for (Education education in user.education) {
        if (educationFilters['degrees'].isNotEmpty &&
            !educationFilters['degrees'].contains(education.level)) {
          continue;
        }
        if (educationFilters['universities'].isNotEmpty &&
            !educationFilters['universities']
                .contains(education.university.name)) {
          continue;
        }
        fieldsOfStudyList.add(education.name);
      }
    }
    List<Map<String, dynamic>> fieldsOfStudy = [];
    for (var fieldOfStudy in fieldsOfStudyList) {
      if (fieldsOfStudy.isEmpty) {
        fieldsOfStudy.add({
          'name': fieldOfStudy,
          'selected': educationFilters['fieldsOfStudy'].contains(fieldOfStudy),
          'count': 1
        });
      } else {
        bool fieldOfStudyExists = false;
        for (var i = 0; i < fieldsOfStudy.length; i++) {
          if (fieldsOfStudy[i]['name'] == fieldOfStudy) {
            fieldsOfStudy[i]['count']++;
            fieldOfStudyExists = true;
            break;
          }
        }
        if (!fieldOfStudyExists) {
          fieldsOfStudy.add({
            'name': fieldOfStudy,
            'selected':
                educationFilters['fieldsOfStudy'].contains(fieldOfStudy),
            'count': 1
          });
        }
      }
    }
    fieldsOfStudy.sort((a, b) => b['count'].compareTo(a['count']));
    fieldsOfStudyAvailable.clear();
    fieldsOfStudyAvailable.addAll(fieldsOfStudy);
    notifyListeners();
  }

  //create list of available degrees
  void createAvailableDegrees() {
    List<String> degreesList = [];
    List<Map<String, List>> usersVisited =
        []; //to avoid counting the same user twice
    for (var user in tmpFilteredUsers) {
      for (Education education in user.education) {
        if (educationFilters['universities'].isNotEmpty &&
            !educationFilters['universities']
                .contains(education.university.name)) {
          continue;
        }
        if (educationFilters['fieldsOfStudy'].isNotEmpty &&
            !educationFilters['fieldsOfStudy'].contains(education.name)) {
          continue;
        }
        if (usersVisited.isEmpty) {
          degreesList.add(education.level);
          usersVisited.add({
            user.id: [education.level]
          });
        } else {
          bool userExists = false;
          for (var i = 0; i < usersVisited.length; i++) {
            if (usersVisited[i].containsKey(user.id)) {
              if (!usersVisited[i][user.id]!.contains(education.level)) {
                usersVisited[i][user.id]!.add(education.level);
                degreesList.add(education.level);
              }
              userExists = true;
              break;
            }
          }
          if (!userExists) {
            degreesList.add(education.level);
            usersVisited.add({
              user.id: [education.level]
            });
          }
        }
      }
    }

    List<Map<String, dynamic>> degrees = [];
    for (var degree in degreesList) {
      if (degrees.isEmpty) {
        degrees.add({
          'name': degree,
          'selected': educationFilters['degrees'].contains(degree),
          'count': 1
        });
      } else {
        bool degreeExists = false;
        for (var i = 0; i < degrees.length; i++) {
          if (degrees[i]['name'] == degree) {
            degrees[i]['count']++;
            degreeExists = true;
            break;
          }
        }
        if (!degreeExists) {
          degrees.add({
            'name': degree,
            'selected': educationFilters['degrees'].contains(degree),
            'count': 1
          });
        }
      }
    }
    degrees.sort((a, b) => b['count'].compareTo(a['count']));
    degreesAvailable.clear();
    degreesAvailable.addAll(degrees);
    notifyListeners();
  }

  void createEducationLists(List<EducationList> listToCreate) {
    if (listToCreate.contains(EducationList.universities) ||
        listToCreate.contains(EducationList.all)) {
      createAvailableUniversities();
    }
    if (listToCreate.contains(EducationList.fieldsOfStudy) ||
        listToCreate.contains(EducationList.all)) {
      createAvailableFieldsOfStudy();
    }
    if (listToCreate.contains(EducationList.degrees) ||
        listToCreate.contains(EducationList.all)) {
      createAvailableDegrees();
    }
  }

  //toggles the selection of a university
  void toggleUniversitySelection(String university) {
    for (var i = 0; i < universitiesAvailable.length; i++) {
      if (universitiesAvailable[i]['name'] == university) {
        universitiesAvailable[i]['selected'] =
            !universitiesAvailable[i]['selected'];
        break;
      }
    }
    notifyListeners();
  }

  //toggles the selection of a field of study
  void toggleFieldOfStudySelection(String fieldOfStudy) {
    for (var i = 0; i < fieldsOfStudyAvailable.length; i++) {
      if (fieldsOfStudyAvailable[i]['name'] == fieldOfStudy) {
        fieldsOfStudyAvailable[i]['selected'] =
            !fieldsOfStudyAvailable[i]['selected'];
        break;
      }
    }
    notifyListeners();
  }

  //toggles the selection of a degree
  void toggleDegreeSelection(String degree) {
    for (var i = 0; i < degreesAvailable.length; i++) {
      if (degreesAvailable[i]['name'] == degree) {
        degreesAvailable[i]['selected'] = !degreesAvailable[i]['selected'];
        break;
      }
    }
    notifyListeners();
  }
}
