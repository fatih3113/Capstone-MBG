export class ApiResponse {
  static success<T>(data: T, message = 'Berhasil', statusCode = 200) {
    return { success: true, message, data, status_code: statusCode };
  }

  static error(message: string, statusCode = 400) {
    return { success: false, message, status_code: statusCode };
  }

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

  static validationError(errors: any[]) {
    return {
      success: false,
      message: 'Validasi gagal',
      errors: errors.map((e) => ({ field: e.path, message: e.msg })),
    };
  }
}
