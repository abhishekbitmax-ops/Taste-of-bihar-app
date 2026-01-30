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

  /// 🔥 OTP from API (deliveryOTP) OR Socket
  final String? deliveryOTP;

  final List<OrderTimeline>? timeline;

  /// 🔥 Can be String OR Map (API + Socket safe)
  final dynamic estimatedDelivery;

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
    this.deliveryOTP,
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
    final delivery = json['delivery'] != null
        ? Delivery.fromJson(json['delivery'])
        : null;

    return OrderTrackingData(
      orderId: json['orderId'],
      id: json['_id'] ?? json['id'], // 🔥 API safety
      status: json['status'],

      /// 🔥 API may send deliveryOTP
      deliveryOTP: json['deliveryOTP'],

      timeline: (json['timeline'] as List?)
          ?.map((e) => OrderTimeline.fromJson(e))
          .toList(),

      estimatedDelivery: json['estimatedDelivery'],

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

      payment: json['payment'] != null
          ? Payment.fromJson(json['payment'])
          : null,

      delivery: delivery,

      createdAt: json['createdAt'],
      canCancel: json['canCancel'],
    );
  }

  // ─────────────────────────────────────
  // 🔥 SOCKET HELPER
  // ─────────────────────────────────────
  OrderTrackingData copyWith({
    String? status,
    String? deliveryOTP,
    List<OrderTimeline>? timeline,
    dynamic estimatedDelivery,
    Payment? payment,
    Delivery? delivery,
    bool? canCancel,
  }) {
    return OrderTrackingData(
      orderId: orderId,
      id: id,
      status: status ?? this.status,

      /// 🔥 Preserve existing OTP
      deliveryOTP: deliveryOTP ?? this.deliveryOTP,

      timeline: timeline ?? this.timeline,
      estimatedDelivery: estimatedDelivery ?? this.estimatedDelivery,
      restaurant: restaurant,
      deliveryAddress: deliveryAddress,
      items: items,
      price: price,
      payment: payment ?? this.payment,
      delivery: delivery ?? this.delivery,
      createdAt: createdAt,
      canCancel: canCancel ?? this.canCancel,
    );
  }

  // ─────────────────────────────────────
  // 🔌 SOCKET MERGE
  // ─────────────────────────────────────
  factory OrderTrackingData.fromSocket({
    required OrderTrackingData old,
    required Map<String, dynamic> json,
  }) {
    return old.copyWith(
      status: json['status'] ?? old.status,

      /// 🔥 Socket may send otp OR deliveryOTP
      deliveryOTP: json['deliveryOTP'] ?? json['otp'] ?? old.deliveryOTP,

      estimatedDelivery: json.containsKey('estimatedDelivery')
          ? json['estimatedDelivery']
          : old.estimatedDelivery,

      timeline:
          (json['timeline'] as List?)
              ?.map((e) => OrderTimeline.fromJson(e))
              .toList() ??
          old.timeline,

      payment: json['payment'] != null
          ? Payment.fromJson(json['payment'])
          : old.payment,

      delivery: json['delivery'] != null
          ? Delivery.fromJson(json['delivery'])
          : old.delivery,

      canCancel: json['canCancel'] ?? old.canCancel,
    );
  }

  // ─────────────────────────────────────
  // 🔥 UI HELPERS (VERY IMPORTANT)
  // ─────────────────────────────────────

  /// ✅ OTP from API OR socket OR delivery object
  String? get effectiveOtp => deliveryOTP ?? delivery?.otp;

  /// ✅ Used to show Track Button & Delivery Partner
  bool get isDeliveryAssigned =>
      effectiveOtp != null || delivery?.partner != null;
}

class OrderTimeline {
  final String? at;
  final String? status;

  OrderTimeline({this.at, this.status});

  factory OrderTimeline.fromJson(Map<String, dynamic> json) {
    return OrderTimeline(at: json['at'], status: json['status']);
  }
}

class Restaurant {
  final String? id;
  final String? name;

  Restaurant({this.id, this.name});

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(id: json['_id'], name: json['name']);
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
      itemId: json['itemId'] != null ? ItemRef.fromJson(json['itemId']) : null,
      name: json['name'],
      quantity: json['quantity'],
      basePrice: json['basePrice'],
      addons: json['addons'],
      finalItemPrice: json['finalItemPrice'] ?? json['price'], // 🔥 FIX
    );
  }
}

class ItemRef {
  final String? id;
  final String? name;
  final String? image;

  ItemRef({this.id, this.name, this.image});

  factory ItemRef.fromJson(Map<String, dynamic> json) {
    return ItemRef(id: json['_id'], name: json['name'], image: json['image']);
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
  final String? assignedAt;
  final String? otpCreatedAt;
  final String? pickedUpAt;
  final String? deliveredAt;
  final DeliveryPartner? partner;

  Delivery({
    this.otp,
    this.assignedAt,
    this.otpCreatedAt,
    this.pickedUpAt,
    this.deliveredAt,
    this.partner,
  });

  factory Delivery.fromJson(Map<String, dynamic> json) {
    final partner = json['partner'] != null
        ? DeliveryPartner.fromJson(json['partner'])
        : null;

    return Delivery(
      otp: json['otp'],
      assignedAt: json['assignedAt'],
      otpCreatedAt: json['otpCreatedAt'],
      pickedUpAt: json['pickedUpAt'], // future-safe
      deliveredAt: json['deliveredAt'], // future-safe
      partner: partner,
    );
  }
}

class DeliveryPartner {
  final String? name;
  final String? phone;
  final Vehicle? vehicle;

