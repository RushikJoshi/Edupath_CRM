import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerLoading extends StatelessWidget {
  const ShimmerLoading({
    super.key,
    required this.child,
    this.isLoading = true,
    this.baseColor = const Color(0xFFE2E8F0),
    this.highlightColor = const Color(0xFFF8FAFC),
  });

  final Widget child;
  final bool isLoading;
  final Color baseColor;
  final Color highlightColor;

  static const Color defaultBase = Color(0xFFE2E8F0);
  static const Color defaultHighlight = Color(0xFFF8FAFC);

  @override
  Widget build(BuildContext context) {
    if (!isLoading) return child;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: child,
    );
  }

  static Widget box({
    required double width,
    required double height,
    double borderRadius = 8,
    Color baseColor = defaultBase,
    Color highlightColor = defaultHighlight,
  }) {
    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }

  static Widget circle({
    required double size,
    Color baseColor = defaultBase,
    Color highlightColor = defaultHighlight,
  }) {
    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  static Widget listPlaceholder({
    int itemCount = 6,
    double itemHeight = 80,
    double padding = 16,
    Color baseColor = defaultBase,
    Color highlightColor = defaultHighlight,
  }) {
    return ListView.builder(
      padding: EdgeInsets.all(padding),
      itemCount: itemCount,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Container(
          height: itemHeight,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: baseColor, width: 1),
          ),
          child: Row(
            children: [
              Container(
                width: 4,
                height: double.infinity,
                decoration: BoxDecoration(
                  color: baseColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              circle(
                size: 42,
                baseColor: baseColor,
                highlightColor: highlightColor,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    box(
                      width: 120,
                      height: 14,
                      baseColor: baseColor,
                      highlightColor: highlightColor,
                    ),
                    const SizedBox(height: 6),
                    box(
                      width: 80,
                      height: 12,
                      baseColor: baseColor,
                      highlightColor: highlightColor,
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

  static Widget detailPlaceholder({
    double padding = 16,
    Color baseColor = defaultBase,
    Color highlightColor = defaultHighlight,
  }) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card
          box(
            width: double.infinity,
            height: 120,
            borderRadius: 20,
            baseColor: baseColor,
            highlightColor: highlightColor,
          ),
          const SizedBox(height: 20),

          // Section 1
          box(
            width: 120,
            height: 16,
            baseColor: baseColor,
            highlightColor: highlightColor,
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: baseColor, width: 1),
            ),
            child: Column(
              children: [
                _shimmerRow(baseColor, highlightColor),
                const Divider(height: 20),
                _shimmerRow(baseColor, highlightColor),
                const Divider(height: 20),
                _shimmerRow(baseColor, highlightColor),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Section 2
          box(
            width: 150,
            height: 16,
            baseColor: baseColor,
            highlightColor: highlightColor,
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: baseColor, width: 1),
            ),
            child: Column(
              children: [
                _shimmerRow(baseColor, highlightColor),
                const Divider(height: 20),
                _shimmerRow(baseColor, highlightColor),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _shimmerRow(Color base, Color highlight) {
    return Row(
      children: [
        box(
          width: 20,
          height: 20,
          borderRadius: 6,
          baseColor: base,
          highlightColor: highlight,
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            box(
              width: 60,
              height: 10,
              baseColor: base,
              highlightColor: highlight,
            ),
            const SizedBox(height: 4),
            box(
              width: 140,
              height: 14,
              baseColor: base,
              highlightColor: highlight,
            ),
          ],
        ),
      ],
    );
  }
}
