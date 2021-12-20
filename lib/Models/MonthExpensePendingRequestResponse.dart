import 'package:societyrun/GlobalClasses/GlobalVariables.dart';

class MonthExpensePendingRequestResponse{

  List<dynamic>? expense;
  List<dynamic>? pending_request;
  String? Receipt_count;
  String? Receipt_amount;
  String? Expense_count;
  String? Expense_amount;
  String? message;
  bool? status;

  MonthExpensePendingRequestResponse({this.expense,this.pending_request,this.message, this.status,this.Receipt_count,this.Receipt_amount,this.Expense_count,this.Expense_amount});


  factory MonthExpensePendingRequestResponse.fromJson(Map<String, dynamic> map){

    return MonthExpensePendingRequestResponse(
        expense: map['expense'],
        pending_request: map['pending_request'],
        Receipt_count: map["Receipt_count"],
        Receipt_amount: map["Receipt_amount"],
        Expense_count: map["Expense_count"],
        Expense_amount: map["Expense_amount"],
        status: map[GlobalVariables.STATUS],
        message: map[GlobalVariables.MESSAGE]
    );

  }
}

class MonthExpenses{

  String? month,exp_amount;

  MonthExpenses({this.month, this.exp_amount});

  factory MonthExpenses.fromJson(Map<String,dynamic> map){
    return MonthExpenses(
      month: map["month"],
      exp_amount: map["exp_amount"]??"0",
    );
  }
}