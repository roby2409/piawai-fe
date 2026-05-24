import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:piawai/core/app_colors.dart';
import 'package:piawai/pages/explore/siap_bantu/models/service_model.dart';
import 'package:piawai/pages/widgets/input_field.dart';
import 'package:piawai/pages/widgets/overlay_snackbar.dart';
import 'package:piawai/services/config_services.dart';
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('general.fetch_failed'.tr(args: ['$e']))),
        );
      }
    }
  }

  Future<void> _deleteService(int id) async {
    try {
      await _workerService.deleteService(id);
      await _refetch();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('service_success_deleted'.tr())));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('general.delete_failed'.tr(args: ['$e']))),
        );
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
                color: context.grey,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: Icon(Icons.edit_outlined, color: context.primary),
              title: Text('siap_bantu.edit_services'.tr()),
              onTap: () {
                Navigator.pop(context);
                _showTambahLayananSheet(
                  context,
                  existing: _items[index],
                  onSuccess: () => _refetch(),
                  onError: (msg) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('general.failed'.tr(args: [msg]))),
                    );
                  },
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: Text(
                'siap_bantu.delete_services'.tr(),
                style: TextStyle(color: context.red),
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
              color: context.red,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Text(msg, style: TextStyle(color: context.white)),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "your_services".tr(),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _showTambahDialog(context),
                    icon: const Icon(Icons.add, size: 18),
                    label: Text(
                      'general.add'.tr(),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.primary,
                      foregroundColor: context.white,
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

              if (_items.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Column(
                      children: [
                        Icon(
                          Icons.work_off_outlined,
                          size: 48,
                          color: context.grey,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'siap_bantu.services_empty'.tr(),
                          style: TextStyle(color: context.black87),
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

        if (_isRefetching)
          Positioned.fill(
            child: ColoredBox(
              color: context.white60,
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
  void Function(String)? onError,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: context.transparent,
    builder: (_) => DraggableScrollableSheet(
      // ← wrap dengan ini
      initialChildSize: 0.75, // ← mulai dari 75% layar
      minChildSize: 0.5, // ← minimum 50%
      maxChildSize: 0.8, // ← bisa full screen
      expand: false,
      builder: (_, scrollController) => _TambahLayananSheet(
        existing: existing,
        onSuccess: onSuccess,
        onError: onError,
        scrollController: scrollController, // ← pass scroll controller
      ),
    ),
  );
}

class _TambahLayananSheet extends StatefulWidget {
  final ServiceModel? existing;
  final VoidCallback? onSuccess;
  final void Function(String)? onError;
  final ScrollController? scrollController;

  const _TambahLayananSheet({
    this.existing,
    this.onSuccess,
    this.onError,
    this.scrollController, // ← tambah ini
  });

  @override
  State<_TambahLayananSheet> createState() => _TambahLayananSheetState();
}

class _TambahLayananSheetState extends State<_TambahLayananSheet> {
  final _namaController = TextEditingController();
  final _deskripsiController = TextEditingController();
  final _workerService = WorkerService();

  bool _isSaving = false;
  bool _isGenerating = false; // ← state loading Gemini

  final _configService = ConfigService();
  String kGeminiApiKey = "";

  Future<void> _loadConfigServices() async {
    final result = await _configService.getConfigKeys();
    setState(() {
      kGeminiApiKey = result["gemini_api_key"];
    });
  }

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      final e = widget.existing!;
      _namaController.text = e.nama;
      _deskripsiController.text = e.deskripsi ?? "";
    }

    _loadConfigServices();
  }

  @override
  void dispose() {
    _namaController.dispose();
    _deskripsiController.dispose();
    super.dispose();
  }

  bool get _canSave => _namaController.text.trim().isNotEmpty && !_isSaving;

  // ── Generate deskripsi dengan Gemini ──────────────────────────────────
  Future<void> _generateDescription() async {
    final nama = _namaController.text.trim();
    if (nama.isEmpty) {
      showOverlaySnackbar(
        context,
        'validator.service_name_required'.tr(),
        isError: true,
      );
      return;
    }
    print("gemini apikey ${kGeminiApiKey}");

    setState(() => _isGenerating = true);

    try {
      final model = GenerativeModel(
        model: 'gemini-3-flash-preview',
        apiKey: kGeminiApiKey,
      );

      final prompt =
          '''
          Buatkan deskripsi untuk layanan jasa bernama "$nama" dalam bahasa Indonesia.

          Ketentuan:
          - Maksimal 500 karakter
          - 2-3 kalimat
          - Jelaskan jenis pekerjaan yang dilakukan
          - Sertakan estimasi harga dengan kalimat "harga bisa nego"
          - Tone santai dan meyakinkan
          - Langsung ke poin, tanpa pembuka seperti "Berikut deskripsinya:"
          - Jangan pakai tanda kutip atau simbol berlebihan

          Contoh output yang benar:
          Menerima jasa instalasi listrik rumah dan gedung komersial. Pengerjaan rapi, aman, dan bergaransi. Mulai dari Rp 150.000, harga bisa nego.

          Contoh output yang benar:
          Layanan cuci dan setrika baju panggilan ke rumah, minimal 3 kg. Cepat, wangi, dan terlipat rapi. Mulai Rp 7.000/kg, harga bisa nego.
          ''';

      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);
      final text = response.text?.trim() ?? '';

      if (text.isNotEmpty) {
        setState(() => _deskripsiController.text = text);
      }
    } catch (e) {
      if (mounted) {
        showOverlaySnackbar(
          context,
          'Gagal generate deskripsi, coba lagi',
          isError: true,
        );
      }
    } finally {
      setState(() => _isGenerating = false);
    }
  }

  Future<void> _onSimpan() async {
    if (!_canSave) return;

    final payload = {
      'nama': _namaController.text.trim(),
      'deskripsi': _deskripsiController.text.trim(),
      'is_active': true,
    };

    setState(() => _isSaving = true);
    try {
      if (widget.existing != null) {
        await _workerService.updateService(widget.existing!.id, payload);
      } else {
        await _workerService.createService(payload);
      }
      widget.onSuccess?.call();
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
      decoration: BoxDecoration(
        color: context.bgContent,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(20, 0, 20, 20 + bottomInset),
      child: SingleChildScrollView(
        controller: widget.scrollController,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: context.grey,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.existing != null
                      ? 'siap_bantu.edit_services'.tr()
                      : 'siap_bantu.add_services'.tr(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.close, size: 22),
                ),
              ],
            ),
            const SizedBox(height: 20),

            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.65,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nama layanan
                    _FieldLabel('fields.service_name'.tr()),
                    const SizedBox(height: 6),
                    InputField(
                      controller: _namaController,
                      hint: 'field_hints.service_name_example'.tr(),
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 16),

                    // Deskripsi + tombol AI
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            _FieldLabel('fields.service_description'.tr()),
                            const SizedBox(width: 4),
                            Text(
                              '(${'general.optional'.tr()})',
                              style: const TextStyle(
                                fontStyle: FontStyle.italic,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),

                        // ← Tombol Generate AI
                        GestureDetector(
                          onTap: _isGenerating ? null : _generateDescription,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _isGenerating
                                  ? context.grey
                                  : context.secondary,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: _isGenerating
                                    ? context.grey
                                    : context.primary.withOpacity(0.3),
                              ),
                            ),
                            child: _isGenerating
                                ? SizedBox(
                                    width: 14,
                                    height: 14,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: context.primary,
                                    ),
                                  )
                                : Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.auto_awesome,
                                        size: 14,
                                        color: context.primary,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'help_generate'.tr(),
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: context.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    InputField(
                      controller: _deskripsiController,
                      hint: 'field_hints.service_desc_example'.tr(),
                      minLines: 5, // ← minimum 5 baris
                      maxLines: 999, // ← tidak dibatasi, bisa scroll
                      maxLength: 500, // ← batas karakter
                      keyboardType: TextInputType.multiline,
                    ),

                    // Hint generate
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 12,
                          color: context.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'field_hints.service_name_info'.tr(),
                          style: TextStyle(
                            fontSize: 11,
                            color: context.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Simpan button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _canSave ? _onSimpan : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.primary,
                  disabledBackgroundColor: const Color(0xFFD1D5DB),
                  foregroundColor: context.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: _isSaving
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: context.white,
                        ),
                      )
                    : Text(
                        'siap_bantu.save_services'.tr(),
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: context.white,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
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

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.divider),
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
                child: Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Icon(
                    Icons.more_vert,
                    size: 20,
                    color: context.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          if (item.deskripsi != null && item.deskripsi!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              item.deskripsi!,
              style: TextStyle(color: context.textSecondary),
            ),
          ],
        ],
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
