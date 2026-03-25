import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

import '../../../../core/theme/color_palette.dart';

/// Small circle used in create/edit rows when [colorHex] is a hex or [AppColors.collectionCoverNoColor].
class CollectionCoverSwatch extends StatelessWidget {
  const CollectionCoverSwatch({super.key, required this.colorHex});

  final String colorHex;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (AppColors.isCollectionCoverNoColor(colorHex)) {
      return SizedBox(
        width: 26,
        height: 26,
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.4),
            ),
          ),
          child: ClipOval(
            child: CustomPaint(
              painter: _MiniCheckerPainter(theme: theme),
            ),
          ),
        ),
      );
    }
    final c = AppColors.resolveCollectionCoverColor(colorHex, theme);
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: c,
        shape: BoxShape.circle,
      ),
    );
  }
}

class _MiniCheckerPainter extends CustomPainter {
  _MiniCheckerPainter({required this.theme});

  final ThemeData theme;

  @override
  void paint(Canvas canvas, Size size) {
    final light = theme.colorScheme.surfaceContainerHighest;
    final dark = theme.colorScheme.outline.withValues(alpha: 0.2);
    const n = 3;
    final w = size.width / n;
    final h = size.height / n;
    for (var row = 0; row < n; row++) {
      for (var col = 0; col < n; col++) {
        final paint = Paint()
          ..color = (row + col).isEven ? light : dark;
        canvas.drawRect(Rect.fromLTWH(col * w, row * h, w, h), paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _MiniCheckerPainter oldDelegate) =>
      oldDelegate.theme != theme;
}

void _openCustomColorDialog({
  required BuildContext rootContext,
  required BuildContext sheetContext,
  required ThemeData theme,
  required String selectedColor,
  required void Function(String colorHex) onSelect,
}) {
  var current = AppColors.tryParseCollectionColorHex(selectedColor) ??
      theme.colorScheme.primary;

  showDialog<void>(
    context: rootContext,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Custom colour'),
            content: SingleChildScrollView(
              child: ColorPicker(
                pickerColor: current,
                onColorChanged: (c) => setDialogState(() => current = c),
                enableAlpha: false,
                labelTypes: const [],
                paletteType: PaletteType.hsvWithHue,
                colorPickerWidth: 280,
                pickerAreaHeightPercent: 0.75,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () {
                  onSelect(AppColors.colorToHexRgb(current));
                  Navigator.pop(dialogContext);
                  Navigator.pop(sheetContext);
                },
                child: const Text('Apply'),
              ),
            ],
          );
        },
      );
    },
  );
}

