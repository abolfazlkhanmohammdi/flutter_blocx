import 'package:blocx/blocx.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'product.freezed.dart';

/// this is an example of how to use [ListEntity] with freezed models don't forget to override [copyWithListFlags]
@freezed
sealed class Product extends ListEntity<Product> with _$Product
// ,EquatableMixin
{
  const factory Product({
    @Default(false) bool isSelected,
    @Default(false) bool isBeingSelected,
    @Default(false) bool isBeingRemoved,
    @Default(false) bool isHighlighted,
    required String uuid,
    required String name,
    required String description,
    required double price,
    required int stock,
    required String imageUrl,
    required String category,
    required String username,
  }) = _Product;

  const Product._() : super.empty(); // private constructor for custom getters

  @override
  String get identifier => uuid;

  @override
  Product copyWithListFlags({
    bool? isSelected,
    bool? isBeingSelected,
    bool? isBeingRemoved,
    bool? isHighlighted,
  }) {
    return copyWith(
      isSelected: isSelected ?? this.isSelected,
      isBeingSelected: isBeingSelected ?? this.isBeingSelected,
      isHighlighted: isHighlighted ?? this.isHighlighted,
      isBeingRemoved: isBeingRemoved ?? this.isBeingRemoved,
    );
  }

  // @override
  // List<Object?> get props => [isBeingRemoved];
}
