// lib/widgets/expense_list_tile.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';

class ExpenseListTile extends StatelessWidget {
  final Expense expense;
  final List<String> users;
  final VoidCallback onMarkSettled;
  final VoidCallback onDelete;

  const ExpenseListTile({
    Key? key,
    required this.expense,
    required this.users,
    required this.onMarkSettled,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM d, yyyy');
    final String otherUser = users.firstWhere((user) => user != expense.paidBy);

    return Dismissible(
      key: Key(expense.id),
      background: Container(
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: InkWell(
          onTap: () {
            // TODO: Implement edit functionality
          },
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        expense.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          decoration: expense.isSettled ? TextDecoration.lineThrough : null,
                          color: expense.isSettled ? Colors.grey : null,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: expense.isSettled ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '₹${expense.totalAmount.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: expense.isSettled ? Colors.green : Colors.orange,
                          decoration: expense.isSettled ? TextDecoration.lineThrough : null,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      expense.paymentMode == PaymentMode.cash ? Icons.money : Icons.payment,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${expense.paidBy} paid (${expense.paymentMode == PaymentMode.cash ? 'Cash' : 'Online'})',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      dateFormat.format(expense.date),
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildDistributionText(),
                    ),
                    Switch(
                      value: expense.isSettled,
                      onChanged: (_) => onMarkSettled(),
                      activeColor: Colors.green,
                    ),
                    Text(
                      expense.isSettled ? 'Settled' : 'Mark as settled',
                      style: TextStyle(
                        color: expense.isSettled ? Colors.green : Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDistributionText() {
    List<String> parts = [];
    expense.distribution.forEach((user, amount) {
      parts.add('$user: ₹${amount.toStringAsFixed(2)}');
    });
    return Text(
      parts.join(', '),
      style: TextStyle(
        color: Colors.grey[600],
        fontSize: 14,
      ),
    );
  }
}