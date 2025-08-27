import 'package:blocx_core/blocx_core.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'product.freezed.dart';

/// this is an example of how to use [ListEntity] with freezed models don't forget to override [copyWithListFlags]
@freezed
sealed class Product extends BaseEntity with _$Product {
  const factory Product({
    required String uuid,
    required String name,
    required String description,
    required double price,
    required int stock,
    required String imageUrl,
    required String category,
    required String username,
  }) = _Product;

  const Product._() : super();

  @override
  String get identifier => uuid;

  // @override
  // List<Object?> get props => [isBeingRemoved];
}
