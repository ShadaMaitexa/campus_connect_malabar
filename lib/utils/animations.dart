import 'package:flutter/material.dart';

/// Enhanced animation utilities for the app
class AppAnimations {
  /// Fade in animation
  static Widget fadeIn({
    required Widget child,
    Duration duration = const Duration(milliseconds: 600),
    Duration delay = Duration.zero,
    Key? key,
  }) {
    return _DelayedAnimation(
      delay: delay,
      child: TweenAnimationBuilder<double>(
        key: key,
        tween: Tween(begin: 0.0, end: 1.0),
        duration: duration,
        curve: Curves.easeIn,
        builder: (context, value, child) {
          return Opacity(
            opacity: value,
            child: child,
          );
        },
        child: child,
      ),
    );
  }

  /// Slide in from bottom animation
  static Widget slideInFromBottom({
    required Widget child,
    double offset = 30.0,
    Duration duration = const Duration(milliseconds: 600),
    Duration delay = Duration.zero,
    Key? key,
  }) {
    return _DelayedAnimation(
      delay: delay,
      child: TweenAnimationBuilder<double>(
        key: key,
        tween: Tween(begin: 0.0, end: 1.0),
        duration: duration,
        curve: Curves.easeOutCubic,
        builder: (context, value, child) {
          return Transform.translate(
            offset: Offset(0, offset * (1 - value)),
            child: Opacity(
              opacity: value,
              child: child,
            ),
          );
        },
        child: child,
      ),
    );
  }

  /// Slide in from left animation
  static Widget slideInFromLeft({
    required Widget child,
    double offset = 50.0,
    Duration duration = const Duration(milliseconds: 600),
    Duration delay = Duration.zero,
    Key? key,
  }) {
    return _DelayedAnimation(
      delay: delay,
      child: TweenAnimationBuilder<double>(
        key: key,
        tween: Tween(begin: 0.0, end: 1.0),
        duration: duration,
        curve: Curves.easeOutCubic,
        builder: (context, value, child) {
          return Transform.translate(
            offset: Offset(-offset * (1 - value), 0),
            child: Opacity(
              opacity: value,
              child: child,
            ),
          );
        },
        child: child,
      ),
    );
  }

  /// Slide in from right animation
  static Widget slideInFromRight({
    required Widget child,
    double offset = 50.0,
    Duration duration = const Duration(milliseconds: 600),
    Duration delay = Duration.zero,
    Key? key,
  }) {
    return _DelayedAnimation(
      delay: delay,
      child: TweenAnimationBuilder<double>(
        key: key,
        tween: Tween(begin: 0.0, end: 1.0),
        duration: duration,
        curve: Curves.easeOutCubic,
        builder: (context, value, child) {
          return Transform.translate(
            offset: Offset(offset * (1 - value), 0),
            child: Opacity(
              opacity: value,
              child: child,
            ),
          );
        },
        child: child,
      ),
    );
  }

  /// Scale in animation
  static Widget scaleIn({
    required Widget child,
    Duration duration = const Duration(milliseconds: 400),
    Duration delay = Duration.zero,
    Key? key,
  }) {
    return _DelayedAnimation(
      delay: delay,
      child: TweenAnimationBuilder<double>(
        key: key,
        tween: Tween(begin: 0.8, end: 1.0),
        duration: duration,
        curve: Curves.easeOutCubic,
        builder: (context, value, child) {
          return Transform.scale(
            scale: value,
            child: Opacity(
              opacity: value,
              child: child,
            ),
          );
        },
        child: child,
      ),
    );
  }

  /// Bounce animation
  static Widget bounce({
    required Widget child,
    Duration duration = const Duration(milliseconds: 800),
    Duration delay = Duration.zero,
    Key? key,
  }) {
    return _DelayedAnimation(
      delay: delay,
      child: TweenAnimationBuilder<double>(
        key: key,
        tween: Tween(begin: 0.0, end: 1.0),
        duration: duration,
        curve: Curves.elasticOut,
        builder: (context, value, child) {
          return Transform.scale(
            scale: value,
            child: child,
          );
        },
        child: child,
      ),
    );
  }

  /// Pulse animation - continuous subtle scale animation
  static Widget pulse({
    required Widget child,
    Duration duration = const Duration(milliseconds: 1500),
    double minScale = 0.95,
    double maxScale = 1.05,
    Key? key,
  }) {
    return _PulseAnimation(
      key: key,
      duration: duration,
      minScale: minScale,
      maxScale: maxScale,
      child: child,
    );
  }

  /// Staggered list animation - animates children with delay
  static Widget staggeredList({
    required List<Widget> children,
    Duration itemDuration = const Duration(milliseconds: 400),
    Duration staggerDelay = const Duration(milliseconds: 100),
    Axis direction = Axis.vertical,
    MainAxisSize mainAxisSize = MainAxisSize.min,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.start,
    Key? key,
  }) {
    return direction == Axis.vertical
        ? Column(
            key: key,
            mainAxisSize: mainAxisSize,
            crossAxisAlignment: crossAxisAlignment,
            children: List.generate(
              children.length,
              (index) => slideInFromBottom(
                child: children[index],
                duration: itemDuration,
                delay: Duration(milliseconds: staggerDelay.inMilliseconds * index),
              ),
            ),
          )
        : Row(
            key: key,
            mainAxisSize: mainAxisSize,
            crossAxisAlignment: crossAxisAlignment,
            children: List.generate(
              children.length,
              (index) => slideInFromLeft(
                child: children[index],
                duration: itemDuration,
                delay: Duration(milliseconds: staggerDelay.inMilliseconds * index),
              ),
            ),
          );
  }

