class CategoryResponse {
  int? statusCode;
  List<CategoryData>? data;
  String? message;
  bool? success;

  CategoryResponse({this.statusCode, this.data, this.message, this.success});

  CategoryResponse.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];
    if (json['data'] != null) {
      data = <CategoryData>[];
      json['data'].forEach((v) {
        data!.add(CategoryData.fromJson(v));
      });
    }
    message = json['message'];
    success = json['success'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['statusCode'] = statusCode;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['message'] = message;
    data['success'] = success;
    return data;
  }
}

class CategoryData {
  String? sId;
  String? restaurant;
  String? name;
  String? type;
  String? description;
  String? categoryImage;
  bool? isActive;
  int? sortOrder;
  bool? isRecommended;
  String? createdAt;
  String? updatedAt;
  int? iV;
  int? count;

  CategoryData({
    this.sId,
    this.restaurant,
    this.name,
    this.type,
    this.description,
    this.categoryImage,
    this.isActive,
    this.sortOrder,
    this.isRecommended,
    this.createdAt,
    this.updatedAt,
    this.iV,
    this.count,
  });

  CategoryData.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    restaurant = json['restaurant'];
    name = json['name'];
    type = json['type'];
    description = json['description'];
    categoryImage = json['categoryImage'];
    isActive = json['isActive'];
    sortOrder = json['sortOrder'];
    isRecommended = json['isRecommended'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
    count = json['count'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['_id'] = sId;
    data['restaurant'] = restaurant;
    data['name'] = name;
    data['type'] = type;
    data['description'] = description;
    data['categoryImage'] = categoryImage;
    data['isActive'] = isActive;
    data['sortOrder'] = sortOrder;
    data['isRecommended'] = isRecommended;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['__v'] = iV;
    data['count'] = count;
    return data;
  }
}

// Subcategory Items Model
class SubCategoryResponse {
  int? statusCode;
  List<SubCategoryData>? data;
  String? message;
  bool? success;

  SubCategoryResponse({this.statusCode, this.data, this.message, this.success});

  SubCategoryResponse.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];

    if (json['data'] != null) {
      data = <SubCategoryData>[];
      json['data'].forEach((v) {
        data!.add(SubCategoryData.fromJson(v));
      });
    }

    message = json['message'];
    success = json['success'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['statusCode'] = statusCode;

    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }

    data['message'] = message;
    data['success'] = success;

    return data;
  }
}

class SubCategoryData {
  String? sId;
  String? restaurant;
  String? category;
  String? name;
  String? description;
  String? subCategoryImage;
  bool? isActive;
  int? sortOrder;
  String? createdAt;
  String? updatedAt;
  int? iV;
  int? count;

  SubCategoryData({
    this.sId,
    this.restaurant,
    this.category,
    this.name,
    this.description,
    this.subCategoryImage,
    this.isActive,
    this.sortOrder,
    this.createdAt,
    this.updatedAt,
    this.iV,
    this.count,
  });

  SubCategoryData.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    restaurant = json['restaurant'];
    category = json['category'];
    name = json['name'];
    description = json['description'];
    subCategoryImage = json['subCategoryImage'];
    isActive = json['isActive'];
    sortOrder = json['sortOrder'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
    count = json['count'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    data['_id'] = sId;
    data['restaurant'] = restaurant;
    data['category'] = category;
    data['name'] = name;
    data['description'] = description;
    data['subCategoryImage'] = subCategoryImage;
    data['isActive'] = isActive;
    data['sortOrder'] = sortOrder;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['__v'] = iV;
    data['count'] = count;

    return data;
  }
}

// Category Items Model

class MenuResponse {
  int? statusCode;
  MenuData? data;
  String? message;
  bool? success;

  MenuResponse({this.statusCode, this.data, this.message, this.success});

  MenuResponse.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];
    final dynamic rawData = json['data'];
    if (rawData is Map<String, dynamic>) {
      data = MenuData.fromJson(rawData);
    } else if (rawData is List) {
      data = MenuData.fromDynamicList(rawData);
    } else {
      data = null;
    }
    message = json['message'];
    success = json['success'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['statusCode'] = statusCode;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    data['message'] = message;
    data['success'] = success;
    return data;
  }
}

class MenuData {
  Meta? meta;
  List<MenuItem>? data;

  MenuData({this.meta, this.data});

