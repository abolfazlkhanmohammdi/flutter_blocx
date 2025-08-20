import 'package:blocx/blocx.dart';
import 'package:flutter_blocx_example/src/list/inventory/data/models/product.dart';
import 'package:flutter_blocx_example/src/list/inventory/data/models/product_repository.dart';
import 'package:flutter_blocx_example/src/list/users/data/models/user.dart';

class GetUserInventoryUseCase extends PaginationUseCase<Product, User> {
  final ProductRepository repository = ProductRepository();
  GetUserInventoryUseCase({required super.queryInput});
  @override
  Future<UseCaseResult<Page<Product>>> perform() async {
    if (queryInput.payload == null) {
      throw StateError("payload cannot be null for this useCase");
    }
    var result = await repository.getProducts(
      queryInput.loadCount,
      queryInput.offset,
      queryInput.payload!.username,
    );
    return successResult(result);
  }
}
