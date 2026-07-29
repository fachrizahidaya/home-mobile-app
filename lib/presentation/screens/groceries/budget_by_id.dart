import 'package:easy_localization/easy_localization.dart';
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
              _showExpenseBottomSheet(context, budget.id);
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
    final provider = context.read<GroceryProvider>();

    final nameController = TextEditingController();
    final amountController = TextEditingController();

    DateTime selectedExpenseDate = DateTime.now();

    final budget = provider.budgets.firstWhere(
      (e) => e.id == budgetId,
    );

    selectedExpenseDate = DateTime.parse(
      budget.periodStart,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (bottomSheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tambah Pengeluaran',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 24),

                    /// Nama Pengeluaran
                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nama Pengeluaran',
                        hintText: 'Contoh: Beras',
                      ),
                    ),

                    const SizedBox(height: 16),

                    /// Tanggal Pengeluaran
                    InkWell(
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: selectedExpenseDate,
                          firstDate: DateTime.parse(
                            budget.periodStart,
                          ),
                          lastDate: DateTime.parse(
                            budget.periodEnd,
                          ),
                        );

                        if (date != null) {
                          setModalState(() {
                            selectedExpenseDate = date;
                          });
                        }
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Tanggal Pengeluaran',
                        ),
                        child: Text(
                          DateFormat(
                            'dd MMM yyyy',
                          ).format(
                            selectedExpenseDate,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    /// Nominal
                    TextFormField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Nominal',
                        prefixText: 'Rp ',
                      ),
                    ),

                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: provider.isSaving
                            ? null
                            : () async {
                                final success = await provider.createExpense(
                                  budgetId: budgetId,
                                  name: nameController.text,
                                  amount: double.tryParse(
                                        amountController.text,
                                      ) ??
                                      0,
                                  expenseDate: DateFormat(
                                    'yyyy-MM-dd',
                                  ).format(
                                    selectedExpenseDate,
                                  ),
                                );

                                if (!context.mounted) return;

                                if (success) {
                                  Navigator.pop(context);

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Pengeluaran berhasil ditambahkan',
                                      ),
                                    ),
                                  );
                                }
                              },
                        child: provider.isSaving
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Simpan Pengeluaran',
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
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
