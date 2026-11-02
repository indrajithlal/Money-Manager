import 'package:money_manager/constants/theme_data.dart';
import 'package:money_manager/database/database_helper.dart';
import 'package:money_manager/functions/functions.dart';
import 'package:money_manager/models/models.dart';
import 'package:money_manager/widgets/widgets.dart';
import 'package:flutter/material.dart';

class SplitExpenseNewGroupPage extends StatefulWidget {
  final String id;
  final Function() updateGroups;
  const SplitExpenseNewGroupPage({
    required this.updateGroups,
    required this.id,
    super.key,
  });

  @override
  State<SplitExpenseNewGroupPage> createState() =>
      _SplitExpenseNewGroupPageState();
}

class _SplitExpenseNewGroupPageState extends State<SplitExpenseNewGroupPage> {
  String title = "";
  String description = "";
  List<String> participantNames = [];
  TextEditingController nameController = TextEditingController();
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  String encodeParticipanNames() {
    String encodedName = '';
    for (String name in participantNames) {
      encodedName += '$name,';
    }
    if (encodedName.isEmpty) {
      return "";
    }
    return encodedName.substring(0, encodedName.length - 1);
  }

  void getGroupInfo() async {
    if (widget.id.isEmpty) {
      title = "";
      description = "";
      return;
    }
    Group? group = await DatabaseHelper.getGroupByID(widget.id);
    print(group!.title);
    title = group.title;
    description = group.description;
    String encodedNames = group.participants;
    participantNames = encodedNames.split(",");
    titleController.text = title;
    descriptionController.text = description;
    print(participantNames);
    setState(() {});
  }

  Future<void> saveGroupToDB() async {
    String title = titleController.text.trim().toLowerCase();
    String description = descriptionController.text.trim().toLowerCase();
    String participants = encodeParticipanNames();

    Group group = Group(
      title: title,
      description: description,
      participants: participants,
    );
    await DatabaseHelper.addGroup(group);
  }

  Future<bool> updateGroupInDB() async {
    String title = titleController.text.trim().toLowerCase();
    String description = descriptionController.text.trim().toLowerCase();
    String participants = encodeParticipanNames();
    Group? oldGroup = await DatabaseHelper.getGroupByID(widget.id);

    Group group = Group(
      id: int.parse(widget.id),
      title: title,
      description: description,
      participants: participants,
    );

    List<String> oldUsers =
        (oldGroup != null && oldGroup.participants.isNotEmpty)
            ? oldGroup.participants.split(',')
            : [];
    List<String> newUsers =
        participants.isNotEmpty ? participants.split(',') : [];
    List<String> removedUsers = [];

    for (String username in oldUsers) {
      if (!newUsers.contains(username)) {
        removedUsers.add(username);
      }
    }

    bool proceed = true;
    for (String user in removedUsers) {
      if (await IfAnyTransactionAssociatedWith(widget.id, user)) {
        proceed = false;
      }
    }
    if (proceed) {
      await DatabaseHelper.updateGroup(group);
      return true;
    } else {
      if (mounted) {
        showAlert(
          context,
          "Update Failed",
          "One or more users you are trying to remove is associated with some transactions!",
          () {},
          () {},
        );
      }
      return false;
    }
  }

  @override
  void initState() {
    super.initState();
    getGroupInfo();
    titleController.text = title;
    descriptionController.text = description;
    for (String name in participantNames) {
      participantNames.add(name);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: white3,
      appBar: AppBar(
        backgroundColor: dark1,
        foregroundColor: white2,
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () {
            print('cancel');
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios, size: 30, color: white1),
        ),
        elevation: 0,
        title: Text(
          widget.id.isEmpty ? "New Group" : "Update Group",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w500,
            color: white2,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15),
            child: Center(
              child: GestureDetector(
                onTap: () async {
                  if (widget.id.isEmpty) {
                    await saveGroupToDB();
                    widget.updateGroups();
                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                  } else {
                    bool proceed = await updateGroupInDB();
                    if (proceed) {
                      widget.updateGroups();
                      if (context.mounted) {
                        Navigator.pop(context);
                      }
                    }
                  }
                },
                child: Text(
                  widget.id.isEmpty ? "Save" : "Update",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w500,
                    color: white1,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                color: white1,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 5,
                    horizontal: 20,
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: 120,
                            child: Text(
                              'Title',
                              style: TextStyle(
                                color: dark_blue,
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: titleController,
                              cursorColor: dark_blue,
                              style: TextStyle(
                                color: dark3,
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                              decoration: InputDecoration(
                                hintText: '',
                                border: UnderlineInputBorder(
                                  borderSide: BorderSide(color: dark_blue),
                                ),
                                focusColor: dark_blue,
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: dark_blue),
                                ),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: dark3),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: 120,
                            child: Text(
                              'Description',
                              style: TextStyle(
                                color: dark_blue,
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: descriptionController,
                              cursorColor: dark_blue,
                              style: TextStyle(
                                color: dark3,
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                              decoration: InputDecoration(
                                hintText: '',
                                border: UnderlineInputBorder(
                                  borderSide: BorderSide(color: dark_blue),
                                ),
                                focusColor: dark_blue,
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: dark_blue),
                                ),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: dark3),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                color: white1,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 5,
                    horizontal: 20,
                  ),
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          child: Text(
                            "Participants",
                            style: TextStyle(
                              color: dark3,
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      Column(
                        children: [
                          for (
                            int index = 0;
                            index < participantNames.length;
                            index++
                          )
                            Row(
                              children: [
                                Text(
                                  participantNames[index],
                                  style: TextStyle(
                                    color: dark3,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Expanded(child: Container()),
                                SizedBox(
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      elevation: 0,
                                      backgroundColor: red,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        participantNames.removeAt(index);
                                      });
                                    },
                                    child: Text(
                                      "Remove",
                                      style: TextStyle(
                                        color: white1,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: nameController,
                              cursorColor: dark_blue,
                              style: TextStyle(
                                color: dark3,
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                              decoration: InputDecoration(
                                hintText: '',
                                border: UnderlineInputBorder(
                                  borderSide: BorderSide(color: dark_blue),
                                ),
                                focusColor: dark_blue,
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: dark_blue),
                                ),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: dark3),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 50),
                          SizedBox(
                            width: 100,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                elevation: 0,
                                backgroundColor: dark_blue,
                              ),
                              onPressed: () {
                                if (nameController.text.isNotEmpty) {
                                  for (String name in participantNames) {
                                    if (nameController.text
                                            .toLowerCase()
                                            .trim() ==
                                        name.toLowerCase().trim()) {
                                      nameController.text = '';
                                      return;
                                    }
                                  }
                                  participantNames.add(
                                    nameController.text.replaceAll(",", " "),
                                  );
                                  nameController.text = '';
                                }

                                setState(() {});
                              },
                              child: Text(
                                "Add",
                                style: TextStyle(
                                  color: white1,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
