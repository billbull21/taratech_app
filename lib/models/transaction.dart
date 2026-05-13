class Transaction {
  final String id;
  final String name;
  final double amount;
  final DateTime datetime;
  final String category;

  Transaction({
    required this.id,
    required this.name,
    required this.amount,
    required this.datetime,
    required this.category,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as String,
      name: json['name'] as String,
      amount: (json['amount'] as num).toDouble(),
      datetime: DateTime.parse(json['datetime'] as String),
      category: json['category'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'amount': amount,
      'datetime': datetime.toIso8601String(),
      'category': category,
    };
  }
}
