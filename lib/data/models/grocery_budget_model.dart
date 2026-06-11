import 'package:homesync/data/models/grocery_expense_model.dart';

class GroceryBudgetModel {
  final int id;
  final String title;
  final double budgetAmount;
  final String periodStart;
  final String periodEnd;

  final double totalExpenses;
  final double remainingBudget;
  final bool overBudget;

  final List<GroceryExpenseModel> expenses;

  GroceryBudgetModel({
    required this.id,
    required this.title,
    required this.budgetAmount,
    required this.periodStart,
    required this.periodEnd,
    required this.totalExpenses,
    required this.remainingBudget,
    required this.overBudget,
    required this.expenses,
  });

  factory GroceryBudgetModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return GroceryBudgetModel(
      id: json['id'],
      title: json['title'] ?? '',
      budgetAmount: double.parse(
        json['budget_amount'].toString(),
      ),
      periodStart: json['period_start'] ?? '',
      periodEnd: json['period_end'] ?? '',
      totalExpenses: double.parse(
        json['total_expenses'].toString(),
      ),
      remainingBudget: double.parse(
        json['remaining_budget'].toString(),
      ),
      overBudget: json['over_budget'] ?? false,
      expenses: (json['expenses'] as List? ?? [])
          .map(
            (e) => GroceryExpenseModel.fromJson(e),
          )
          .toList(),
    );
  }
}
