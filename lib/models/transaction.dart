class Transaction {
  final int id;
  final String name;
  final int amount;
  final DateTime date;
  final String category;

  Transaction({
    required this.id,
    required this.name,
    required this.amount,
    required this.date,
    required this.category,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as int,
      name: json['name'] as String,
      amount: json['amount'] as int,
      date: DateTime.parse(json['date'] as String),
      category: json['category'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'amount': amount,
      'date': date.toIso8601String(),
      'category': category,
    };
  }
}
