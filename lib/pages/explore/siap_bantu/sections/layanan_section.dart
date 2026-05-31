import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:piawai/core/app_colors.dart';
import 'package:piawai/core/snackbar_helper.dart';
import 'package:piawai/pages/explore/siap_bantu/models/service_model.dart';
import 'package:piawai/pages/widgets/input_field.dart';
import 'package:piawai/pages/widgets/overlay_snackbar.dart';
import 'package:piawai/services/config_services.dart';
import 'package:piawai/services/worker_services.dart';
import 'package:speech_to_text/speech_to_text.dart';

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
        SnackBarHelper.showErrorSnackBar(
          context,
          'general.fetch_failed'.tr(args: ['$e']),
        );
      }
    }
  }

  Future<void> _deleteService(int id) async {
    try {
      await _workerService.deleteService(id);
      await _refetch();
      if (mounted) {
        SnackBarHelper.showSuccessSnackBar(
          context,
          'service_success_deleted'.tr(),
        );
      }
    } catch (e) {
      if (mounted) {
        SnackBarHelper.showErrorSnackBar(
          context,
          'general.delete_failed'.tr(args: ['$e']),
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
                    SnackBarHelper.showErrorSnackBar(
                      context,
                      'general.failed'.tr(args: [msg]),
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
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      expand: false,
      builder: (_, scrollController) => _TambahLayananSheet(
        existing: existing,
        onSuccess: onSuccess,
        onError: onError,
        scrollController: scrollController,
      ),
    ),
  );
}

// ─────────────────────────────────────────
// SHEET WIDGET
// ─────────────────────────────────────────
class _TambahLayananSheet extends StatefulWidget {
  final ServiceModel? existing;
  final VoidCallback? onSuccess;
  final void Function(String)? onError;
  final ScrollController? scrollController;

  const _TambahLayananSheet({
    this.existing,
    this.onSuccess,
    this.onError,
    this.scrollController,
  });

  @override
  State<_TambahLayananSheet> createState() => _TambahLayananSheetState();
}

enum _SheetMode { voice, form }

enum _RecordState { idle, recording, processing }

class _TambahLayananSheetState extends State<_TambahLayananSheet>
    with SingleTickerProviderStateMixin {
  // Controllers
  final _namaController = TextEditingController();
  final _deskripsiController = TextEditingController();
  final _workerService = WorkerService();
  final _configService = ConfigService();
  final _speechToText = SpeechToText(); // package: speech_to_text

  // State
  _SheetMode _mode = _SheetMode.voice;
  _RecordState _recordState = _RecordState.idle;
  bool _isSaving = false;
  bool _aiFilledForm = false; // badge ✨ AI
  String _spokenWords = '';
  String kGeminiApiKey = '';

  // Animation
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();

    // Kalau edit existing → langsung form mode
    if (widget.existing != null) {
      _mode = _SheetMode.form;
      _namaController.text = widget.existing!.nama;
      _deskripsiController.text = widget.existing!.deskripsi ?? '';
    }

    _loadConfig();
    _initSpeech();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _pulseAnim = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  Future<void> _loadConfig() async {
    final result = await _configService.getConfigKeys();
    setState(() => kGeminiApiKey = result["gemini_api_key"]);
  }

  Future<void> _initSpeech() async {
    await _speechToText.initialize();
  }

  @override
  void dispose() {
    _namaController.dispose();
    _deskripsiController.dispose();
    _pulseController.dispose();
    _speechToText.stop();
    super.dispose();
  }

  bool get _canSave => _namaController.text.trim().isNotEmpty && !_isSaving;

  // ── Toggle record ──────────────────────────────────────────────────────
  Future<void> _toggleRecord() async {
    if (_recordState == _RecordState.recording) {
      await _stopRecord();
    } else {
      await _startRecord();
    }
  }

  Future<void> _startRecord() async {
    final available = await _speechToText.initialize(
      onError: (e) => _handleSpeechError(e.errorMsg),
    );
    if (!available) {
      showOverlaySnackbar(context, 'Mikrofon tidak tersedia', isError: true);
      return;
    }

    setState(() {
      _recordState = _RecordState.recording;
      _spokenWords = '';
    });

    _speechToText.listen(
      onResult: (result) {
        setState(() => _spokenWords = result.recognizedWords);
        // Auto stop saat user berhenti bicara (finalResult)
        if (result.finalResult && _spokenWords.isNotEmpty) {
          _stopRecord();
        }
      },
      localeId: 'id_ID', // Bahasa Indonesia
      listenMode: ListenMode.dictation,
    );
  }

  Future<void> _stopRecord() async {
    await _speechToText.stop();
    if (_spokenWords.trim().isEmpty) {
      setState(() => _recordState = _RecordState.idle);
      if (mounted) {
        showOverlaySnackbar(
          context,
          'siap_bantu.voice_empty'
              .tr(), // "Tidak ada suara terdeteksi, coba lagi"
          isError: true,
        );
      }
      return;
    }
    await _processWithGemini(_spokenWords);
  }

  void _handleSpeechError(String msg) {
    setState(() => _recordState = _RecordState.idle);
    showOverlaySnackbar(context, 'Error: $msg', isError: true);
  }

  // ── 1x Gemini call: extract nama + generate deskripsi ─────────────────
  Future<void> _processWithGemini(String spokenText) async {
    setState(() => _recordState = _RecordState.processing);

    try {
      final model = GenerativeModel(
        model: 'gemini-2.0-flash',
        apiKey: kGeminiApiKey,
      );

      final prompt =
          '''
Dari teks berikut, ekstrak informasi layanan jasa dan kembalikan HANYA JSON tanpa markdown.

Teks: "$spokenText"

Ketentuan deskripsi:
- Maksimal 500 karakter
- 2-3 kalimat
- Jelaskan jenis pekerjaan yang dilakukan
- Sertakan estimasi harga dengan kalimat "harga bisa nego"
- Tone santai dan meyakinkan

Format JSON yang dikembalikan (tanpa backtick, tanpa penjelasan):
{"nama":"...", "deskripsi":"..."}
''';

      final response = await model.generateContent([Content.text(prompt)]);
      final raw = response.text?.trim() ?? '';

      // Bersihkan kalau ada backtick
      final cleaned = raw
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();

      final json = jsonDecode(cleaned) as Map<String, dynamic>;
      final nama = json['nama']?.toString().trim() ?? '';
      final deskripsi = json['deskripsi']?.toString().trim() ?? '';

      if (nama.isEmpty) throw Exception('Nama layanan tidak terdeteksi');

      setState(() {
        _namaController.text = nama;
        _deskripsiController.text = deskripsi;
        _aiFilledForm = true;
        _recordState = _RecordState.idle;
        _mode = _SheetMode.form; // ← auto switch ke form
      });
    } catch (e) {
      setState(() => _recordState = _RecordState.idle);
      if (mounted) {
        showOverlaySnackbar(
          context,
          'Gagal memproses, coba lagi',
          isError: true,
        );
      }
    }
  }

  // ── Simpan ─────────────────────────────────────────────────────────────
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

  // ── BUILD ──────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: BoxDecoration(
        color: context.bgContent,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
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
            const SizedBox(height: 16),

            // Toggle — sembunyikan kalau edit existing
            if (widget.existing == null) _buildToggle(),
            if (widget.existing == null) const SizedBox(height: 20),

            // Content
            Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _mode == _SheetMode.voice
                    ? _buildVoiceMode()
                    : _buildFormMode(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Toggle ─────────────────────────────────────────────────────────────
  Widget _buildToggle() {
    return Container(
      decoration: BoxDecoration(
        color: context.grey.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          _ToggleBtn(
            label: '🎤  ${'general.voice'.tr()}',
            isActive: _mode == _SheetMode.voice,
            onTap: () => setState(() => _mode = _SheetMode.voice),
          ),
          _ToggleBtn(
            label: '📝  ${'general.form'.tr()}',
            isActive: _mode == _SheetMode.form,
            onTap: () => setState(() => _mode = _SheetMode.form),
          ),
        ],
      ),
    );
  }

  // ── Voice Mode ─────────────────────────────────────────────────────────
  Widget _buildVoiceMode() {
    return SizedBox(
      key: const ValueKey('voice'),
      child: Column(
        children: [
          Text(
            'siap_bantu.voice_hint'
                .tr(), // "Ceritakan layanan yang ingin kamu tambahkan"
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: context.textSecondary),
          ),
          const SizedBox(height: 32),

          // Mic button + ripple
          SizedBox(
            width: 120,
            height: 120,
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (_recordState == _RecordState.recording)
                  ...[1.0, 1.4, 1.8].map(
                    (scale) => AnimatedBuilder(
                      animation: _pulseAnim,
                      builder: (_, __) => Transform.scale(
                        scale: scale * (_pulseAnim.value * 0.15 + 0.85),
                        child: Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.red.withOpacity(0.08),
                          ),
                        ),
                      ),
                    ),
                  ),

                GestureDetector(
                  onTap: _recordState == _RecordState.processing
                      ? null
                      : _toggleRecord,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _recordState == _RecordState.recording
                          ? Colors.red
                          : context.primary,
                      boxShadow: [
                        BoxShadow(
                          color:
                              (_recordState == _RecordState.recording
                                      ? Colors.red
                                      : context.primary)
                                  .withOpacity(0.35),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: _recordState == _RecordState.processing
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : Icon(
                            _recordState == _RecordState.recording
                                ? Icons.stop_rounded
                                : Icons.mic_rounded,
                            color: Colors.white,
                            size: 30,
                          ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Status text
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Text(
              key: ValueKey(_recordState),
              _recordState == _RecordState.idle
                  ? 'siap_bantu.tap_to_record'.tr()
                  : _recordState == _RecordState.recording
                  ? 'siap_bantu.recording'.tr()
                  : 'siap_bantu.processing'.tr(),
              style: TextStyle(
                fontSize: 13,
                fontWeight: _recordState != _RecordState.idle
                    ? FontWeight.w600
                    : FontWeight.normal,
                color: _recordState == _RecordState.recording
                    ? Colors.red
                    : _recordState == _RecordState.processing
                    ? context.primary
                    : context.textSecondary,
              ),
            ),
          ),

          // Live transcript preview
          if (_spokenWords.isNotEmpty && _recordState == _RecordState.recording)
            Container(
              margin: const EdgeInsets.only(top: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: context.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                _spokenWords,
                style: TextStyle(fontSize: 13, color: context.textSecondary),
                textAlign: TextAlign.center,
              ),
            ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ── Form Mode ──────────────────────────────────────────────────────────
  Widget _buildFormMode() {
    return SizedBox(
      key: const ValueKey('form'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nama
          Row(
            children: [
              _FieldLabel('fields.service_name'.tr()),
              if (_aiFilledForm) ...[const SizedBox(width: 6), _AiBadge()],
            ],
          ),
          const SizedBox(height: 6),
          InputField(
            controller: _namaController,
            hint: 'field_hints.service_name_example'.tr(),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 16),

          // Deskripsi
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
              if (_aiFilledForm) ...[const SizedBox(width: 6), _AiBadge()],
            ],
          ),
          const SizedBox(height: 6),
          InputField(
            controller: _deskripsiController,
            hint: 'field_hints.service_desc_example'.tr(),
            minLines: 5,
            maxLines: 999,
            maxLength: 500,
            keyboardType: TextInputType.multiline,
          ),

          const SizedBox(height: 20),

          // Simpan
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
    );
  }
}

// ─────────────────────────────────────────
// SMALL WIDGETS
// ─────────────────────────────────────────
class _ToggleBtn extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _ToggleBtn({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? context.bgContent : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ]
                : [],
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isActive ? context.primary : context.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

class _AiBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: context.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.auto_awesome, size: 10, color: context.primary),
          const SizedBox(width: 3),
          Text(
            'AI',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: context.primary,
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
