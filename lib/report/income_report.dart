import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:untitled/common/color_extension.dart';
import '../controller/home_controller.dart';

class IncomePdfGenerator {
  final HomeController homeCtrl = Get.find();

  void _log(String title, String message, {bool isError = false}) {
    print("${isError ? 'ERROR' : 'INFO'} - $title: $message");
    Get.snackbar(
      title,
      message,
      backgroundColor: isError ? Get.theme.colorScheme.error.withOpacity(0.9) : TColor.line,
      colorText: TColor.white,
      duration: Duration(seconds: isError ? 5 : 3),
    );
  }

  Future<void> generateAndSaveIncomeReport() async {
    try {
      await homeCtrl.fetchIncome();

      // Load custom font
      final fontData = await rootBundle.load("assets/font/Roboto-Regular.ttf");
      final ttf = pw.Font.ttf(fontData.buffer.asByteData());

      final pdf = pw.Document();
      final formatter = DateFormat('yyyy-MM-dd');

      pdf.addPage(
        pw.MultiPage(
          build: (context) => [
            pw.Header(
              level: 0,
              child: pw.Text("User Monthly Income Report", style: pw.TextStyle(font: ttf, fontSize: 24)),
            ),
            pw.Table.fromTextArray(
              headers: ['Description', 'Amount', 'Date'],
              data: homeCtrl.income.map((income) {
                return [
                  income.name ?? '',
                  '${income.amount} RWF',
                  income.date != null ? formatter.format(income.date!) : 'N/A',
                ];
              }).toList(),
              headerStyle: pw.TextStyle(font: ttf, fontWeight: pw.FontWeight.bold),
              cellStyle: pw.TextStyle(font: ttf),
            ),
          ],
        ),
      );

      final bytes = await pdf.save();

      if (Platform.isAndroid) {
        if (await _requestStoragePermission()) {
          bool saved = await _saveToDownloads(bytes);
          if (!saved) throw Exception("Failed to save PDF to Downloads.");
        } else {
          _log("Permission Denied", "Storage permission is required to save the PDF.", isError: true);
        }
      } else {
        _log("Unsupported Platform", "This feature is intended for Android only.", isError: true);
      }
    } catch (e) {
      _log("Error", "Failed to generate income PDF: ${e.toString()}", isError: true);
    }
  }

  Future<bool> _requestStoragePermission() async {
    if (await Permission.manageExternalStorage.isGranted || await Permission.storage.isGranted) {
      return true;
    }

    if (await Permission.manageExternalStorage.request().isGranted || await Permission.storage.request().isGranted) {
      return true;
    }

    return false;
  }

  Future<bool> _saveToDownloads(List<int> bytes) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = "income_report_$timestamp.pdf";
      final directory = Directory('/storage/emulated/0/Download');

      if (!await directory.exists()) {
        _log("Error", "Download directory does not exist", isError: true);
        return false;
      }

      final file = File('${directory.path}/$fileName');
      await file.writeAsBytes(bytes);

      _log("Success", "Income PDF report saved to Downloads: ${file.path}");
      return true;
    } catch (e) {
      _log("Error", "Failed to save file: ${e.toString()}", isError: true);
      return false;
    }
  }
}
