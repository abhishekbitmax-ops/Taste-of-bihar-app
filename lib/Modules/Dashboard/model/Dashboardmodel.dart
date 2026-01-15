class CategoryResponse {
  bool? success;
  List<CategoryData>? data;

  CategoryResponse({this.success, this.data});

  factory CategoryResponse.fromJson(Map<String, dynamic> json) {
    return CategoryResponse(
      success: json['success'],
      data: json['data'] != null
          ? (json['data'] as List).map((e) => CategoryData.fromJson(e)).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'success': success, 'data': data?.map((e) => e.toJson()).toList()};
  }
}

class CategoryData {
  String? foodType;
  int? sortOrder;
  bool? isRecommended;
  bool? isRecommendedFlag; // for safety if key mismatch happens
  bool? isActive;
  bool? isRecommended2;
  int? sortOrder2;
  bool? isRecommended3;
  String? id;
  String? restaurantId;
  String? restaurant;
  String? name;
  String? description;
  String? image;
  String? createdAt;
  String? updatedAt;
  int? v;
  int? version;
  int? v2;

  CategoryData({
    this.foodType,
    this.sortOrder,
    this.isRecommended,
    this.isActive,
    this.isRecommended2,
    this.sortOrder2,
    this.isRecommended3,
    this.id,
    this.restaurantId,
    this.restaurant,
    this.name,
    this.description,
    this.image,
    this.createdAt,
    this.updatedAt,
    this.v,
    this.version,
    this.v2,
  });

