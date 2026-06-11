import 'package:dio/dio.dart';
import 'package:homesync/data/models/grocery_budget_model.dart';
import 'package:homesync/data/services/api_service.dart';

class GroceryService {
  final ApiService _apiService = ApiService();

  Future<List<GroceryBudgetModel>> getBudgets() async {
    try {
      final response = await _apiService.get(
        '/groceries/budgets',
      );

      return (response.data['data'] as List)
          .map(
            (e) => GroceryBudgetModel.fromJson(e),
          )
          .toList();
    } on DioException {
      rethrow;
    }
  }

  Future<void> createBudget({
    required String title,
    required double budgetAmount,
    required String periodStart,
  }) async {
    await _apiService.post(
      '/groceries/budgets',
      data: {
        'title': title,
        'budget_amount': budgetAmount,
        'period_start': periodStart,
      },
    );
  }

  Future<void> updateBudget({
    required int budgetId,
    required String title,
    required double budgetAmount,
    required String periodStart,
  }) async {
    await _apiService.put(
      '/groceries/budgets/$budgetId',
      data: {
        'title': title,
        'budget_amount': budgetAmount,
        'period_start': periodStart,
      },
    );
  }

  Future<void> deleteBudget(
    int budgetId,
  ) async {
    await _apiService.delete(
      '/groceries/budgets/$budgetId',
    );
  }

  Future<void> createExpense({
    required int budgetId,
    required String name,
    required double amount,
    required String expenseDate,
    String? notes,
  }) async {
    await _apiService.post(
      '/groceries/budgets/$budgetId/expenses',
      data: {
        'name': name,
        'amount': amount,
        'expense_date': expenseDate,
        'notes': notes,
      },
    );
  }

  Future<void> updateExpense({
    required int budgetId,
    required int expenseId,
    required String name,
    required double amount,
    required String expenseDate,
    String? notes,
  }) async {
    await _apiService.put(
      '/groceries/budgets/$budgetId/expenses/$expenseId',
      data: {
        'name': name,
        'amount': amount,
        'expense_date': expenseDate,
        'notes': notes,
      },
    );
  }

  Future<void> deleteExpense({
    required int budgetId,
    required int expenseId,
  }) async {
    await _apiService.delete(
      '/groceries/budgets/$budgetId/expenses/$expenseId',
    );
  }
}
