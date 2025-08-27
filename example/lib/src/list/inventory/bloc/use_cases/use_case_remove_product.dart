import 'package:blocx_core/blocx_core.dart';
import 'package:blocx_flutter_example/src/list/inventory/data/models/product.dart';
import 'package:blocx_flutter_example/src/list/inventory/data/models/product_repository.dart';

class UseCaseRemoveProduct extends BaseUseCase<bool> {
  final Product product;
  ProductRepository repository = ProductRepository();
  UseCaseRemoveProduct({required this.product});
  @override
  Future<UseCaseResult<bool>> perform() async {
    var result = await repository.deleteProduct(product);
    return UseCaseResult.success(result);
  }
}
