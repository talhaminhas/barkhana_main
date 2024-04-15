class GlobalTokenPost {
  GlobalTokenPost(
      {this.userEmail,
        this.userPhone,
        this.userAddress1,
        this.userAddress2,
        this.userCity,
        this.userPostcode,
        this.userTotal,
        this.jsonResponse,
        this.transactionStatus
      });

  String? userEmail;
  String? userPhone;
  String? userAddress1;
  String? userAddress2;
  String? userCity;
  String? userPostcode;
  String? userTotal;
  String? transactionStatus;
  String? jsonResponse; // zero means posting to get token, if it is assigned with a response then server will return transaction result

  List<Map<String, dynamic>>? details;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = <String, dynamic>{};
    map['user_email'] = userEmail;
    map['user_phone'] = userPhone;
    map['user_address1'] = userAddress1;
    map['user_address2'] = userAddress2;
    map['user_city'] = userCity;
    map['user_postcode'] = userPostcode;
    map['user_total'] = userTotal;
    map['transaction_status'] = transactionStatus;
    map['json_response'] = jsonResponse;

    return map;
  }
}