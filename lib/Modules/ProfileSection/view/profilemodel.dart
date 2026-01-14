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
      location: json['location'] != null
          ? LocationData.fromJson(json['location'])
          : null,
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

  Map<String, dynamic> toJson() => {'address': address, 'lat': lat, 'lng': lng};
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

  /// FULL coupon object
  CouponModel? coupon;

  bool? isEmpty;
  String? updatedAt;

  CartModel({
    this.id,
    this.user,
    this.restaurant,
    this.items,
    this.summary,
    this.coupon,
    this.isEmpty,
    this.updatedAt,
  });

  factory CartModel.fromJson(Map<String, dynamic> json) {
    return CartModel(
      id: json["id"],
      user: json["user"],

      restaurant: json["restaurant"] == null
          ? null
          : RestaurantModel.fromJson(json["restaurant"]),

      items: json["items"] == null
          ? []
          : (json["items"] as List).map((e) => CartItem.fromJson(e)).toList(),

      summary: json["summary"] == null
          ? null
          : SummaryModel.fromJson(json["summary"]),

      // ✅ FIXED: coupon is OBJECT
      coupon: json["coupon"] == null
          ? null
          : CouponModel.fromJson(json["coupon"]),

      isEmpty: json["isEmpty"] ?? false,
      updatedAt: json["updatedAt"],
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
      addons: json["addons"] == null
          ? []
          : (json["addons"] as List).map((e) => Addon.fromJson(e)).toList(),
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

  SummaryModel({
    this.itemCount,
    this.subtotal,
    this.tax,
    this.deliveryCharge,
    this.discount,
    this.grandTotal,
  });

  factory SummaryModel.fromJson(Map<String, dynamic> json) {
    return SummaryModel(
      itemCount: json["itemCount"],
      subtotal: json["subtotal"],
      tax: (json["tax"] as num?)?.toDouble(), // ✅ FIX
      deliveryCharge: json["deliveryCharge"],
      discount: json["discount"],
      grandTotal: (json["grandTotal"] as num?)?.toDouble(), // ✅ FIX
    );
  }
}

class CouponModel {
  String? code;
  int? discountAmount;
  String? description;

  CouponModel({this.code, this.discountAmount, this.description});

  factory CouponModel.fromJson(Map<String, dynamic> json) {
    return CouponModel(
      code: json["code"],
      discountAmount: json["discountAmount"],
      description: json["description"],
    );
  }
}

//--------------------------------------------------------

class CategoryData {
  String? id;
  String? name;

  CategoryData({this.id, this.name});

  factory CategoryData.fromJson(Map<String, dynamic> json) {
    return CategoryData(id: json["id"], name: json["name"]);
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
      data: json["data"] == null
          ? null
          : CategoryItemsData.fromJson(json["data"]),
    );
  }
}

class CategoryItemsData {
  RestaurantModel? restaurant;
  List<CartItem>? items;

  CategoryItemsData({this.restaurant, this.items});

  factory CategoryItemsData.fromJson(Map<String, dynamic> json) {
    return CategoryItemsData(
      restaurant: json["restaurant"] == null
          ? null
          : RestaurantModel.fromJson(json["restaurant"]),
      items: json["items"] == null
          ? null
          : (json["items"] as List).map((e) => CartItem.fromJson(e)).toList(),
    );
  }
}

// Orders Tracking  ---------------------

class OrderTrackingResponse {
  final bool? success;
  final String? message;
  final OrderTrackingData? data;

  OrderTrackingResponse({this.success, this.message, this.data});

  factory OrderTrackingResponse.fromJson(Map<String, dynamic> json) {
    return OrderTrackingResponse(
      success: json['success'],
      message: json['message'],
      data: json['data'] != null
          ? OrderTrackingData.fromJson(json['data'])
          : null,
    );
  }
}

class OrderTrackingData {
  final String? orderId;
  final String? id;
  final String? status;
  final List<OrderTimeline>? timeline;
  final EstimatedDelivery? estimatedDelivery;
  final Restaurant? restaurant;
  final DeliveryAddress? deliveryAddress;
  final List<OrderItem>? items;
  final Price? price;
  final Payment? payment;
  final Delivery? delivery;
  final String? createdAt;
  final bool? canCancel;

  OrderTrackingData({
    this.orderId,
    this.id,
    this.status,
    this.timeline,
    this.estimatedDelivery,
    this.restaurant,
    this.deliveryAddress,
    this.items,
    this.price,
    this.payment,
    this.delivery,
    this.createdAt,
    this.canCancel,
  });

