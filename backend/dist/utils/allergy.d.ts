/**
 * Validasi & normalisasi data alergi makanan pengguna.
 * Dipakai oleh register dan update profil.
 *
 * Aturan:
 *  - allergies: array nilai dari ALLOWED_ALLERGIES (huruf kecil, tanpa duplikat)
 *  - "lainnya" wajib disertai allergy_other (maks 100 karakter)
 *  - allergy_other diabaikan (null) jika "lainnya" tidak dipilih
 *  - "Tidak ada alergi" = allergies kosong + allergy_filled true
 *  - Jika tidak ada satu pun field alergi di request → dianggap tidak dikirim
 *    (register: tetap "belum diisi", update profil: data lama tidak diubah)
 */
export declare const ALLOWED_ALLERGIES: readonly ["kacang", "telur", "susu", "ikan", "udang", "gandum", "kedelai", "lainnya"];
export declare const ALLERGY_OTHER_MAX_LENGTH = 100;
export interface AllergyData {
    allergies: string[];
    allergyOther: string | null;
    allergyFilled: boolean;
}
export type AllergyParseResult = {
    ok: false;
    message: string;
} | {
    ok: true;
    provided: false;
} | {
    ok: true;
    provided: true;
    data: AllergyData;
};
export declare function parseAllergyInput(body: Record<string, any> | undefined): AllergyParseResult;
/** Field Prisma untuk di-spread ke `data` saat create/update. Kosong jika tidak dikirim. */
export declare function allergyDbFields(result: {
    ok: true;
    provided: false;
} | {
    ok: true;
    provided: true;
    data: AllergyData;
}): Partial<AllergyData>;
/**
 * Bentuk respons untuk pemilik akun (snake_case, sama gaya dengan respons login).
 * Menghapus key camelCase hasil Prisma agar tidak muncul ganda.
 */
export declare function toAllergyResponse<T extends {
    allergies: string[];
    allergyOther: string | null;
    allergyFilled: boolean;
}>(user: T): Omit<T, "allergies" | "allergyOther" | "allergyFilled"> & {
    allergies: string[];
    allergy_other: string | null;
    allergy_filled: boolean;
};
//# sourceMappingURL=allergy.d.ts.map