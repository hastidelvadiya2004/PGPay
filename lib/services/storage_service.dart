
// lib/services/storage_service.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/expense.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  late SharedPreferences _prefs;

  // Keys for SharedPreferences
  static const String _usersKey = 'users';
  static const String _expensesKey = 'expenses';

  factory StorageService() {
    return _instance;
  }

  StorageService._internal();

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // User methods
  Future<void> saveUsers(List<String> users) async {
    await _prefs.setStringList(_usersKey, users);
  }

  Future<List<String>> getUsers() async {
    return _prefs.getStringList(_usersKey) ?? [];
  }

  // Expense methods
  Future<void> saveExpense(Expense expense) async {
    List<Expense> expenses = await getExpenses();
    
    // Check if the expense already exists
    int index = expenses.indexWhere((e) => e.id == expense.id);
    if (index != -1) {
      expenses[index] = expense;
    } else {
      expenses.add(expense);
    }
    
    await _saveExpenses(expenses);
  }

  Future<void> deleteExpense(String id) async {
    List<Expense> expenses = await getExpenses();
    expenses.removeWhere((expense) => expense.id == id);
    await _saveExpenses(expenses);
  }

  Future<void> markExpenseAsSettled(String id, bool isSettled) async {
    List<Expense> expenses = await getExpenses();
    int index = expenses.indexWhere((e) => e.id == id);
    
    if (index != -1) {
      expenses[index] = expenses[index].copyWith(isSettled: isSettled);
      await _saveExpenses(expenses);
    }
  }

  Future<List<Expense>> getExpenses() async {
    final String? expensesJson = _prefs.getString(_expensesKey);
    
    if (expensesJson == null) {
      return [];
    }
    
    final List<dynamic> decoded = jsonDecode(expensesJson);
    return decoded.map((item) => Expense.fromJson(item)).toList();
  }

  Future<void> _saveExpenses(List<Expense> expenses) async {
    final List<Map<String, dynamic>> jsonList = 
        expenses.map((expense) => expense.toJson()).toList();
    await _prefs.setString(_expensesKey, jsonEncode(jsonList));
  }

  // Summary methods
  Future<Map<String, double>> getBalanceSummary() async {
    List<String> users = await getUsers();
    List<Expense> expenses = await getExpenses();
    
    if (users.length < 2) {
      return {};
    }
    
    String user1 = users[0];
    String user2 = users[1];
    
    // Positive means user1 owes user2, negative means user2 owes user1
    double balance = 0;
    
    for (Expense expense in expenses) {
      if (expense.isSettled) continue;
      
      // Calculate what each person paid vs what they consumed
      if (expense.paidBy == user1) {
        // User1 paid, so subtract what they consumed
        double user1Consumed = expense.distribution[user1] ?? 0;
        double user2Consumed = expense.distribution[user2] ?? 0;
        
        // User1 paid for user2's consumption
        balance += user2Consumed;
      } else if (expense.paidBy == user2) {
        // User2 paid, so subtract what they consumed
        double user1Consumed = expense.distribution[user1] ?? 0;
        double user2Consumed = expense.distribution[user2] ?? 0;
        
        // User2 paid for user1's consumption
        balance -= user1Consumed;
      }
    }
    
    Map<String, double> result = {};
    if (balance > 0) {
      // User1 owes User2
      result[user1] = balance;
    } else if (balance < 0) {
      // User2 owes User1
      result[user2] = balance.abs();
    }
    
    return result;
  }

  Future<void> clearAll() async {
    await _prefs.clear();
  }
}