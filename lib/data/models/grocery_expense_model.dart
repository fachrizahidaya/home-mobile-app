class GroceryExpenseModel {
  final int id;
  final String name;
  final double amount;
  final String expenseDate;
  final String? notes;

  GroceryExpenseModel({
    required this.id,
    required this.name,
    required this.amount,
    required this.expenseDate,
    this.notes,
  });

  factory GroceryExpenseModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return GroceryExpenseModel(
      id: json['id'],
      name: json['name'] ?? '',
      amount: double.parse(
        json['amount'].toString(),
      ),
      expenseDate: json['expense_date'] ?? '',
      notes: json['notes'],
    );
  }
}
