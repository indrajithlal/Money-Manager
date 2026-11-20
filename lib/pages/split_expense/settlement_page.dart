import 'package:money_manager/constants/theme_data.dart';
import 'package:money_manager/database/database_helper.dart';
import 'package:money_manager/functions/functions.dart';
import 'package:money_manager/models/models.dart';
import 'package:money_manager/pages/split_expense/functions.dart'
    show SettlementPdfApi, SaveAndOpenDocument;
import 'package:flutter/material.dart';

class SplitExpensePageSettlePage extends StatefulWidget {
  final String gid;
  final String currency;
  const SplitExpensePageSettlePage({
    required this.gid,
    this.currency = '₹',
    super.key,
  });

  @override
  State<SplitExpensePageSettlePage> createState() =>
      _SplitExpensePageSettlePageState();
}

class _SplitExpensePageSettlePageState
    extends State<SplitExpensePageSettlePage> {
  late List<Expense>? expenses = [];
  List<Map<String, String>> summaryInfo = [];

  Future<List<Participant>> settle() async {
    late List<Participant> participants = [];
    late List<Participant> tempParticipants = [];

    participants = await getParticipants(widget.gid);
    tempParticipants = await getParticipants(widget.gid);
    expenses = await DatabaseHelper.getExpensesFromGid(widget.gid);

    for (Expense expense in expenses!) {
      updateParticipant(expense, participants);
      updateParticipant(expense, tempParticipants);
    }

    summaryInfo = calculatePayments(tempParticipants);

    return participants;
  }

  @override
  void initState() {
    super.initState();
    settle();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white3,
      body: FutureBuilder(
        future: settle(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<Participant>? data = snapshot.data;
            return Padding(
              padding: const EdgeInsets.all(10),
              child: ListView(
                children: [
                  Material(
                    color: white1,
                    borderRadius: BorderRadius.circular(10),
                    clipBehavior: Clip.antiAlias,
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Summary',
                            style: TextStyle(
                              color: dark_blue,
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Column(
                            children: [
                              for (
                                int index = 0;
                                index < data!.length;
                                index++
                              )
                                ListTile(
                                  title: Text(
                                    data[index].participantName,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                      color: dark4,
                                    ),
                                  ),
                                  subtitle: Text(
                                    "Charged ${widget.currency} ${data[index].moneyNeededToPay}, Paid ${widget.currency} ${data[index].moneyPaid}",
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                      color: dark3,
                                    ),
                                  ),
                                  trailing: Text(
                                    "${data[index].moneyPaid - data[index].moneyNeededToPay < 0 ? "-${widget.currency} ${(data[index].moneyNeededToPay - data[index].moneyPaid)}" : (data[index].moneyPaid - data[index].moneyNeededToPay > 0 ? "+${widget.currency} ${(data[index].moneyPaid - data[index].moneyNeededToPay)}" : "${widget.currency} 0")}",
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                      color:
                                          data[index].moneyPaid -
                                                  data[index]
                                                      .moneyNeededToPay <
                                              0
                                          ? red
                                          : dark_blue,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Material(
                    color: white1,
                    borderRadius: BorderRadius.circular(10),
                    clipBehavior: Clip.antiAlias,
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'How to settle?',
                            style: TextStyle(
                              color: dark_blue,
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Column(
                            children: [
                              for (
                                int index = 0;
                                index < summaryInfo.length;
                                index++
                              )
                                ListTile(
                                  title: Text(
                                    summaryInfo[index]["payer"]!,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                      color: dark4,
                                    ),
                                  ),
                                  subtitle: Text(
                                    "should pay to ${summaryInfo[index]["borrower"]!}",
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                      color: dark3,
                                    ),
                                  ),
                                  trailing: Text(
                                    "${widget.currency} ${summaryInfo[index]["amount"]!}",
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                      color: dark_blue,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () async {
                      Group? group =
                          await DatabaseHelper.getGroupByID(widget.gid);
                      if (group != null) {
                        final settlementPdf =
                            await SettlementPdfApi.generatePdf(
                              {
                                'title': group.title,
                                'description': group.description,
                                'participants': group.participants.split(','),
                                'id': widget.gid,
                              },
                              data,
                              summaryInfo,
                              expenses: expenses,
                            );
                        SaveAndOpenDocument.openPdf(settlementPdf);
                      }
                    },
                    icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
                    label: const Text(
                      "Download PDF Report",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: dark_blue,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                ],
              ),
            );
          }
          return Container();
        },
      ),
    );
  }
}
