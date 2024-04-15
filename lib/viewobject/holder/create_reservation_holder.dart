import 'package:flutterrestaurant/viewobject/common/ps_holder.dart'
    show PsHolder;

class ReservationParameterHolder extends PsHolder<ReservationParameterHolder> {
  ReservationParameterHolder(
      {required this.reservationDate,
      required this.reservationTime,
      required this.userNote,
      required this.shopId,
      required this.userId,
      required this.userEmail,
      required this.userPhoneNumber,
        required this.noOfPeople,
      required this.userName});

  final String reservationDate;
  final String reservationTime;
  final String userNote;
  final String shopId;
  final String userId;
  final String userEmail;
  final String userPhoneNumber;
  final String userName;
  final String noOfPeople;

  @override
  Map<String, dynamic> toMap() {
    final Map<String, dynamic> map = <String, dynamic>{};

    map['resv_date'] = reservationDate;
    map['resv_time'] = reservationTime;
    map['note'] = userNote;
    map['shop_id'] = shopId;
    map['user_id'] = userId;
    map['user_email'] = userEmail;
    map['user_phone_no'] = userPhoneNumber;
    map['user_name'] = userName;
    map['no_of_people'] = noOfPeople;
    return map;
  }

  @override
  ReservationParameterHolder fromMap(dynamic dynamicData) {
    return ReservationParameterHolder(
      reservationDate: dynamicData['resv_date'],
      reservationTime: dynamicData['resv_time'],
      userNote: dynamicData['note'],
      shopId: dynamicData['shop_id'],
      userId: dynamicData['user_id'],
      userEmail: dynamicData['user_email'],
      userPhoneNumber: dynamicData['user_phone_no'],
      userName: dynamicData['user_name'],
      noOfPeople: dynamicData['no_of_people'],
    );
  }

  @override
  String getParamKey() {
    String key = '';

    if (reservationDate != '') {
      key += reservationDate;
    }
    if (reservationTime != '') {
      key += reservationTime;
    }
    if (userNote != '') {
      key += userNote;
    }
    if (shopId != '') {
      key += shopId;
    }
    if (userId != '') {
      key += userId;
    }
    if (userEmail != '') {
      key += userEmail;
    }
    if (userPhoneNumber != '') {
      key += userPhoneNumber;
    }
    if (userName != '') {
      key += userName;
    }
    if (noOfPeople != '') {
      key += noOfPeople;
    }
    return key;
  }
}
