import 'dart:convert';

WorkerExploreModel workerFromJson(String str) =>
    WorkerExploreModel.fromJson(json.decode(str));

String workerToJson(WorkerExploreModel data) => json.encode(data.toJson());

class WorkerExploreModel {
  int userId;
  String username;
  String fullName;
  String? avatarUrl;
  String? bio;
  int? age;
  String? gender;
  String? areaLabel;
  bool? isAvailable;
  String? lat;
  String? lng;
  List<String> services;
  double distanceKm;

  WorkerExploreModel({
    required this.userId,
    required this.username,
    required this.fullName,
    required this.avatarUrl,
    required this.bio,
    required this.age,
    required this.gender,
    required this.areaLabel,
    required this.isAvailable,
    required this.lat,
    required this.lng,
    required this.services,
    required this.distanceKm,
  });

  factory WorkerExploreModel.fromJson(Map<String, dynamic> json) =>
      WorkerExploreModel(
        userId: json["user_id"],
        username: json["username"],
        fullName: json["full_name"],
        avatarUrl: json["avatar_url"],
        bio: json["bio"],
        age: json["age"],
        gender: json["gender"],
        areaLabel: json["area_label"],
        isAvailable: json["is_available"],
        lat: json["lat"],
        lng: json["lng"],
        services: List<String>.from(json["services"].map((x) => x)),
        distanceKm: json["distance_km"]?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
    "user_id": userId,
    "username": username,
    "full_name": fullName,
    "avatar_url": avatarUrl,
    "bio": bio,
    "age": age,
    "gender": gender,
    "area_label": areaLabel,
    "is_available": isAvailable,
    "lat": lat,
    "lng": lng,
    "services": List<dynamic>.from(services.map((x) => x)),
    "distance_km": distanceKm,
  };
}
