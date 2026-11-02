import 'package:money_manager/database/database_helper.dart';
import 'package:money_manager/models/models.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

String getBackupName() {
  DateTime today = DateTime.now();
  return "backup ${today.day}-${today.month}-${today.year}.db";
}

Future<String> getUserName() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  String? username = prefs.getString('username');
  if (username == null) {
    username = "User";
    await prefs.setString('username', username);
  }
  return username;
}

void setUserName(String username) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('username', username);
}

void set24Format(bool value) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setBool('use24format', value);
}

void setEnableBiometrics(bool value) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setBool('enableBiometrics', value);
}

Future<bool> get24FormatStatus() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  bool? value = prefs.getBool('use24format');
  if (value == null) {
    value = false;
    await prefs.setBool('use24format', value);
  }
  return value;
}

Future<bool> getEnableBiometricsStatus() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  bool? value = prefs.getBool('enableBiometrics');
  if (value == null) {
    value = false;
    await prefs.setBool('enableBiometrics', value);
  }
  print("satatus is");
  print(value);
  return value;
}

void setDateFormatIndex(int value) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setInt('dateFormatIndex', value);
  formatedDate(DateTime.now());
}

Future<int> getDateFormatIndex() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  int? value = prefs.getInt('dateFormatIndex');
  if (value == null) {
    value = 0;
    await prefs.setInt('dateFormatIndex', value);
  }
  return value;
}

void setIsLoggedIn(bool value) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  print("setiing loged in stattus as $value");
  await prefs.setBool('isLoggedIn', value);
}

Future<bool> getIsLoggedInStatus() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  bool? value = prefs.getBool('isLoggedIn');
  if (value == null) {
    value = false;
    await prefs.setBool('isLoggedIn', value);
  }
  return value;
}

void setCurrency(String value) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('currency', value);
}

Future<String> getFormatedAmount(int amount) async {
  final formatter = NumberFormat('##,##,##0.##');
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  String? currency = prefs.getString('currency');
  if (currency == null) {
    currency = "₹";
    await prefs.setString('currency', currency);
  }

  return "$currency ${formatter.format(amount)}.00";
}

List<DateTime> getDates(List<TransactionModel> transactions) {
  List<DateTime> dates = [];
  List<DateTime> uniqueDates = [];
  for (TransactionModel transaction in transactions) {
    dates.add(
      DateTime(
        transaction.date.year,
        transaction.date.month,
        transaction.date.day,
      ),
    );
  }

  for (DateTime date in dates) {
    if (!uniqueDates.contains(date)) {
      uniqueDates.add(date);
    }
  }

  return uniqueDates;
}

Future<String> formatedDate(DateTime date) async {
  int format = await getDateFormatIndex();
  String prettyDate = "";
  switch (format) {
    case 0:
      prettyDate = "${date.day} ${DateFormat.MMM().format(date)}, ${date.year}";
      break;
    case 1:
      prettyDate = "${DateFormat.MMM().format(date)} ${date.day}, ${date.year}";
      break;
    case 2:
      prettyDate =
          "${date.year}, ${DateFormat.MMM().format(date)} ${date.month}";
      break;
  }
  return prettyDate;
}

String formatAmount(int amt) {
  final formatter = NumberFormat('##,##,##0.##');
  return formatter.format(amt);
}

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
