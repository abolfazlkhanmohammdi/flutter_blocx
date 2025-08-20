// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'product.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Product {

 bool get isSelected; bool get isBeingSelected; bool get isBeingRemoved; bool get isHighlighted; String get uuid; String get name; String get description; double get price; int get stock; String get imageUrl; String get category; String get username;
/// Create a copy of Product
/// with the given fields replaced by the non-null parameter values.
 @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProductCopyWith<Product> get copyWith => _$ProductCopyWithImpl<Product>(this as Product, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Product&&super == other&&(identical(other.isSelected, isSelected) || other.isSelected == isSelected)&&(identical(other.isBeingSelected, isBeingSelected) || other.isBeingSelected == isBeingSelected)&&(identical(other.isBeingRemoved, isBeingRemoved) || other.isBeingRemoved == isBeingRemoved)&&(identical(other.isHighlighted, isHighlighted) || other.isHighlighted == isHighlighted)&&(identical(other.uuid, uuid) || other.uuid == uuid)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.price, price) || other.price == price)&&(identical(other.stock, stock) || other.stock == stock)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.category, category) || other.category == category)&&(identical(other.username, username) || other.username == username));
}


@override
int get hashCode => Object.hash(runtimeType,super.hashCode,isSelected,isBeingSelected,isBeingRemoved,isHighlighted,uuid,name,description,price,stock,imageUrl,category,username);

@override
String toString() {
  return 'Product(isSelected: $isSelected, isBeingSelected: $isBeingSelected, isBeingRemoved: $isBeingRemoved, isHighlighted: $isHighlighted, uuid: $uuid, name: $name, description: $description, price: $price, stock: $stock, imageUrl: $imageUrl, category: $category, username: $username)';
}


}

/// @nodoc
abstract mixin class $ProductCopyWith<$Res>  {
  factory $ProductCopyWith(Product value, $Res Function(Product) _then) = _$ProductCopyWithImpl;
@useResult
$Res call({
 bool isSelected, bool isBeingSelected, bool isBeingRemoved, bool isHighlighted, String uuid, String name, String description, double price, int stock, String imageUrl, String category, String username
});




}
/// @nodoc
class _$ProductCopyWithImpl<$Res>
    implements $ProductCopyWith<$Res> {
  _$ProductCopyWithImpl(this._self, this._then);

  final Product _self;
  final $Res Function(Product) _then;

/// Create a copy of Product
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isSelected = null,Object? isBeingSelected = null,Object? isBeingRemoved = null,Object? isHighlighted = null,Object? uuid = null,Object? name = null,Object? description = null,Object? price = null,Object? stock = null,Object? imageUrl = null,Object? category = null,Object? username = null,}) {
  return _then(_self.copyWith(
isSelected: null == isSelected ? _self.isSelected : isSelected // ignore: cast_nullable_to_non_nullable
as bool,isBeingSelected: null == isBeingSelected ? _self.isBeingSelected : isBeingSelected // ignore: cast_nullable_to_non_nullable
as bool,isBeingRemoved: null == isBeingRemoved ? _self.isBeingRemoved : isBeingRemoved // ignore: cast_nullable_to_non_nullable
as bool,isHighlighted: null == isHighlighted ? _self.isHighlighted : isHighlighted // ignore: cast_nullable_to_non_nullable
as bool,uuid: null == uuid ? _self.uuid : uuid // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,stock: null == stock ? _self.stock : stock // ignore: cast_nullable_to_non_nullable
as int,imageUrl: null == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [Product].
extension ProductPatterns on Product {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Product value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Product() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Product value)  $default,){
final _that = this;
switch (_that) {
case _Product():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Product value)?  $default,){
final _that = this;
switch (_that) {
case _Product() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool isSelected,  bool isBeingSelected,  bool isBeingRemoved,  bool isHighlighted,  String uuid,  String name,  String description,  double price,  int stock,  String imageUrl,  String category,  String username)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Product() when $default != null:
return $default(_that.isSelected,_that.isBeingSelected,_that.isBeingRemoved,_that.isHighlighted,_that.uuid,_that.name,_that.description,_that.price,_that.stock,_that.imageUrl,_that.category,_that.username);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool isSelected,  bool isBeingSelected,  bool isBeingRemoved,  bool isHighlighted,  String uuid,  String name,  String description,  double price,  int stock,  String imageUrl,  String category,  String username)  $default,) {final _that = this;
switch (_that) {
case _Product():
return $default(_that.isSelected,_that.isBeingSelected,_that.isBeingRemoved,_that.isHighlighted,_that.uuid,_that.name,_that.description,_that.price,_that.stock,_that.imageUrl,_that.category,_that.username);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool isSelected,  bool isBeingSelected,  bool isBeingRemoved,  bool isHighlighted,  String uuid,  String name,  String description,  double price,  int stock,  String imageUrl,  String category,  String username)?  $default,) {final _that = this;
switch (_that) {
case _Product() when $default != null:
return $default(_that.isSelected,_that.isBeingSelected,_that.isBeingRemoved,_that.isHighlighted,_that.uuid,_that.name,_that.description,_that.price,_that.stock,_that.imageUrl,_that.category,_that.username);case _:
  return null;

}
}

}

