import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/material.dart';
import 'package:untitled/controller/expense_controller.dart';
import '../controller/budgetController.dart';

class BudgetPdfGenerator {
  final BudgetController budgetCtrl = Get.find();
  final ExpenseController expenseCtrl = Get.find();

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

  Future<void> generateAndSaveBudgetReport() async {
    try {
      print("Starting PDF generation...");
      final budgetStatusList = await budgetCtrl.fetchExpenseStatusForCurrentMonth();

      final pdf = await _createPdfDocument(budgetStatusList);
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
      _log("Error", "Failed to generate PDF: ${e.toString()}", isError: true);
    }
  }

  Future<pw.Document> _createPdfDocument(List<Map<String, dynamic>> budgets) async {
    final fontData = await rootBundle.load("assets/font/Roboto-Regular.ttf");
    final ttf = pw.Font.ttf(fontData.buffer.asByteData());

    final pdf = pw.Document();
    final formatter = DateFormat('yyyy-MM-dd');
    final now = DateTime.now();

    // Title like: "Monthly Budget - June 2025"
    final String title = "Monthly Budget - ${DateFormat('MMMM yyyy').format(now)}";

    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Text(title, style: pw.TextStyle(font: ttf, fontSize: 24)),
          ),
          if (budgets.isNotEmpty &&
              budgets.first.containsKey('startDate') &&
              budgets.first['startDate'] is DateTime &&
              budgets.first['endDate'] is DateTime)
            pw.Paragraph(
              text:
              "Period: ${formatter.format(budgets.first['startDate'])} to ${formatter.format(budgets.first['endDate'])}",
              style: pw.TextStyle(font: ttf, fontSize: 14),
            ),
          pw.SizedBox(height: 10),
          pw.Table.fromTextArray(
            headers: ['No.', 'Budget', 'Used', 'Remaining', 'Advice'],
            data: List.generate(budgets.length, (index) {
              final budget = budgets[index];
              final budgetAmount = (budget['budget'] ?? 0.0).toDouble();
              final used = (budget['used'] ?? 0.0).toDouble();
              final remaining = (budget['remaining'] ?? 0.0).toDouble();
              final spendings = (budget['spendings'] ?? []) as List<Map<String, dynamic>>;
              final advice = _getAdvice(used, budgetAmount, spendings);

              return [
                (index + 1).toString(),
                "${budgetAmount.toStringAsFixed(2)} RWF",
                "${used.toStringAsFixed(2)} RWF",
                "${remaining.toStringAsFixed(2)} RWF",
                advice,
              ];
            }),
            cellStyle: pw.TextStyle(font: ttf),
            headerStyle: pw.TextStyle(font: ttf, fontWeight: pw.FontWeight.bold),
            columnWidths: {
              4: const pw.FlexColumnWidth(4),
            },
          ),
        ],
      ),
    );

    return pdf;
  }

  String _getAdvice(double used, double budget, List<Map<String, dynamic>> spendings) {
    if (budget == 0) return "No budget data";

    double percent = (used / budget) * 100;

    if (percent <= 70) {
      return "Safe Zone: Excellent! You are managing well. Consider saving or investing.";
    } else if (percent <= 95) {
      String biggest = expenseCtrl.getHighestSpendingCategory();
      return "Warning Zone: Close to the limit. Watch spending on $biggest. then take decision for next month";
    } else {
      String biggest = expenseCtrl.getHighestSpendingCategory();
      return "Critical Zone: Overspending! Consider reducing $biggest or adjust your budget.";
    }
  }

  Future<bool> _saveToDownloads(List<int> bytes) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = "budget_report_$timestamp.pdf";
      final directory = Directory('/storage/emulated/0/Download');

      if (!await directory.exists()) {
        _log("Error", "Download directory does not exist", isError: true);
        return false;
      }

      final file = File('${directory.path}/$fileName');
      await file.writeAsBytes(bytes);

      _log("Success", "PDF saved to Downloads: ${file.path}");
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
