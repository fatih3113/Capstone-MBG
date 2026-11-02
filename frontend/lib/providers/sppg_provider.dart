import 'package:flutter/foundation.dart';
import '../data/models/school_model.dart';
import '../data/models/sppg_model.dart';
import '../data/services/sppg_service.dart';

enum SppgLoadState { initial, loading, loaded, error }

/// Provider untuk dropdown wilayah SPPG berjenjang di halaman Register.
/// Mengikuti pola yang sudah ada (ChangeNotifier + service injection).
class SppgProvider extends ChangeNotifier {
  final SppgService _service;

  SppgProvider(this._service);

  // ── State provinsi ───────────────────────────────────────────────────────
  SppgLoadState _provinsiState = SppgLoadState.initial;
  List<String> _provinces = [];
  String? _selectedProvinsi;
  String? _provinsiError;

  // ── State kabupaten/kota ─────────────────────────────────────────────────
  SppgLoadState _kabupatenState = SppgLoadState.initial;
  List<String> _kabupatenList = [];
  String? _selectedKabupaten;
  String? _kabupatenError;

  // ── State kecamatan ──────────────────────────────────────────────────────
  SppgLoadState _kecamatanState = SppgLoadState.initial;
  List<String> _kecamatanList = [];
  String? _selectedKecamatan;
  String? _kecamatanError;

  // ── State SPPG ───────────────────────────────────────────────────────────
  SppgLoadState _sppgState = SppgLoadState.initial;
  List<SppgModel> _sppgList = [];
  SppgModel? _selectedSppg;
  String? _sppgError;

  // ── State sekolah (bergantung pada SPPG terpilih) ───────────────────────
  SppgLoadState _schoolState = SppgLoadState.initial;
  List<SchoolModel> _schoolList = [];
  SchoolModel? _selectedSchool;
  String? _schoolError;

  // ── Getters ──────────────────────────────────────────────────────────────
  SppgLoadState get provinsiState => _provinsiState;
  List<String> get provinces => _provinces;
  String? get selectedProvinsi => _selectedProvinsi;
  String? get provinsiError => _provinsiError;

  SppgLoadState get kabupatenState => _kabupatenState;
  List<String> get kabupatenList => _kabupatenList;
  String? get selectedKabupaten => _selectedKabupaten;
  String? get kabupatenError => _kabupatenError;

  SppgLoadState get kecamatanState => _kecamatanState;
  List<String> get kecamatanList => _kecamatanList;
  String? get selectedKecamatan => _selectedKecamatan;
  String? get kecamatanError => _kecamatanError;

  SppgLoadState get sppgState => _sppgState;
  List<SppgModel> get sppgList => _sppgList;
  SppgModel? get selectedSppg => _selectedSppg;
  String? get sppgError => _sppgError;

  SppgLoadState get schoolState => _schoolState;
  List<SchoolModel> get schoolList => _schoolList;
  SchoolModel? get selectedSchool => _selectedSchool;
  String? get schoolError => _schoolError;

  // ── Actions ──────────────────────────────────────────────────────────────

  /// Muat daftar provinsi saat widget pertama kali dibuka.
  Future<void> loadProvinces() async {
    if (_provinsiState == SppgLoadState.loading) return;
    _provinsiState = SppgLoadState.loading;
    _provinsiError = null;
    notifyListeners();

    final resp = await _service.getProvinces();
    if (resp.success && resp.data != null) {
      _provinces = resp.data!;
      _provinsiState = SppgLoadState.loaded;
    } else {
      _provinsiError = resp.message;
      _provinsiState = SppgLoadState.error;
    }
    notifyListeners();
  }

  /// Dipanggil saat pengguna memilih provinsi.
  Future<void> selectProvinsi(String? provinsi) async {
    if (_selectedProvinsi == provinsi) return;
    _selectedProvinsi = provinsi;

    // Reset semua level di bawahnya
    _resetKabupaten();
    _resetKecamatan();
    _resetSppg();

    if (provinsi == null) {
      notifyListeners();
      return;
    }

    _kabupatenState = SppgLoadState.loading;
    notifyListeners();

    final resp = await _service.getKabupaten(provinsi);
    if (resp.success && resp.data != null) {
      _kabupatenList = resp.data!;
      _kabupatenState = SppgLoadState.loaded;
    } else {
      _kabupatenError = resp.message;
      _kabupatenState = SppgLoadState.error;
    }
    notifyListeners();
  }