/// @nodoc


class _Product extends Product {
  const _Product({this.isSelected = false, this.isBeingSelected = false, this.isBeingRemoved = false, this.isHighlighted = false, required this.uuid, required this.name, required this.description, required this.price, required this.stock, required this.imageUrl, required this.category, required this.username}): super._();
  

@override@JsonKey() final  bool isSelected;
@override@JsonKey() final  bool isBeingSelected;
@override@JsonKey() final  bool isBeingRemoved;
@override@JsonKey() final  bool isHighlighted;
@override final  String uuid;
@override final  String name;
@override final  String description;
@override final  double price;
@override final  int stock;
@override final  String imageUrl;
@override final  String category;
@override final  String username;

/// Create a copy of Product
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProductCopyWith<_Product> get copyWith => __$ProductCopyWithImpl<_Product>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Product&&super == other&&(identical(other.isSelected, isSelected) || other.isSelected == isSelected)&&(identical(other.isBeingSelected, isBeingSelected) || other.isBeingSelected == isBeingSelected)&&(identical(other.isBeingRemoved, isBeingRemoved) || other.isBeingRemoved == isBeingRemoved)&&(identical(other.isHighlighted, isHighlighted) || other.isHighlighted == isHighlighted)&&(identical(other.uuid, uuid) || other.uuid == uuid)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.price, price) || other.price == price)&&(identical(other.stock, stock) || other.stock == stock)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.category, category) || other.category == category)&&(identical(other.username, username) || other.username == username));
}


@override
int get hashCode => Object.hash(runtimeType,super.hashCode,isSelected,isBeingSelected,isBeingRemoved,isHighlighted,uuid,name,description,price,stock,imageUrl,category,username);

@override
String toString() {
  return 'Product(isSelected: $isSelected, isBeingSelected: $isBeingSelected, isBeingRemoved: $isBeingRemoved, isHighlighted: $isHighlighted, uuid: $uuid, name: $name, description: $description, price: $price, stock: $stock, imageUrl: $imageUrl, category: $category, username: $username)';
}


}

/// @nodoc
abstract mixin class _$ProductCopyWith<$Res> implements $ProductCopyWith<$Res> {
  factory _$ProductCopyWith(_Product value, $Res Function(_Product) _then) = __$ProductCopyWithImpl;
@override @useResult
$Res call({
 bool isSelected, bool isBeingSelected, bool isBeingRemoved, bool isHighlighted, String uuid, String name, String description, double price, int stock, String imageUrl, String category, String username
});




}
/// @nodoc
class __$ProductCopyWithImpl<$Res>
    implements _$ProductCopyWith<$Res> {
  __$ProductCopyWithImpl(this._self, this._then);

  final _Product _self;
  final $Res Function(_Product) _then;

/// Create a copy of Product
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isSelected = null,Object? isBeingSelected = null,Object? isBeingRemoved = null,Object? isHighlighted = null,Object? uuid = null,Object? name = null,Object? description = null,Object? price = null,Object? stock = null,Object? imageUrl = null,Object? category = null,Object? username = null,}) {
  return _then(_Product(
isSelected: null == isSelected ? _self.isSelected : isSelected // ignore: cast_nullable_to_non_nullable
as bool,isBeingSelected: null == isBeingSelected ? _self.isBeingSelected : isBeingSelected // ignore: cast_nullable_to_non_nullable
as bool,isBeingRemoved: null == isBeingRemoved ? _self.isBeingRemoved : isBeingRemoved // ignore: cast_nullable_to_non_nullable
as bool,isHighlighted: null == isHighlighted ? _self.isHighlighted : isHighlighted // ignore: cast_nullable_to_non_nullable
as bool,uuid: null == uuid ? _self.uuid : uuid // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,stock: null == stock ? _self.stock : stock // ignore: cast_nullable_to_non_nullable
as int,imageUrl: null == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
