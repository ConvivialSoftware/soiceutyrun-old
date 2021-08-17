import 'package:retrofit/retrofit.dart';
import 'package:dio/dio.dart';
import 'package:societyrun/GlobalClasses/GlobalVariables.dart';
import 'package:societyrun/Models/BankResponse.dart';
import 'package:societyrun/Models/BillViewResponse.dart';
import 'package:societyrun/Models/DataResponse.dart';
import 'package:societyrun/Models/DuesResponse.dart';
import 'package:societyrun/Models/LedgerResponse.dart';
import 'package:societyrun/Models/MonthExpensePendingRequestResponse.dart';
import 'package:societyrun/Models/ReceiptViewResponse.dart';
import 'package:societyrun/Models/StatusMsgResponse.dart';
import 'RestAPI.dart';

@RestApi(baseUrl: GlobalVariables.BaseURLERP)
abstract class RestClientERP {

  factory RestClientERP(Dio dio, {String baseUrl}) = RestAPI;

  @FormUrlEncoded()
  @POST(GlobalVariables.duesAPI)
  Future<DuesResponse> getDuesData(@Field("SOCIETY_ID") String socId, @Field("FLAT") String flat,
      @Field("BLOCK") String block );

  @FormUrlEncoded()
  @POST(GlobalVariables.ledgerAPI)
  Future<LedgerResponse> getLedgerData(@Field("SOCIETY_ID") String socId, @Field("FLAT") String flat,
      @Field("BLOCK") String block,@Field("YEAR") String year);

  @FormUrlEncoded()
  @POST(GlobalVariables.viewBillsAPI)
  Future<DataResponse> getAllBillData(@Field("SOCIETY_ID") String socId, @Field("FLAT") String flat,
      @Field("BLOCK") String block );

  @FormUrlEncoded()
  @POST(GlobalVariables.billAPI)
  Future<BillViewResponse> getBillData(@Field("SOCIETY_ID") String socId, @Field("FLAT") String flat,
      @Field("BLOCK") String block,@Field("INVOICE_NO") String invoiceNo,@Field("YEAR") String year );

  @FormUrlEncoded()
  @POST(GlobalVariables.receiptAPI)
  Future<ReceiptViewResponse> getReceiptData(@Field("SOCIETY_ID") String socId, @Field("FLAT") String flat,
      @Field("BLOCK") String block,@Field("RECEIPT_NO") String receiptNo,@Field("YEAR") String year);

  @FormUrlEncoded()
  @POST(GlobalVariables.bankAPI)
  Future<BankResponse> getBankData(@Field("SOCIETY_ID") String socId,@Field("INVOICE_NO") String invoiceNo);

  @FormUrlEncoded()
  @POST(GlobalVariables.paymentRequestAPI)
  Future<StatusMsgResponse> addAlreadyPaidPaymentRequest(@Field("SOCIETY_ID") String socId, @Field("FLAT") String flat,
      @Field("BLOCK") String block,@Field("INVOICE_NO") String invoiceNo,@Field("AMOUNT") String amount,
      @Field("REFERENCE_NO") String referenceNo,@Field("TRANSACTION_MODE") String transactionMode,
      @Field("BANK_ACCOUNTNO") String bankAccountNo,@Field("PAYMENT_DATE") String paymentDate,
      @Field("USER_ID") String userId,@Field("NARRATION") String narration,@Field("CHEQUE_BANKNAME") String checkBankName,
      @Field("ATTACHMENT") String attachment,@Field("STATUS") String status,);

  @FormUrlEncoded()
  @POST(GlobalVariables.insertPaymentAPI)
  Future<StatusMsgResponse> addOnlinePaymentRequest( @Field("SOCIETY_ID") String socId, @Field("FLAT") String flat,
      @Field("BLOCK") String block,@Field("INVOICE_NO") String invoiceNo,@Field("AMOUNT") String amount,
      @Field("REFERENCE_NO") String referenceNo,@Field("TRANSACTION_MODE") String transactionMode,
      @Field("BANK_ACCOUNTNO") String bankAccountNo,@Field("PAYMENT_DATE") String paymentDate,@Field("STATUS") String paymentStatus,@Field("ORDER_ID") String orderID);

  @FormUrlEncoded()
  @POST(GlobalVariables.mailAPI)
  Future<StatusMsgResponse> getBillMail(@Field("SOCIETY_ID") String socId, @Field("TYPE") String type,
      @Field("NUMBER") String number,@Field("Email_id") String emailId,@Field("YEAR") String year);

