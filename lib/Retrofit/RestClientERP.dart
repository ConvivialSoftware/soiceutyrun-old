import 'package:retrofit/retrofit.dart';
import 'package:dio/dio.dart';
import 'package:societyrun/GlobalClasses/GlobalVariables.dart';
import 'package:societyrun/Models/BankResponse.dart';
import 'package:societyrun/Models/BillViewResponse.dart';
import 'package:societyrun/Models/DataResponse.dart';
import 'package:societyrun/Models/DuesResponse.dart';
import 'package:societyrun/Models/LedgerResponse.dart';
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
      @Field("BLOCK") String block );

  @FormUrlEncoded()
  @POST(GlobalVariables.viewBillsAPI)
  Future<DataResponse> getAllBillData(@Field("SOCIETY_ID") String socId, @Field("FLAT") String flat,
      @Field("BLOCK") String block );

  @FormUrlEncoded()
  @POST(GlobalVariables.billAPI)
  Future<BillViewResponse> getBillData(@Field("SOCIETY_ID") String socId, @Field("FLAT") String flat,
      @Field("BLOCK") String block,@Field("INVOICE_NO") String invoiceNo );

  @FormUrlEncoded()
  @POST(GlobalVariables.receiptAPI)
  Future<ReceiptViewResponse> getReceiptData(@Field("SOCIETY_ID") String socId, @Field("FLAT") String flat,
      @Field("BLOCK") String block,@Field("RECEIPT_NO") String receiptNo);

  @FormUrlEncoded()
  @POST(GlobalVariables.bankAPI)
  Future<BankResponse> getBankData(@Field("SOCIETY_ID") String socId,@Field("INVOICE_NO") String invoiceNo);

  @FormUrlEncoded()
  @POST(GlobalVariables.paymentRequestAPI)
  Future<StatusMsgResponse> addAlreadyPaidPaymentRequest( @Field("SOCIETY_ID") String socId, @Field("FLAT") String flat,
      @Field("BLOCK") String block,@Field("INVOICE_NO") String invoiceNo,@Field("AMOUNT") String amount,
      @Field("REFERENCE_NO") String referenceNo,@Field("TRANSACTION_MODE") String transactionMode,
      @Field("BANK_ACCOUNTNO") String bankAccountNo,@Field("PAYMENT_DATE") String paymentDate,
      @Field("USER_ID") String userId,@Field("NARRATION") String narration,@Field("CHEQUE_BANKNAME") String checkBankName,
      @Field("ATTACHMENT") String attachment,@Field("STATUS") String status);

  @FormUrlEncoded()
  @POST(GlobalVariables.insertPaymentAPI)
  Future<StatusMsgResponse> addOnlinePaymentRequest( @Field("SOCIETY_ID") String socId, @Field("FLAT") String flat,
      @Field("BLOCK") String block,@Field("INVOICE_NO") String invoiceNo,@Field("AMOUNT") String amount,
      @Field("REFERENCE_NO") String referenceNo,@Field("TRANSACTION_MODE") String transactionMode,
      @Field("BANK_ACCOUNTNO") String bankAccountNo,@Field("PAYMENT_DATE") String paymentDate,@Field("STATUS") String paymentStatus,@Field("ORDER_ID") String orderID);

  @FormUrlEncoded()
  @POST(GlobalVariables.mailAPI)
  Future<StatusMsgResponse> getBillMail(@Field("SOCIETY_ID") String socId, @Field("TYPE") String type,
      @Field("NUMBER") String number,@Field("Email_id") String emailId);

  @FormUrlEncoded()
  @POST(GlobalVariables.razorPayTransactionAPI)
  Future<StatusMsgResponse> postRazorPayTransactionOrderID(@Field("SOCIETY_ID") String socId, @Field("FLAT_NO") String flat,
      @Field("ORDER_ID") String orderId,@Field("AMOUNT") String amount);

  @FormUrlEncoded()
  @POST(GlobalVariables.expenseAPI)
  Future<DataResponse> getExpenseData(@Field("SOCIETY_ID") String socId);

  @FormUrlEncoded()
  @POST(GlobalVariables.accountLedgerAPI)
  Future<DataResponse> getExpenseAccountLedger(@Field("SOCIETY_ID") String socId);

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
  Future<StatusMsgResponse> getReceiptMail(@Field("SOCIETY_ID") String socId,@Field("RECEIPT_NO") String receiptNo,@Field("Email_id") String emailId);

}