  /// Dipanggil saat pengguna memilih kabupaten/kota.
  Future<void> selectKabupaten(String? kabupaten) async {
    if (_selectedKabupaten == kabupaten) return;
    _selectedKabupaten = kabupaten;

    _resetKecamatan();
    _resetSppg();

    if (kabupaten == null) {
      notifyListeners();
      return;
    }

    _kecamatanState = SppgLoadState.loading;
    notifyListeners();

    final resp = await _service.getKecamatan(kabupaten);
    if (resp.success && resp.data != null) {
      _kecamatanList = resp.data!;
      _kecamatanState = SppgLoadState.loaded;
    } else {
      _kecamatanError = resp.message;
      _kecamatanState = SppgLoadState.error;
    }
    notifyListeners();
  }

  /// Dipanggil saat pengguna memilih kecamatan.
  Future<void> selectKecamatan(String? kecamatan) async {
    if (_selectedKecamatan == kecamatan) return;
    _selectedKecamatan = kecamatan;
    _resetSppg();

    if (kecamatan == null) {
      notifyListeners();
      return;
    }

    _sppgState = SppgLoadState.loading;
    notifyListeners();

    final resp = await _service.getSppgList(
      provinsi: _selectedProvinsi,
      kabupatenKota: _selectedKabupaten,
      kecamatan: kecamatan,
    );
    if (resp.success && resp.data != null) {
      _sppgList = resp.data!;
      _sppgState = SppgLoadState.loaded;
    } else {
      _sppgError = resp.message;
      _sppgState = SppgLoadState.error;
    }
    notifyListeners();
  }

  /// Dipanggil saat pengguna memilih SPPG akhir.
  Future<void> selectSppg(SppgModel? sppg) async {
    _selectedSppg = sppg;
    _resetSchool();

    if (sppg == null) {
      notifyListeners();
      return;
    }

    _schoolState = SppgLoadState.loading;
    notifyListeners();

    final resp = await _service.getSchools(sppgId: sppg.id);
    // Abaikan hasil lama bila pengguna sudah mengganti SPPG selagi memuat
    if (_selectedSppg?.id != sppg.id) return;
    if (resp.success && resp.data != null) {
      _schoolList = resp.data!;
      _schoolState = SppgLoadState.loaded;
    } else {
      _schoolError = resp.message;
      _schoolState = SppgLoadState.error;
    }
    notifyListeners();
  }

  /// Dipanggil saat pengguna memilih sekolah.
  void selectSchool(SchoolModel? school) {
    _selectedSchool = school;
    notifyListeners();
  }

  /// Reset seluruh state (mis. saat form direset).
  void resetAll() {
    _selectedProvinsi = null;
    _selectedKabupaten = null;
    _selectedKecamatan = null;
    _selectedSppg = null;
    _resetKabupaten();
    _resetKecamatan();
    _resetSppg();
    notifyListeners();
  }

  // ── Private helpers ──────────────────────────────────────────────────────
  void _resetKabupaten() {
    _kabupatenList = [];
    _selectedKabupaten = null;
    _kabupatenError = null;
    _kabupatenState = SppgLoadState.initial;
  }

  void _resetKecamatan() {
    _kecamatanList = [];
    _selectedKecamatan = null;
    _kecamatanError = null;
    _kecamatanState = SppgLoadState.initial;
  }

  void _resetSppg() {
    _sppgList = [];
    _selectedSppg = null;
    _sppgError = null;
    _sppgState = SppgLoadState.initial;
    _resetSchool();
  }

  void _resetSchool() {
    _schoolList = [];
    _selectedSchool = null;
    _schoolError = null;
    _schoolState = SppgLoadState.initial;
  }
}