import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:openfoodfacts/model/Product.dart';
import 'package:smooth_app/structures/ranked_product.dart';
import 'package:smooth_app/data_models/user_preferences_model.dart';
import 'package:smooth_app/temp/filter_ranking_helper.dart';

class SmoothItModel extends ChangeNotifier {
  SmoothItModel(this.unprocessedProducts, final BuildContext context) {
    _loadData(context);
    scrollController.addListener(_scrollListener);
  }

  final ScrollController scrollController = ScrollController();
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  Future<bool> _loadData(final BuildContext context) async {
    try {
      dataLoaded = await processProductList(context);
      notifyListeners();
      return true;
    } catch (e) {
      print('An error occurred while processing the product list : $e');
      dataLoaded = false;
      return false;
    }
  }

  List<Product> unprocessedProducts;
  List<RankedProduct> products;

  List<RankedProduct> topPicks;
  List<RankedProduct> contenders;
  List<RankedProduct> dismissed;

  bool dataLoaded = false;

  bool showTitle = true;

  Future<bool> processProductList(final BuildContext context) async {
    try {
      final UserPreferencesModel model = UserPreferencesModel(context);
      products = FilterRankingHelper.process(unprocessedProducts, model);
      topPicks = products
          .where((RankedProduct rankedProduct) =>
              rankedProduct.type == RankingType.TOP_PICKS)
          .toList();
      topPicks.sort(
          (RankedProduct a, RankedProduct b) => b.score.compareTo(a.score));
      contenders = products
          .where((RankedProduct rankedProduct) =>
              rankedProduct.type == RankingType.CONTENDERS)
          .toList();
      contenders.sort(
          (RankedProduct a, RankedProduct b) => b.score.compareTo(a.score));
      dismissed = products
          .where((RankedProduct rankedProduct) =>
              rankedProduct.type == RankingType.DISMISSED)
          .toList();
      dismissed.sort(
          (RankedProduct a, RankedProduct b) => b.score.compareTo(a.score));
      print('Processed products');
      notifyListeners();
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  void _scrollListener() {
    if (scrollController.offset <= scrollController.position.minScrollExtent &&
        !scrollController.position.outOfRange) {
      // Reached Top
      showTitle = true;
      notifyListeners();
    } else {
      showTitle = false;
      notifyListeners();
    }
  }
}
