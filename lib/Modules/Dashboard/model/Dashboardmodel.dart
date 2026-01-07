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
      foodType: json['foodType'] ?? json['foodType'] ?? json['foodType'],
      isVeg: json['isVeg'] ?? json['isVeg'] ?? json['isVeg'],
      tags: json['tags'] != null ? List<String>.from(json['tags']) : null,
      variants: json['variants'],
      addons: json['addons'],
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
