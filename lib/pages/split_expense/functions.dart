import 'package:money_manager/database/database_helper.dart';
import 'package:money_manager/models/models.dart';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'package:intl/intl.dart'; // For currency formatting

void updateParticipant(Expense expense, List<Participant> participants) {
  List<String> participantNames = expense.borrowers.split(",");
  List<String> borrowedAmt = expense.borrowedamt.split(",");

  for (Participant participant in participants) {
    if (expense.payername == participant.participantName) {
      participant.moneyPaid += expense.amount.toDouble();
      break;
    }
  }

  for (Participant participant in participants) {
    for (int i = 0; i < participantNames.length; i++) {
      if (participant.participantName == participantNames[i]) {
        participant.moneyNeededToPay += int.parse(borrowedAmt[i]);
      }
    }
  }

  for (Participant participant in participants) {
    participant.moneyOwedByOthers = calculateMoneyOwedBy(
      participant.moneyPaid,
      participant.moneyNeededToPay,
    );
    participant.moneyOwedToOthers = calculateMoneyOwedTo(
      participant.moneyPaid,
      participant.moneyNeededToPay,
    );
  }
}

double calculateMoneyOwedTo(double moneyPaid, double moneyNeededToPay) {
  double moneyOwedTo = 0;
  if (moneyPaid > moneyNeededToPay) {
    moneyOwedTo = 0;
  } else {
    moneyOwedTo = (moneyNeededToPay - moneyPaid).toDouble();
  }
  return moneyOwedTo;
}

double calculateMoneyOwedBy(double moneyPaid, double moneyNeededToPay) {
  double moneyOwedBy = 0;
  if (moneyPaid > moneyNeededToPay) {
    moneyOwedBy = (moneyPaid - moneyNeededToPay).toDouble();
  } else {
    moneyOwedBy = 0;
  }
  return moneyOwedBy;
}

Future<List<Participant>> getParticipants(String gid) async {
  late List<Participant> participants = [];
  Group? group = await DatabaseHelper.getGroupByID(gid);
  List<String> participantNames = group!.participants.split(",");

  for (String participantName in participantNames) {
    Participant participant = Participant(
      participantName: participantName,
      moneyPaid: 0.0,
      moneyNeededToPay: 0.0,
      moneyOwedToOthers: 0.0,
      moneyOwedByOthers: 0.0,
    );

    participants.add(participant);
  }
  return participants;
}

List<Map<String, String>> calculatePayments(List<Participant> participants) {
  List<Participant> moneyLenders = [];
  List<Participant> moneyBorrowers = [];
  List<Map<String, String>> tempSummaryInfo = [];

  for (Participant participant in participants) {
    if (participant.moneyOwedByOthers > 0) {
      moneyLenders.add(participant);
    } else {
      moneyBorrowers.add(participant);
    }
  }

  for (Participant lender in moneyLenders) {
    for (Participant borrower in moneyBorrowers) {
      if (borrower.moneyOwedToOthers > 0 && lender.moneyOwedByOthers > 0) {
        if (lender.moneyOwedByOthers > borrower.moneyOwedToOthers) {
          print(
            "${borrower.participantName} pays ${lender.participantName} ${borrower.moneyOwedToOthers}",
          );
          tempSummaryInfo.add({
            "payer": borrower.participantName,
            "borrower": lender.participantName,
            "amount": "${borrower.moneyOwedToOthers}",
          });
          lender.moneyOwedByOthers -= borrower.moneyOwedToOthers;
          borrower.moneyOwedToOthers = 0;
        } else {
          print(
            "${borrower.participantName} pays ${lender.participantName} ${lender.moneyOwedByOthers}",
          );
          tempSummaryInfo.add({
            "payer": borrower.participantName,
            "borrower": lender.participantName,
            "amount": "${lender.moneyOwedByOthers}",
          });
          borrower.moneyOwedToOthers -= lender.moneyOwedByOthers;
          lender.moneyOwedByOthers = 0;
        }
      }
    }
  }
  return tempSummaryInfo;
}

