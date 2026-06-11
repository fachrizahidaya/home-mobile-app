import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:homesync/presentation/screens/groceries/budget_by_id.dart';
import 'package:homesync/presentation/widgets/currency_formatter.dart';
import 'package:homesync/providers/grocery_provider.dart';
import 'package:homesync/ui/core/constants/app_colors.dart';
import 'package:provider/provider.dart';

class GroceriesScreen extends StatefulWidget {
  const GroceriesScreen({super.key});

  @override
  State<GroceriesScreen> createState() => _GroceriesScreenState();
}

class _GroceriesScreenState extends State<GroceriesScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GroceryProvider>().fetchBudgets();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GroceryProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text('Groceries'),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
          floatingActionButton: FloatingActionButton.extended(
            backgroundColor: AppColors.primary,
            onPressed: () {
              _showBudgetBottomSheet(context);
            },
            icon: const Icon(Icons.add),
            label: const Text('Budget'),
          ),
          body: provider.isLoading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : RefreshIndicator(
                  onRefresh: provider.fetchBudgets,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _buildBudgetList(provider),
                    ],
                  ),
                ),
        );
      },
    );
  }

  Widget _buildBudgetList(
    GroceryProvider provider,
  ) {
    if (provider.budgets.isEmpty) {
      return _emptyCard(
        'Belum ada budget',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Budget Periods',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...provider.budgets.map(
          (budget) => Card(
            child: ListTile(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BudgetDetailScreen(
                      budgetId: budget.id,
                    ),
                  ),
                );
              },
              title: Text(
                budget.title,
              ),
              subtitle: Text(
                '${budget.periodStart} - ${budget.periodEnd}',
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    CurrencyFormatter.format(
                      budget.remainingBudget,
                    ),
                  ),
                  Text(
                    budget.overBudget ? 'Over Budget' : 'Safe',
                    style: TextStyle(
                      color: budget.overBudget ? Colors.red : Colors.green,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _emptyCard(
    String text,
  ) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Text(text),
      ),
    );
  }

  String calculatePeriodEnd(
    String periodStart,
  ) {
    final start = DateTime.parse(
      periodStart,
    );

    final nextMonth = DateTime(
      start.year,
      start.month + 1,
      start.day,
    );

    final periodEnd = nextMonth.subtract(
      const Duration(days: 1),
    );

    return DateFormat(
      'yyyy-MM-dd',
    ).format(
      periodEnd,
    );
  }

  void _showBudgetBottomSheet(
    BuildContext context,
  ) {
    final provider = context.read<GroceryProvider>();

    final titleController = TextEditingController();

    final amountController = TextEditingController();

    DateTime selectedDate = DateTime.now();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(
            24,
          ),
        ),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (
            context,
            setState,
          ) {
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
                      'Tambah Budget',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(
                      height: 24,
                    ),

                    /// Nama Budget
                    TextFormField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Nama Periode',
                        hintText: 'Contoh: Belanja Juni',
                      ),
                    ),

                    const SizedBox(
                      height: 16,
                    ),

                    /// Budget Amount
                    TextFormField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Budget',
                      ),
                    ),

                    const SizedBox(
                      height: 16,
                    ),

                    /// Tanggal Mulai
                    InkWell(
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(
                            2024,
                          ),
                          lastDate: DateTime(
                            2100,
                          ),
                        );

                        if (date != null) {
                          setState(() {
                            selectedDate = date;
                          });
                        }
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Tanggal Mulai',
                        ),
                        child: Text(
                          DateFormat(
                            'dd MMM yyyy',
                          ).format(
                            selectedDate,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 16,
                    ),

                    /// Auto End Date
                    InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Tanggal Berakhir',
                      ),
                      child: Text(
                        DateFormat(
                          'dd MMM yyyy',
                        ).format(
                          DateTime.parse(
                            calculatePeriodEnd(
                              DateFormat(
                                'yyyy-MM-dd',
                              ).format(
                                selectedDate,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 24,
                    ),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: provider.isSaving
                            ? null
                            : () async {
                                final success = await provider.createBudget(
                                  title: titleController.text,
                                  budgetAmount: double.tryParse(
                                        amountController.text,
                                      ) ??
                                      0,
                                  periodStart: DateFormat(
                                    'yyyy-MM-dd',
                                  ).format(
                                    selectedDate,
                                  ),
                                );

                                if (!context.mounted) {
                                  return;
                                }

                                if (success) {
                                  Navigator.pop(
                                    context,
                                  );

                                  ScaffoldMessenger.of(
                                    context,
                                  ).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Budget berhasil dibuat',
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
                                'Simpan Budget',
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
}
