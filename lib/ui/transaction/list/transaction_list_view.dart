import 'package:flutter/material.dart';
import 'package:flutterrestaurant/constant/ps_constants.dart';
import 'package:flutterrestaurant/constant/ps_dimens.dart';
import 'package:flutterrestaurant/provider/transaction/transaction_header_provider.dart';
import 'package:flutterrestaurant/repository/transaction_header_repository.dart';
import 'package:flutterrestaurant/ui/common/ps_ui_widget.dart';
import 'package:flutterrestaurant/ui/dashboard/core/drawer_view.dart';
import 'package:flutterrestaurant/ui/transaction/item/transaction_list_item.dart';
import 'package:flutterrestaurant/viewobject/common/ps_value_holder.dart';
//import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';

import '../../../utils/utils.dart';
GlobalKey<RefreshIndicatorState> orderListRefreshKey =
GlobalKey<RefreshIndicatorState>();
class TransactionListView extends StatefulWidget {
  const TransactionListView(
      {Key? key, required this.animationController, required this.scaffoldKey})
      : super(key: key);
  final AnimationController animationController;
  final GlobalKey<ScaffoldState> scaffoldKey;
  @override
  _TransactionListViewState createState() => _TransactionListViewState();
}

class _TransactionListViewState extends State<TransactionListView>
    with TickerProviderStateMixin, WidgetsBindingObserver{
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<_TransactionListViewState> _key = GlobalKey<_TransactionListViewState>();
  TransactionHeaderProvider? _transactionProvider;

  @override
  void initState() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _transactionProvider!.nextTransactionList();
      }
    });

    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      print('appear');
    }
  }
  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }
  TransactionHeaderRepository ?repo1;
  PsValueHolder? psValueHolder;
  dynamic data;
  bool isConnectedToInternet = false;
  bool isSuccessfullyLoaded = true;


  @override
  Widget build(BuildContext context) {

    repo1 = Provider.of<TransactionHeaderRepository>(context);
    psValueHolder = Provider.of<PsValueHolder>(context);
    // Register a callback to be called after the first frame is drawn

    print(
        '............................Build UI Again ............................');
    return ChangeNotifierProvider<TransactionHeaderProvider>(
      lazy: false,
      key: _key,
      create: (BuildContext context) {
        final TransactionHeaderProvider provider = TransactionHeaderProvider(
            repo: repo1!, psValueHolder: psValueHolder!);
        provider.loadTransactionList(psValueHolder!.loginUserId!);
        _transactionProvider = provider;
        return _transactionProvider!;
      },
      child: Consumer<TransactionHeaderProvider>(builder: (BuildContext context,
          TransactionHeaderProvider provider, Widget? child) {

        if (provider.transactionList.data != null &&
            provider.transactionList.data!.isNotEmpty) {
          /*WidgetsBinding.instance.addPostFrameCallback((_) {
            if(Utils.MoveToTransactionDetail)
              Navigator.pushNamed(
                  context, RoutePaths.transactionDetail,
                  arguments: provider
                      .transactionList.data![0]);
          });*/
          return Column(
            children: <Widget>[
              /*const PsAdMobBannerWidget(
                admobSize: AdSize.banner
              ),*/
              Expanded(
                child: Stack(
                  children: <Widget>[
                    RefreshIndicator(
                      key: orderListRefreshKey,
                      child: CustomScrollView(
                          controller: _scrollController,
                          physics: const AlwaysScrollableScrollPhysics(),
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          slivers: <Widget>[
                            SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (BuildContext context, int index) {
                                  final int count =
                                      provider.transactionList.data!.length;

                                  return TransactionListItem(
                                    scaffoldKey: widget.scaffoldKey,
                                    animationController:
                                        widget.animationController,
                                    animation:
                                        Tween<double>(begin: 0.0, end: 1.0)
                                            .animate(
                                      CurvedAnimation(
                                        parent: widget.animationController,
                                        curve: Interval(
                                            (1 / count) * index, 1.0,
                                            curve: Curves.fastOutSlowIn),
                                      ),
                                    ),
                                    transaction:
                                        provider.transactionList.data![index],
                                    onTap: () {
                                      dashboardViewKey.currentState?.selectedTransactionHeader = provider
                                          .transactionList.data![index];
                                      dashboardViewKey.currentState?.updateSelectedIndexWithAnimation(Utils.getString(
                                          context, 'transaction_detail__title'),
                                          PsConst.REQUEST_CODE__MENU_TRANSACTION_DETAIL_FRAGMENT);
                                      /*Navigator.pushNamed(
                                          context, RoutePaths.orderDetail,
                                          arguments: provider
                                              .transactionList.data![index]);*/

                                    },
                                  );
                                },
                                childCount:
                                    provider.transactionList.data!.length,
                              ),
                            ),
                            SliverToBoxAdapter(
                              child: Container(height: PsDimens.space10,),
                            )
                          ]),
                      onRefresh: () {

                        return provider.resetTransactionList();
                      },
                    ),
                    PSProgressIndicator(provider.transactionList.status)
                  ],
                ),
              )
            ],
          );
        } else {
          return Container();
        }
      }),
    );
  }
}
