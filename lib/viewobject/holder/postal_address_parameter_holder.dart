import 'package:flutterrestaurant/viewobject/common/ps_holder.dart'
    show PsHolder;

class PostalAddressParameterHolder extends PsHolder<PostalAddressParameterHolder> {
  PostalAddressParameterHolder(
      {required this.postcode});

  final String postcode;

  @override
  Map<String, dynamic> toMap() {
    final Map<String, dynamic> map = <String, dynamic>{};

    map['postcode'] = postcode;

    return map;
  }

  @override
  PostalAddressParameterHolder fromMap(dynamic dynamicData) {
    return PostalAddressParameterHolder(
      postcode: dynamicData['postcode']
    );
  }

  @override
  String getParamKey() {
    // TODO: implement getParamKey
    throw UnimplementedError();
  }

}
