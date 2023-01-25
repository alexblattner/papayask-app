import 'package:flutter/material.dart';

import 'package:papayask_app/main/advisor_service.dart';
import 'package:papayask_app/theme/colors.dart';
import 'package:provider/provider.dart';

class BudgetFilter extends StatefulWidget {
  const BudgetFilter({super.key});

  @override
  State<BudgetFilter> createState() => _BudgetFilterState();
}

class _BudgetFilterState extends State<BudgetFilter> {
  final TextEditingController minController = TextEditingController();
  final TextEditingController maxController = TextEditingController();
  FocusNode minFocusNode = FocusNode();
  FocusNode maxFocusNode = FocusNode();
  Color minIconColor = Colors.grey;
  Color maxIconColor = Colors.grey;

  void filterByBudget(double? min, double? max) {
    final advisorService = Provider.of<AdvisorService>(context, listen: false);
    advisorService.applyFilter(Filter.budget, {
      'min': min,
      'max': max,
    });
  }

  @override
  void initState() {
    minFocusNode.addListener(() {
      setState(() {
        minIconColor = minFocusNode.hasFocus
            ? Theme.of(context).colorScheme.primaryColor
            : Colors.grey;
      });
    });
    maxFocusNode.addListener(() {
      setState(() {
        maxIconColor = maxFocusNode.hasFocus
            ? Theme.of(context).colorScheme.primaryColor
            : Colors.grey;
      });
    });
    final advisorService = Provider.of<AdvisorService>(context, listen: false);
    if (advisorService.budgetMinMaxValues.first != null) {
      minController.text = advisorService.budgetMinMaxValues.first.toString();
    }
    if (advisorService.budgetMinMaxValues.last != null) {
      maxController.text = advisorService.budgetMinMaxValues.last.toString();
    }

    super.initState();
  }

  @override
  void didChangeDependencies() {
    final advisorService = Provider.of<AdvisorService>(context);
    Provider.of<AdvisorService>(context).addListener(() {
      if (advisorService.budgetMinMaxValues.first == null) {
        minController.text = '';
      }
      if (advisorService.budgetMinMaxValues.last == null) {
        maxController.text = '';
      }
    });
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    minFocusNode.dispose();
    maxFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Budget:',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  focusNode: minFocusNode,
                  controller: minController,
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    filterByBudget(double.tryParse(value),
                        double.tryParse(maxController.text));
                  },
                  decoration: InputDecoration(
                    labelText: 'Min',
                    suffixIcon: Icon(
                      Icons.attach_money,
                      color: minIconColor,
                      size: 20,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  focusNode: maxFocusNode,
                  controller: maxController,
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    filterByBudget(double.tryParse(minController.text),
                        double.tryParse(value));
                  },
                  decoration: InputDecoration(
                    labelText: 'Max',
                    suffixIcon: Icon(
                      Icons.attach_money,
                      color: maxIconColor,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
