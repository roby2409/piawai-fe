import 'service_model.dart';

class WorkerProfileModel {
  final int? id;
  final int? userId;
  final String username;
  final String fullName;
  final String? avatarUrl;
  final String? phoneWa; // nullable
  final String? emailContact; // nullable
  final String? instagram;
  final String? bio;
  final double? lat; // nullable
  final double? lng; // nullable
  final int radiusKm;
  final String? areaLabel; // nullable
  final bool isAvailable;
  final int? age; // nullable
  final String? gender; // nullable
  final String? createdAt;
  final String? updatedAt;
  final List<ServiceModel> services;

  WorkerProfileModel({
    this.id,
    this.userId,
    required this.username,
    required this.fullName,
    this.avatarUrl,
    this.phoneWa,
    this.emailContact,
    this.instagram,
    this.bio,
    this.lat,
    this.lng,
    required this.radiusKm,
    this.areaLabel,
    required this.isAvailable,
    this.age,
    this.gender,
    this.createdAt,
    this.updatedAt,
    required this.services,
  });

  factory WorkerProfileModel.fromJson(Map<String, dynamic> json) =>
      WorkerProfileModel(
        id: json['id'],
        userId: json['user_id'],
        username: json['username'],
        fullName: json['full_name'],
        avatarUrl: json['avatar_url'],
        phoneWa: json['phone_wa'],
        emailContact: json['email_contact'],
        instagram: json['instagram'],
        bio: json['bio'],
        lat: json['lat'] != null ? double.parse(json['lat'].toString()) : null,
        lng: json['lng'] != null ? double.parse(json['lng'].toString()) : null,
        radiusKm: json['radius_km'] ?? 15,
        areaLabel: json['area_label'],
        isAvailable: json['is_available'] ?? false,
        age: json['age'],
        gender: json['gender'],
        createdAt: json['created_at'],
        updatedAt: json['updated_at'],
        services: (json['services'] as List? ?? [])
            .map((e) => ServiceModel.fromJson(e))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
    'username': username,
    'full_name': fullName,
    'avatar_url': avatarUrl,
    'phone_wa': phoneWa,
    'email_contact': emailContact,
    'instagram': instagram,
    'bio': bio,
    'lat': lat,
    'lng': lng,
    'radius_km': radiusKm,
    'area_label': areaLabel,
    'is_available': isAvailable,
    'age': age,
    'gender': gender,
  };

  // Tambah getter di WorkerProfileModel
  bool get isProfileComplete =>
      fullName.isNotEmpty &&
      gender != null &&
      phoneWa != null &&
      services.isNotEmpty &&
      lat != null &&
      lng != null;
}
