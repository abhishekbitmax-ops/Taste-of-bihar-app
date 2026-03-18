class QuickCategoryModel {
  int? statusCode;
  List<CategoryData>? data;
  String? message;
  bool? success;

  QuickCategoryModel({
    this.statusCode,
    this.data,
    this.message,
    this.success,
  });

  QuickCategoryModel.fromJson(Map<String, dynamic> json) {
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
    final Map<String, dynamic> dataMap = {};
    dataMap['statusCode'] = statusCode;
    if (data != null) {
      dataMap['data'] = data!.map((v) => v.toJson()).toList();
    }
    dataMap['message'] = message;
    dataMap['success'] = success;
    return dataMap;
  }
}

class CategoryData {
  String? id;
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
  int? v;
  int? count;

  CategoryData({
    this.id,
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
    this.v,
    this.count,
  });

  CategoryData.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
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
    v = json['__v'];
    count = json['count'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> dataMap = {};
    dataMap['_id'] = id;
    dataMap['restaurant'] = restaurant;
    dataMap['name'] = name;
    dataMap['type'] = type;
    dataMap['description'] = description;
    dataMap['categoryImage'] = categoryImage;
    dataMap['isActive'] = isActive;
    dataMap['sortOrder'] = sortOrder;
    dataMap['isRecommended'] = isRecommended;
    dataMap['createdAt'] = createdAt;
    dataMap['updatedAt'] = updatedAt;
    dataMap['__v'] = v;
    dataMap['count'] = count;
    return dataMap;
  }
}