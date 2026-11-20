import 'package:money_manager/constants/theme_data.dart';
import 'package:money_manager/database/database_helper.dart';
import 'package:money_manager/models/models.dart';
import 'package:money_manager/pages/group_expens_page.dart';
import 'package:money_manager/pages/new_group_page.dart';
import 'package:money_manager/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class GroupExpensePage extends StatefulWidget {
  const GroupExpensePage({super.key});

  @override
  State<GroupExpensePage> createState() => _SplitExpensePageState();
}

class _SplitExpensePageState extends State<GroupExpensePage> {
  List<Map<String, String>> groups = [];
  bool isLoading = true;

  Future<void> loadGroups() async {
    List<Map<String, String>> groupInfo = [];
    List<Group>? groupList = await DatabaseHelper.getAllGroups();
    if (groupList != null) {
      for (int i = 0; i < groupList.length; i++) {
        groupInfo.add({
          'id': '${groupList[i].id}',
          'title': groupList[i].title,
          'description': groupList[i].description,
          'participants': groupList[i].participants,
        });
      }
    }
    if (mounted) {
      setState(() {
        groups = groupInfo;
        isLoading = false;
      });
    }
  }

  void addGroup() async {
    await loadGroups();
  }

  void onDelete(Map<String, String> group) async {
    await DatabaseHelper.deleteGroup(group['id']!);
    if (mounted) {
      setState(() {
        groups.removeWhere((g) => g['id'] == group['id']);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    loadGroups();
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
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : groups.isEmpty
              ? Center(
                  child: Text(
                    "No split expense sessions yet",
                    style: TextStyle(
                      color: dark3,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )
              : ListView.builder(
                  itemCount: groups.length,
                  itemBuilder: (context, index) {
                    final group = groups[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 7,
                      ),
                      child: Slidable(
                        key: ValueKey(group['id']),
                        startActionPane: ActionPane(
                          motion: const ScrollMotion(),
                          extentRatio: 1 / 4,
                          children: [
                            SlidableAction(
                              onPressed: (context) {
                                onDelete(group);
                              },
                              borderRadius: BorderRadius.circular(10),
                              backgroundColor: red,
                              foregroundColor: dark2,
                              icon: Icons.delete,
                              label: 'delete',
                            ),
                          ],
                        ),
                        endActionPane: ActionPane(
                          motion: const ScrollMotion(),
                          extentRatio: 1 / 4,
                          children: [
                            SlidableAction(
                              onPressed: (context) {
                                onDelete(group);
                              },
                              borderRadius: BorderRadius.circular(10),
                              backgroundColor: red,
                              foregroundColor: dark2,
                              icon: Icons.delete,
                              label: 'delete',
                            ),
                          ],
                        ),
                        child: Material(
                          color: white1,
                          borderRadius: BorderRadius.circular(10),
                          clipBehavior: Clip.antiAlias,
                          child: ListTile(
                            title: Text(
                              group['title']!,
                              style: TextStyle(
                                color: dark_blue,
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            subtitle: Text(
                              group['description']!,
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
                                    id: group['id']!,
                                    participants: group['participants']!,
                                  ),
                                ),
                              );
                              loadGroups();
                            },
                          ),
                        ),
                      ),
                    );
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
