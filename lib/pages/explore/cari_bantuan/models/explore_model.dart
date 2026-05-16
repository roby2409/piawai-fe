// To parse this JSON data, do
//
//     final explore = exploreFromJson(jsonString);

import 'dart:convert';

import 'package:piawai/pages/explore/cari_bantuan/models/worker_model.dart';

ExploreModel exploreFromJson(String str) =>
    ExploreModel.fromJson(json.decode(str));

String exploreToJson(ExploreModel data) => json.encode(data.toJson());

class ExploreModel {
  int total;
  List<WorkerExploreModel> workers;
  Filter filter;

  ExploreModel({
    required this.total,
    required this.workers,
    required this.filter,
  });

  factory ExploreModel.fromJson(Map<String, dynamic> json) => ExploreModel(
    total: json["total"],
    workers: List<WorkerExploreModel>.from(
      json["workers"].map((x) => WorkerExploreModel.fromJson(x)),
    ),
    filter: Filter.fromJson(json["filter"]),
  );

  Map<String, dynamic> toJson() => {
    "total": total,
    "workers": List<dynamic>.from(workers.map((x) => x.toJson())),
    "filter": filter.toJson(),
  };
}

class Filter {
  double lat;
  double lng;
  double radius;
  String q;
  String? gender;
  int? ageMin;
  int? ageMax;

  Filter({
    required this.lat,
    required this.lng,
    required this.radius,
    required this.q,
    required this.gender,
    required this.ageMin,
    required this.ageMax,
  });

  factory Filter.fromJson(Map<String, dynamic> json) => Filter(
    lat: json["lat"]?.toDouble(),
    lng: json["lng"]?.toDouble(),
    radius: json["radius"]?.toDouble(),
    q: json["q"],
    gender: json["gender"],
    ageMin: json["age_min"],
    ageMax: json["age_max"],
  );

  Map<String, dynamic> toJson() => {
    "lat": lat,
    "lng": lng,
    "radius": radius,
    "q": q,
    "gender": gender,
    "age_min": ageMin,
    "age_max": ageMax,
  };
}
