class ProfileResponse {
  bool? success;
  String? message;
  ProfileData? data;

  ProfileResponse({this.success, this.message, this.data});

  factory ProfileResponse.fromJson(Map<String, dynamic> json) {
    return ProfileResponse(
      success: json['success'],
      message: json['message'],
      data: json['data'] != null ? ProfileData.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'success': success, 'message': message, 'data': data?.toJson()};
  }
}

class ProfileData {
  String? id;
  String? mobile;
  String? name;
  String? email;
  bool? isMobileVerified;
  bool? isEmailVerified;
  String? createdAt;

  ProfileData({
    this.id,
    this.mobile,
    this.name,
    this.email,
    this.isMobileVerified,
    this.isEmailVerified,
    this.createdAt,
  });

  factory ProfileData.fromJson(Map<String, dynamic> json) {
    return ProfileData(
      id: json['id'],
      mobile: json['mobile'],
      name: json['name'],
      email: json['email'],
      isMobileVerified: json['isMobileVerified'],
      isEmailVerified: json['isEmailVerified'],
      createdAt: json['createdAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mobile': mobile,
      'name': name,
      'email': email,
      'isMobileVerified': isMobileVerified,
      'isEmailVerified': isEmailVerified,
      'createdAt': createdAt,
    };
  }
}
