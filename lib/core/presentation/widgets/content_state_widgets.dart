import 'package:flutter/material.dart';

class _SkeletonBox extends StatefulWidget {
  const _SkeletonBox({
    this.width,
    required this.height,
    this.radius = 10,
    this.margin,
  });

  final double? width;
  final double height;
  final double radius;
  final EdgeInsetsGeometry? margin;

  @override
  State<_SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<_SkeletonBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1050),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).colorScheme.surfaceContainerHighest;
    return FadeTransition(
      opacity: Tween<double>(begin: 0.45, end: 0.85).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
      ),
      child: Container(
        width: widget.width,
        height: widget.height,
        margin: widget.margin,
        decoration: BoxDecoration(
          color: base,
          borderRadius: BorderRadius.circular(widget.radius),
        ),
      ),
    );
  }
}

/// Skeleton placeholder for URL / list rows while async data loads.
class ItemsListSkeleton extends StatelessWidget {
  const ItemsListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, i) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    const _SkeletonBox(
                      width: 40,
                      height: 40,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _SkeletonBox(
                            height: 14,
                            radius: 4,
                            margin: EdgeInsets.only(bottom: 8),
                          ),
                          const _SkeletonBox(
                            height: 10,
                            width: 120,
                            radius: 4,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              childCount: 8,
            ),
          ),
        ),
      ],
    );
  }
}

/// Skeleton for collection grid (Library / Home cards).
class CollectionGridSkeleton extends StatelessWidget {
  const CollectionGridSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.15,
      ),
      itemCount: 6,
      itemBuilder: (_, __) => const _SkeletonBox(
        width: null,
        height: 140,
        radius: 20,
      ),
    );
  }
}

/// Skeleton lines for Home dashboard sections.
class HomeSectionSkeleton extends StatelessWidget {
  const HomeSectionSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const _SkeletonBox(height: 24, width: 160, radius: 6),
        const SizedBox(height: 16),
        SizedBox(
          height: 132,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: 4,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, __) => const _SkeletonBox(
              width: 128,
              height: 132,
              radius: 20,
            ),
          ),
        ),
        const SizedBox(height: 32),
        const _SkeletonBox(height: 24, width: 140, radius: 6),
        const SizedBox(height: 12),
        ...List.generate(
          4,
          (i) => const _SkeletonBox(
            width: null,
            height: 64,
            radius: 16,
            margin: EdgeInsets.only(bottom: 8),
          ),
        ),
      ],
    );
  }
}

/// Consistent error surface with retry.
class AppErrorState extends StatelessWidget {
  final Object error;
  final VoidCallback onRetry;
  final String? title;

  const AppErrorState({
    super.key,
    required this.error,
    required this.onRetry,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off_outlined,
              size: 56,
              color: theme.colorScheme.error.withValues(alpha: 0.75),
            ),
            const SizedBox(height: 16),
            Text(
              title ?? 'Something went wrong',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              '$error',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
