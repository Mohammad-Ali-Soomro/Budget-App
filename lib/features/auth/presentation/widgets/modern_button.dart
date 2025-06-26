import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class ModernButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double height;
  final BorderRadius? borderRadius;
  final List<BoxShadow>? boxShadow;

  const ModernButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height = 56,
    this.borderRadius,
    this.boxShadow,
  });

  @override
  State<ModernButton> createState() => _ModernButtonState();
}

class _ModernButtonState extends State<ModernButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _opacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.8,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _animationController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _animationController.reverse();
  }

  void _handleTapCancel() {
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEnabled = widget.onPressed != null && !widget.isLoading;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: GestureDetector(
              onTapDown: isEnabled ? _handleTapDown : null,
              onTapUp: isEnabled ? _handleTapUp : null,
              onTapCancel: isEnabled ? _handleTapCancel : null,
              onTap: isEnabled ? () {
                _animationController.reverse();
                widget.onPressed?.call();
              } : null,
              child: Container(
                width: widget.width ?? double.infinity,
                height: widget.height,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isEnabled
                        ? [
                            widget.backgroundColor ?? theme.colorScheme.primary,
                            (widget.backgroundColor ?? theme.colorScheme.primary)
                                .withValues(alpha: 0.8),
                          ]
                        : [
                            theme.colorScheme.onSurface.withValues(alpha: 0.12),
                            theme.colorScheme.onSurface.withValues(alpha: 0.08),
                          ],
                  ),
                  borderRadius: widget.borderRadius ?? BorderRadius.circular(16),
                  boxShadow: widget.boxShadow ?? [
                    if (isEnabled)
                      BoxShadow(
                        color: (widget.backgroundColor ?? theme.colorScheme.primary)
                            .withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: widget.borderRadius ?? BorderRadius.circular(16),
                    onTap: isEnabled ? widget.onPressed : null,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (widget.isLoading) ...[
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  widget.textColor ?? Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                          ] else if (widget.icon != null) ...[
                            Icon(
                              widget.icon,
                              color: widget.textColor ?? Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                          ],
                          Text(
                            widget.text,
                            style: TextStyle(
                              color: isEnabled
                                  ? (widget.textColor ?? Colors.white)
                                  : theme.colorScheme.onSurface.withValues(alpha: 0.38),
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
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
}

// Secondary button variant
class ModernSecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final double? width;
  final double height;

  const ModernSecondaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.width,
    this.height = 56,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return ModernButton(
      text: text,
      onPressed: onPressed,
      isLoading: isLoading,
      icon: icon,
      width: width,
      height: height,
      backgroundColor: Colors.transparent,
      textColor: theme.colorScheme.primary,
      boxShadow: [],
    );
  }
}

// Outline button variant
class ModernOutlineButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final double? width;
  final double height;

  const ModernOutlineButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.width,
    this.height = 56,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      width: width ?? double.infinity,
      height: height,
      decoration: BoxDecoration(
        border: Border.all(
          color: theme.colorScheme.primary,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ModernButton(
        text: text,
        onPressed: onPressed,
        isLoading: isLoading,
        icon: icon,
        width: width,
        height: height,
        backgroundColor: Colors.transparent,
        textColor: theme.colorScheme.primary,
        boxShadow: [],
      ),
    );
  }
}
