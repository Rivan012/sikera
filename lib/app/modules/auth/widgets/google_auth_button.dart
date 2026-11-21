import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class AuthDivider extends StatelessWidget {
  final String label;

  const AuthDivider({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lineColor = isDark ? AppTheme.borderDark : AppTheme.borderLight;
    final textColor = isDark
        ? AppTheme.textSecondaryDark
        : AppTheme.textSecondaryLight;

    return Row(
      children: [
        Expanded(child: Divider(color: lineColor, thickness: 1, height: 1)),
        Flexible(
          flex: 3,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: textColor,
                height: 1.35,
              ),
            ),
          ),
        ),
        Expanded(child: Divider(color: lineColor, thickness: 1, height: 1)),
      ],
    );
  }
}

class GoogleAuthButton extends StatelessWidget {
  final String label;
  final String loadingLabel;
  final bool isLoading;
  final bool disabled;
  final bool compact;
  final VoidCallback onPressed;

  const GoogleAuthButton({
    super.key,
    required this.label,
    this.loadingLabel = 'Menghubungkan Google...',
    required this.isLoading,
    required this.disabled,
    required this.compact,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = Theme.of(context).colorScheme;
    final bgColor = isDark ? AppTheme.elevatedSurfaceDark : AppTheme.surfaceLight;
    final fgColor = isDark ? AppTheme.textPrimaryDark : AppTheme.primary900;
    final borderColor = isDark
        ? AppTheme.textMutedDark
        : AppTheme.textMutedLight;
    final overlayColor = isDark
        ? AppTheme.softAccentSurfaceDark
        : AppTheme.pocketSurfaceLight;

    return OutlinedButton(
      onPressed: (isLoading || disabled) ? null : onPressed,
      style: OutlinedButton.styleFrom(
        backgroundColor: bgColor,
        foregroundColor: fgColor,
        disabledBackgroundColor: colors.surfaceContainerHigh,
        disabledForegroundColor: colors.onSurface,
        minimumSize: const Size(double.infinity, 50),
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 12 : 20,
          vertical: 14,
        ),
        side: BorderSide(
          color: (isLoading || disabled) ? colors.outlineVariant : borderColor,
          width: 1.2,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        ),
        overlayColor: overlayColor,
        textStyle: const TextStyle(
          fontSize: 15,
          fontFamily: 'Roboto',
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
        ),
      ),
      child: isLoading
          ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    semanticsLabel: 'Sedang masuk dengan Google...',
                    color: colors.onSurface,
                  ),
                ),
                SizedBox(width: compact ? 10 : 12),
                Flexible(
                  child: ExcludeSemantics(
                    child: Text(
                      loadingLabel,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const ExcludeSemantics(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CustomPaint(painter: _GoogleLogoPainter()),
                  ),
                ),
                SizedBox(width: compact ? 10 : 12),
                Flexible(
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  const _GoogleLogoPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = size.width * 0.21;
    final rect = Rect.fromLTWH(
      strokeWidth / 2,
      strokeWidth / 2,
      size.width - strokeWidth,
      size.height - strokeWidth,
    );

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    // Red top-left arc
    paint.color = const Color(0xFFEA4335);
    canvas.drawArc(rect, -math.pi * 0.78, math.pi * 0.54, false, paint);

    // Yellow left-bottom arc
    paint.color = const Color(0xFFFBBC05);
    canvas.drawArc(rect, math.pi * 0.78, math.pi * 0.44, false, paint);

    // Green bottom arc
    paint.color = const Color(0xFF34A853);
    canvas.drawArc(rect, math.pi * 0.18, math.pi * 0.62, false, paint);

    // Blue right arc
    paint.color = const Color(0xFF4285F4);
    canvas.drawArc(rect, -math.pi * 0.02, math.pi * 0.24, false, paint);

    // Blue horizontal crossbar
    final barPaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.fill;
    final barHeight = strokeWidth * 0.92;
    canvas.drawRect(
      Rect.fromLTWH(
        size.width * 0.5,
        (size.height - barHeight) / 2,
        size.width * 0.48,
        barHeight,
      ),
      barPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
