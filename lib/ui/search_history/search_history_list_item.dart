import 'package:flutter/material.dart';
import 'package:flutterrestaurant/config/ps_colors.dart';
import 'package:flutterrestaurant/viewobject/search_history.dart';

class SearchHistoryListItem extends StatelessWidget {
  const SearchHistoryListItem({
    Key? key,
    required this.searchHistory,
    this.onTap,
    this.onDeleteTap
  }) : super(key: key);

  final SearchHistory searchHistory;
  final Function? onTap;
  final Function? onDeleteTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: onTap as void Function()?,
        child:IntrinsicWidth(
          child: Container(
            padding: const EdgeInsets.only(
            ),
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).disabledColor,
                width: 2.0,
              ),
              borderRadius: BorderRadius.circular(25.0),
            ),
            child: MaterialButton(
              //color: PsColors.baseColor,
              elevation: 0,
              // Remove fixed height to fit content
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        searchHistory.searchTeam!,
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall!
                            .copyWith(),
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    InkWell(
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle, // Make the container circular
                          border: Border.all(
                            color: PsColors.discountColor,
                            width: 2.0,
                          ),
                        ),
                        child: Icon(
                          Icons.clear,
                          size: 20,
                          color: PsColors.discountColor,
                        ),
                      ),
                      onTap: onDeleteTap as void Function()?,
                    ),

                  ],
                ),
              ),
              onPressed: onTap as void Function()?,
            ),
          ),
        ),


    );
  }
}
