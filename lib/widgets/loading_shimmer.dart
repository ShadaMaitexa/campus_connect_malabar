import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Enhanced shimmer loading widget with animated gradient effect
class LoadingShimmer extends StatefulWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;
  final bool isCircle;

  const LoadingShimmer({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
    this.isCircle = false,
  });

  @override
  State<LoadingShimmer> createState() => _LoadingShimmerState();
}

class _LoadingShimmerState extends State<LoadingShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _animation = Tween<double>(begin: -2, end: 2).animate(
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark
        ? AppTheme.darkSurface.withOpacity(0.6)
        : AppTheme.lightBorder.withOpacity(0.5);
    final highlightColor = isDark
        ? AppTheme.darkBorder.withOpacity(0.8)
        : Colors.white.withOpacity(0.9);

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            shape: widget.isCircle ? BoxShape.circle : BoxShape.rectangle,
            borderRadius: widget.isCircle
                ? null
                : (widget.borderRadius ?? BorderRadius.circular(AppTheme.radiusM)),
            gradient: LinearGradient(
              begin: Alignment(_animation.value - 1, 0),
              end: Alignment(_animation.value + 1, 0),
              colors: [
                baseColor,
                highlightColor,
                baseColor,
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        );
      },
    );
  }
}

/// Shimmer card placeholder for dashboard cards
class ShimmerCard extends StatelessWidget {
  final double? width;
  final double? height;

  const ShimmerCard({
    super.key,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height ?? 150,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
        color: Theme.of(context).colorScheme.surface,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          LoadingShimmer(
            width: 50,
            height: 50,
            isCircle: true,
          ),
          const SizedBox(height: 16),
          LoadingShimmer(
            width: 80,
            height: 20,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 8),
          LoadingShimmer(
            width: 60,
            height: 14,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }
}

/// Shimmer list item placeholder
class ShimmerListItem extends StatelessWidget {
  final bool showAvatar;
  final bool showSubtitle;
  final bool showTrailing;

  const ShimmerListItem({
    super.key,
    this.showAvatar = true,
    this.showSubtitle = true,
    this.showTrailing = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
        color: Theme.of(context).colorScheme.surface,
      ),
      child: Row(
        children: [
          if (showAvatar) ...[
            LoadingShimmer(
              width: 48,
              height: 48,
              isCircle: true,
            ),
            const SizedBox(width: 16),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LoadingShimmer(
                  width: double.infinity,
                  height: 16,
                  borderRadius: BorderRadius.circular(4),
                ),
                if (showSubtitle) ...[
                  const SizedBox(height: 8),
                  LoadingShimmer(
                    width: 150,
                    height: 12,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ],
            ),
          ),
          if (showTrailing) ...[
            const SizedBox(width: 16),
            LoadingShimmer(
              width: 60,
              height: 32,
              borderRadius: BorderRadius.circular(AppTheme.radiusS),
            ),
          ],
        ],
      ),
    );
  }
}

/// Shimmer grid for dashboard
class ShimmerGrid extends StatelessWidget {
  final int crossAxisCount;
  final int itemCount;
  final double spacing;
  final double childAspectRatio;

  const ShimmerGrid({
    super.key,
    this.crossAxisCount = 2,
    this.itemCount = 6,
    this.spacing = 16,
    this.childAspectRatio = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: spacing,
        crossAxisSpacing: spacing,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) => const ShimmerCard(),
    );
  }
}

/// Shimmer list for content loading
class ShimmerList extends StatelessWidget {
  final int itemCount;
  final double spacing;
  final bool showAvatar;
  final bool showSubtitle;

  const ShimmerList({
    super.key,
    this.itemCount = 5,
    this.spacing = 12,
    this.showAvatar = true,
    this.showSubtitle = true,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: itemCount,
      separatorBuilder: (_, __) => SizedBox(height: spacing),
      itemBuilder: (context, index) => ShimmerListItem(
        showAvatar: showAvatar,
        showSubtitle: showSubtitle,
      ),
    );
  }
}
