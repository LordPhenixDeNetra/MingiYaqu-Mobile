import 'package:flutter/material.dart';

/// Classe utilitaire pour les transitions de pages personnalisées
class PageTransitions {
  /// Transition de glissement depuis la droite
  static Route<T> slideFromRight<T extends Object?>(
    Widget page, {
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  /// Transition de glissement depuis le bas
  static Route<T> slideFromBottom<T extends Object?>(
    Widget page, {
    Duration duration = const Duration(milliseconds: 400),
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        const curve = Curves.easeOutCubic;

        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );

        var fadeAnimation = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
        ));

        return SlideTransition(
          position: animation.drive(tween),
          child: FadeTransition(
            opacity: fadeAnimation,
            child: child,
          ),
        );
      },
    );
  }

  /// Transition de fondu avec échelle
  static Route<T> fadeScale<T extends Object?>(
    Widget page, {
    Duration duration = const Duration(milliseconds: 350),
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var fadeAnimation = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOut,
        ));

        var scaleAnimation = Tween<double>(
          begin: 0.8,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutBack,
        ));

        return FadeTransition(
          opacity: fadeAnimation,
          child: ScaleTransition(
            scale: scaleAnimation,
            child: child,
          ),
        );
      },
    );
  }

  /// Transition de rotation avec fondu
  static Route<T> rotationFade<T extends Object?>(
    Widget page, {
    Duration duration = const Duration(milliseconds: 500),
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var rotationAnimation = Tween<double>(
          begin: 0.1,
          end: 0.0,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        ));

        var fadeAnimation = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOut,
        ));

        var scaleAnimation = Tween<double>(
          begin: 0.9,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutBack,
        ));

        return FadeTransition(
          opacity: fadeAnimation,
          child: ScaleTransition(
            scale: scaleAnimation,
            child: RotationTransition(
              turns: rotationAnimation,
              child: child,
            ),
          ),
        );
      },
    );
  }

  /// Transition personnalisée pour les modales
  static Route<T> modalSlide<T extends Object?>(
    Widget page, {
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      opaque: false,
      barrierColor: Colors.black54,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        const curve = Curves.easeOutCubic;

        var slideAnimation = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );

        var fadeAnimation = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeOut,
        ));

        return SlideTransition(
          position: animation.drive(slideAnimation),
          child: FadeTransition(
            opacity: fadeAnimation,
            child: child,
          ),
        );
      },
    );
  }
}

/// Extension pour faciliter l'utilisation des transitions
extension NavigatorTransitions on NavigatorState {
  /// Navigation avec transition de glissement depuis la droite
  Future<T?> pushSlideRight<T extends Object?>(Widget page) {
    return push<T>(PageTransitions.slideFromRight<T>(page));
  }

  /// Navigation avec transition de glissement depuis le bas
  Future<T?> pushSlideBottom<T extends Object?>(Widget page) {
    return push<T>(PageTransitions.slideFromBottom<T>(page));
  }

  /// Navigation avec transition de fondu et échelle
  Future<T?> pushFadeScale<T extends Object?>(Widget page) {
    return push<T>(PageTransitions.fadeScale<T>(page));
  }

  /// Navigation avec transition de rotation et fondu
  Future<T?> pushRotationFade<T extends Object?>(Widget page) {
    return push<T>(PageTransitions.rotationFade<T>(page));
  }

  /// Navigation modale avec transition personnalisée
  Future<T?> pushModal<T extends Object?>(Widget page) {
    return push<T>(PageTransitions.modalSlide<T>(page));
  }
}