import 'package:flutter/material.dart';
import 'package:papayask_app/main/filters_divider.dart';
import 'package:provider/provider.dart';

import 'package:papayask_app/main/advisor_service.dart';
import 'package:papayask_app/theme/colors.dart';

class LocationFilter extends StatefulWidget {
  const LocationFilter({super.key});

  @override
  State<LocationFilter> createState() => _LocationFilterState();
}

class _LocationFilterState extends State<LocationFilter> {
  var showAllCountries = false;
  var showAllLanguages = false;
  void filterByCountry() {
    final advsiorService = Provider.of<AdvisorService>(context, listen: false);
    var value = {'countries': []};
    for (Map<String, dynamic> country in advsiorService.countriesAvailable) {
      if (country['selected']) {
        value['countries']!.add(country['name']);
      }
    }
    advsiorService.applyFilter(Filter.country, value);
  }

  void filterByLanguage() {
    final advsiorService = Provider.of<AdvisorService>(context, listen: false);
    var value = {'languages': []};
    for (Map<String, dynamic> language in advsiorService.languagesAvailable) {
      if (language['selected']) {
        value['languages']!.add(language['name']);
      }
    }
    advsiorService.applyFilter(Filter.language, value);
  }

  @override
  Widget build(BuildContext context) {
    final advsiorService = Provider.of<AdvisorService>(context);
    List<Map<String, dynamic>> countries = advsiorService.countriesAvailable;
    List<Map<String, dynamic>> languages = advsiorService.languagesAvailable;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          if (countries.isNotEmpty)
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Advisors lives in:',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          const SizedBox(height: 8),
          ListView.builder(
            primary: false,
            shrinkWrap: true,
            itemCount: countries.length < 3
                ? countries.length
                : showAllCountries
                    ? countries.length
                    : 3,
            itemBuilder: (context, index) {
              return CheckboxListTile(
                title: Text(
                    '${countries[index]['name']} (${countries[index]['count']})'),
                value: countries[index]['selected'],
                onChanged: (value) {
                  advsiorService
                      .toggleCountrySelection(countries[index]['name']);
                  filterByCountry();
                },
              );
            },
          ),
          const SizedBox(height: 8),
          if (countries.length > 3)
            GestureDetector(
              onTap: () {
                setState(() {
                  showAllCountries = !showAllCountries;
                });
              },
              child: Text(
                showAllCountries ? 'Show less' : 'Show more',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primaryColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          const SizedBox(height: 16),
          if (languages.isNotEmpty)
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Advisors speaks:',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          const SizedBox(height: 8),
          ListView.builder(
            primary: false,
            shrinkWrap: true,
            itemCount: languages.length < 3
                ? languages.length
                : showAllLanguages
                    ? languages.length
                    : 3,
            itemBuilder: (context, index) {
              return CheckboxListTile(
                title: Text(
                    '${languages[index]['name']} (${languages[index]['count']})'),
                value: languages[index]['selected'],
                onChanged: (value) {
                  advsiorService
                      .toggleLanguageSelection(languages[index]['name']);
                  filterByLanguage();
                },
              );
            },
          ),
          const SizedBox(height: 8),
          if (languages.length > 3)
            GestureDetector(
              onTap: () {
                setState(() {
                  showAllLanguages = !showAllLanguages;
                });
              },
              child: Text(
                showAllLanguages ? 'Show less' : 'Show more',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primaryColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          if (countries.isNotEmpty || languages.isNotEmpty)
            const FiltersDivider(),
        ],
      ),
    );
  }
}
