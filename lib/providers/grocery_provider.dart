import 'package:flutter/material.dart';
import 'package:homesync/data/models/grocery_budget_model.dart';
import 'package:homesync/data/services/grocery_service.dart';

class GroceryProvider extends ChangeNotifier {
  final GroceryService _service = GroceryService();

  bool isLoading = false;
  bool isSaving = false;

  String? errorMessage;

  List<GroceryBudgetModel> budgets = [];

  GroceryBudgetModel? selectedBudget;

  Future<void> fetchBudgets() async {
    try {
      isLoading = true;
      errorMessage = null;

      notifyListeners();

      budgets = await _service.getBudgets();

      if (budgets.isNotEmpty) {
        selectedBudget ??= budgets.first;
      }

      if (selectedBudget != null) {
        selectedBudget = budgets.firstWhere(
          (e) => e.id == selectedBudget!.id,
          orElse: () => budgets.first,
        );
      }
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void selectBudget(
    GroceryBudgetModel budget,
  ) {
    selectedBudget = budget;
    notifyListeners();
  }

  Future<bool> createBudget({
    required String title,
    required double budgetAmount,
    required String periodStart,
  }) async {
    try {
      isSaving = true;
      notifyListeners();

      await _service.createBudget(
        title: title,
        budgetAmount: budgetAmount,
        periodStart: periodStart,
      );

      await fetchBudgets();

      return true;
    } catch (e) {
      errorMessage = e.toString();
      return false;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> updateBudget({
    required int budgetId,
    required String title,
    required double budgetAmount,
    required String periodStart,
  }) async {
    try {
      isSaving = true;
      notifyListeners();

      await _service.updateBudget(
        budgetId: budgetId,
        title: title,
        budgetAmount: budgetAmount,
        periodStart: periodStart,
      );

      await fetchBudgets();

      return true;
    } catch (e) {
      errorMessage = e.toString();
      return false;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> deleteBudget(
    int budgetId,
  ) async {
    try {
      isSaving = true;
      notifyListeners();

      await _service.deleteBudget(
        budgetId,
      );

      await fetchBudgets();

      return true;
    } catch (e) {
      errorMessage = e.toString();
      return false;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> createExpense({
    required int budgetId,
    required String name,
    required double amount,
    required String expenseDate,
    String? notes,
  }) async {
    try {
      isSaving = true;
      notifyListeners();

      await _service.createExpense(
        budgetId: budgetId,
        name: name,
        amount: amount,
        expenseDate: expenseDate,
        notes: notes,
      );

      await fetchBudgets();

      selectedBudget = budgets.firstWhere(
        (e) => e.id == budgetId,
      );

      return true;
    } catch (e) {
      errorMessage = e.toString();
      return false;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> updateExpense({
    required int budgetId,
    required int expenseId,
    required String name,
    required double amount,
    required String expenseDate,
    String? notes,
  }) async {
    try {
      isSaving = true;
      notifyListeners();

      await _service.updateExpense(
        budgetId: budgetId,
        expenseId: expenseId,
        name: name,
        amount: amount,
        expenseDate: expenseDate,
        notes: notes,
      );

      await fetchBudgets();

      return true;
    } catch (e) {
      errorMessage = e.toString();
      return false;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> deleteExpense({
    required int budgetId,
    required int expenseId,
  }) async {
    try {
      isSaving = true;
      notifyListeners();

      await _service.deleteExpense(
        budgetId: budgetId,
        expenseId: expenseId,
      );

      await fetchBudgets();

      return true;
    } catch (e) {
      errorMessage = e.toString();
      return false;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  Future<void> fetchBudgetDetail(
    int budgetId,
  ) async {
    try {
      isLoading = true;
      notifyListeners();

      if (budgets.isEmpty) {
        budgets = await _service.getBudgets();
      }

      selectedBudget = budgets.firstWhere(
        (e) => e.id == budgetId,
      );
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  double get totalBudget {
    return budgets.fold(
      0,
      (sum, item) => sum + item.budgetAmount,
    );
  }

  double get totalExpenses {
    return budgets.fold(
      0,
      (sum, item) => sum + item.totalExpenses,
    );
  }

  double get remainingBudget {
    return totalBudget - totalExpenses;
  }
}