  /// Shimmer effect for loading states
  static Widget shimmer({
    required Widget child,
    Duration duration = const Duration(milliseconds: 1500),
    Key? key,
  }) {
    return _ShimmerEffect(
      key: key,
      duration: duration,
      child: child,
    );
  }

  /// Floating animation - subtle up/down movement
  static Widget floating({
    required Widget child,
    Duration duration = const Duration(milliseconds: 2000),
    double offset = 8.0,
    Key? key,
  }) {
    return _FloatingAnimation(
      key: key,
      duration: duration,
      offset: offset,
      child: child,
    );
  }

  /// Rotate animation
  static Widget rotate({
    required Widget child,
    Duration duration = const Duration(seconds: 2),
    bool continuous = true,
    Key? key,
  }) {
    return _RotateAnimation(
      key: key,
      duration: duration,
      continuous: continuous,
      child: child,
    );
  }
}

/// Delayed animation wrapper
class _DelayedAnimation extends StatefulWidget {
  final Duration delay;
  final Widget child;

  const _DelayedAnimation({
    required this.delay,
    required this.child,
  });

  @override
  State<_DelayedAnimation> createState() => _DelayedAnimationState();
}

class _DelayedAnimationState extends State<_DelayedAnimation> {
  bool _show = false;

  @override
  void initState() {
    super.initState();
    if (widget.delay == Duration.zero) {
      _show = true;
    } else {
      Future.delayed(widget.delay, () {
        if (mounted) {
          setState(() => _show = true);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _show ? widget.child : const SizedBox.shrink();
  }
}

/// Pulse animation widget
class _PulseAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double minScale;
  final double maxScale;

  const _PulseAnimation({
    super.key,
    required this.child,
    required this.duration,
    required this.minScale,
    required this.maxScale,
  });

  @override
  State<_PulseAnimation> createState() => _PulseAnimationState();
}

class _PulseAnimationState extends State<_PulseAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat(reverse: true);

    _animation = Tween<double>(
      begin: widget.minScale,
      end: widget.maxScale,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(
          scale: _animation.value,
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

/// Shimmer effect widget
class _ShimmerEffect extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const _ShimmerEffect({
    super.key,
    required this.child,
    required this.duration,
  });

  @override
  State<_ShimmerEffect> createState() => _ShimmerEffectState();
}

class _ShimmerEffectState extends State<_ShimmerEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat();

    _animation = Tween<double>(begin: -1, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
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
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment(_animation.value - 1, 0),
              end: Alignment(_animation.value + 1, 0),
              colors: const [
                Colors.grey,
                Colors.white,
                Colors.grey,
              ],
              stops: const [0.0, 0.5, 1.0],
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

/// Floating animation widget
class _FloatingAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double offset;

  const _FloatingAnimation({
    super.key,
    required this.child,
    required this.duration,
    required this.offset,
  });

  @override
  State<_FloatingAnimation> createState() => _FloatingAnimationState();
}

class _FloatingAnimationState extends State<_FloatingAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat(reverse: true);

    _animation = Tween<double>(
      begin: -widget.offset,
      end: widget.offset,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _animation.value),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

/// Rotate animation widget
class _RotateAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final bool continuous;

  const _RotateAnimation({
    super.key,
    required this.child,
    required this.duration,
    required this.continuous,
  });

  @override
  State<_RotateAnimation> createState() => _RotateAnimationState();
}

class _RotateAnimationState extends State<_RotateAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    if (widget.continuous) {
      _controller.repeat();
    } else {
      _controller.forward();
    }

    _animation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.linear,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.rotate(
          angle: _animation.value * 2 * 3.14159,
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

/// Hero animation wrapper
class AnimatedListItem extends StatelessWidget {
  final int index;
  final Widget child;
  final Duration duration;
  final Duration staggerDelay;

  const AnimatedListItem({
    super.key,
    required this.index,
    required this.child,
    this.duration = const Duration(milliseconds: 400),
    this.staggerDelay = const Duration(milliseconds: 100),
  });

  @override
  Widget build(BuildContext context) {
    return AppAnimations.slideInFromBottom(
      child: child,
      duration: duration,
      delay: Duration(milliseconds: staggerDelay.inMilliseconds * index),
    );
  }
}

/// Page transition animations
class PageTransitions {
  static Route<T> fadeThrough<T>({
    required Widget page,
    Duration duration = const Duration(milliseconds: 400),
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    );
  }

  static Route<T> slideUp<T>({
    required Widget page,
    Duration duration = const Duration(milliseconds: 400),
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        final tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: Curves.easeOutCubic),
        );
        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  static Route<T> slideRight<T>({
    required Widget page,
    Duration duration = const Duration(milliseconds: 400),
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        final tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: Curves.easeOutCubic),
        );
        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  static Route<T> scale<T>({
    required Widget page,
    Duration duration = const Duration(milliseconds: 400),
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: Tween<double>(begin: 0.9, end: 1.0).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
          ),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
    );
  }
}
