import 'dart:async';

import 'package:bloc/src/bloc.dart';
import 'package:blocx/blocx.dart';
import 'package:flutter_blocx_example/src/list/inventory/bloc/use_cases/use_case_refresh_user_inventory.dart';
import 'package:flutter_blocx_example/src/list/inventory/bloc/use_cases/use_case_get_user_inventory.dart';
import 'package:flutter_blocx_example/src/list/inventory/bloc/use_cases/use_case_remove_product.dart';
import 'package:flutter_blocx_example/src/list/inventory/bloc/use_cases/use_case_search_products.dart';
import 'package:flutter_blocx_example/src/list/inventory/data/models/product.dart';
import 'package:flutter_blocx_example/src/list/users/data/models/user.dart';

// in this bloc we'll provide use cases instead of direct load
class InventoryBloc extends ListBloc<Product, User>
    with
        InfiniteListBlocMixin<Product, User>,
        RefreshableListBlocMixin<Product, User>,
        DeletableListBlocMixin<Product, User>,
        SelectableListBlocMixin<Product, User>,
        HighlightableListBlocMixin<Product, User>,
        SearchableListBlocMixin<Product, User> {
  /// You better use dependency-injection for providing ScreenManagerCubit and InfiniteListBloc instances here
  /// i didn't do that for the sake of simplicity
  InventoryBloc() : super(ScreenManagerCubit(), InfiniteListBloc());

  @override
  (String, String?) convertErrorToMessageAndTitle(Object error) {
    return ("an error occurred", "error");
  }

  @override
  PaginationUseCase<Product, User>? get loadInitialPageUseCase => GetUserInventoryUseCase(
    queryInput: PaginationQuery<User>(payload: payload, loadCount: loadCount, offset: 0),
  );

  @override
  PaginationUseCase<Product, User>? get loadNextPageUseCase => GetUserInventoryUseCase(
    queryInput: PaginationQuery<User>(payload: payload, loadCount: loadCount, offset: offset),
  );

  @override
  PaginationUseCase<Product, User>? get refreshPageUseCase =>
      UseCaseRefreshUserInventory(queryInput: PaginationQuery<User>.payloadOnly(payload));

  @override
  BaseUseCase<bool>? deleteItemUseCase(Product item) {
    return UseCaseRemoveProduct(product: item);
  }

  @override
  SearchUseCase<Product, User>? searchUseCase(String searchText, {int offset = 0}) {
    return UseCaseSearchUserProducts(
      searchQuery: SearchQuery(
        searchText: searchText,
        payload: payload,
        loadCount: loadCount,
        offset: offset,
      ),
    );
  }

  @override
  bool get isSingleSelect => false;
}
