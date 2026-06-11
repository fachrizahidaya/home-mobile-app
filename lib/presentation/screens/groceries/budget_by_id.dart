import 'package:flutter/material.dart';
import 'package:homesync/data/models/grocery_budget_model.dart';
import 'package:homesync/presentation/widgets/currency_formatter.dart';
import 'package:homesync/providers/grocery_provider.dart';
import 'package:homesync/ui/core/constants/app_colors.dart';
import 'package:provider/provider.dart';

class BudgetDetailScreen extends StatefulWidget {
  final int budgetId;

  const BudgetDetailScreen({
    super.key,
    required this.budgetId,
  });

  @override
  State<BudgetDetailScreen> createState() => _BudgetDetailScreenState();
}

class _BudgetDetailScreenState extends State<BudgetDetailScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GroceryProvider>().fetchBudgetDetail(
            widget.budgetId,
          );
    });
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Consumer<GroceryProvider>(
      builder: (
        context,
        provider,
        child,
      ) {
        final budget = provider.selectedBudget;

        if (provider.isLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (budget == null) {
          return const Scaffold(
            body: Center(
              child: Text(
                'Budget tidak ditemukan',
              ),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(
              budget.title,
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              _showExpenseBottomSheet(
                context,
                budget.id,
              );
            },
            icon: const Icon(
              Icons.add,
            ),
            label: const Text(
              'Expense',
            ),
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              await provider.fetchBudgets();

              await provider.fetchBudgetDetail(
                budget.id,
              );
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildBudgetSummary(
                  budget,
                ),
                const SizedBox(
                  height: 16,
                ),
                _buildBudgetInfo(
                  budget,
                ),
                const SizedBox(
                  height: 16,
                ),
                _buildExpenseList(
                  budget,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBudgetSummary(
    GroceryBudgetModel budget,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(
          20,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            budget.title,
            style: const TextStyle(
              color: Colors.white70,
            ),
          ),
          const SizedBox(
            height: 12,
          ),
          Text(
            CurrencyFormatter.format(
              budget.budgetAmount,
            ),
          ),
          const SizedBox(
            height: 16,
          ),
          Row(
            children: [
              Expanded(
                child: _summaryItem(
                  'Expenses',
                  budget.totalExpenses,
                ),
              ),
              Expanded(
                child: _summaryItem(
                  'Remaining',
                  budget.remainingBudget,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetInfo(
    GroceryBudgetModel budget,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(
          16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              budget.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            Text(
              'Periode : ${budget.periodStart} - ${budget.periodEnd}',
            ),
            Text(
              'Status : ${budget.overBudget ? "Over Budget" : "Safe"}',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpenseList(
    GroceryBudgetModel budget,
  ) {
    if (budget.expenses.isEmpty) {
      return _emptyCard(
        'Belum ada pengeluaran',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Expenses',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(
          height: 12,
        ),
        ...budget.expenses.map(
          (expense) => Card(
            child: ListTile(
              title: Text(
                expense.name,
              ),
              subtitle: Text(
                expense.expenseDate,
              ),
              trailing: Text(
                CurrencyFormatter.format(
                  expense.amount,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _summaryItem(
    String title,
    double value,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          CurrencyFormatter.format(
            value,
          ),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  void _showExpenseBottomSheet(
    BuildContext context,
    int budgetId,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: const SizedBox(
            height: 300,
            child: Center(
              child: Text(
                'Form Expense',
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _emptyCard(
    String text,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          16,
        ),
      ),
      child: Center(
        child: Text(
          text,
        ),
      ),
    );
  }
}
