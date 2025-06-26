import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/material.dart';
import '../controller/expense_controller.dart';

class ExpensePdfGenerator {
  final ExpenseController expenseCtrl = Get.find<ExpenseController>();

  void _log(String title, String message, {bool isError = false}) {
    print("${isError ? 'ERROR' : 'INFO'} - $title: $message");
    Get.snackbar(
      title,
      message,
      backgroundColor: isError ? Colors.red.withOpacity(0.8) : Colors.green.withOpacity(0.8),
      colorText: Colors.white,
      duration: Duration(seconds: isError ? 5 : 3),
    );
  }

  Future<void> generateAndSaveExpenseReport() async {
    try {
      print("Starting Expense PDF generation...");

      // ADD: Debug data before PDF generation
      await _debugExpenseData();

      final pdf = await _createPdfDocument();
      final bytes = await pdf.save();

      if (Platform.isAndroid) {
        if (await _requestStoragePermission()) {
          bool saved = await _saveToDownloads(bytes);
          if (!saved) throw Exception("Failed to save PDF to Downloads");
        } else {
          _log("Permission Denied", "Storage permission is required to save the PDF.", isError: true);
        }
      } else {
        _log("Unsupported Platform", "This PDF generation is intended for Android only.", isError: true);
      }
    } catch (e) {
      _log("Error", "Failed to generate Expense PDF: ${e.toString()}", isError: true);
    }
  }

  // ADD: Debug method to check data
  Future<void> _debugExpenseData() async {
    print("=== DEBUGGING EXPENSE DATA ===");
    print("Controller found: ${expenseCtrl != null}");
    print("Current month expenses count: ${expenseCtrl.currentMonthExpenses?.length ?? 0}");

    if (expenseCtrl.currentMonthExpenses?.isNotEmpty == true) {
      print("First expense data: ${expenseCtrl.currentMonthExpenses[0]}");
      print("Data type: ${expenseCtrl.currentMonthExpenses[0].runtimeType}");

      // Print all expenses for debugging
      for (int i = 0; i < expenseCtrl.currentMonthExpenses.length; i++) {
        var expense = expenseCtrl.currentMonthExpenses[i];
        print("Expense $i: $expense");
        print("  - Category: ${expense['category']} (${expense['category'].runtimeType})");
        print("  - Amount: ${expense['amount']} (${expense['amount'].runtimeType})");
      }
    } else {
      print("No expense data found!");

      // Try to refresh data
      print("Attempting to refresh expense data...");
      await expenseCtrl.fetchCurrentMonthExpenses();
      print("After refresh, count: ${expenseCtrl.currentMonthExpenses?.length ?? 0}");
    }
    print("=== END DEBUG ===");
  }

