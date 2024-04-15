import 'dart:async';
import 'package:flutterrestaurant/api/common/ps_resource.dart';
import 'package:flutterrestaurant/api/common/ps_status.dart';
import 'package:flutterrestaurant/db/search_history_dao.dart';
import 'package:flutterrestaurant/viewobject/search_history.dart';

import 'Common/ps_repository.dart';

class SearchHistoryRepository extends PsRepository {
  SearchHistoryRepository({required SearchHistoryDao searchHistoryDao}) {
    _searchHistoryDao = searchHistoryDao;
  }

  String primaryKey = 'searchterm';
 late SearchHistoryDao _searchHistoryDao;

  Future<dynamic> insert(SearchHistory history) async {
    return _searchHistoryDao.insert(primaryKey, history);
  }

  Future<dynamic> update(SearchHistory history) async {
    return _searchHistoryDao.update(history);
  }

  Future<dynamic> delete(SearchHistory history) async {
    return _searchHistoryDao.delete(history);
  }

  Future<dynamic> getAllSearchHistoryList(
      StreamController<PsResource<List<SearchHistory>>> searchHistoryListStream,
      PsStatus status) async {
    searchHistoryListStream.sink.add(await _searchHistoryDao.getAll(status: status));
  }

  Future<dynamic> addAllSearchHistoryList(
      StreamController<PsResource<List<SearchHistory>>> searchHistoryListStream,
      PsStatus status,
      SearchHistory searchHistory) async {
    await _searchHistoryDao.insert(primaryKey, searchHistory);
    searchHistoryListStream.sink.add(await _searchHistoryDao.getAll(status: status));
  }

  Future<dynamic> deleteSearchHistory(
      StreamController<PsResource<List<SearchHistory>>> searchHistoryListStream,
      SearchHistory searchHistory) async {
    await _searchHistoryDao.delete(searchHistory);
    searchHistoryListStream.sink
        .add(await _searchHistoryDao.getAll(status: PsStatus.SUCCESS));
  }
}