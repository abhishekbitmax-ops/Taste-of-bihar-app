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
