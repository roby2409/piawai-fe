import 'package:flutter/material.dart';
import 'package:piawai/core/constants.dart';
import 'package:piawai/pages/explore/siap_bantu/models/service_model.dart';
import 'package:piawai/services/worker_services.dart';

// ─────────────────────────────────────────
// LAYANAN SECTION
// ─────────────────────────────────────────
class LayananSection extends StatefulWidget {
  final List<ServiceModel> initialServices;
  final VoidCallback? onDataChanged;

  const LayananSection({
    super.key,
    required this.initialServices,
    this.onDataChanged,
  });

  @override
  State<LayananSection> createState() => LayananSectionState();
}

class LayananSectionState extends State<LayananSection> {
  final _workerService = WorkerService();
  late List<ServiceModel> _items;
  bool _isRefetching = false;

  @override
  void initState() {
    super.initState();
    _items = widget.initialServices;
  }

  // ── Refetch setelah CRUD ───────────────────────────────────────────────
  Future<void> _refetch() async {
    try {
      setState(() => _isRefetching = true);
      final raw = await _workerService.fetchServices();
      setState(() {
        _items = raw.map((e) => ServiceModel.fromJson(e)).toList();
        _isRefetching = false;
      });
      widget.onDataChanged?.call();
    } catch (e) {
      setState(() => _isRefetching = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal memuat data: $e')));
      }
    }
  }

