// lib/screens/expense_screen.dart
import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../services/storage_service.dart';

class ExpenseScreen extends StatefulWidget {
  final List<String> users;
  final Expense? existingExpense;

  const ExpenseScreen({
    Key? key,
    required this.users,
    this.existingExpense,
  }) : super(key: key);

  @override
  State<ExpenseScreen> createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  late PaymentMode _paymentMode;
  late String _paidBy;
  late Map<String, TextEditingController> _distributionControllers;

  @override
  void initState() {
    super.initState();
    _paymentMode = widget.existingExpense?.paymentMode ?? PaymentMode.cash;
    _paidBy = widget.existingExpense?.paidBy ?? widget.users[0];

    if (widget.existingExpense != null) {
      _titleController.text = widget.existingExpense!.title;
      _amountController.text = widget.existingExpense!.totalAmount.toString();
    }

    _distributionControllers = {};
    for (var user in widget.users) {
      double initialValue = 0.0;
      if (widget.existingExpense != null) {
        initialValue = widget.existingExpense!.distribution[user] ?? 0.0;
      }
      _distributionControllers[user] = TextEditingController(
        text: initialValue > 0 ? initialValue.toString() : '',
      );
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    for (var controller in _distributionControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.existingExpense == null ? 'Add Expense' : 'Edit Expense',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          if (widget.existingExpense != null)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: _showDeleteConfirmation,
            ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).primaryColor.withOpacity(0.1),
              Colors.white,
            ],
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextFormField(
                            controller: _titleController,
                            decoration: InputDecoration(
                              labelText: 'Title/Description',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              prefixIcon: const Icon(Icons.title),
                              filled: true,
                              fillColor: Colors.grey[50],
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter a title';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _amountController,
                            decoration: InputDecoration(
                              labelText: 'Total Amount (₹)',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              prefixIcon: const Icon(Icons.currency_rupee),
                              filled: true,
                              fillColor: Colors.grey[50],
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter an amount';
                              }
                              if (double.tryParse(value) == null || double.parse(value) <= 0) {
                                return 'Please enter a valid amount';
                              }
                              return null;
                            },
                            onChanged: (_) {
                              _updateDistribution();
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Payment Mode:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: RadioListTile<PaymentMode>(
                                  title: const Text('Cash'),
                                  value: PaymentMode.cash,
                                  groupValue: _paymentMode,
                                  activeColor: Theme.of(context).primaryColor,
                                  onChanged: (value) {
                                    setState(() {
                                      _paymentMode = value!;
                                    });
                                  },
                                ),
                              ),
                              Expanded(
                                child: RadioListTile<PaymentMode>(
                                  title: const Text('Online'),
                                  value: PaymentMode.online,
                                  groupValue: _paymentMode,
                                  activeColor: Theme.of(context).primaryColor,
                                  onChanged: (value) {
                                    setState(() {
                                      _paymentMode = value!;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Paid By:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            value: _paidBy,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              filled: true,
                              fillColor: Colors.grey[50],
                              prefixIcon: const Icon(Icons.person),
                            ),
                            items: widget.users.map((user) {
                              return DropdownMenuItem(
                                value: user,
                                child: Text(user),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _paidBy = value!;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Amount Distribution:',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextButton.icon(
                                onPressed: _splitEvenly,
                                icon: const Icon(Icons.balance),
                                label: const Text('Split Evenly'),
                                style: TextButton.styleFrom(
                                  foregroundColor: Theme.of(context).primaryColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ...widget.users.map((user) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: TextFormField(
                                controller: _distributionControllers[user],
                                decoration: InputDecoration(
                                  labelText: 'Amount for $user',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  prefixIcon: const Icon(Icons.currency_rupee),
                                  filled: true,
                                  fillColor: Colors.grey[50],
                                ),
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter an amount';
                                  }
                                  if (double.tryParse(value) == null) {
                                    return 'Please enter a valid amount';
                                  }
                                  return null;
                                },
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _saveExpense,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      backgroundColor: Theme.of(context).primaryColor,
                    ),
                    child: Text(
                      widget.existingExpense == null ? 'Add Expense' : 'Update Expense',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Expense'),
        content: const Text('Are you sure you want to delete this expense?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteExpense();
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _deleteExpense() async {
    if (widget.existingExpense != null) {
      await StorageService().deleteExpense(widget.existingExpense!.id!);
      if (!mounted) return;
      Navigator.of(context).pop();
    }
  }

  void _splitEvenly() {
    if (_amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a total amount first')),
      );
      return;
    }

    final double totalAmount = double.parse(_amountController.text);
    final double splitAmount = totalAmount / widget.users.length;

    setState(() {
      for (var user in widget.users) {
        _distributionControllers[user]!.text = splitAmount.toStringAsFixed(2);
      }
    });
  }

  void _updateDistribution() {
    // This method could be used to update distribution when total changes
    // For now, we'll keep it simple
  }

  void _saveExpense() async {
    if (_formKey.currentState!.validate()) {
      // Validate that distribution sums to total
      double totalAmount = double.parse(_amountController.text);
      double distributionSum = 0;

      Map<String, double> distribution = {};
      for (var user in widget.users) {
        double amount = double.parse(_distributionControllers[user]!.text);
        distribution[user] = amount;
        distributionSum += amount;
      }

      // Allow small rounding errors
      if ((distributionSum - totalAmount).abs() > 0.01) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Distribution sum (${distributionSum.toStringAsFixed(2)}) does not match total amount (${totalAmount.toStringAsFixed(2)})'),
          ),
        );
        return;
      }

      final expense = Expense(
        id: widget.existingExpense?.id,
        title: _titleController.text,
        totalAmount: totalAmount,
        paymentMode: _paymentMode,
        paidBy: _paidBy,
        distribution: distribution,
        isSettled: widget.existingExpense?.isSettled ?? false,
      );

      await StorageService().saveExpense(expense);
      if (!mounted) return;
      
      Navigator.of(context).pop();
    }
  }
}
