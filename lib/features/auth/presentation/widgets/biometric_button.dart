import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:animate_do/animate_do.dart';
import '../../../../core/providers/auth_provider.dart';

class BiometricButton extends ConsumerStatefulWidget {
  final VoidCallback? onPressed;

  const BiometricButton({
    super.key,
    this.onPressed,
  });

  @override
  ConsumerState<BiometricButton> createState() => _BiometricButtonState();
}

class _BiometricButtonState extends ConsumerState<BiometricButton>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _scaleController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _scaleAnimation;
  bool _isBiometricAvailable = false;

  @override
  void initState() {
    super.initState();
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));
    
    _checkBiometricAvailability();
    _startPulseAnimation();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  void _checkBiometricAvailability() async {
    final isAvailable = await ref.read(authControllerProvider.notifier).checkBiometricAvailability();
    if (mounted) {
      setState(() {
        _isBiometricAvailable = isAvailable;
      });
    }
  }

  void _startPulseAnimation() {
    _pulseController.repeat(reverse: true);
  }

  void _handleTap() {
    _scaleController.forward().then((_) {
      _scaleController.reverse();
    });
    widget.onPressed?.call();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (!_isBiometricAvailable) {
      return const SizedBox.shrink();
    }

    return FadeInUp(
      duration: const Duration(milliseconds: 800),
      delay: const Duration(milliseconds: 600),
      child: Column(
        children: [
          // Divider with "OR"
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        theme.colorScheme.onSurface.withValues(alpha: 0.2),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'OR',
                  style: TextStyle(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1,
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.onSurface.withValues(alpha: 0.2),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Biometric Button
          AnimatedBuilder(
            animation: Listenable.merge([_pulseAnimation, _scaleAnimation]),
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: GestureDetector(
                  onTap: _handleTap,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          theme.colorScheme.primary.withValues(alpha: 0.1),
                          theme.colorScheme.secondary.withValues(alpha: 0.1),
                        ],
                      ),
                      border: Border.all(
                        color: theme.colorScheme.primary.withValues(alpha: 0.3),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.primary.withValues(alpha: 0.2),
                          blurRadius: 20 * _pulseAnimation.value,
                          spreadRadius: 5 * (_pulseAnimation.value - 1),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        PhosphorIcons.fingerprint(),
                        size: 32,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          
          const SizedBox(height: 12),
          
          Text(
            'Use Biometric',
            style: TextStyle(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// Floating biometric button for quick access
class FloatingBiometricButton extends ConsumerWidget {
  final VoidCallback? onPressed;

  const FloatingBiometricButton({
    super.key,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    
    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: theme.colorScheme.primary,
      elevation: 8,
      child: Icon(
        PhosphorIcons.fingerprint(),
        color: Colors.white,
        size: 28,
      ),
    );
  }
}
