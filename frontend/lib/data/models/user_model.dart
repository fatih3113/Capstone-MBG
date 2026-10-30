class UserModel {
  final String id;
  final String name;
  final String email;
  final String? schoolId;
  final String? schoolName;
  final String? className;
  final String? gender; // 'L' or 'P'
  final int? age;
  final String? profileImageUrl;
  final String? schoolLevel; // SD, SMP, SMA, SMK
  final DateTime createdAt;

  // SPPG info (dari login response)
  final String? sppgId;
  final String? sppgName;
  final String? provinsi;
  final String? kabupatenKota;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.schoolId,
    this.schoolName,
    this.className,
    this.gender,
    this.age,
    this.profileImageUrl,
    this.schoolLevel,
    required this.createdAt,
    this.sppgId,
    this.sppgName,
    this.provinsi,
    this.kabupatenKota,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      schoolId: json['school_id']?.toString(),
      schoolName: json['school_name'] as String?,
      className: json['class'] as String?,
      gender: json['gender'] as String?,
      age: json['age'] as int?,
      profileImageUrl: json['profile_image_url'] as String?,
      schoolLevel: json['school_level'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      sppgId: json['sppg_id'] as String?,
      sppgName: json['sppg_name'] as String?,
      provinsi: json['provinsi'] as String?,
      kabupatenKota: json['kabupaten_kota'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'school_id': schoolId,
      'school_name': schoolName,
      'class': className,
      'gender': gender,
      'age': age,
      'profile_image_url': profileImageUrl,
      'school_level': schoolLevel,
      'created_at': createdAt.toIso8601String(),
      'sppg_id': sppgId,
      'sppg_name': sppgName,
      'provinsi': provinsi,
      'kabupaten_kota': kabupatenKota,
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? schoolId,
    String? schoolName,
    String? className,
    String? gender,
    int? age,
    String? profileImageUrl,
    String? schoolLevel,
    DateTime? createdAt,
    String? sppgId,
    String? sppgName,
    String? provinsi,
    String? kabupatenKota,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      schoolId: schoolId ?? this.schoolId,
      schoolName: schoolName ?? this.schoolName,
      className: className ?? this.className,
      gender: gender ?? this.gender,
      age: age ?? this.age,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      schoolLevel: schoolLevel ?? this.schoolLevel,
      createdAt: createdAt ?? this.createdAt,
      sppgId: sppgId ?? this.sppgId,
      sppgName: sppgName ?? this.sppgName,
      provinsi: provinsi ?? this.provinsi,
      kabupatenKota: kabupatenKota ?? this.kabupatenKota,
    );
  }

  String get genderLabel {
    switch (gender) {
      case 'L': return 'Laki-laki';
      case 'P': return 'Perempuan';
      default: return '-';
    }
  }

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }
}