  Future<pw.Document> _createPdfDocument() async {
    final fontData = await rootBundle.load("assets/font/Roboto-Regular.ttf");
    final ttf = pw.Font.ttf(fontData.buffer.asByteData());

    final pdf = pw.Document();
    final formatter = DateFormat('yyyy-MM-dd');

    // Set title from the first available record or fallback to current month
    DateTime titleDate = DateTime.now();
    if (expenseCtrl.currentMonthExpenses?.isNotEmpty == true &&
        expenseCtrl.currentMonthExpenses[0]['date'] != null &&
        expenseCtrl.currentMonthExpenses[0]['date'] is DateTime) {
      titleDate = expenseCtrl.currentMonthExpenses[0]['date'];
    }

    final String title = "Monthly Expense - ${DateFormat('MMMM yyyy').format(titleDate)}";

    // FIXED: Better data handling with proper type conversion
    List<List<String>> tableData = [];

    if (expenseCtrl.currentMonthExpenses?.isNotEmpty == true) {
      print("Processing ${expenseCtrl.currentMonthExpenses.length} expenses for PDF...");

      tableData = List.generate(expenseCtrl.currentMonthExpenses.length, (index) {
        final expense = expenseCtrl.currentMonthExpenses[index];

        print("Processing expense $index: $expense");

        // FIXED: Handle the actual data structure from your controller
        String category = 'Unknown';
        String amount = '0';

        if (expense != null && expense is Map<String, dynamic>) {
          // Extract category
          if (expense.containsKey('category') && expense['category'] != null) {
            category = expense['category'].toString().trim();
          }

          // Extract and format amount - handle different numeric types
          if (expense.containsKey('amount') && expense['amount'] != null) {
            final rawAmount = expense['amount'];
            double numericAmount = 0.0;

            if (rawAmount is double) {
              numericAmount = rawAmount;
            } else if (rawAmount is int) {
              numericAmount = rawAmount.toDouble();
            } else if (rawAmount is String) {
              numericAmount = double.tryParse(rawAmount) ?? 0.0;
            } else if (rawAmount is num) {
              numericAmount = rawAmount.toDouble();
            }

            // Format the amount properly
            amount = numericAmount.toStringAsFixed(0); // Remove decimals for display
          }
        }

        print("Formatted - Category: '$category', Amount: '$amount'");

        return [
          (index + 1).toString(),
          category.isEmpty ? 'Uncategorized' : category,
          "$amount RWF",
        ];
      });

      print("Generated table data: $tableData");
    } else {
      // FIXED: Handle empty data case
      print("No expense data available, creating placeholder row");
      tableData = [
        ['1', 'No expenses found', '0 RWF']
      ];
    }

    // Calculate total for summary
    double totalAmount = 0.0;
    if (expenseCtrl.currentMonthExpenses?.isNotEmpty == true) {
      for (var expense in expenseCtrl.currentMonthExpenses) {
        if (expense != null && expense['amount'] != null) {
          final rawAmount = expense['amount'];
          if (rawAmount is double) {
            totalAmount += rawAmount;
          } else if (rawAmount is int) {
            totalAmount += rawAmount.toDouble();
          } else if (rawAmount is String) {
            totalAmount += double.tryParse(rawAmount) ?? 0.0;
          } else if (rawAmount is num) {
            totalAmount += rawAmount.toDouble();
          }
        }
      }
    }

    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Text(title, style: pw.TextStyle(font: ttf, fontSize: 24)),
          ),
          // FIXED: Add data count info and total
          pw.Padding(
            padding: pw.EdgeInsets.only(bottom: 10),
            child: pw.Text(
              "Total Records: ${expenseCtrl.currentMonthExpenses?.length ?? 0}",
              style: pw.TextStyle(font: ttf, fontSize: 12),
            ),
          ),
          pw.Padding(
            padding: pw.EdgeInsets.only(bottom: 20),
            child: pw.Text(
              "Total Amount: ${totalAmount.toStringAsFixed(0)} RWF",
              style: pw.TextStyle(font: ttf, fontSize: 14, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.Table.fromTextArray(
            headers: ['No.', 'Category', 'Amount'],
            data: tableData,
            headerStyle: pw.TextStyle(font: ttf, fontWeight: pw.FontWeight.bold),
            cellStyle: pw.TextStyle(font: ttf),
            border: pw.TableBorder.all(), // ADD: Border for better visibility
          ),
        ],
      ),
    );

    return pdf;
  }

  Future<bool> _saveToDownloads(List<int> bytes) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = "expense_report_$timestamp.pdf";
      final directory = Directory('/storage/emulated/0/Download');

      if (!await directory.exists()) {
        _log("Error", "Download directory does not exist", isError: true);
        return false;
      }

      final file = File('${directory.path}/$fileName');
      await file.writeAsBytes(bytes);

      _log("Success", "Expense PDF saved to Downloads: ${file.path}");
      return true;
    } catch (e) {
      _log("Error", "Failed to save to Downloads: ${e.toString()}", isError: true);
      return false;
    }
  }

  Future<bool> _requestStoragePermission() async {
    if (await Permission.manageExternalStorage.isGranted || await Permission.storage.isGranted) {
      return true;
    }

    if (await Permission.manageExternalStorage.request().isGranted ||
        await Permission.storage.request().isGranted) {
      return true;
    }

    _log("Permission Denied", "Storage permission is required to save the PDF.", isError: true);
    return false;
  }
}