  factory OrderTrackingData.fromJson(Map<String, dynamic> json) {
    return OrderTrackingData(
      orderId: json['orderId'],
      id: json['_id'],
      status: json['status'],
      timeline: (json['timeline'] as List?)
          ?.map((e) => OrderTimeline.fromJson(e))
          .toList(),
      estimatedDelivery: json['estimatedDelivery'] != null
          ? EstimatedDelivery.fromJson(json['estimatedDelivery'])
          : null,
      restaurant: json['restaurant'] != null
          ? Restaurant.fromJson(json['restaurant'])
          : null,
      deliveryAddress: json['deliveryAddress'] != null
          ? DeliveryAddress.fromJson(json['deliveryAddress'])
          : null,
      items: (json['items'] as List?)
          ?.map((e) => OrderItem.fromJson(e))
          .toList(),
      price: json['price'] != null ? Price.fromJson(json['price']) : null,
      payment:
          json['payment'] != null ? Payment.fromJson(json['payment']) : null,
      delivery:
          json['delivery'] != null ? Delivery.fromJson(json['delivery']) : null,
      createdAt: json['createdAt'],
      canCancel: json['canCancel'],
    );
  }
}

class OrderTimeline {
  final String? at;
  final String? status;

  OrderTimeline({this.at, this.status});

  factory OrderTimeline.fromJson(Map<String, dynamic> json) {
    return OrderTimeline(
      at: json['at'],
      status: json['status'],
    );
  }
}

class EstimatedDelivery {
  final String? time;
  final int? minutes;
  final String? message;

  EstimatedDelivery({this.time, this.minutes, this.message});

  factory EstimatedDelivery.fromJson(Map<String, dynamic> json) {
    return EstimatedDelivery(
      time: json['time'],
      minutes: json['minutes'],
      message: json['message'],
    );
  }
}

class Restaurant {
  final String? id;
  final String? name;

  Restaurant({this.id, this.name});

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      id: json['_id'],
      name: json['name'],
    );
  }
}

class DeliveryAddress {
  final String? name;
  final String? phone;
  final String? addressLine;
  final String? city;
  final String? pincode;
  final double? lat;
  final double? lng;

  DeliveryAddress({
    this.name,
    this.phone,
    this.addressLine,
    this.city,
    this.pincode,
    this.lat,
    this.lng,
  });

  factory DeliveryAddress.fromJson(Map<String, dynamic> json) {
    return DeliveryAddress(
      name: json['name'],
      phone: json['phone'],
      addressLine: json['addressLine'],
      city: json['city'],
      pincode: json['pincode'],
      lat: (json['lat'] as num?)?.toDouble(),
      lng: (json['lng'] as num?)?.toDouble(),
    );
  }
}

class OrderItem {
  final ItemRef? itemId;
  final String? name;
  final int? quantity;
  final int? basePrice;
  final List<dynamic>? addons;
  final int? finalItemPrice;

  OrderItem({
    this.itemId,
    this.name,
    this.quantity,
    this.basePrice,
    this.addons,
    this.finalItemPrice,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      itemId:
          json['itemId'] != null ? ItemRef.fromJson(json['itemId']) : null,
      name: json['name'],
      quantity: json['quantity'],
      basePrice: json['basePrice'],
      addons: json['addons'],
      finalItemPrice: json['finalItemPrice'],
    );
  }
}

class ItemRef {
  final String? id;
  final String? name;
  final String? image;

  ItemRef({this.id, this.name, this.image});

  factory ItemRef.fromJson(Map<String, dynamic> json) {
    return ItemRef(
      id: json['_id'],
      name: json['name'],
      image: json['image'],
    );
  }
}

class Price {
  final num? itemsTotal;
  final num? tax;
  final num? deliveryFee;
  final num? discount;
  final num? grandTotal;

  Price({
    this.itemsTotal,
    this.tax,
    this.deliveryFee,
    this.discount,
    this.grandTotal,
  });

  factory Price.fromJson(Map<String, dynamic> json) {
    return Price(
      itemsTotal: json['itemsTotal'],
      tax: json['tax'],
      deliveryFee: json['deliveryFee'],
      discount: json['discount'],
      grandTotal: json['grandTotal'],
    );
  }
}

class Payment {
  final String? method;
  final String? status;
  final String? transactionId;

  Payment({this.method, this.status, this.transactionId});

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      method: json['method'],
      status: json['status'],
      transactionId: json['transactionId'],
    );
  }
}

class Delivery {
  final String? otp;

  Delivery({this.otp});

  factory Delivery.fromJson(Map<String, dynamic> json) {
    return Delivery(
      otp: json['otp'],
    );
  }
}

