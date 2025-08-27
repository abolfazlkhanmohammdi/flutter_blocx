import 'package:blocx_core/blocx_core.dart';
import 'package:blocx_flutter_example/src/list/inventory/data/models/product.dart';
import 'package:blocx_flutter_example/src/list/inventory/data/models/product_repository.dart';
import 'package:blocx_flutter_example/src/list/users/data/models/user.dart';

class UseCaseRefreshUserInventory extends PaginationUseCase<Product, User> {
  final ProductRepository repository = ProductRepository();
  UseCaseRefreshUserInventory({required super.queryInput});

  @override
  Future<UseCaseResult<Page<Product>>> perform() async {
    var list = await repository.getAllProducts(queryInput.payload?.username ?? "");
    return successResult(list);
  }
}