  MenuData.fromJson(Map<String, dynamic> json) {
    meta = json['meta'] != null ? Meta.fromJson(json['meta']) : null;
    if (json['data'] != null) {
      data = <MenuItem>[];
      json['data'].forEach((v) {
        data!.add(MenuItem.fromJson(v));
      });
    }
  }

  MenuData.fromDynamicList(List<dynamic> jsonList) {
    data = <MenuItem>[];
    for (final item in jsonList) {
      if (item is Map<String, dynamic>) {
        data!.add(MenuItem.fromJson(item));
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (meta != null) {
      data['meta'] = meta!.toJson();
    }
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Meta {
  int? total; 
  int? page;
  int? limit;
  int? totalPages;

  Meta({this.total, this.page, this.limit, this.totalPages});

  Meta.fromJson(Map<String, dynamic> json) {
    total = json['total'];
    page = json['page'];
    limit = json['limit'];
    totalPages = json['totalPages'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['total'] = total;
    data['page'] = page;
    data['limit'] = limit;
    data['totalPages'] = totalPages;
    return data;
  }
}

class MenuItem {
  String? sId;
  String? restaurant;
  Category? category;
  Category? subCategory;
  String? name;
  String? description;
  int? basePrice;
  String? foodType;
  bool? isVeg;
  List<dynamic>? tags;
  List<Variant>? variants;
  List<dynamic>? addons;
  bool? isAvailable;
  bool? isAvailableToday;
  String? mealType;
  String? menuImage;
  String? createdAt;
  String? updatedAt;
  int? iV;

  MenuItem({
    this.sId,
    this.restaurant,
    this.category,
    this.subCategory,
    this.name,
    this.description,
    this.basePrice,
    this.foodType,
    this.isVeg,
    this.tags,
    this.variants,
    this.addons,
    this.isAvailable,
    this.isAvailableToday,
    this.mealType,
    this.menuImage,
    this.createdAt,
    this.updatedAt,
    this.iV,
  });

  MenuItem.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    restaurant = json['restaurant'];
    category =
        json['category'] != null ? Category.fromJson(json['category']) : null;
    subCategory = json['subCategory'] != null
        ? Category.fromJson(json['subCategory'])
        : null;
    name = json['name'];
    description = json['description'];
    basePrice = json['basePrice'];
    foodType = json['foodType'];
    isVeg = json['isVeg'];
    tags = json['tags'];
    if (json['variants'] != null) {
      variants = <Variant>[];
      json['variants'].forEach((v) {
        variants!.add(Variant.fromJson(v));
      });
    }
    addons = json['addons'];
    isAvailable = json['isAvailable'];
    isAvailableToday = json['isAvailableToday'];
    mealType = json['mealType'];
    menuImage = json['menuImage'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['_id'] = sId;
    data['restaurant'] = restaurant;
    if (category != null) {
      data['category'] = category!.toJson();
    }
    if (subCategory != null) {
      data['subCategory'] = subCategory!.toJson();
    }
    data['name'] = name;
    data['description'] = description;
    data['basePrice'] = basePrice;
    data['foodType'] = foodType;
    data['isVeg'] = isVeg;
    data['tags'] = tags;
    if (variants != null) {
      data['variants'] = variants!.map((v) => v.toJson()).toList();
    }
    data['addons'] = addons;
    data['isAvailable'] = isAvailable;
    data['isAvailableToday'] = isAvailableToday;
    data['mealType'] = mealType;
    data['menuImage'] = menuImage;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['__v'] = iV;
    return data;
  }
}

class Category {
  String? sId;
  String? name;
  String? categoryImage;
  String? subCategoryImage;

  Category({this.sId, this.name, this.categoryImage, this.subCategoryImage});

  Category.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    categoryImage = json['categoryImage'];
    subCategoryImage = json['subCategoryImage'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['_id'] = sId;
    data['name'] = name;
    data['categoryImage'] = categoryImage;
    data['subCategoryImage'] = subCategoryImage;
    return data;
  }
}

class Variant {
  String? name;
  int? price;

  Variant({this.name, this.price});

  Variant.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    price = json['price'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['name'] = name;
    data['price'] = price;
    return data;
  }
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

// class Meta {
//   final int? total;
//   final int? page;
//   final int? limit;

//   Meta({this.total, this.page, this.limit});

//   factory Meta.fromJson(Map<String, dynamic> json) {
//     return Meta(total: json['total'], page: json['page'], limit: json['limit']);
//   }
// }

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

  BannerResponse({this.success, this.message, this.data});

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