  factory CategoryData.fromJson(Map<String, dynamic> json) {
    return CategoryData(
      id: json['_id'], // ✔ correct mapping
      name: json['name'],
      description: json['description'],
      image: json['image'],
      foodType: json['foodType'],
      isActive: json['isActive'],
      sortOrder: json['sortOrder'],
      isRecommended: json['isRecommended'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      v: json['__v'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'foodType': foodType,
      'sortOrder': sortOrder,
      'isRecommended': isRecommended,
      'isActive': isActive,
      'restaurantId': restaurantId,
      'restaurant': restaurant,
      'name': name,
      'description': description,
      'image': image,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      '__v': v,
    };
  }
}

// Category Items Model

class CategoryItemsResponse {
  bool? success;
  String? message;
  CategoryItemsData? data;

  CategoryItemsResponse({this.success, this.message, this.data});

  factory CategoryItemsResponse.fromJson(Map<String, dynamic> json) {
    return CategoryItemsResponse(
      success: json['success'],
      message: json['message'],
      data: json['data'] != null
          ? CategoryItemsData.fromJson(json['data'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'success': success,
    'message': message,
    'data': data?.toJson(),
  };
}

class CategoryItemsData {
  CategoryModel? category;
  List<ItemModel>? items;

  CategoryItemsData({this.category, this.items});

  factory CategoryItemsData.fromJson(Map<String, dynamic> json) {
    return CategoryItemsData(
      category: json['category'] != null
          ? CategoryModel.fromJson(json['category'])
          : null,
      items: json['items'] != null
          ? List<ItemModel>.from(
              json['items'].map((x) => ItemModel.fromJson(x)),
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'category': category?.toJson(),
    'items': items?.map((x) => x.toJson()).toList(),
  };
}

class CategoryModel {
  String? id;
  String? restaurant;
  String? name;
  String? description;
  String? image;
  String? foodType;
  bool? isActive;
  int? sortOrder;
  bool? isRecommended;
  String? createdAt;
  String? updatedAt;
  int? v;

  CategoryModel({
    this.id,
    this.restaurant,
    this.name,
    this.description,
    this.image,
    this.foodType,
    this.isActive,
    this.sortOrder,
    this.isRecommended,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['_id'],
      restaurant: json['restaurant'],
      name: json['name'],
      description: json['description'],
      image: json['image'],
      foodType: json['foodType'] ?? json['foodType'] ?? json['foodType'],
      isActive: json['isActive'],
      sortOrder: json['sortOrder'],
      isRecommended: json['isRecommended'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      v: json['__v'],
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'restaurant': restaurant,
    'name': name,
    'description': description,
    'image': image,
    'foodType': foodType,
    'isActive': isActive,
    'sortOrder': sortOrder,
    'isRecommended': isRecommended,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
    '__v': v,
  };
}

class ItemModel {
  String? id;
  String? restaurant;
  String? category;
  String? name;
  String? description;
  int? basePrice;
  String? foodType;
  bool? isVeg;
  List<String>? tags;
  List<dynamic>? variants;
  List<dynamic>? addons;
  String? image;
  bool? isAvailable;
  bool? isActive;
  bool? isAvailable2;
  bool? isAvailable3;
  bool? isAvailableFlag;
  bool? isActiveFlag;
  bool? isRecommended;
  String? createdAt;
  String? updatedAt;
  int? v;

  ItemModel({
    this.id,
    this.restaurant,
    this.category,
    this.name,
    this.description,
    this.basePrice,
    this.foodType,
    this.isVeg,
    this.tags,
    this.variants,
    this.addons,
    this.image,
    this.isAvailable,
    this.isActive,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  factory ItemModel.fromJson(Map<String, dynamic> json) {
    return ItemModel(
      id: json['_id'],
      restaurant: json['restaurant'],
      category: json['category'],
      name: json['name'],
      description: json['description'],
      basePrice: json['basePrice'],
      foodType: json['foodType'],
      isVeg: json['isVeg'],
      tags: json['tags'] != null ? List<String>.from(json['tags']) : null,
      variants: json['variants'],
      addons: json['addons'],

      image: json['image'], // 🔥🔥🔥 THIS WAS MISSING

      isAvailable: json['isAvailable'],
      isActive: json['isActive'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      v: json['__v'],
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'restaurant': restaurant,
    'category': category,
    'name': name,
    'description': description,
    'basePrice': basePrice,
    'foodType': foodType,
    'isVeg': isVeg,
    'tags': tags,
    'variants': variants,
    'addons': addons,
    'isAvailable': isAvailable,
    'isActive': isActive,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
    '__v': v,
  };
}

// Card total item show model class
class AddressResponse {
  bool? success;
  String? message;
  int? count;
  List<AddressData>? data;

  AddressResponse({this.success, this.message, this.count, this.data});

  factory AddressResponse.fromJson(Map<String, dynamic> json) {
    return AddressResponse(
      success: json['success'],
      message: json['message'],
      count: json['count'],
      data: json['data'] != null
          ? List<AddressData>.from(
              json['data'].map((x) => AddressData.fromJson(x)),
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'count': count,
      'data': data?.map((x) => x.toJson()).toList(),
    };
  }
}

class AddressData {
  String? id;
  String? user;
  String? label;
  String? street;
  String? area;
  String? city;
  String? state;
  String? zipCode;
  double? lat;
  double? lng;
  String? landmark;
  bool? isDefault;
  bool? isActive;
  String? createdAtIST;
  String? updatedAtIST;
  String? createdAt;
  String? updatedAt;
  int? v;

  AddressData({
    this.id,
    this.user,
    this.label,
    this.street,
    this.area,
    this.city,
    this.state,
    this.zipCode,
    this.lat,
    this.lng,
    this.landmark,
    this.isDefault,
    this.isActive,
    this.createdAtIST,
    this.updatedAtIST,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  factory AddressData.fromJson(Map<String, dynamic> json) {
    return AddressData(
      id: json['_id'],
      user: json['user'],
      label: json['label'],
      street: json['street'],
      area: json['area'],
      city: json['city'],
      state: json['state'],
      zipCode: json['zipCode'],
      lat: json['lat'] != null ? (json['lat'] as num).toDouble() : null,
      lng: json['lng'] != null ? (json['lng'] as num).toDouble() : null,
      landmark: json['landmark'],
      isDefault: json['isDefault'],
      isActive: json['isActive'],
      createdAtIST: json['createdAtIST'],
      updatedAtIST: json['updatedAtIST'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      v: json['__v'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'user': user,
      'label': label,
      'street': street,
      'area': area,
      'city': city,
      'state': state,
      'zipCode': zipCode,
      'lat': lat,
      'lng': lng,
      'landmark': landmark,
      'isDefault': isDefault,
      'isActive': isActive,
      'createdAtIST': createdAtIST,
      'updatedAtIST': updatedAtIST,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      '__v': v,
    };
  }
}


//order history 

class OrderHistoryResponse {
  final bool? success;
  final String? message;
  final Meta? meta;
  final List<OrderData>? data;

  OrderHistoryResponse({this.success, this.message, this.meta, this.data});

  factory OrderHistoryResponse.fromJson(Map<String, dynamic> json) {
    return OrderHistoryResponse(
      success: json['success'],
      message: json['message'],
      meta: json['meta'] != null ? Meta.fromJson(json['meta']) : null,
      data: json['data'] != null
          ? List<OrderData>.from(json['data'].map((x) => OrderData.fromJson(x)))
          : [],
    );
  }
}

class Meta {
  final int? total;
  final int? page;
  final int? limit;

  Meta({this.total, this.page, this.limit});

  factory Meta.fromJson(Map<String, dynamic> json) {
    return Meta(total: json['total'], page: json['page'], limit: json['limit']);
  }
}

class OrderData {
  final String? id;
  final String? orderId;
  final Restaurant? restaurant;
  final Customer? customer;
  final DeliveryAddress? deliveryAddress;
  final List<OrderItem>? items;
  final Price? price;
  final Payment? payment;
  final String? status;
  final List<Timeline>? timeline;
  final String? createdAt;
  final String? updatedAt;

  OrderData({
    this.id,
    this.orderId,
    this.restaurant,
    this.customer,
    this.deliveryAddress,
    this.items,
    this.price,
    this.payment,
    this.status,
    this.timeline,
    this.createdAt,
    this.updatedAt,
  });

  factory OrderData.fromJson(Map<String, dynamic> json) {
    return OrderData(
      id: json['_id'],
      orderId: json['orderId'],
      restaurant: json['restaurant'] != null
          ? Restaurant.fromJson(json['restaurant'])
          : null,
      customer: json['customer'] != null
          ? Customer.fromJson(json['customer'])
          : null,
      deliveryAddress: json['deliveryAddress'] != null
          ? DeliveryAddress.fromJson(json['deliveryAddress'])
          : null,
      items: json['items'] != null
          ? List<OrderItem>.from(
              json['items'].map((x) => OrderItem.fromJson(x)),
            )
          : [],
      price: json['price'] != null ? Price.fromJson(json['price']) : null,
      payment: json['payment'] != null
          ? Payment.fromJson(json['payment'])
          : null,
      status: json['status'],
      timeline: json['timeline'] != null
          ? List<Timeline>.from(
              json['timeline'].map((x) => Timeline.fromJson(x)),
            )
          : [],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
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

class Customer {
  final String? name;
  final String? phone;

  Customer({this.name, this.phone});

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(name: json['name'], phone: json['phone']);
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
  final String? itemId;
  final String? name;
  final int? quantity;
  final int? basePrice;
  final int? finalItemPrice;

  OrderItem({
    this.itemId,
    this.name,
    this.quantity,
    this.basePrice,
    this.finalItemPrice,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      itemId: json['itemId'],
      name: json['name'],
      quantity: json['quantity'],
      basePrice: json['basePrice'],
      finalItemPrice: json['finalItemPrice'],
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

class Timeline {
  final String? status;
  final String? at;

  Timeline({this.status, this.at});

  factory Timeline.fromJson(Map<String, dynamic> json) {
    return Timeline(status: json['status'], at: json['at']);
  }
}




// Banner section ----------model ------


class BannerResponse {
  final bool? success;
  final String? message;
  final List<BannerItem>? data;

  BannerResponse({
    this.success,
    this.message,
    this.data,
  });

  factory BannerResponse.fromJson(Map<String, dynamic> json) {
    return BannerResponse(
      success: json['success'],
      message: json['message'],
      data: (json['data'] as List?)
          ?.map((e) => BannerItem.fromJson(e))
          .toList(),
    );
  }
}

class BannerItem {
  final String? id;
  final String? title;
  final String? description;
  final String? image;
  final bool? isActive;
  final String? createdAt;
  final String? updatedAt;
  final int? order;

  BannerItem({
    this.id,
    this.title,
    this.description,
    this.image,
    this.isActive,
    this.createdAt,
    this.updatedAt,
    this.order,
  });

  factory BannerItem.fromJson(Map<String, dynamic> json) {
    return BannerItem(
      id: json['_id'],
      title: json['title'],
      description: json['description'],
      image: json['image'],
      isActive: json['isActive'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      order: json['order'],
    );
  }
}