  // ── Delete ─────────────────────────────────────────────────────────────
  Future<void> _deleteService(int id) async {
    try {
      await _workerService.deleteService(id);
      await _refetch();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Layanan berhasil dihapus')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal menghapus: $e')));
      }
    }
  }

  void _showMenuOptions(BuildContext context, int index) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.edit_outlined, color: kPrimary),
              title: const Text('Edit Layanan'),
              onTap: () {
                Navigator.pop(context);
                // di _showMenuOptions bagian edit
                _showTambahLayananSheet(
                  context,
                  existing: _items[index],
                  onSuccess: () => _refetch(),
                  onError: (msg) {
                    ScaffoldMessenger.of(
                      this.context,
                    ).showSnackBar(SnackBar(content: Text('Gagal: $msg')));
                  },
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text(
                'Hapus Layanan',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () {
                Navigator.pop(context);
                _deleteService(_items[index].id);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showTambahDialog(BuildContext context) {
    _showTambahLayananSheet(
      context,
      onSuccess: () => _refetch(),
      onError: (msg) {
        final overlay = Overlay.of(this.context);
        final entry = OverlayEntry(
          builder: (_) => Positioned(
            bottom: 50,
            left: 16,
            right: 16,
            child: Material(
              borderRadius: BorderRadius.circular(8),
              color: Colors.red.shade700,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Text(msg, style: const TextStyle(color: Colors.white)),
              ),
            ),
          ),
        );
        overlay.insert(entry);
        Future.delayed(const Duration(seconds: 3), () => entry.remove());
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header Row ──
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Layanan',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _showTambahDialog(context),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text(
                      'Tambah',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ── List Layanan ──
              if (_items.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Column(
                      children: [
                        Icon(
                          Icons.work_off_outlined,
                          size: 48,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Belum ada layanan',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ...List.generate(_items.length, (i) {
                  final item = _items[i];
                  return _LayananCard(
                    item: item,
                    onMenuTap: () => _showMenuOptions(context, i),
                  );
                }),
            ],
          ),
        ),

        // ── Loading overlay saat refetch ──
        if (_isRefetching)
          const Positioned.fill(
            child: ColoredBox(
              color: Colors.white60,
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────
// TAMBAH / EDIT LAYANAN BOTTOM SHEET
// ─────────────────────────────────────────

void _showTambahLayananSheet(
  BuildContext context, {
  ServiceModel? existing,
  VoidCallback? onSuccess,
  void Function(String)? onError, // ← tambah ini
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _TambahLayananSheet(
      existing: existing,
      onSuccess: onSuccess,
      onError: onError, // ← pass ke sheet
    ),
  );
}

class _TambahLayananSheet extends StatefulWidget {
  final ServiceModel? existing;
  final VoidCallback? onSuccess; // ← ganti onSave jadi onSuccess
  final void Function(String)? onError;

  const _TambahLayananSheet({this.existing, this.onSuccess, this.onError});

  @override
  State<_TambahLayananSheet> createState() => _TambahLayananSheetState();
}

class _TambahLayananSheetState extends State<_TambahLayananSheet> {
  final _namaController = TextEditingController();
  final _deskripsiController = TextEditingController();
  final _jamController = TextEditingController();
  final _hariController = TextEditingController();
  final _proyekController = TextEditingController();

  final _workerService = WorkerService();
  bool _showTarifError = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // ── Pre-fill kalau mode edit ──
    if (widget.existing != null) {
      final e = widget.existing!;
      _namaController.text = e.nama;
      _deskripsiController.text = e.deskripsi;
      _jamController.text = e.hargaJam > 0 ? e.hargaJam.toString() : '';
      _hariController.text = e.hargaHari > 0 ? e.hargaHari.toString() : '';
      _proyekController.text = e.hargaProyek != null
          ? e.hargaProyek.toString()
          : '';
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _deskripsiController.dispose();
    _jamController.dispose();
    _hariController.dispose();
    _proyekController.dispose();
    super.dispose();
  }

  bool get _tarifValid =>
      _jamController.text.trim().isNotEmpty ||
      _hariController.text.trim().isNotEmpty ||
      _proyekController.text.trim().isNotEmpty;

  bool get _canSave =>
      _namaController.text.trim().isNotEmpty && _tarifValid && !_isSaving;

  int? _parseHarga(String raw) {
    final clean = raw.trim();
    if (clean.isEmpty) return null;
    return int.tryParse(clean);
  }

  Future<void> _onSimpan() async {
    setState(() => _showTarifError = !_tarifValid);
    if (!_canSave) return;

    final payload = {
      'nama': _namaController.text.trim(),
      'deskripsi': _deskripsiController.text.trim(),
      'harga_jam': _parseHarga(_jamController.text) ?? 0,
      'harga_hari': _parseHarga(_hariController.text) ?? 0,
      'harga_proyek': _parseHarga(_proyekController.text),
      'is_active': true,
    };

    setState(() => _isSaving = true);
    try {
      if (widget.existing != null) {
        await _workerService.updateService(widget.existing!.id, payload);
      } else {
        await _workerService.createService(payload);
      }
      widget.onSuccess?.call(); // ← kasih tau parent buat refetch
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() => _isSaving = false);
      widget.onError?.call(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(20, 0, 20, 20 + bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Drag handle ──
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // ── Header ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.existing != null ? 'Edit Layanan' : 'Tambah Layanan',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.close, size: 22, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // ── Scroll area ──
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.65,
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _FieldLabel('Nama Layanan'),
                  const SizedBox(height: 6),
                  _InputField(
                    controller: _namaController,
                    hint: 'Contoh: Tukang Kebun',
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 16),

                  _FieldLabel('Deskripsi'),
                  const SizedBox(height: 6),
                  _InputField(
                    controller: _deskripsiController,
                    hint: 'Jelaskan layanan yang Anda tawarkan...',
                    maxLines: 4,
                  ),
                  const SizedBox(height: 16),

                  const Text(
                    'Tarif Layanan',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Isi minimal satu tarif',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 10),

                  _FieldLabel('Per Jam'),
                  const SizedBox(height: 6),
                  _TarifField(
                    controller: _jamController,
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 12),

                  _FieldLabel('Per Hari'),
                  const SizedBox(height: 6),
                  _TarifField(
                    controller: _hariController,
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 12),

                  _FieldLabel('Per Proyek'),
                  const SizedBox(height: 6),
                  _TarifField(
                    controller: _proyekController,
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 12),

                  // ── Error tarif ──
                  AnimatedCrossFade(
                    duration: const Duration(milliseconds: 200),
                    crossFadeState: _showTarifError && !_tarifValid
                        ? CrossFadeState.showFirst
                        : CrossFadeState.showSecond,
                    firstChild: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFBEB),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFFDE68A)),
                      ),
                      child: const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            size: 16,
                            color: Color(0xFFD97706),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Minimal satu tarif harus diisi (Jam, Hari, atau Proyek)',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF92400E),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    secondChild: const SizedBox.shrink(),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // ── Simpan Button ──
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _canSave ? _onSimpan : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimary,
                disabledBackgroundColor: const Color(0xFFD1D5DB),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: _isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Simpan Layanan',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// LAYANAN CARD
// ─────────────────────────────────────────
class _LayananCard extends StatelessWidget {
  final ServiceModel item;
  final VoidCallback onMenuTap;

  const _LayananCard({required this.item, required this.onMenuTap});

  String _formatHarga(int? value) {
    if (value == null || value == 0) return '-';
    if (value >= 1000) {
      final k = value ~/ 1000;
      final sisa = value % 1000;
      return sisa == 0 ? 'Rp ${k}k' : 'Rp $value';
    }
    return 'Rp $value';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kGrey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  item.nama,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              GestureDetector(
                onTap: onMenuTap,
                child: const Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Icon(Icons.more_vert, size: 20, color: Colors.grey),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            item.deskripsi,
            style: const TextStyle(fontSize: 13, color: Colors.grey),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _HargaChip(label: 'Jam', value: _formatHarga(item.hargaJam)),
              const SizedBox(width: 8),
              _HargaChip(label: 'Hari', value: _formatHarga(item.hargaHari)),
              const SizedBox(width: 8),
              _HargaChip(
                label: 'Proyek',
                value: _formatHarga(item.hargaProyek),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// HARGA CHIP
// ─────────────────────────────────────────
class _HargaChip extends StatelessWidget {
  final String label;
  final String value;

  const _HargaChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final bool hasValue = value != '-';
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
            const SizedBox(height: 3),
            Text(
              value,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: hasValue ? kPrimary : Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// HELPERS
// ─────────────────────────────────────────
class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
    );
  }
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final int maxLines;
  final void Function(String)? onChanged;

  const _InputField({
    required this.controller,
    required this.hint,
    this.maxLines = 1,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: kPrimary),
        ),
      ),
    );
  }
}

class _TarifField extends StatelessWidget {
  final TextEditingController controller;
  final void Function(String)? onChanged;

  const _TarifField({required this.controller, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: '0',
        hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
        prefixIcon: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Rp',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(width: 8),
              Container(width: 1, height: 20, color: Colors.grey[300]),
            ],
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: kPrimary),
        ),
      ),
    );
  }
}
