
// lib/models/expense.dart
import 'package:uuid/uuid.dart';

class Expense {
  final String id;
  final String title;
  final double totalAmount;
  final PaymentMode paymentMode;
  final String paidBy; // Name of the user who paid
  final Map<String, double> distribution; // User name to amount mapping
  final DateTime date;
  bool isSettled;

  Expense({
    String? id,
    required this.title,
    required this.totalAmount,
    required this.paymentMode,
    required this.paidBy,
    required this.distribution,
    DateTime? date,
    this.isSettled = false,
  }) : id = id ?? const Uuid().v4(),
       date = date ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'totalAmount': totalAmount,
      'paymentMode': paymentMode.toString(),
      'paidBy': paidBy,
      'distribution': distribution,
      'date': date.toIso8601String(),
      'isSettled': isSettled,
    };
  }

  factory Expense.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> rawDistribution = Map<String, dynamic>.from(json['distribution']);
    Map<String, double> distribution = {};
    
    rawDistribution.forEach((key, value) {
      distribution[key] = (value is int) ? value.toDouble() : value;
    });

    return Expense(
      id: json['id'],
      title: json['title'],
      totalAmount: (json['totalAmount'] is int) 
          ? (json['totalAmount'] as int).toDouble() 
          : json['totalAmount'],
      paymentMode: json['paymentMode'] == 'PaymentMode.cash'
          ? PaymentMode.cash
          : PaymentMode.online,
      paidBy: json['paidBy'],
      distribution: distribution,
      date: DateTime.parse(json['date']),
      isSettled: json['isSettled'] ?? false,
    );
  }

  // Create a copy of the expense with updated fields
  Expense copyWith({
    String? title,
    double? totalAmount,
    PaymentMode? paymentMode,
    String? paidBy,
    Map<String, double>? distribution,
    DateTime? date,
    bool? isSettled,
  }) {
    return Expense(
      id: id,
      title: title ?? this.title,
      totalAmount: totalAmount ?? this.totalAmount,
      paymentMode: paymentMode ?? this.paymentMode,
      paidBy: paidBy ?? this.paidBy,
      distribution: distribution ?? this.distribution,
      date: date ?? this.date,
      isSettled: isSettled ?? this.isSettled,
    );
  }
}

enum PaymentMode { cash, online }