  @FormUrlEncoded()
  @POST(GlobalVariables.razorPayTransactionAPI)
  Future<StatusMsgResponse> postRazorPayTransactionOrderID(@Field("SOCIETY_ID") String socId, @Field("FLAT_NO") String flat,
      @Field("ORDER_ID") String orderId,@Field("AMOUNT") String amount);

  @FormUrlEncoded()
  @POST(GlobalVariables.expenseAPI)
  Future<DataResponse> getExpenseData(@Field("SOCIETY_ID") String socId,@Field("START_DATE") String startDate,@
  Field("END_DATE") String endDate,@Field("HEADS") String heads,@Field("LEDGER_YEAR") String ledgerYear);

  @FormUrlEncoded()
  @POST(GlobalVariables.accountLedgerAPI)
  Future<DataResponse> getExpenseAccountLedger(@Field("SOCIETY_ID") String socId);

  @FormUrlEncoded()
  @POST(GlobalVariables.incomeLedgerAPI)
  Future<DataResponse> getExpenseIncomeLedger(@Field("SOCIETY_ID") String socId);

  @FormUrlEncoded()
  @POST(GlobalVariables.expenseBankAPI)
  Future<DataResponse> getExpenseBankAccount(@Field("SOCIETY_ID") String socId);

  @FormUrlEncoded()
  @POST(GlobalVariables.addExpenseAPI)
  Future<StatusMsgResponse> addExpense( @Field("SOCIETY_ID") String socId,@Field("AMOUNT") String amount,
      @Field("REFERENCE_NO") String referenceNo,@Field("TRANSACTION_TYPE") String transactionType,
      @Field("BANK") String bank,@Field("LEDGER_ID") String ledgerId,@Field("DATE") String date,
      @Field("NARRATION") String narration, @Field("ATTACHMENT") String attachment);

  @FormUrlEncoded()
  @POST(GlobalVariables.receiptMailAPI)
  Future<StatusMsgResponse> getReceiptMail(@Field("SOCIETY_ID") String socId,@Field("RECEIPT_NO") String receiptNo,@Field("Email_id") String emailId,@Field("YEAR") String year);

  @FormUrlEncoded()
  @POST(GlobalVariables.billPDFAPI)
  Future<DataResponse> getBillPDFData(@Field("SOCIETY_ID") String socId,@Field("Bill_no") String billNo);

  @FormUrlEncoded()
  @POST(GlobalVariables.receiptPDFAPI)
  Future<DataResponse> getReceiptPDFData(@Field("SOCIETY_ID") String socId,@Field("Receipt_no") String billNo);

  @FormUrlEncoded()
  @POST(GlobalVariables.monthExpensePendingRequestAPI)
  Future<MonthExpensePendingRequestResponse> getMonthExpensePendingRequest(@Field("SOCIETY_ID") String socId);

  @FormUrlEncoded()
  @POST(GlobalVariables.headWiseExpenseAPI)
  Future<DataResponse> getHeadWiseExpenseData(@Field("SOCIETY_ID") String socId);

  @FormUrlEncoded()
  @POST(GlobalVariables.cancelReceiptRequestAPI)
  Future<StatusMsgResponse> cancelReceiptRequest(@Field("SOCIETY_ID") String socId,@Field("ID") String id);

  @FormUrlEncoded()
  @POST(GlobalVariables.approveReceiptRequestAPI)
  Future<StatusMsgResponse> approveReceiptRequest(@Field("SOCIETY_ID") String socId,@Field("ID") String id);

  @FormUrlEncoded()
  @POST(GlobalVariables.addInvoiceAPI)
  Future<StatusMsgResponse> addInvoice( @Field("SOCIETY_ID") String socId,@Field("amount") String amount,
      @Field("due_date") String dueDate,@Field("flat_no") String flatNo,
      @Field("ledger_id") String ledgerId,@Field("date") String date,
      @Field("narration") String narration,);

  @FormUrlEncoded()
  @POST(GlobalVariables.approveReceiptRequestAPI)
  Future<StatusMsgResponse> addApproveReceiptRequest( @Field("SOCIETY_ID") String socId,
      @Field("FLAT_NO") String flatNo,@Field("PAYMENT_DATE") String paymentDate,
      @Field("AMOUNT") String amount,@Field("PENALTY_AMOUNT") String penaltyAmount,
      @Field("REFERENCE_NO") String referenceNo,@Field("TRANSACTION_MODE") String transactionMode,
      @Field("BANK_ACCOUNTNO") String bankAccountNo,
      @Field("ID") String id,@Field("NARRATION") String narration);

}