Future<bool> IfAnyTransactionAssociatedWith(String gid, String username) async {
  Participant? toBeRemovedParticipant;
  List<Participant> participants = await getParticipants(gid);
  List<Expense>? expenses = await DatabaseHelper.getExpensesFromGid(gid);

  for (Expense expense in expenses!) {
    updateParticipant(expense, participants);
  }

  for (Participant participant in participants) {
    if (participant.participantName == username) {
      toBeRemovedParticipant = participant;
    }
  }

  if (toBeRemovedParticipant == null) {
    return false;
  }

  if (toBeRemovedParticipant.moneyPaid > 0 ||
      toBeRemovedParticipant.moneyNeededToPay > 0 ||
      toBeRemovedParticipant.moneyOwedByOthers > 0 ||
      toBeRemovedParticipant.moneyOwedToOthers > 0) {
    return true;
  }

  return false;
}

class SaveAndOpenDocument {
  static Future<File> savePdf({
    required String name,
    required pw.Document pdf,
  }) async {
    final root = Platform.isAndroid
        ? await getExternalStorageDirectory()
        : await getApplicationDocumentsDirectory();
    final file = File('${root?.path}/$name');
    await file.writeAsBytes(await pdf.save());
    debugPrint('${root?.path}/$name');
    return file;
  }

  static Future<void> openPdf(File file) async {
    final path = file.path;
    await OpenFile.open(path);
  }
}

/*class SettlementPdfApi {
  static Future<File> generatePdf(
    Map headers,
    List participants,
    List summary,
  ) async {
    final pdf = pw.Document();

    print("pdf creation");
    print(summary);
    print(participants);

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            children: [
              pw.Center(child: pw.Text("${headers['title']} Expense Report")),
              pw.Text(headers['description']),
              pw.Text("Participants"),
              pw.Text(headers['participants'].join(', ')),
            ],
          ); // Center
        },
      ),
    );
    return SaveAndOpenDocument.savePdf(name: "test.pdf", pdf: pdf);
  }
}*/

