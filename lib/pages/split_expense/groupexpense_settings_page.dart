import 'package:money_manager/constants/theme_data.dart';
import 'package:money_manager/database/database_helper.dart';
import 'package:money_manager/models/models.dart';
import 'package:money_manager/pages/new_group_page.dart';
import 'package:money_manager/pages/split_expense/functions.dart';
import 'package:money_manager/pages/split_expense/pdr_template_page.dart';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;

class SplitExpenseSettingsPage extends StatefulWidget {
  final String id;
  const SplitExpenseSettingsPage({required this.id, super.key});

  @override
  State<SplitExpenseSettingsPage> createState() =>
      _SplitExpenseSettingsPageState();
}

class _SplitExpenseSettingsPageState extends State<SplitExpenseSettingsPage> {
  late String id = '';
  late String title = 'Title';
  late String description = 'No description';
  late List<String> participantNames = [];

  late List<Expense>? expenses = [];
  List<Map<String, String>> summaryInfo = [];

  Future<List<Participant>> settle() async {
    late List<Participant> participants = [];
    late List<Participant> tempParticipants = [];

    participants = await getParticipants(widget.id);
    tempParticipants = await getParticipants(widget.id);
    expenses = await DatabaseHelper.getExpensesFromGid(widget.id);

    for (Expense expense in expenses!) {
      updateParticipant(expense, participants);
      updateParticipant(expense, tempParticipants);
    }

    summaryInfo = calculatePayments(tempParticipants);
    print(summaryInfo);

    return participants;
  }

  void getGroupInfo() async {
    Group? group = await DatabaseHelper.getGroupByID(widget.id);
    print(group!.title);
    title = group.title;
    id = "${group.id!}";
    description = group.description;
    String encodedNames = group.participants;
    participantNames = encodedNames.split(",");
    print(participantNames);
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    getGroupInfo();
    settle();
  }

  void onAddRemove() {
    //Navigator.pop(context);
    print('a');
    getGroupInfo();

    print('add remove');
    print(participantNames);
    //Navigator.pop(context);
  }

  Future<void> printDoc() async {
    final doc = pw.Document();
    doc.addPage(
      pw.Page(
        build: (pw.Context context) {
          return buildPrintableData();
        },
      ),
    );
    await Printing.layoutPdf(onLayout: (format) async => doc.save());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white3,
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: ListView(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: Container(
                color: white1,
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Title',
                        style: TextStyle(
                          color: dark_blue,
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        title,
                        style: TextStyle(
                          color: dark3,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 15),
                      Text(
                        'Description',
                        style: TextStyle(
                          color: dark_blue,
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        description,
                        style: TextStyle(
                          color: dark3,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 15),
            ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: Container(
                color: white1,
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Participants',
                        style: TextStyle(
                          color: dark_blue,
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (int i = 0; i < participantNames.length; i++)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 0,
                                vertical: 10,
                              ),
                              child: Text(
                                participantNames[i],
                                style: TextStyle(
                                  color: dark3,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 15),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 15),
            Material(
              color: white1,
              borderRadius: BorderRadius.circular(5),
              clipBehavior: Clip.antiAlias,
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Options',
                      style: TextStyle(
                        color: dark_blue,
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 5),
                    ListTile(
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SplitExpenseNewGroupPage(
                              id: widget.id,
                              updateGroups: () {
                                getGroupInfo();
                                settle();
                              },
                            ),
                          ),
                        );
                        getGroupInfo();
                        settle();
                      },
                      title: Text(
                        'edit',
                        style: TextStyle(
                          color: dark3,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      trailing: Icon(Icons.edit, color: dark_blue),
                    ),
                    ListTile(
                      onTap: () async {
                        final participantsData = await settle();
                        final settlementPdf =
                            await SettlementPdfApi.generatePdf(
                              {
                                'title': title,
                                'description': description,
                                'participants': participantNames,
                                'id': widget.id,
                              },
                              participantsData,
                              summaryInfo,
                              expenses: expenses,
                            );
                        SaveAndOpenDocument.openPdf(settlementPdf);
                      }, //printDoc,
                      title: Text(
                        'download',
                        style: TextStyle(
                          color: dark3,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      trailing: Icon(Icons.download, color: dark_blue),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