class _CustomColorPlaceholder extends StatelessWidget {
  const _CustomColorPlaceholder({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: theme.colorScheme.surfaceContainerHighest,
      child: Center(
        child: Icon(
          Icons.palette_outlined,
          size: 28,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }
}

/// Cover colour picker: "No colour" sentinel plus [AppColors.collectionColorHexes].
class CollectionColorSheet {
  CollectionColorSheet._();

  static void showPicker({
    required BuildContext context,
    required String selectedColor,
    required void Function(String colorHex) onSelect,
  }) {
    final theme = Theme.of(context);
    final bgColor = theme.scaffoldBackgroundColor;
    final textColor = theme.colorScheme.onSurface;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: bgColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return DraggableScrollableSheet(
          initialChildSize: 0.55,
          minChildSize: 0.35,
          maxChildSize: 0.85,
          expand: false,
          builder: (_, scrollController) {
            return Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(sheetContext),
                        child: Icon(Icons.arrow_back,
                            color: theme.colorScheme.primary),
                      ),
                      Text(
                        'Choose colour',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(width: 24),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      const spacing = 10.0;
                      const minCell = 52.0;
                      final width = constraints.maxWidth - 32;
                      final count = (width / (minCell + spacing)).floor().clamp(3, 8);
                      final tile =
                          (width - (count - 1) * spacing) / count;

                      return GridView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: count,
                          mainAxisSpacing: spacing,
                          crossAxisSpacing: spacing,
                          childAspectRatio: 1,
                        ),
                        itemCount:
                            2 + AppColors.collectionColorHexes.length,
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            final isSelected = AppColors.isCollectionCoverNoColor(
                                selectedColor);
                            return _ColorCell(
                              size: tile,
                              isSelected: isSelected,
                              selectedBorderColor: textColor,
                              onTap: () {
                                onSelect(AppColors.collectionCoverNoColor);
                                Navigator.pop(sheetContext);
                              },
                              child: _NoCoverSwatch(theme: theme),
                            );
                          }
                          if (index == 1) {
                            final isCustom = AppColors.isUserCustomCoverHex(
                                selectedColor);
                            final customParsed = isCustom
                                ? AppColors.tryParseCollectionColorHex(
                                    selectedColor)
                                : null;
                            return _ColorCell(
                              size: tile,
                              isSelected: isCustom,
                              selectedBorderColor: textColor,
                              onTap: () => _openCustomColorDialog(
                                rootContext: context,
                                sheetContext: sheetContext,
                                theme: theme,
                                selectedColor: selectedColor,
                                onSelect: onSelect,
                              ),
                              child: customParsed != null
                                  ? Container(
                                      decoration: BoxDecoration(
                                        color: customParsed,
                                        borderRadius:
                                            BorderRadius.circular(18),
                                      ),
                                    )
                                  : _CustomColorPlaceholder(theme: theme),
                            );
                          }
                          final colorHex = AppColors
                              .collectionColorHexes[index - 2];
                          Color color;
                          try {
                            color = Color(int.parse(
                                colorHex.replaceFirst('#', '0xFF')));
                          } catch (_) {
                            color = const Color(0xFFB3E0FF);
                          }
                          final normalized = selectedColor
                              .trim()
                              .toUpperCase();
                          final isSelected =
                              colorHex.toUpperCase() == normalized;
                          return _ColorCell(
                            size: tile,
                            isSelected: isSelected,
                            selectedBorderColor: textColor,
                            onTap: () {
                              onSelect(colorHex);
                              Navigator.pop(sheetContext);
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: color,
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _ColorCell extends StatelessWidget {
  const _ColorCell({
    required this.size,
    required this.isSelected,
    required this.selectedBorderColor,
    required this.onTap,
    required this.child,
  });

  final double size;
  final bool isSelected;
  final Color selectedBorderColor;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: SizedBox(
          width: size,
          height: size,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: isSelected
                  ? Border.all(color: selectedBorderColor, width: 2.5)
                  : Border.all(
                      color: Theme.of(context)
                          .colorScheme
                          .outline
                          .withValues(alpha: 0.25),
                    ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

class _NoCoverSwatch extends StatelessWidget {
  const _NoCoverSwatch({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final a = theme.colorScheme.surfaceContainerHighest;
    final b = theme.colorScheme.outline.withValues(alpha: 0.2);
    return CustomPaint(
      painter: _CheckerPainter(light: a, dark: b),
      child: Center(
        child: Icon(
          Icons.format_color_reset_outlined,
          size: 22,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _CheckerPainter extends CustomPainter {
  _CheckerPainter({required this.light, required this.dark});

  final Color light;
  final Color dark;

  @override
  void paint(Canvas canvas, Size size) {
    const squares = 4;
    final w = size.width / squares;
    final h = size.height / squares;
    for (var row = 0; row < squares; row++) {
      for (var col = 0; col < squares; col++) {
        final paint = Paint()
          ..color = (row + col).isEven ? light : dark;
        canvas.drawRect(
          Rect.fromLTWH(col * w, row * h, w, h),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _CheckerPainter oldDelegate) =>
      oldDelegate.light != light || oldDelegate.dark != dark;
}
