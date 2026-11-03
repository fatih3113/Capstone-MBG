"use strict";
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
Object.defineProperty(exports, "__esModule", { value: true });
exports.ALLERGY_OTHER_MAX_LENGTH = exports.ALLOWED_ALLERGIES = void 0;
exports.parseAllergyInput = parseAllergyInput;
exports.allergyDbFields = allergyDbFields;
exports.toAllergyResponse = toAllergyResponse;
exports.ALLOWED_ALLERGIES = [
    'kacang',
    'telur',
    'susu',
    'ikan',
    'udang',
    'gandum',
    'kedelai',
    'lainnya',
];
exports.ALLERGY_OTHER_MAX_LENGTH = 100;
const fail = (message) => ({ ok: false, message });
/** Trim, hapus karakter kontrol, rapikan spasi berlebih. */
function sanitizeText(value) {
    return value
        .replace(/[\u0000-\u001F\u007F]/g, ' ')
        .replace(/\s+/g, ' ')
        .trim();
}
function parseAllergyInput(body) {
    const src = body ?? {};
    const rawAllergies = src.allergies;
    const rawOther = src.allergy_other ?? src.allergyOther;
    const rawFilled = src.allergy_filled ?? src.allergyFilled;
    const isSet = (v) => v !== undefined && v !== null;
    // Tidak ada field alergi sama sekali → tidak dikirim
    if (!isSet(rawAllergies) && !isSet(rawOther) && !isSet(rawFilled)) {
        return { ok: true, provided: false };
    }
    // ── allergies ──
    const allergies = [];
    if (isSet(rawAllergies)) {
        if (!Array.isArray(rawAllergies) || rawAllergies.length > 20) {
            return fail('Format data alergi tidak valid');
        }
        for (const item of rawAllergies) {
            if (typeof item !== 'string')
                return fail('Format data alergi tidak valid');
            const value = item.trim().toLowerCase();
            if (!exports.ALLOWED_ALLERGIES.includes(value)) {
                return fail('Pilihan alergi tidak valid');
            }
            if (!allergies.includes(value))
                allergies.push(value);
        }
    }
    // ── allergy_filled ──
    if (isSet(rawFilled) && typeof rawFilled !== 'boolean') {
        return fail('Format data alergi tidak valid');
    }
    // Harus memilih alergi, atau secara eksplisit "Tidak ada alergi"
    if (allergies.length === 0 && rawFilled !== true) {
        return fail('Pilih alergi makanan atau Tidak ada alergi');
    }
    // ── allergy_other ──
    let allergyOther = null;
    if (allergies.includes('lainnya')) {
        if (isSet(rawOther) && typeof rawOther !== 'string') {
            return fail('Format data alergi tidak valid');
        }
        const cleaned = sanitizeText(typeof rawOther === 'string' ? rawOther : '');
        if (cleaned.length === 0)
            return fail('Sebutkan alergi makanan lainnya');
        if (cleaned.length > exports.ALLERGY_OTHER_MAX_LENGTH) {
            return fail(`Alergi lainnya maksimal ${exports.ALLERGY_OTHER_MAX_LENGTH} karakter`);
        }
        allergyOther = cleaned;
    }
    // jika "lainnya" tidak dipilih, allergy_other diabaikan (tetap null)
    return {
        ok: true,
        provided: true,
        data: { allergies, allergyOther, allergyFilled: true },
    };
}
/** Field Prisma untuk di-spread ke `data` saat create/update. Kosong jika tidak dikirim. */
function allergyDbFields(result) {
    return result.provided ? { ...result.data } : {};
}
/**
 * Bentuk respons untuk pemilik akun (snake_case, sama gaya dengan respons login).
 * Menghapus key camelCase hasil Prisma agar tidak muncul ganda.
 */
function toAllergyResponse(user) {
    const { allergies, allergyOther, allergyFilled, ...rest } = user;
    return {
        ...rest,
        allergies,
        allergy_other: allergyOther,
        allergy_filled: allergyFilled,
    };
}
//# sourceMappingURL=allergy.js.map