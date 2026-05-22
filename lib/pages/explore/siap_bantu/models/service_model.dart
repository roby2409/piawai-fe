class ServiceModel {
  final int id;
  final String nama;
  final String? deskripsi;
  final bool isActive;

  ServiceModel({
    required this.id,
    required this.nama,
    required this.deskripsi,
    required this.isActive,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) => ServiceModel(
    id: json['id'],
    nama: json['nama'],
    deskripsi: json['deskripsi'],
    isActive: json['is_active'],
  );

  Map<String, dynamic> toJson() => {
    'nama': nama,
    'deskripsi': deskripsi,
    'is_active': isActive,
  };
}
