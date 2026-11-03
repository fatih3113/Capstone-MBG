// File ini mendefinisikan model data unit Satuan Pelayanan Pemenuhan Gizi (SPPG) di suatu wilayah.

/// Model untuk data SPPG dari endpoint publik GET /api/v1/sppg
// SppgModel: memegang informasi unit penyedia makanan MBG, termasuk lokasi geografis (provinsi, kabupaten, kecamatan).
class SppgModel {
  final String id;
  final String? kode;
  final String nama;
  final String provinsi;
  final String kabupatenKota;
  final String kecamatan;
  final String kelurahanDesa;
  final String? alamat;
  final double? latitude;
  final double? longitude;

  const SppgModel({
    required this.id,
    this.kode,
    required this.nama,
    required this.provinsi,
    required this.kabupatenKota,
    required this.kecamatan,
    required this.kelurahanDesa,
    this.alamat,
    this.latitude,
    this.longitude,
  });

  // Factory untuk memetakan data JSON unit SPPG dari backend.
  factory SppgModel.fromJson(Map<String, dynamic> json) {
    return SppgModel(
      id: json['id'] as String,
      kode: json['kode'] as String?,
      nama: json['nama'] as String,
      provinsi: json['provinsi'] as String,
      kabupatenKota: json['kabupatenKota'] as String,
      kecamatan: json['kecamatan'] as String,
      kelurahanDesa: json['kelurahanDesa'] as String,
      alamat: json['alamat'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );
  }

  /// Label ringkas untuk ditampilkan di dropdown
  // Label gabungan nama dan kode SPPG untuk memudahkan identifikasi pada dropdown.
  String get displayLabel => kode != null ? '$nama ($kode)' : nama;

  @override
  String toString() => displayLabel;
}
