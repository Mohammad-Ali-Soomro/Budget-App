import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animate_do/animate_do.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/presentation/widgets/modern_button.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      icon: PhosphorIcons.wallet(),
      title: 'Smart Budget Management',
      description: 'Take control of your finances with intelligent budgeting tools designed for Pakistani users.',
      color: Colors.blue,
    ),
    OnboardingPage(
      icon: PhosphorIcons.chartLine(),
      title: 'Track Your Expenses',
      description: 'Monitor your spending patterns and get insights to make better financial decisions.',
      color: Colors.green,
    ),
    OnboardingPage(
      icon: PhosphorIcons.target(),
      title: 'Achieve Your Goals',
      description: 'Set financial goals and track your progress with our advanced analytics and reminders.',
      color: Colors.purple,
    ),
    OnboardingPage(
      icon: PhosphorIcons.shield(),
      title: 'Secure & Private',
      description: 'Your financial data is protected with bank-level security and biometric authentication.',
      color: Colors.orange,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _finishOnboarding() {
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              _pages[_currentPage].color.withValues(alpha: 0.1),
              _pages[_currentPage].color.withValues(alpha: 0.05),
              theme.colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Skip Button
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (_currentPage > 0)
                      TextButton(
                        onPressed: _previousPage,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              PhosphorIcons.arrowLeft(),
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            const Text('Back'),
                          ],
                        ),
                      )
                    else
                      const SizedBox(),
                    TextButton(
                      onPressed: _finishOnboarding,
                      child: const Text(
                        'Skip',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),

              // Page View
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemCount: _pages.length,
                  itemBuilder: (context, index) {
                    return _buildPage(_pages[index], index);
                  },
                ),
              ),

              // Page Indicator and Navigation
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Page Indicator
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _pages.length,
                        (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: _currentPage == index ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _currentPage == index
                                ? _pages[_currentPage].color
                                : _pages[_currentPage].color.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Navigation Button
                    ModernButton(
                      text: _currentPage == _pages.length - 1 ? 'Get Started' : 'Next',
                      onPressed: _nextPage,
                      backgroundColor: _pages[_currentPage].color,
                      icon: _currentPage == _pages.length - 1 
                          ? PhosphorIcons.rocketLaunch() 
                          : PhosphorIcons.arrowRight(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingPage page, int index) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon
          FadeInDown(
            duration: const Duration(milliseconds: 800),
            delay: Duration(milliseconds: index * 200),
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    page.color,
                    page.color.withValues(alpha: 0.7),
                  ],
                ),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: page.color.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Icon(
                page.icon,
                size: 60,
                color: Colors.white,
              ),
            ),
          ),

          const SizedBox(height: 48),

          // Title
          FadeInUp(
            duration: const Duration(milliseconds: 800),
            delay: Duration(milliseconds: index * 200 + 200),
            child: Text(
              page.title,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: 24),

          // Description
          FadeInUp(
            duration: const Duration(milliseconds: 800),
            delay: Duration(milliseconds: index * 200 + 400),
            child: Text(
              page.description,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingPage {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  OnboardingPage({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });
}
