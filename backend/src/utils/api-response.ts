// Utilitas Pembungkus Respon API: menyeragamkan format respon JSON (sukses, error, paginasi, dan validasi) di seluruh endpoint controller.

export class ApiResponse {
  // Format standar respon sukses dengan data muatan dan pesan informasi.
  static success<T>(data: T, message = 'Berhasil', statusCode = 200) {
    return { success: true, message, data, status_code: statusCode };
  }

  // Format standar respon kegagalan dengan pesan kesalahan dan kode status HTTP.
  static error(message: string, statusCode = 400) {
    return { success: false, message, status_code: statusCode };
  }

  // Format respon daftar data berpaginasi (total item, halaman saat ini, dan jumlah per halaman).
  static paginated<T>(
    data: T[],
    total: number,
    currentPage: number,
    perPage: number,
  ) {
    return {
      success: true,
      message: 'Berhasil',
      data,
      total,
      current_page: currentPage,
      last_page: Math.ceil(total / perPage),
      per_page: perPage,
    };
  }

  // Format respon khusus kegagalan validasi formulir (daftar field yang salah dan pesan errornya).
  static validationError(errors: any[]) {
    return {
      success: false,
      message: 'Validasi gagal',
      errors: errors.map((e) => ({ field: e.path, message: e.msg })),
    };
  }
}