  DeliveryPartner({this.name, this.phone, this.vehicle});

  factory DeliveryPartner.fromJson(Map<String, dynamic> json) {
    return DeliveryPartner(
      name: json['name'],
      phone: json['phone'],
      vehicle: json['vehicle'] != null
          ? Vehicle.fromJson(json['vehicle'])
          : null,
    );
  }
}

class Vehicle {
  final String? type;

  Vehicle({this.type});

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(type: json['type']);
  }
}

// popluar dishes------------------------------

class ProductResponse {
  final bool? success;
  final int? count;
  final List<ProductData>? data;

  ProductResponse({this.success, this.count, this.data});

  factory ProductResponse.fromJson(Map<String, dynamic> json) {
    return ProductResponse(
      success: json['success'],
      count: json['count'],
      data: json['data'] != null
          ? List<ProductData>.from(
              json['data'].map((x) => ProductData.fromJson(x)),
            )
          : null,
    );
  }
}

class ProductData {
  final int? totalSold;
  final String? id;
  final String? name;
  final String? image;
  final int? price;
  final String? description;
  final bool? isVeg;
  final double? rating;

  ProductData({
    this.totalSold,
    this.id,
    this.name,
    this.image,
    this.price,
    this.description,
    this.isVeg,
    this.rating,
  });

  factory ProductData.fromJson(Map<String, dynamic> json) {
    return ProductData(
      totalSold: json['totalSold'],
      id: json['_id'],
      name: json['name'],
      image: json['image'],
      price: json['price'],
      description: json['description'],
      isVeg: json['isVeg'],
      rating: json['rating'] != null
          ? (json['rating'] as num).toDouble()
          : null,
    );
  }
}

// Get multiple apply coupan list model class

class CouponResponse {
  final bool? success;
  final String? message;
  final List<Coupon>? data;

  CouponResponse({this.success, this.message, this.data});

  factory CouponResponse.fromJson(Map<String, dynamic> json) {
    return CouponResponse(
      success: json['success'] as bool?,
      message: json['message'] as String?,
      data: json['data'] != null
          ? List<Coupon>.from(json['data'].map((x) => Coupon.fromJson(x)))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data?.map((x) => x.toJson()).toList(),
    };
  }
}

class Coupon {
  final String? id;
  final String? code;
  final String? description;
  final String? discountType;
  final int? value;
  final int? minOrderValue;
  final int? maxDiscountLimit;
  final bool? isActive;
  final String? expiryDate;
  final int? usageLimit;
  final String? createdAt;
  final String? updatedAt;

  Coupon({
    this.id,
    this.code,
    this.description,
    this.discountType,
    this.value,
    this.minOrderValue,
    this.maxDiscountLimit,
    this.isActive,
    this.expiryDate,
    this.usageLimit,
    this.createdAt,
    this.updatedAt,
  });

