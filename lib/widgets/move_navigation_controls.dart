import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../models/move_history.dart';

/// Widget for navigating through move history
class MoveNavigationControls extends StatelessWidget {
  /// The move history to navigate
  final MoveHistory moveHistory;

  /// Callback when user wants to go back
  final VoidCallback onGoBack;

  /// Callback when user wants to go forward
  final VoidCallback onGoForward;

  /// Callback when user wants to go to start
  final VoidCallback? onGoToStart;

  /// Callback when user wants to go to end
  final VoidCallback? onGoToEnd;

  /// Custom styling for the controls
  final NavigationControlsStyle? style;

  const MoveNavigationControls({
    super.key,
    required this.moveHistory,
    required this.onGoBack,
    required this.onGoForward,
    this.onGoToStart,
    this.onGoToEnd,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveStyle = style ?? NavigationControlsStyle();
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;

    return Container(
      padding: effectiveStyle.padding,
      decoration: effectiveStyle.decoration,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Go to start (only show if callback provided)
          if (onGoToStart != null)
            _buildNavigationButton(
              context: context,
              onPressed: moveHistory.canGoBack ? onGoToStart : null,
              icon: isIOS ? CupertinoIcons.backward_fill : Icons.skip_previous,
              tooltip: 'Go to start',
              isEnabled: moveHistory.canGoBack,
              style: effectiveStyle,
            ),

          // Go back one move
          _buildNavigationButton(
            context: context,
            onPressed: moveHistory.canGoBack ? onGoBack : null,
            icon: isIOS ? CupertinoIcons.chevron_left : Icons.chevron_left,
            tooltip: 'Previous move',
            isEnabled: moveHistory.canGoBack,
            style: effectiveStyle,
          ),

          // Current position indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: effectiveStyle.positionIndicatorColor,
              borderRadius: BorderRadius.circular(isIOS ? 8 : 4),
            ),
            child: Text(
              '${moveHistory.currentIndex < 0 ? 1 : moveHistory.currentIndex + 2}/${moveHistory.length + 1}',
              style: effectiveStyle.positionTextStyle,
            ),
          ),

          // Go forward one move
          _buildNavigationButton(
            context: context,
            onPressed: moveHistory.canGoForward ? onGoForward : null,
            icon: isIOS ? CupertinoIcons.chevron_right : Icons.chevron_right,
            tooltip: 'Next move',
            isEnabled: moveHistory.canGoForward,
            style: effectiveStyle,
          ),

          // Go to end (only show if callback provided)
          if (onGoToEnd != null)
            _buildNavigationButton(
              context: context,
              onPressed: moveHistory.canGoForward ? onGoToEnd : null,
              icon: isIOS ? CupertinoIcons.forward_fill : Icons.skip_next,
              tooltip: 'Go to end',
              isEnabled: moveHistory.canGoForward,
              style: effectiveStyle,
            ),
        ],
      ),
    );
  }

  Widget _buildNavigationButton({
    required BuildContext context,
    required VoidCallback? onPressed,
    required IconData icon,
    required String tooltip,
    required bool isEnabled,
    required NavigationControlsStyle style,
  }) {
    final color = isEnabled ? style.enabledIconColor : style.disabledIconColor;

    return Theme.of(context).platform == TargetPlatform.iOS
        ? CupertinoButton(
            onPressed: onPressed,
            padding: const EdgeInsets.all(8),
            child: Icon(
              icon,
              color: color,
              size: style.iconSize,
            ),
          )
        : IconButton(
            onPressed: onPressed,
            icon: Icon(
              icon,
              color: color,
              size: style.iconSize,
            ),
            tooltip: tooltip,
          );
  }
}

/// Styling options for navigation controls
class NavigationControlsStyle {
  /// Padding around the controls
  final EdgeInsets padding;

  /// Background decoration for the controls container
  final BoxDecoration? decoration;

  /// Size of the navigation icons
  final double iconSize;

  /// Color for enabled icons
  final Color enabledIconColor;

  /// Color for disabled icons
  final Color disabledIconColor;

  /// Background color for position indicator
  final Color positionIndicatorColor;

  /// Text style for position indicator
  final TextStyle positionTextStyle;

  NavigationControlsStyle({
    this.padding = const EdgeInsets.all(8.0),
    this.decoration,
    this.iconSize = 24.0,
    this.enabledIconColor = Colors.black87,
    this.disabledIconColor = Colors.grey,
    this.positionIndicatorColor = const Color(0xFFE0E0E0),
    this.positionTextStyle = const TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
    ),
  });
}
