// ignore_for_file: public_member_api_docs

class UserTransaction {
  const UserTransaction({
    required this.id,
    required this.userId,
    required this.amount,
    required this.type,
    required this.createdAt,
    required this.transactionId,
    required this.currency,
    required this.status,
  });

  factory UserTransaction.fromJson(Map<String, dynamic> json) {
    return UserTransaction(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      amount: json['amount'] as double,
      type: json['type'] as String,
      createdAt: json['created_at'] as String,
      transactionId: json['transaction_id'] as String,
      currency: json['currency'] as String,
      status: json['status'] as String,
    );
  }

  final String id;
  final String userId;
  final double amount;
  final String type;
  final String createdAt;
  final String transactionId;
  final String currency;
  final String status;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'amount': amount,
      'type': type,
      'createdAt': createdAt,
      'transactionId': transactionId,
      'currency': currency,
      'status': status,
    };
  }

  UserTransaction copyWith({
    String? id,
    String? userId,
    double? amount,
    String? type,
    String? createdAt,
    String? transactionId,
    String? currency,
    String? status,
  }) {
    return UserTransaction(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      transactionId: transactionId ?? this.transactionId,
      currency: currency ?? this.currency,
      status: status ?? this.status,
    );
  }
}
