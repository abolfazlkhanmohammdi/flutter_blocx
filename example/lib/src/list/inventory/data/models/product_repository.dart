import 'package:flutter_blocx_example/src/core/fake_repository.dart';
import 'package:flutter_blocx_example/src/list/inventory/data/models/product.dart';

class ProductRepository extends FakeRepository {
  static final List<Product> _allProducts = [];

  Future<List<Product>> getProducts(int loadCount, int offset, String username) async {
    await randomWaitFuture;
    var userProductCount = _allProducts.where((e) => e.username == username).length;
    var products = List.generate(userProductCount >= 10 ? 5 : loadCount, (i) => generateProduct(username));
    return products;
  }

  Product generateProduct(String username) {
    var product = Product(
      uuid: uuid,
      name: faker.food.dish(), // using faker to get a product-like name
      description: faker.lorem.sentence(),
      price: faker.randomGenerator.decimal(min: 5, scale: 100).toDouble(),
      stock: faker.randomGenerator.integer(200, min: 0),
      imageUrl: image,
      category: faker.lorem.word(),
      username: username,
    );
    _allProducts.add(product);
    return product;
  }

  Future<List<Product>> getAllProducts(String username) async {
    await randomWaitFuture;
    return _allProducts.where((e) => e.username == username).toList();
  }

  Future<bool> deleteProduct(Product product) async {
    await randomWaitFuture;
    int index = _allProducts.indexWhere((e) => e.identifier == product.identifier);
    if (index == -1) return false;
    _allProducts.removeAt(index);
    return true;
  }

  Future getUserProductsViaSearch(String username, String searchText, int loadCount, int offset) async {
    await randomWaitFuture;
    final usersProducts = _allProducts.where((e) => e.username == username);
    final searchedUserProducts = usersProducts
        .where((e) => e.name.contains(searchText) || e.description.contains(searchText))
        .toList();
    return searchedUserProducts;
  }
}
