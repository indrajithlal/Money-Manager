class Group{
  final int? id;
  final String title;
  final String description;
  final String participants;

  const Group({required this.title, required this.description,required this.participants, this.id});

  factory Group.fromJson(Map<String,dynamic> json) => Group(
    id: json['id'],
    title: json['title'], 
    description: json['description'],
    participants: json['participants'],
  );

  Map<String,dynamic> toJson() => {
    //'id':id,
    'title':title,
    'description':description,
    'participants': participants
  };

}

class Expense{
  final int? tid;
  final int gid;
  final String tname;
  final String payername;
  final int amount;
  final DateTime date;
  final String borrowers;
  final String borrowedamt;

  const Expense({required this.gid, required this.tname,required this.payername,required this.amount,required this.date,required this.borrowers,required this.borrowedamt, this.tid});

  factory Expense.fromJson(Map<String,dynamic> json) => Expense(
    tid: json['tid'],
    gid: json['gid'],
    tname: json['tname'], 
    payername: json['payername'],
    amount: json['amount'],
    date: DateTime.parse(json['date']),
    borrowers: json['borrowers'],
    borrowedamt: json['borrowedamt'],
  );

  Map<String,dynamic> toJson() => {
    //'id':id,
    'gid':gid,
    'tname':tname,
    'payername': payername,
    'amount':amount,
    'date':date.toIso8601String(),
    'borrowers':borrowers,
    'borrowedamt':borrowedamt,
  };

}

class TransactionModel {
  String name;
  int amount;
  String category;
  String account;
  DateTime date;
  String description;
  bool isExpense;

  TransactionModel({
    required this.name,
    required this.amount,
    required this.category,
    required this.account,
    required this.date,
    required this.description,
    required this.isExpense
  });

  factory TransactionModel.fromJson(Map<String,dynamic> json) => TransactionModel(
    name: json['name'],
    amount: json['amount'],
    category: json['category'], 
    account: json['account'],
    date: DateTime.parse(json['date']),
    description: json['description'] ?? '',
    isExpense: json['isExpense'] == 'true',
  );


  Map<String,dynamic> toJson() => {
    'name':name,
    'amount':amount,
    'category': category,
    'account': account,
    'date': date.toIso8601String(),
    'description': description,
    'isExpense': "$isExpense"
  };
}

class Participant {
  String participantName;
  double moneyPaid;
  double moneyNeededToPay;
  double moneyOwedToOthers;
  double moneyOwedByOthers;

  Participant({
    required this.participantName,
    required this.moneyPaid,
    required this.moneyNeededToPay,
    required this.moneyOwedToOthers,
    required this.moneyOwedByOthers,
  });
}