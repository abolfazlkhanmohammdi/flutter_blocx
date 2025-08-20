import 'package:blocx/blocx.dart';
import 'package:flutter_blocx_example/src/list/inventory/data/models/product.dart';
import 'package:flutter_blocx_example/src/list/inventory/data/models/product_Repository.dart';
import 'package:flutter_blocx_example/src/list/users/data/models/user.dart';

class UseCaseSearchUserProducts extends SearchUseCase<Product, User> {
  ProductRepository repository = ProductRepository();
  UseCaseSearchUserProducts({required super.searchQuery});
  @override
  Future<UseCaseResult<Page<Product>>> perform() async {
    var items = await repository.getUserProductsViaSearch(
      searchQuery.payload?.username ?? "",
      searchQuery.searchText,
      searchQuery.loadCount,
      searchQuery.offset,
    );
    return successResult(items);
  }
}
