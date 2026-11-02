import 'package:money_manager/constants/theme_data.dart';
import 'package:money_manager/database/database_helper.dart';
import 'package:money_manager/models/models.dart';
import 'package:money_manager/pages/group_expens_page.dart';
import 'package:money_manager/pages/new_group_page.dart';
import 'package:money_manager/widgets/widgets.dart';
import 'package:flutter/material.dart';

class GroupExpensePage extends StatefulWidget {
  const GroupExpensePage({super.key});

  @override
  State<GroupExpensePage> createState() => _SplitExpensePageState();
}

class _SplitExpensePageState extends State<GroupExpensePage> {
  Future<List<Map<String, String>>> getGroups() async {
    List<Map<String, String>> groupInfo = [];
    List<Group>? groups = await DatabaseHelper.getAllGroups();
    for (int i = 0; i < groups!.length; i++) {
      //print();
      groupInfo.add({
        'id': '${groups[i].id}',
        'title': groups[i].title,
        'description': groups[i].description,
        'participants': groups[i].participants,
      });
    }
    return groupInfo;
  }

  void addGroup() async {
    await getGroups();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white3,
      appBar: AppBar(
        elevation: 0,
        foregroundColor: dark4,
        backgroundColor: white3,
        title: Padding(
          padding: const EdgeInsets.all(10),
          child: Text(
            'Split Expense',
            style: TextStyle(
              color: dark2,
              fontSize: 22,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        centerTitle: false,
        toolbarHeight: 70,
        //automaticallyImplyLeading: false,
      ),
      body: FutureBuilder(
        future: getGroups(),
        builder: (context, snapshot) {
          List<Map<String, String>>? data = snapshot.data;
          if (snapshot.hasData) {
            print(snapshot.data);
            return ListView.builder(
              itemCount: data!.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 7,
                  ),
                  child: Material(
                    color: white1,
                    borderRadius: BorderRadius.circular(10),
                    clipBehavior: Clip.antiAlias,
                    child: Dismissible(
                      background: Container(
                        decoration: BoxDecoration(
                          color: red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        //color: nord_red,
                        child: Icon(Icons.delete, color: dark2),
                      ),
                      onDismissed: (direction) {
                        DatabaseHelper.deleteGroup(data[index]['id']!);
                      },
                      key: ValueKey<int>(index),
                      child: ListTile(
                        title: Text(
                          data[index]['title']!,
                          style: TextStyle(
                            color: dark_blue,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: Text(
                          data[index]['description']!,
                          style: TextStyle(
                            color: dark3,
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        trailing: Icon(
                          Icons.arrow_forward_ios,
                          color: dark_blue,
                        ),
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SplitExpensePage(
                                id: data[index]['id']!,
                                participants: data[index]['participants']!,
                              ),
                            ),
                          );
                          setState(() {});
                        },
                      ),
                    ),
                  ),
                );
              },
            );
          }
          return Container();
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: dark_blue,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        onPressed: () {
          nextScreen(
            context,
            SplitExpenseNewGroupPage(id: "", updateGroups: addGroup),
          );
        },
        label: Text(
          "New Group",
          style: TextStyle(fontWeight: FontWeight.w500, color: white1),
        ),
        icon: Icon(Icons.add, color: white1),
      ),
    );
  }
}
