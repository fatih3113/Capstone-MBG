// File ini mendefinisikan pembungkus (wrapper) standar untuk hasil respons API backend agar penanganan data dan error seragam.

// ApiResponse: kelas generik pembungkus respons backend berisi status sukses, pesan, data payload, dan daftar error jika ada.
class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final int? statusCode;
  final Map<String, dynamic>? errors;

  const ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.statusCode,
    this.errors,
  });

  // Factory untuk memetakan respons JSON dari server ke dalam objek ApiResponse.
  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJson,
  ) {
    return ApiResponse<T>(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      data: json['data'] != null && fromJson != null
          ? fromJson(json['data'])
          : null,
      statusCode: json['status_code'] as int?,
      errors: json['errors'] as Map<String, dynamic>?,
    );
  }

  // Factory bantuan untuk membuat respons sukses lokal.
  factory ApiResponse.success({
    required T data,
    String message = 'Berhasil',
  }) {
    return ApiResponse<T>(
      success: true,
      message: message,
      data: data,
    );
  }

  // Factory bantuan untuk membuat respons error lokal.
  factory ApiResponse.error({
    required String message,
    int? statusCode,
    Map<String, dynamic>? errors,
  }) {
    return ApiResponse<T>(
      success: false,
      message: message,
      statusCode: statusCode,
      errors: errors,
    );
  }

  bool get hasData => data != null;
  bool get hasErrors => errors != null && errors!.isNotEmpty;
}

/// PaginatedResponse: pembungkus respons untuk data daftar dengan pagination/halaman.
class PaginatedResponse<T> {
  final List<T> data;
  final int total;
  final int currentPage;
  final int lastPage;
  final int perPage;

  const PaginatedResponse({
    required this.data,
    required this.total,
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
  });

  // Factory untuk memetakan JSON paginasi dari backend ke objek PaginatedResponse.
  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    return PaginatedResponse<T>(
      data: (json['data'] as List<dynamic>?)
              ?.map((e) => fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      total: json['total'] as int? ?? 0,
      currentPage: json['current_page'] as int? ?? 1,
      lastPage: json['last_page'] as int? ?? 1,
      perPage: json['per_page'] as int? ?? 20,
    );
  }

  bool get hasMorePages => currentPage < lastPage;
}
