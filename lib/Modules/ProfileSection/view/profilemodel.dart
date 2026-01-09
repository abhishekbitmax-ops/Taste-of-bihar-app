class ProfileResponse {
  bool? success;
  String? message;
  UserData? data;

  ProfileResponse({this.success, this.message, this.data});

  factory ProfileResponse.fromJson(Map<String, dynamic> json) {
    return ProfileResponse(
      success: json['success'],
      message: json['message'],
      data: json['data'] != null ? UserData.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'success': success,
        'message': message,
        'data': data?.toJson(),
      };
}

class UserData {
  String? id;
  String? mobile;
  String? name;
  String? email;
  bool? isMobileVerified;
  bool? isEmailVerified;
  String? profile;
  String? gender;
  String? dob;
  LocationData? location;
  String? createdAt;

  UserData({
    this.id,
    this.mobile,
    this.name,
    this.email,
    this.isMobileVerified,
    this.isEmailVerified,
    this.profile,
    this.gender,
    this.dob,
    this.location,
    this.createdAt,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      id: json['id'],
      mobile: json['mobile'],
      name: json['name'],
      email: json['email'],
      isMobileVerified: json['isMobileVerified'],
      isEmailVerified: json['isEmailVerified'],
      profile: json['profile'],
      gender: json['gender'],
      dob: json['dob'],
      location:
          json['location'] != null ? LocationData.fromJson(json['location']) : null,
      createdAt: json['createdAt'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'mobile': mobile,
        'name': name,
        'email': email,
        'isMobileVerified': isMobileVerified,
        'isEmailVerified': isEmailVerified,
        'profile': profile,
        'gender': gender,
        'dob': dob,
        'location': location?.toJson(),
        'createdAt': createdAt,
      };
}

class LocationData {
  String? address;
  double? lat;
  double? lng;

  LocationData({this.address, this.lat, this.lng});

  factory LocationData.fromJson(Map<String, dynamic> json) {
    return LocationData(
      address: json['address'],
      lat: (json['lat'] as num?)?.toDouble(),
      lng: (json['lng'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'address': address,
        'lat': lat,
        'lng': lng,
      };
}


// Cart All item show model class

class CartResponse {
  bool? success;
  String? message;
  CartData? data;

  CartResponse({this.success, this.message, this.data});

  factory CartResponse.fromJson(Map<String, dynamic> json) {
    return CartResponse(
      success: json["success"],
      message: json["message"],
      data: json["data"] == null ? null : CartData.fromJson(json["data"]),
    );
  }
}

class CartData {
  CartModel? cart;

  CartData({this.cart});

  factory CartData.fromJson(Map<String, dynamic> json) {
    return CartData(
      cart: json["cart"] == null ? null : CartModel.fromJson(json["cart"]),
    );
  }
}

class CartModel {
  String? id;
  String? user;
  RestaurantModel? restaurant;
  List<CartItem>? items;
  SummaryModel? summary;
  String? coupon;
  dynamic couponData;
  String? updatedAt;
  CouponModel? couponModel;
  bool? isEmpty;

  CartModel({
    this.id,
    this.user,
    this.restaurant,
    this.items,
    this.summary,
    this.coupon,
    this.couponData,
    this.updatedAt,
    this.couponModel,
    this.isEmpty,
  });

  factory CartModel.fromJson(Map<String, dynamic> json) {
    return CartModel(
      id: json["id"],
      user: json["user"],
      restaurant: json["restaurant"] == null ? null : RestaurantModel.fromJson(json["restaurant"]),
      items: json["items"] == null ? null : (json["items"] as List).map((e) => CartItem.fromJson(e)).toList(),
      summary: json["summary"] == null ? null : SummaryModel.fromJson(json["summary"]),
      coupon: json["coupon"],
      couponData: json["coupon"],
      updatedAt: json["updatedAt"],
      isEmpty: json["isEmpty"],
    );
  }
}

class RestaurantModel {
  String? id;
  String? name;
  String? address;
  String? image;

  RestaurantModel({this.id, this.name, this.address, this.image});

  factory RestaurantModel.fromJson(Map<String, dynamic> json) {
    return RestaurantModel(
      id: json["id"],
      name: json["name"],
      address: json["address"],
      image: json["image"],
    );
  }
}

class CartItem {
  String? cartItemId;
  String? menuItemId;
  String? name;
  String? image;
  String? foodType;
  bool? isVeg;
  String? variant;
  List<Addon>? addons;
  int? basePrice;
  int? quantity;
  int? itemTotal;
  String? specialInstructions;

  CartItem({
    this.cartItemId,
    this.menuItemId,
    this.name,
    this.image,
    this.foodType,
    this.isVeg,
    this.variant,
    this.addons,
    this.basePrice,
    this.quantity,
    this.itemTotal,
    this.specialInstructions,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      cartItemId: json["cartItemId"],
      menuItemId: json["menuItemId"],
      name: json["name"],
      image: json["image"],
      foodType: json["foodType"],
      isVeg: json["isVeg"],
      variant: json["variant"],
      addons: json["addons"] == null ? null : (json["addons"] as List).map((e) => Addon.fromJson(e)).toList(),
      basePrice: json["basePrice"],
      quantity: json["quantity"],
      itemTotal: json["itemTotal"],
      specialInstructions: json["specialInstructions"],
    );
  }
}

class Addon {
  String? addonId;
  String? name;
  int? price;

  Addon({this.addonId, this.name, this.price});

  factory Addon.fromJson(Map<String, dynamic> json) {
    return Addon(
      addonId: json["addonId"],
      name: json["name"],
      price: json["price"],
    );
  }
}

class SummaryModel {
  int? itemCount;
  int? subtotal;
  double? tax;
  int? deliveryCharge;
  int? discount;
  double? grandTotal;

  SummaryModel({this.itemCount, this.subtotal, this.tax, this.deliveryCharge, this.discount, this.grandTotal});

  factory SummaryModel.fromJson(Map<String, dynamic> json) {
    return SummaryModel(
      itemCount: json["itemCount"],
      subtotal: json["subtotal"],
      tax: (json["tax"] as num?)?.toDouble(),
      deliveryCharge: json["deliveryCharge"],
      discount: json["discount"],
      grandTotal: (json["grandTotal"] as num?)?.toDouble(),
    );
  }
}

class CouponModel {
  String? code;
  int? discountAmount;

  CouponModel({this.code, this.discountAmount});

  factory CouponModel.fromJson(Map<String, dynamic> json) {
    return CouponModel(
      code: json["code"],
      discountAmount: json["discountAmount"],
    );
  }
}

class CategoryData {
  String? id;
  String? name;

  CategoryData({this.id, this.name});

  factory CategoryData.fromJson(Map<String, dynamic> json) {
    return CategoryData(
      id: json["id"],
      name: json["name"],
    );
  }
}

class CategoryItemsResponse {
  bool? success;
  String? message;
  CategoryItemsData? data;

  CategoryItemsResponse({this.success, this.message, this.data});

  factory CategoryItemsResponse.fromJson(Map<String, dynamic> json) {
    return CategoryItemsResponse(
      success: json["success"],
      message: json["message"],
      data: json["data"] == null ? null : CategoryItemsData.fromJson(json["data"]),
    );
  }
}

class CategoryItemsData {
  RestaurantModel? restaurant;
  List<CartItem>? items;

  CategoryItemsData({this.restaurant, this.items});

  factory CategoryItemsData.fromJson(Map<String, dynamic> json) {
    return CategoryItemsData(
      restaurant: json["restaurant"] == null ? null : RestaurantModel.fromJson(json["restaurant"]),
      items: json["items"] == null ? null : (json["items"] as List).map((e) => CartItem.fromJson(e)).toList(),
    );
  }
}
