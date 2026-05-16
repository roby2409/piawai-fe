import 'dart:async';
import 'package:flutter/material.dart';
import 'package:piawai/core/constants.dart';
import 'package:piawai/services/explore_services.dart';

class SearchPage extends StatefulWidget {
  final ValueChanged<String> onSearch;
  final String initialQuery;

  const SearchPage({super.key, required this.onSearch, this.initialQuery = ''});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late final TextEditingController _ctrl;
  late final FocusNode _focusNode;
  final _exploreService = ExploreService();

  Timer? _debounce;

  String _query = '';
  List<String> _suggestions = [];
  bool _isLoadingSuggestions = false;

  final List<String> _recents = ['Sedot WC', 'Servis AC', 'Cleaning Service'];

  bool get _showSuggestions => _suggestions.isNotEmpty;
  bool get _showRecents =>
      !_showSuggestions && _recents.isNotEmpty && _query.isEmpty;

  @override
  void initState() {
    super.initState();
    _query = widget.initialQuery;
    _ctrl = TextEditingController(text: widget.initialQuery);
    _focusNode = FocusNode();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _focusNode.requestFocus(),
    );
    // Load popular suggestions saat pertama buka
    _fetchSuggestions('');
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _ctrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onQueryChanged(String val) {
    setState(() => _query = val);
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      _fetchSuggestions(val);
    });
  }

  Future<void> _fetchSuggestions(String q) async {
    setState(() => _isLoadingSuggestions = true);
    try {
      final results = await _exploreService.fetchSuggestions(q: q);
      if (mounted) setState(() => _suggestions = results);
    } catch (_) {
      if (mounted) setState(() => _suggestions = []);
    } finally {
      if (mounted) setState(() => _isLoadingSuggestions = false);
    }
  }

  void _submit(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return;
    _addRecent(trimmed);
    widget.onSearch(trimmed);
    Navigator.of(context).pop();
  }

  void _addRecent(String value) {
    setState(() {
      _recents.remove(value);
      _recents.insert(0, value);
      if (_recents.length > 8) _recents.removeLast();
    });
  }

  void _fillQuery(String value) {
    setState(() {
      _query = value;
      _ctrl.text = value;
      _ctrl.selection = TextSelection.fromPosition(
        TextPosition(offset: value.length),
      );
    });
    _fetchSuggestions(value);
  }

  void _removeRecent(String value) => setState(() => _recents.remove(value));
  void _clearAllRecents() => setState(() => _recents.clear());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Search bar ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black87),
                    onPressed: () => Navigator.of(context).pop(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 36,
                      minHeight: 36,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Container(
                      height: 46,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2F4F7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        controller: _ctrl,
                        focusNode: _focusNode,
                        textInputAction: TextInputAction.search,
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Cari pekerja...',
                          hintStyle: TextStyle(
                            color: Colors.black38,
                            fontSize: 15,
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            color: Colors.black45,
                            size: 20,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 13),
                        ),
                        onChanged: _onQueryChanged,
                        onSubmitted: _submit,
                      ),
                    ),
                  ),
                  if (_query.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _query = '';
                          _suggestions = [];
                        });
                        _ctrl.clear();
                        _focusNode.requestFocus();
                        _fetchSuggestions('');
                      },
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: const BoxDecoration(
                          color: Color(0xFFE5E7EB),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          size: 16,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Loading bar tipis
            if (_isLoadingSuggestions)
              const LinearProgressIndicator(
                minHeight: 2,
                backgroundColor: Colors.transparent,
                color: kPrimary,
              )
            else
              const Divider(height: 1, color: Color(0xFFF0F0F0)),

            // ── Content ──
            Expanded(
              child: ListView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                children: [
                  // Suggestions dari API
                  if (_showSuggestions) ...[
                    const SizedBox(height: 8),
                    ..._suggestions.map(
                      (s) => _SuggestionTile(
                        query: _query,
                        suggestion: s,
                        onTap: () => _submit(s),
                        onFill: () => _fillQuery(s),
                      ),
                    ),
                  ],

                  // Recent searches
                  if (_showRecents) ...[
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Pencarian Terakhir',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),
                          GestureDetector(
                            onTap: _clearAllRecents,
                            child: const Text(
                              'Hapus Semua',
                              style: TextStyle(
                                fontSize: 13,
                                color: kPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _recents
                            .map(
                              (r) => _RecentChip(
                                label: r,
                                onTap: () => _submit(r),
                                onRemove: () => _removeRecent(r),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ],

                  // Empty state
                  if (!_showSuggestions &&
                      !_showRecents &&
                      _query.isNotEmpty &&
                      !_isLoadingSuggestions)
                    _EmptyState(query: _query),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SuggestionTile extends StatelessWidget {
  final String query;
  final String suggestion;
  final VoidCallback onTap;
  final VoidCallback onFill;

  const _SuggestionTile({
    required this.query,
    required this.suggestion,
    required this.onTap,
    required this.onFill,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(
          children: [
            const Icon(Icons.search, color: Colors.black38, size: 20),
            const SizedBox(width: 14),
            Expanded(
              child: _HighlightedText(full: suggestion, query: query),
            ),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onFill,
              child: Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Icon(
                  Icons.north_west,
                  size: 18,
                  color: Colors.grey[400],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HighlightedText extends StatelessWidget {
  final String full;
  final String query;

  const _HighlightedText({required this.full, required this.query});

  @override
  Widget build(BuildContext context) {
    if (query.isEmpty)
      return Text(
        full,
        style: const TextStyle(fontSize: 15, color: Colors.black87),
      );

    final lowerFull = full.toLowerCase();
    final lowerQuery = query.toLowerCase();
    final matchStart = lowerFull.indexOf(lowerQuery);

    if (matchStart == -1)
      return Text(
        full,
        style: const TextStyle(fontSize: 15, color: Colors.black87),
      );

    final matchEnd = matchStart + query.length;

    return RichText(
      text: TextSpan(
        style: const TextStyle(fontSize: 15, color: Colors.black87),
        children: [
          if (matchStart > 0)
            TextSpan(
              text: full.substring(0, matchStart),
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          TextSpan(
            text: full.substring(matchStart, matchEnd),
            style: const TextStyle(
              color: Colors.black38,
              fontWeight: FontWeight.w400,
            ),
          ),
          if (matchEnd < full.length)
            TextSpan(
              text: full.substring(matchEnd),
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
        ],
      ),
    );
  }
}

class _RecentChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _RecentChip({
    required this.label,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.only(left: 12, right: 6, top: 7, bottom: 7),
        decoration: BoxDecoration(
          color: const Color(0xFFF2F4F7),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 6),
            GestureDetector(
              onTap: onRemove,
              child: const Icon(Icons.close, size: 14, color: Colors.black45),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String query;
  const _EmptyState({required this.query});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 32),
      child: Column(
        children: [
          Icon(Icons.search_off_rounded, size: 52, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'Tidak ada hasil untuk\n"$query"',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              color: Colors.black45,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
