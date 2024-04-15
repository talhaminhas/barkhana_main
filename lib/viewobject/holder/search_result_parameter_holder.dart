import 'package:flutterrestaurant/viewobject/common/ps_holder.dart';

class SearchResultParameterHolder
    extends PsHolder<SearchResultParameterHolder> {
  SearchResultParameterHolder({required this.searchTerm});

  late final String searchTerm;

  @override
  SearchResultParameterHolder fromMap(dynamic dynamicData) {
    return SearchResultParameterHolder(
      searchTerm: dynamicData['searchterm'],
    );
  }

  @override
  String getParamKey() {
    return '';
  }

  void setSearchTerm (String text)
  {
    searchTerm = text;
  }
  @override
  Map<String, dynamic> toMap() {
    final Map<String, dynamic> map = <String, dynamic>{};

    map['searchterm'] = searchTerm;

    return map;
  }
}