class SettlementPdfApi {
  static Future<File> generatePdf(
    Map headers,
    List<Participant> participants,
    List<Map<String, dynamic>> summary, {
    List<Expense>? expenses,
  }) async {
    final pdf = pw.Document();

    // Fetch expenses if not supplied or empty
    List<Expense> groupExpenses = expenses ?? [];
    if (groupExpenses.isEmpty && headers['id'] != null) {
      final fetched =
          await DatabaseHelper.getExpensesFromGid(headers['id'].toString());
      if (fetched != null) {
        groupExpenses = fetched;
      }
    }

    // Define color scheme for the PDF
    final primaryColor = PdfColors.blue800;
    final secondaryColor = PdfColors.grey700;
    final accentColor = PdfColors.green700;
    final headerBackgroundColor = PdfColors.blue50;
    final rowAlternateColor = PdfColors.grey50;

    // Header section
    final headerSection = pw.Container(
      decoration: pw.BoxDecoration(
        color: headerBackgroundColor,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      padding: const pw.EdgeInsets.all(20),
      margin: const pw.EdgeInsets.only(bottom: 20),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Center(
            child: pw.Text(
              "${headers['title']} Expense Report",
              style: pw.TextStyle(
                fontSize: 24,
                fontWeight: pw.FontWeight.bold,
                color: primaryColor,
              ),
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Text(
            headers['description'] ?? '',
            style: pw.TextStyle(
              fontSize: 14,
              color: secondaryColor,
              fontStyle: pw.FontStyle.italic,
            ),
          ),
          pw.SizedBox(height: 15),
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: primaryColor),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  "Participants:",
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                pw.SizedBox(height: 5),
                pw.Text(
                  (headers['participants'] is List)
                      ? (headers['participants'] as List).join(', ')
                      : headers['participants'].toString(),
                  style: pw.TextStyle(fontSize: 14, color: secondaryColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    // Participants Summary Table
    final participantSummaryTable = pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 25),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            "Participants Summary",
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
              color: primaryColor,
            ),
          ),
          pw.SizedBox(height: 12),
          pw.TableHelper.fromTextArray(
            border: pw.TableBorder.all(color: primaryColor, width: 1),
            headerStyle: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white,
            ),
            headerDecoration: pw.BoxDecoration(
              color: primaryColor,
              borderRadius: const pw.BorderRadius.only(
                topLeft: pw.Radius.circular(5),
                topRight: pw.Radius.circular(5),
              ),
            ),
            rowDecoration: pw.BoxDecoration(
              border: pw.Border(
                bottom: pw.BorderSide(color: primaryColor, width: 1),
              ),
            ),
            oddRowDecoration: pw.BoxDecoration(color: rowAlternateColor),
            cellAlignment: pw.Alignment.centerLeft,
            cellPadding: const pw.EdgeInsets.all(8),
            headerAlignment: pw.Alignment.centerLeft,
            data: <List<String>>[
              <String>['Participant', 'Paid', 'Charged', 'Balance'],
              ...participants.map((participant) {
                final balance =
                    participant.moneyOwedToOthers -
                    participant.moneyOwedByOthers;
                final net = balance * -1;
                final netStr = net > 0
                    ? "+ ${net.toStringAsFixed(net.truncateToDouble() == net ? 0 : 2)}"
                    : net < 0
                        ? "- ${(-net).toStringAsFixed((-net).truncateToDouble() == -net ? 0 : 2)}"
                        : "0";

                return <String>[
                  participant.participantName,
                  participant.moneyPaid.toStringAsFixed(participant.moneyPaid.truncateToDouble() == participant.moneyPaid ? 0 : 2),
                  participant.moneyNeededToPay.toStringAsFixed(participant.moneyNeededToPay.truncateToDouble() == participant.moneyNeededToPay ? 0 : 2),
                  netStr,
                ];
              }),
            ],
          ),
        ],
      ),
    );

    // Settlement Instructions Table
    final settlementTable = pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 25),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            "Settlement Instructions",
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
              color: primaryColor,
            ),
          ),
          pw.SizedBox(height: 10),
          if (summary.isEmpty)
            pw.Padding(
              padding: const pw.EdgeInsets.symmetric(vertical: 8),
              child: pw.Text(
                "All debts are settled. No payments required.",
                style: pw.TextStyle(
                  fontSize: 12,
                  color: accentColor,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            )
          else
            pw.TableHelper.fromTextArray(
              border: pw.TableBorder.all(color: primaryColor, width: 1),
              headerStyle: pw.TextStyle(
                fontSize: 12,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
              ),
              headerDecoration: pw.BoxDecoration(
                color: primaryColor,
                borderRadius: const pw.BorderRadius.only(
                  topLeft: pw.Radius.circular(5),
                  topRight: pw.Radius.circular(5),
                ),
              ),
              rowDecoration: pw.BoxDecoration(
                border: pw.Border(
                  bottom: pw.BorderSide(color: primaryColor, width: 1),
                ),
              ),
              oddRowDecoration: pw.BoxDecoration(color: rowAlternateColor),
              cellAlignment: pw.Alignment.centerLeft,
              cellPadding: const pw.EdgeInsets.all(10),
              headerAlignment: pw.Alignment.centerLeft,
              data: <List<String>>[
                <String>['Who Should Pay', 'To Whom', 'How Much'],
                ...summary.map((transaction) {
                  final amt =
                      double.tryParse("${transaction['amount']}") ?? 0.0;
                  final amtStr = amt.truncateToDouble() == amt
                      ? "${amt.toInt()}"
                      : amt.toStringAsFixed(2);
                  return <String>[
                    transaction['payer'] ?? '',
                    transaction['borrower'] ?? '',
                    amtStr,
                  ];
                }),
              ],
            ),
        ],
      ),
    );

    // All Group Expenses Table
    double totalGroupExpenseAmount = 0.0;
    for (var exp in groupExpenses) {
      totalGroupExpenseAmount += exp.amount;
    }

    final allExpensesTable = pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 25),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            "All Group Expenses",
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
              color: primaryColor,
            ),
          ),
          pw.SizedBox(height: 10),
          if (groupExpenses.isEmpty)
            pw.Text(
              "No expenses recorded for this group.",
              style: pw.TextStyle(
                fontSize: 12,
                color: secondaryColor,
                fontStyle: pw.FontStyle.italic,
              ),
            )
          else
            pw.TableHelper.fromTextArray(
              border: pw.TableBorder.all(color: primaryColor, width: 1),
              headerStyle: pw.TextStyle(
                fontSize: 11,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
              ),
              headerDecoration: pw.BoxDecoration(
                color: primaryColor,
                borderRadius: const pw.BorderRadius.only(
                  topLeft: pw.Radius.circular(5),
                  topRight: pw.Radius.circular(5),
                ),
              ),
              rowDecoration: pw.BoxDecoration(
                border: pw.Border(
                  bottom: pw.BorderSide(color: primaryColor, width: 1),
                ),
              ),
              oddRowDecoration: pw.BoxDecoration(color: rowAlternateColor),
              cellAlignment: pw.Alignment.centerLeft,
              cellPadding: const pw.EdgeInsets.all(8),
              data: <List<String>>[
                <String>['Date', 'Expense', 'Paid By', 'Amount', 'Split Among'],
                ...groupExpenses.map((exp) {
                  final bNames = exp.borrowers.split(',');
                  final bAmts = exp.borrowedamt.split(',');
                  final activeBorrowers = <String>[];
                  for (int i = 0; i < bNames.length; i++) {
                    final name = bNames[i].trim();
                    if (name.isEmpty) continue;
                    if (i < bAmts.length) {
                      final amt = double.tryParse(bAmts[i].trim()) ?? 0.0;
                      if (amt > 0) {
                        activeBorrowers.add(name);
                      }
                    }
                  }
                  final splitText = activeBorrowers.isNotEmpty
                      ? activeBorrowers.join(', ')
                      : exp.borrowers
                          .split(',')
                          .map((e) => e.trim())
                          .where((e) => e.isNotEmpty)
                          .join(', ');

                  return <String>[
                    DateFormat('dd MMM yyyy').format(exp.date),
                    exp.tname,
                    exp.payername,
                    "${exp.amount}",
                    splitText,
                  ];
                }),
                <String>[
                  'Total Spending',
                  '',
                  '',
                  "${totalGroupExpenseAmount.truncateToDouble() == totalGroupExpenseAmount ? totalGroupExpenseAmount.toInt() : totalGroupExpenseAmount.toStringAsFixed(2)}",
                  '',
                ],
              ],
            ),
        ],
      ),
    );

    // Section header for Detailed Participant Breakdown
    final participantSectionHeader = pw.Container(
      margin: const pw.EdgeInsets.only(top: 10, bottom: 15),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            "Detailed Expenses by Participant",
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
              color: primaryColor,
            ),
          ),
          pw.SizedBox(height: 5),
          pw.Text(
            "Itemized breakdown of every expense each participant was charged for or paid, explaining why they owe or receive that amount.",
            style: pw.TextStyle(
              fontSize: 11,
              color: secondaryColor,
              fontStyle: pw.FontStyle.italic,
            ),
          ),
        ],
      ),
    );

    // Build per-participant breakdown widgets
    List<pw.Widget> participantDetailWidgets = [participantSectionHeader];

    for (Participant p in participants) {
      List<List<String>> participantRows = [];
      double totalCharged = 0.0;
      double totalPaid = 0.0;

      for (Expense exp in groupExpenses) {
        List<String> bNames = exp.borrowers.split(',');
        List<String> bAmts = exp.borrowedamt.split(',');

        double charged = 0.0;
        int idx = bNames.indexWhere(
          (name) =>
              name.trim().toLowerCase() == p.participantName.trim().toLowerCase(),
        );
        if (idx != -1 && idx < bAmts.length) {
          charged = double.tryParse(bAmts[idx].trim()) ?? 0.0;
        }

        bool isPayer = exp.payername.trim().toLowerCase() ==
            p.participantName.trim().toLowerCase();
        double paid = isPayer ? exp.amount.toDouble() : 0.0;

        if (charged > 0 || isPayer) {
          totalCharged += charged;
          totalPaid += paid;
          participantRows.add([
            DateFormat('dd MMM yyyy').format(exp.date),
            exp.tname,
            "${exp.amount}",
            exp.payername,
            charged > 0
                ? "${charged.truncateToDouble() == charged ? charged.toInt() : charged.toStringAsFixed(2)}"
                : "-",
            isPayer ? "${exp.amount}" : "-",
          ]);
        }
      }

      final double netBalance = totalPaid - totalCharged;
      final String netText = netBalance > 0
          ? "Gets Back: ${netBalance.truncateToDouble() == netBalance ? netBalance.toInt() : netBalance.toStringAsFixed(2)}"
          : netBalance < 0
              ? "Owes: ${(-netBalance).truncateToDouble() == -netBalance ? (-netBalance).toInt() : (-netBalance).toStringAsFixed(2)}"
              : "Settled (0)";

      participantDetailWidgets.add(
        pw.Container(
          margin: const pw.EdgeInsets.only(bottom: 20),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: primaryColor, width: 0.8),
            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Participant banner
              pw.Container(
                padding:
                    const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                decoration: pw.BoxDecoration(
                  color: primaryColor,
                  borderRadius: const pw.BorderRadius.only(
                    topLeft: pw.Radius.circular(5),
                    topRight: pw.Radius.circular(5),
                  ),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      p.participantName,
                      style: pw.TextStyle(
                        fontSize: 13,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.white,
                      ),
                    ),
                    pw.Text(
                      netText,
                      style: pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                        color: netBalance >= 0
                            ? PdfColors.green100
                            : PdfColors.amber100,
                      ),
                    ),
                  ],
                ),
              ),
              if (participantRows.isEmpty)
                pw.Padding(
                  padding: const pw.EdgeInsets.all(12),
                  child: pw.Text(
                    "No expenses charged to or paid by ${p.participantName}.",
                    style: pw.TextStyle(
                      fontSize: 11,
                      color: secondaryColor,
                      fontStyle: pw.FontStyle.italic,
                    ),
                  ),
                )
              else
                pw.TableHelper.fromTextArray(
                  border: pw.TableBorder(
                    horizontalInside: pw.BorderSide(
                      color: PdfColors.grey300,
                      width: 0.5,
                    ),
                  ),
                  headerStyle: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blue900,
                  ),
                  headerDecoration: pw.BoxDecoration(
                    color: headerBackgroundColor,
                  ),
                  rowDecoration: const pw.BoxDecoration(),
                  oddRowDecoration: pw.BoxDecoration(color: rowAlternateColor),
                  cellAlignment: pw.Alignment.centerLeft,
                  cellPadding: const pw.EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 6,
                  ),
                  cellStyle: const pw.TextStyle(fontSize: 10),
                  data: <List<String>>[
                    <String>[
                      'Date',
                      'Expense',
                      'Total Cost',
                      'Paid By',
                      'Their Share',
                      'Paid by Them',
                    ],
                    ...participantRows,
                    <String>[
                      'Total',
                      '',
                      '',
                      '',
                      "${totalCharged.truncateToDouble() == totalCharged ? totalCharged.toInt() : totalCharged.toStringAsFixed(2)}",
                      "${totalPaid.truncateToDouble() == totalPaid ? totalPaid.toInt() : totalPaid.toStringAsFixed(2)}",
                    ],
                  ],
                ),
            ],
          ),
        ),
      );
    }

    // Build the PDF
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(30),
        build: (pw.Context context) {
          return [
            headerSection,
            pw.SizedBox(height: 10),
            participantSummaryTable,
            pw.SizedBox(height: 10),
            settlementTable,
            pw.SizedBox(height: 10),
            allExpensesTable,
            pw.SizedBox(height: 10),
            ...participantDetailWidgets,
          ];
        },
      ),
    );

    // Create filename with timestamp
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final fileName =
        "${headers['title'].toString().replaceAll(' ', '_')}_$timestamp.pdf";

    return SaveAndOpenDocument.savePdf(name: fileName, pdf: pdf);
  }
}

// Helper to get application documents directory
Future<Directory> getApplicationDocumentsDirectory() async {
  return Directory
      .systemTemp; // You might want to change this based on your needs
}
