class ServiceModel {
  final int id;
  final String nama;
  final String deskripsi;
  final int hargaJam;
  final int hargaHari;
  final int? hargaProyek; // nullable karena bisa null
  final bool isActive;

  ServiceModel({
    required this.id,
    required this.nama,
    required this.deskripsi,
    required this.hargaJam,
    required this.hargaHari,
    this.hargaProyek,
    required this.isActive,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) => ServiceModel(
    id: json['id'],
    nama: json['nama'],
    deskripsi: json['deskripsi'],
    hargaJam: json['harga_jam'],
    hargaHari: json['harga_hari'],
    hargaProyek: json['harga_proyek'],
    isActive: json['is_active'],
  );

  Map<String, dynamic> toJson() => {
    'nama': nama,
    'deskripsi': deskripsi,
    'harga_jam': hargaJam,
    'harga_hari': hargaHari,
    'harga_proyek': hargaProyek,
    'is_active': isActive,
  };
}