  factory Coupon.fromJson(Map<String, dynamic> json) {
    return Coupon(
      id: json['_id'] as String?,
      code: json['code'] as String?,
      description: json['description'] as String?,
      discountType: json['discountType'] as String?,
      value: json['value'] as int?,
      minOrderValue: json['minOrderValue'] as int?,
      maxDiscountLimit: json['maxDiscountLimit'] as int?,
      isActive: json['isActive'] as bool?,
      expiryDate: json['expiryDate'] as String?,
      usageLimit: json['usageLimit'] as int?,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'code': code,
      'description': description,
      'discountType': discountType,
      'value': value,
      'minOrderValue': minOrderValue,
      'maxDiscountLimit': maxDiscountLimit,
      'isActive': isActive,
      'expiryDate': expiryDate,
      'usageLimit': usageLimit,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}

//Refund payment model class -----

class RefundResponse {
  final bool? success;
  final String? message;
  final RefundData? data;

  RefundResponse({this.success, this.message, this.data});

  factory RefundResponse.fromJson(Map<String, dynamic> json) {
    return RefundResponse(
      success: json['success'],
      message: json['message'],
      data: json['data'] != null ? RefundData.fromJson(json['data']) : null,
    );
  }
}

class RefundData {
  final String? orderId;
  final String? paymentId;
  final String? status;
  final String? refundStatus;
  final num? totalRefunded;
  final String? currency;
  final RefundAmount? amount;
  final List<RefundItem>? refunds;
  final RefundRequest? refundRequest;

  RefundData({
    this.orderId,
    this.paymentId,
    this.status,
    this.refundStatus,
    this.totalRefunded,
    this.currency,
    this.amount,
    this.refunds,
    this.refundRequest,
  });

  factory RefundData.fromJson(Map<String, dynamic> json) {
    return RefundData(
      orderId: json['orderId'],
      paymentId: json['paymentId'],
      status: json['status'],
      refundStatus: json['refundStatus'],
      totalRefunded: json['totalRefunded'],
      currency: json['currency'],
      amount: json['amount'] != null
          ? RefundAmount.fromJson(json['amount'])
          : null,
      refunds: (json['refunds'] as List?)
          ?.map((e) => RefundItem.fromJson(e))
          .toList(),
      refundRequest: json['refundRequest'] != null
          ? RefundRequest.fromJson(json['refundRequest'])
          : null,
    );
  }
}

class RefundAmount {
  final num? total;
  final num? tax;
  final num? deliveryFee;
  final num? discount;
  final num? payable;

  RefundAmount({
    this.total,
    this.tax,
    this.deliveryFee,
    this.discount,
    this.payable,
  });

  factory RefundAmount.fromJson(Map<String, dynamic> json) {
    return RefundAmount(
      total: json['total'],
      tax: json['tax'],
      deliveryFee: json['deliveryFee'],
      discount: json['discount'],
      payable: json['payable'],
    );
  }
}

class RefundItem {
  final String? refundId;
  final num? amount;
  final String? status;
  final String? createdAt;

  RefundItem({this.refundId, this.amount, this.status, this.createdAt});

  factory RefundItem.fromJson(Map<String, dynamic> json) {
    return RefundItem(
      refundId: json['refundId'],
      amount: json['amount'],
      status: json['status'],
      createdAt: json['createdAt'],
    );
  }
}

class RefundRequest {
  final bool? isRequested;
  final String? status;

  RefundRequest({this.isRequested, this.status});

  factory RefundRequest.fromJson(Map<String, dynamic> json) {
    return RefundRequest(
      isRequested: json['isRequested'],
      status: json['status'],
    );
  }
}

// Notification model classs ----------------

class NotificationResponse {
  final bool? success;
  final List<AppNotification>? data;

  NotificationResponse({this.success, this.data});

  factory NotificationResponse.fromJson(Map<String, dynamic> json) {
    return NotificationResponse(
      success: json['success'] as bool?,
      data: (json['data'] as List?)
          ?.map((e) => AppNotification.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class AppNotification {
  final String? id;
  final String? user;
  final String? recipientRole;
  final String? type;
  final String? title;
  final String? message;
  final NotificationPayload? data;
  final bool? isRead;
  final DateTime? createdAt;
  final int? v;

  AppNotification({
    this.id,
    this.user,
    this.recipientRole,
    this.type,
    this.title,
    this.message,
    this.data,
    this.isRead,
    this.createdAt,
    this.v,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['_id'] as String?,
      user: json['user'] as String?,
      recipientRole: json['recipientRole'] as String?,
      type: json['type'] as String?,
      title: json['title'] as String?,
      message: json['message'] as String?,
      data: json['data'] != null
          ? NotificationPayload.fromJson(json['data'] as Map<String, dynamic>)
          : null,
      isRead: json['isRead'] as bool?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
      v: json['__v'] as int?,
    );
  }

  /// 🔥 REQUIRED FOR PATCH READ UPDATE
  AppNotification copyWith({bool? isRead}) {
    return AppNotification(
      id: id,
      user: user,
      recipientRole: recipientRole,
      type: type,
      title: title,
      message: message,
      data: data,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
      v: v,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "_id": id,
      "user": user,
      "recipientRole": recipientRole,
      "type": type,
      "title": title,
      "message": message,
      "data": data?.toJson(),
      "isRead": isRead,
      "createdAt": createdAt?.toIso8601String(),
      "__v": v,
    };
  }
}

class NotificationPayload {
  // ================= ORDER / OTP =================
  final String? otp;
  final String? orderId;
  final String? orderCustomId;

  // ================= TYPE =================
  final String? type; // DAILY_MENU, DELIVERY_OTP etc

  // ================= MENU ITEM =================
  final String? itemId;
  final String? name;
  final num? price;
  final String? foodType; // VEG / NON_VEG
  final String? image;
  final String? description;

  NotificationPayload({
    this.otp,
    this.orderId,
    this.orderCustomId,
    this.type,
    this.itemId,
    this.name,
    this.price,
    this.foodType,
    this.image,
    this.description,
  });

  factory NotificationPayload.fromJson(Map<String, dynamic> json) {
    return NotificationPayload(
      otp: json['otp']?.toString(),
      orderId: json['orderId'] as String?,
      orderCustomId: json['orderCustomId'] as String?,
      type: json['type'] as String?,

      // 🍽️ MENU ITEM
      itemId: json['itemId'] as String?,
      name: json['name'] as String?,
      price: json['price'],
      foodType: json['foodType'] as String?,
      image: json['image'] as String?,
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "otp": otp,
      "orderId": orderId,
      "orderCustomId": orderCustomId,
      "type": type,

      // 🍽️ MENU ITEM
      "itemId": itemId,
      "name": name,
      "price": price,
      "foodType": foodType,
      "image": image,
      "description": description,
    };
  }
}
