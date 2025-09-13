import 'package:flutter/material.dart';

/// Widget d'animation pour les éléments de liste
class AnimatedListItem extends StatefulWidget {
  final Widget child;
  final int index;
  final Duration delay;
  final Duration duration;
  final Curve curve;
  final bool slideFromBottom;
  final bool fadeIn;
  final bool scaleIn;

  const AnimatedListItem({
    Key? key,
    required this.child,
    required this.index,
    this.delay = const Duration(milliseconds: 100),
    this.duration = const Duration(milliseconds: 600),
    this.curve = Curves.easeOutBack,
    this.slideFromBottom = true,
    this.fadeIn = true,
    this.scaleIn = false,
  }) : super(key: key);

  @override
  State<AnimatedListItem> createState() => _AnimatedListItemState();
}

class _AnimatedListItemState extends State<AnimatedListItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: widget.fadeIn ? 0.0 : 1.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));

    _slideAnimation = Tween<Offset>(
      begin: widget.slideFromBottom 
        ? const Offset(0.0, 0.5) 
        : const Offset(0.5, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));

    _scaleAnimation = Tween<double>(
      begin: widget.scaleIn ? 0.8 : 1.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));

    // Démarrer l'animation avec un délai basé sur l'index
    Future.delayed(
      Duration(milliseconds: widget.index * widget.delay.inMilliseconds),
      () {
        if (mounted) {
          _controller.forward();
        }
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        Widget animatedChild = widget.child;

        if (widget.scaleIn) {
          animatedChild = ScaleTransition(
            scale: _scaleAnimation,
            child: animatedChild,
          );
        }

        if (widget.slideFromBottom || !widget.slideFromBottom) {
          animatedChild = SlideTransition(
            position: _slideAnimation,
            child: animatedChild,
          );
        }

        if (widget.fadeIn) {
          animatedChild = FadeTransition(
            opacity: _fadeAnimation,
            child: animatedChild,
          );
        }

        return animatedChild;
      },
    );
  }
}

/// Widget d'animation pour les grilles
class AnimatedGridItem extends StatefulWidget {
  final Widget child;
  final int index;
  final int crossAxisCount;
  final Duration delay;
  final Duration duration;
  final Curve curve;

  const AnimatedGridItem({
    Key? key,
    required this.child,
    required this.index,
    this.crossAxisCount = 2,
    this.delay = const Duration(milliseconds: 50),
    this.duration = const Duration(milliseconds: 500),
    this.curve = Curves.easeOutCubic,
  }) : super(key: key);

  @override
  State<AnimatedGridItem> createState() => _AnimatedGridItemState();
}

class _AnimatedGridItemState extends State<AnimatedGridItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));

    // Animation de glissement basée sur la position dans la grille
    final row = widget.index ~/ widget.crossAxisCount;
    final col = widget.index % widget.crossAxisCount;
    
    _slideAnimation = Tween<Offset>(
      begin: Offset(
        col.isEven ? -0.3 : 0.3,
        0.3,
      ),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));

    // Démarrer l'animation avec un délai basé sur la position
    final delayMultiplier = (row * widget.crossAxisCount) + col;
    Future.delayed(
      Duration(milliseconds: delayMultiplier * widget.delay.inMilliseconds),
      () {
        if (mounted) {
          _controller.forward();
        }
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return SlideTransition(
          position: _slideAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: widget.child,
            ),
          ),
        );
      },
    );
  }
}

/// Widget d'animation pour les éléments qui apparaissent au scroll
class ScrollAnimatedItem extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;
  final double threshold;

  const ScrollAnimatedItem({
    Key? key,
    required this.child,
    this.duration = const Duration(milliseconds: 600),
    this.curve = Curves.easeOutBack,
    this.threshold = 0.1,
  }) : super(key: key);

  @override
  State<ScrollAnimatedItem> createState() => _ScrollAnimatedItemState();
}

class _ScrollAnimatedItemState extends State<ScrollAnimatedItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  bool _hasAnimated = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.9,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _checkVisibility() {
    if (!_hasAnimated) {
      _hasAnimated = true;
      _controller.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        _checkVisibility();
        return false;
      },
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return SlideTransition(
            position: _slideAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: widget.child,
              ),
            ),
          );
        },
      ),
    );
  }
}