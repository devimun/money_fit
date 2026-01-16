/// HSVColorPicker - HSV-based color selection widget
/// Provides hue, saturation, and value sliders for precise color selection
library;

import 'package:flutter/material.dart';
import 'package:money_fit/core/theme/theme_extensions.dart';
import 'package:money_fit/core/widgets/responsive_text/responsive_text.dart';

/// Widget that provides HSV (Hue, Saturation, Value) color selection
/// 
/// Features:
/// - Hue slider (0-360 degrees)
/// - Saturation slider (0-100%)
/// - Value/Brightness slider (0-100%)
/// - Real-time color preview
/// - Live callback on color changes
class HSVColorPicker extends StatefulWidget {
  const HSVColorPicker({
    required this.initialColor,
    required this.onColorChanged,
    super.key,
  });

  /// Initial color to display
  final Color initialColor;

  /// Callback when color changes
  final ValueChanged<Color> onColorChanged;

  @override
  State<HSVColorPicker> createState() => _HSVColorPickerState();
}

class _HSVColorPickerState extends State<HSVColorPicker> {
  late HSVColor _hsvColor;

  @override
  void initState() {
    super.initState();
    _hsvColor = HSVColor.fromColor(widget.initialColor);
  }

  @override
  void didUpdateWidget(HSVColorPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialColor != oldWidget.initialColor) {
      _hsvColor = HSVColor.fromColor(widget.initialColor);
    }
  }

  void _updateColor(HSVColor newColor) {
    setState(() {
      _hsvColor = newColor;
    });
    widget.onColorChanged(_hsvColor.toColor());
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Color Preview
        _ColorPreview(color: _hsvColor.toColor()),
        
        const SizedBox(height: 24),
        
        // Hue Slider
        _SliderSection(
          label: 'Hue',
          value: _hsvColor.hue,
          min: 0,
          max: 360,
          divisions: 360,
          onChanged: (value) {
            _updateColor(_hsvColor.withHue(value));
          },
          gradientColors: _buildHueGradient(),
        ),
        
        const SizedBox(height: 16),
        
        // Saturation Slider
        _SliderSection(
          label: 'Saturation',
          value: _hsvColor.saturation * 100,
          min: 0,
          max: 100,
          divisions: 100,
          onChanged: (value) {
            _updateColor(_hsvColor.withSaturation(value / 100));
          },
          gradientColors: [
            HSVColor.fromAHSV(1, _hsvColor.hue, 0, _hsvColor.value).toColor(),
            HSVColor.fromAHSV(1, _hsvColor.hue, 1, _hsvColor.value).toColor(),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Value/Brightness Slider
        _SliderSection(
          label: 'Brightness',
          value: _hsvColor.value * 100,
          min: 0,
          max: 100,
          divisions: 100,
          onChanged: (value) {
            _updateColor(_hsvColor.withValue(value / 100));
          },
          gradientColors: [
            HSVColor.fromAHSV(1, _hsvColor.hue, _hsvColor.saturation, 0)
                .toColor(),
            HSVColor.fromAHSV(1, _hsvColor.hue, _hsvColor.saturation, 1)
                .toColor(),
          ],
        ),
      ],
    );
  }

  /// Builds gradient colors for hue slider (full spectrum)
  List<Color> _buildHueGradient() {
    return List.generate(
      7,
      (index) => HSVColor.fromAHSV(1, index * 60.0, 1, 1).toColor(),
    );
  }
}

/// Color preview widget showing current selected color
class _ColorPreview extends StatelessWidget {
  const _ColorPreview({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: context.colors.border.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
    );
  }
}

/// Slider section with label and gradient background
class _SliderSection extends StatelessWidget {
  const _SliderSection({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.onChanged,
    required this.gradientColors,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final ValueChanged<double> onChanged;
  final List<Color> gradientColors;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label with value
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ResponsiveLabelText(
              text: label,
              style: context.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '${value.round()}${label == 'Hue' ? '°' : '%'}',
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colors.textPrimary.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 8),
        
        // Slider with gradient background
        Stack(
          alignment: Alignment.center,
          children: [
            // Gradient background
            Container(
              height: 32,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: gradientColors),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: context.colors.border.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
            ),
            
            // Slider
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 32,
                thumbShape: const RoundSliderThumbShape(
                  enabledThumbRadius: 12,
                  elevation: 4,
                ),
                overlayShape: const RoundSliderOverlayShape(
                  overlayRadius: 20,
                ),
                activeTrackColor: Colors.transparent,
                inactiveTrackColor: Colors.transparent,
                thumbColor: Colors.white,
                overlayColor: context.colors.brandPrimary.withValues(alpha: 0.2),
              ),
              child: Slider(
                value: value,
                min: min,
                max: max,
                divisions: divisions,
                onChanged: onChanged,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
