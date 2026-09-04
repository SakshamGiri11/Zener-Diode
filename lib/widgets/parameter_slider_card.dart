import 'package:flutter/material.dart';

class ParameterSliderCard extends StatefulWidget {
  final String label;
  final String symbol;
  final String unit;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final double step;
  final Color accentColor;
  final ValueChanged<double> onChanged;
  final List<double>? quickValues;
  final bool enabled;
  final String? disabledMessage;

  const ParameterSliderCard({
    super.key,
    required this.label,
    required this.symbol,
    required this.unit,
    required this.value,
    required this.min,
    required this.max,
    this.divisions = 200,
    this.step = 0.5,
    this.accentColor = const Color(0xFF38BDF8),
    required this.onChanged,
    this.quickValues,
    this.enabled = true,
    this.disabledMessage,
  });

  @override
  State<ParameterSliderCard> createState() => _ParameterSliderCardState();
}

class _ParameterSliderCardState extends State<ParameterSliderCard> {
  late TextEditingController _textController;
  bool _isEditingText = false;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: _formatValue(widget.value));
  }

  @override
  void didUpdateWidget(covariant ParameterSliderCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value && !_isEditingText) {
      _textController.text = _formatValue(widget.value);
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  String _formatValue(double v) {
    if (v >= 1000) {
      return (v % 1 == 0) ? v.toInt().toString() : v.toStringAsFixed(1);
    } else if (v >= 10) {
      return (v % 1 == 0) ? v.toInt().toString() : v.toStringAsFixed(1);
    } else {
      return v.toStringAsFixed(2);
    }
  }

  void _submitText(String val) {
    final parsed = double.tryParse(val);
    if (parsed != null) {
      final clamped = parsed.clamp(widget.min, widget.max);
      widget.onChanged(clamped);
      _textController.text = _formatValue(clamped);
    } else {
      _textController.text = _formatValue(widget.value);
    }
    setState(() => _isEditingText = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF131D2F) : Colors.white;
    final borderColor = isDark ? const Color(0xFF22324D) : const Color(0xFFE2E8F0);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: widget.enabled ? cardBg : cardBg.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: widget.enabled ? borderColor : borderColor.withOpacity(0.5),
          width: 1.2,
        ),
        boxShadow: widget.enabled
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.2 : 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Symbol, Label & Numeric Value Box
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: widget.accentColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: widget.accentColor.withOpacity(0.35),
                    width: 1,
                  ),
                ),
                child: Text(
                  widget.symbol,
                  style: TextStyle(
                    color: widget.accentColor,
                    fontWeight: FontWeight.w800,
                    fontSize: 12.5,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  widget.label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13.5,
                    color: widget.enabled
                        ? (isDark ? const Color(0xFFF1F5F9) : const Color(0xFF1E293B))
                        : Colors.grey,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              if (widget.enabled) ...[
                // Value Display / Editable Box
                Container(
                  width: 82,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF090E1A)
                        : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: _isEditingText
                          ? widget.accentColor
                          : borderColor,
                      width: 1.2,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: TextField(
                    controller: _textController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                      fontFamily: 'monospace',
                      color: widget.accentColor,
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(horizontal: 4),
                    ),
                    onTap: () => setState(() => _isEditingText = true),
                    onSubmitted: _submitText,
                    onEditingComplete: () {
                      _submitText(_textController.text);
                      FocusScope.of(context).unfocus();
                    },
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  widget.unit,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  ),
                ),
              ] else ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.orange.withOpacity(0.4)),
                  ),
                  child: Text(
                    widget.disabledMessage ?? 'Disconnected',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                ),
              ],
            ],
          ),

          if (widget.enabled) ...[
            const SizedBox(height: 10),
            // Slider Row with - / + buttons
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  tooltip: 'Decrease by ${widget.step}',
                  onPressed: () {
                    final newVal =
                        (widget.value - widget.step).clamp(widget.min, widget.max);
                    widget.onChanged(newVal);
                  },
                ),
                Expanded(
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: widget.accentColor,
                      inactiveTrackColor: widget.accentColor.withOpacity(0.18),
                      thumbColor: widget.accentColor,
                      overlayColor: widget.accentColor.withOpacity(0.14),
                      trackHeight: 4.0,
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 7.0,
                      ),
                    ),
                    child: Slider(
                      value: widget.value.clamp(widget.min, widget.max),
                      min: widget.min,
                      max: widget.max,
                      divisions: widget.divisions,
                      onChanged: widget.onChanged,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  tooltip: 'Increase by ${widget.step}',
                  onPressed: () {
                    final newVal =
                        (widget.value + widget.step).clamp(widget.min, widget.max);
                    widget.onChanged(newVal);
                  },
                ),
              ],
            ),

            // Quick Preset Values
            if (widget.quickValues != null && widget.quickValues!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 5,
                children: widget.quickValues!.map((qv) {
                  final isSelected = (widget.value - qv).abs() < 0.01;
                  return InkWell(
                    borderRadius: BorderRadius.circular(5),
                    onTap: () => widget.onChanged(qv),
                    child: Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? widget.accentColor.withOpacity(0.2)
                            : (isDark
                                ? const Color(0xFF090E1A)
                                : const Color(0xFFF1F5F9)),
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(
                          color: isSelected
                              ? widget.accentColor
                              : borderColor,
                          width: 1.0,
                        ),
                      ),
                      child: Text(
                        qv >= 1000 ? '${(qv / 1000).toStringAsFixed(1)}k' : '${qv.toInt()}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight:
                              isSelected ? FontWeight.w800 : FontWeight.w500,
                          color: isSelected
                              ? widget.accentColor
                              : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ],
      ),
    );
  }
}
