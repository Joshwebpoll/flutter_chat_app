import 'package:flutter/material.dart';

// Toast types enum for different styles
enum ToastTypes { success, error, warning, info }

// Main Toast utility class
class AppToast {
  static OverlayEntry? _overlayEntry;
  static bool _isVisible = false;

  // Show toast with different types
  static void show(
    BuildContext context,
    String message, {
    ToastTypes type = ToastTypes.info,
    Duration duration = const Duration(seconds: 3),
    ToastPosition position = ToastPosition.bottom,
  }) {
    if (_isVisible) {
      hide(); // Hide existing toast before showing new one
    }

    final overlay = Overlay.of(context);
    _overlayEntry = OverlayEntry(
      builder:
          (context) => ToastWidget(
            message: message,
            type: type,
            position: position,
            onDismiss: hide,
          ),
    );

    overlay.insert(_overlayEntry!);
    _isVisible = true;

    // Auto-hide after duration
    Future.delayed(duration, () {
      hide();
    });
  }

  // Convenience methods for different toast types
  static void success(BuildContext context, String message) {
    show(context, message, type: ToastTypes.success);
  }

  static void error(BuildContext context, String message) {
    show(context, message, type: ToastTypes.error);
  }

  static void warning(BuildContext context, String message) {
    show(context, message, type: ToastTypes.warning);
  }

  static void info(BuildContext context, String message) {
    show(context, message, type: ToastTypes.info);
  }

  // Hide current toast
  static void hide() {
    if (_overlayEntry != null && _isVisible) {
      _overlayEntry!.remove();
      _overlayEntry = null;
      _isVisible = false;
    }
  }
}

// Toast position enum
enum ToastPosition { top, center, bottom }

// Toast widget that displays the actual toast
class ToastWidget extends StatefulWidget {
  final String message;
  final ToastTypes type;
  final ToastPosition position;
  final VoidCallback onDismiss;

  const ToastWidget({
    Key? key,
    required this.message,
    required this.type,
    required this.position,
    required this.onDismiss,
  }) : super(key: key);

  @override
  State<ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<ToastWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _slideAnimation = Tween<Offset>(
      begin: _getInitialOffset(),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _controller.forward();
  }

  Offset _getInitialOffset() {
    switch (widget.position) {
      case ToastPosition.top:
        return const Offset(0, -1);
      case ToastPosition.center:
        return const Offset(0, 0);
      case ToastPosition.bottom:
        return const Offset(0, 1);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: widget.position == ToastPosition.top ? 50 : null,
      bottom: widget.position == ToastPosition.bottom ? 50 : null,
      left: 0,
      right: 0,
      child: Center(child: _buildToast()),
    );
  }

  Widget _buildToast() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Material(
              color: Colors.transparent,
              child: GestureDetector(
                onTap: () {
                  _controller.reverse().then((_) {
                    widget.onDismiss();
                  });
                },
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width - 32,
                    minWidth: 100,
                  ),
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: _getBackgroundColor(),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IntrinsicWidth(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(_getIcon(), color: _getIconColor(), size: 20),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            widget.message,
                            style: TextStyle(
                              color: _getTextColor(),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getBackgroundColor() {
    switch (widget.type) {
      case ToastTypes.success:
        return const Color(0xFF4CAF50);
      case ToastTypes.error:
        return const Color(0xFFE53E3E);
      case ToastTypes.warning:
        return const Color(0xFFFF9800);
      case ToastTypes.info:
        return const Color(0xFF2196F3);
    }
  }

  Color _getIconColor() {
    return Colors.white;
  }

  Color _getTextColor() {
    return Colors.white;
  }

  IconData _getIcon() {
    switch (widget.type) {
      case ToastTypes.success:
        return Icons.check_circle;
      case ToastTypes.error:
        return Icons.error;
      case ToastTypes.warning:
        return Icons.warning;
      case ToastTypes.info:
        return Icons.info;
    }
  }
}

// Example usage in your app
class ToastExamplePage extends StatelessWidget {
  const ToastExamplePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Toast Examples')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                AppToast.success(context, 'Operation completed successfully!');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: const Text('Show Success Toast'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                AppToast.error(context, 'Something went wrong!');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Show Error Toast'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                AppToast.warning(context, 'Please check your input!');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              child: const Text('Show Warning Toast'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                AppToast.info(context, 'Here is some information for you.');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: const Text('Show Info Toast'),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                AppToast.show(
                  context,
                  'Custom positioned toast at top!',
                  type: ToastTypes.info,
                  position: ToastPosition.top,
                  duration: const Duration(seconds: 5),
                );
              },
              child: const Text('Show Top Toast'),
            ),
          ],
        ),
      ),
    );
  }
}
