/// Model sekolah dari endpoint publik GET /api/v1/schools
class SchoolModel {
  final String id;
  final String name;
  final String level; // SD | SMP | SMA | SMK
  final String? address;
  final String? city;
  final String? sppgId;

  const SchoolModel({
    required this.id,
    required this.name,
    required this.level,
    this.address,
    this.city,
    this.sppgId,
  });

  factory SchoolModel.fromJson(Map<String, dynamic> json) {
    return SchoolModel(
      id: json['id'] as String,
      name: json['name'] as String,
      level: json['level'] as String? ?? '',
      address: json['address'] as String?,
      city: json['city'] as String?,
      sppgId: json['sppgId'] as String?,
    );
  }

  /// Label di dropdown, contoh: "SMA N 2 Brebes (SMA)"
  String get displayLabel => level.isNotEmpty ? '$name ($level)' : name;

  @override
  String toString() => displayLabel;
}