// File ini mendefinisikan model menu harian MBG per sekolah serta item komponen makanannya.

import 'food_model.dart';

// MbgMenuModel: data menu harian MBG untuk sekolah tertentu pada tanggal dan hari tertentu.
class MbgMenuModel {
  final String id;
  final String schoolId;
  final String schoolName;
  final DateTime date;
  final String dayName;
  final List<MbgMenuItemModel> items;

  const MbgMenuModel({
    required this.id,
    required this.schoolId,
    required this.schoolName,
    required this.date,
    required this.dayName,
    required this.items,
  });

  // Factory untuk memetakan data JSON jadwal menu harian dari backend.
  factory MbgMenuModel.fromJson(Map<String, dynamic> json) {
    return MbgMenuModel(
      id: json['id']?.toString() ?? '',
      schoolId: json['school_id']?.toString() ?? '',
      schoolName: json['school_name'] as String? ?? '',
      date: json['date'] != null
          ? DateTime.parse(json['date'] as String)
          : DateTime.now(),
      dayName: json['day_name'] as String? ?? '',
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => MbgMenuItemModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  // Mengubah objek menu ke dalam format JSON.
  Map<String, dynamic> toJson() => {
    'id': id,
    'school_id': schoolId,
    'school_name': schoolName,
    'date': date.toIso8601String(),
    'day_name': dayName,
    'items': items.map((e) => e.toJson()).toList(),
  };

  // Mengambil daftar nama seluruh hidangan dalam menu ini.
  List<String> get foodNames => items.map((e) => e.food.name).toList();
}

// MbgMenuItemModel: rincian satu item hidangan dalam menu beserta berat porsi standar (gram).
class MbgMenuItemModel {
  final String id;
  final String menuId;
  final FoodModel food;
  final double portionGram;

  const MbgMenuItemModel({
    required this.id,
    required this.menuId,
    required this.food,
    required this.portionGram,
  });

  // Factory untuk mengonversi data JSON item makanan ke MbgMenuItemModel.
  factory MbgMenuItemModel.fromJson(Map<String, dynamic> json) {
    return MbgMenuItemModel(
      id: json['id']?.toString() ?? '',
      menuId: json['menu_id']?.toString() ?? '',
      food: FoodModel.fromJson(json['food'] as Map<String, dynamic>? ?? {}),
      portionGram: (json['portion_gram'] as num?)?.toDouble() ?? 100,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'menu_id': menuId,
    'food': food.toJson(),
    'portion_gram': portionGram,
  };
}
