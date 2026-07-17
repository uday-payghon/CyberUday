// ignore_for_file: file_names

import 'dart:convert';
import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class CyberNewspaperFeed extends StatefulWidget {
  const CyberNewspaperFeed({
    super.key,
    required this.baseUrl,
    this.client,
    this.title = 'Cyber Uday India Watch',
  });

  final String baseUrl;
  final http.Client? client;
  final String title;

  @override
  State<CyberNewspaperFeed> createState() => _CyberNewspaperFeedState();
}

class _CyberNewspaperFeedState extends State<CyberNewspaperFeed> {
  late final http.Client _client;
  late Future<CyberNewsFeed> _future;

  @override
  void initState() {
    super.initState();
    _client = widget.client ?? http.Client();
    _future = _fetchFeed();
  }

  @override
  void dispose() {
    if (widget.client == null) {
      _client.close();
    }
    super.dispose();
  }

  Future<CyberNewsFeed> _fetchFeed() async {
    final uri = Uri.parse(widget.baseUrl).resolve('/api/v1/news/cyber-india');
    final response = await _client
        .get(uri, headers: {'Accept': 'application/json'})
        .timeout(const Duration(seconds: 12));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw CyberNewsException(
        'News desk unavailable (${response.statusCode})',
      );
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return CyberNewsFeed.fromJson(json);
  }

  void _retry() {
    setState(() {
      _future = _fetchFeed();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<CyberNewsFeed>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _NewsLoadingState();
        }

        if (snapshot.hasError) {
          return _NewsErrorState(onRetry: _retry);
        }

        final feed = snapshot.data;
        if (feed == null || feed.items.isEmpty) {
          return _NewsErrorState(
            title: 'No bulletins available',
            message: 'The India cyber desk has no live updates right now.',
            onRetry: _retry,
          );
        }

        return _NewsSuccessState(title: widget.title, feed: feed);
      },
    );
  }
}

class CyberNewsFeed {
  const CyberNewsFeed({
    required this.generatedAt,
    required this.country,
    required this.edition,
    required this.items,
  });

  final DateTime generatedAt;
  final String country;
  final String edition;
  final List<CyberNewsItem> items;

  factory CyberNewsFeed.fromJson(Map<String, dynamic> json) {
    final rawItems = (json['items'] as List<dynamic>? ?? const []);
    return CyberNewsFeed(
      generatedAt: DateTime.parse(json['generated_at'] as String),
      country: json['country'] as String? ?? 'IN',
      edition: json['edition'] as String? ?? 'Cyber Uday India Watch',
      items: rawItems
          .map((item) => CyberNewsItem.fromJson(item as Map<String, dynamic>))
          .toList(growable: false),
    );
  }
}

class CyberNewsItem {
  const CyberNewsItem({
    required this.newsId,
    required this.headline,
    required this.summary,
    required this.sourceUrl,
    required this.imageUrl,
    required this.severityTag,
    required this.category,
    required this.publishedDate,
  });

  final String newsId;
  final String headline;
  final String summary;
  final String sourceUrl;
  final String imageUrl;
  final String severityTag;
  final String category;
  final DateTime publishedDate;

  factory CyberNewsItem.fromJson(Map<String, dynamic> json) {
    return CyberNewsItem(
      newsId: json['news_id'] as String,
      headline: json['headline'] as String,
      summary: json['summary'] as String,
      sourceUrl: json['source_url'] as String,
      imageUrl: json['image_url'] as String,
      severityTag: json['severity_tag'] as String,
      category: json['category'] as String,
      publishedDate: DateTime.parse(json['published_date'] as String),
    );
  }
}

class CyberNewsException implements Exception {
  const CyberNewsException(this.message);

  final String message;

  @override
  String toString() => message;
}

class _NewsSuccessState extends StatelessWidget {
  const _NewsSuccessState({required this.title, required this.feed});

  final String title;
  final CyberNewsFeed feed;

  @override
  Widget build(BuildContext context) {
    final dateLabel = DateFormat(
      'EEE, d MMM yyyy - h:mm a',
    ).format(feed.generatedAt.toLocal());

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = width >= 1100
            ? 3
            : width >= 720
            ? 2
            : 1;
        final lead = feed.items.first;
        final rest = feed.items.skip(1).toList(growable: false);

        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 10),
                child: _NewspaperMasthead(
                  title: title,
                  edition: feed.edition,
                  generatedAt: dateLabel,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: _LeadStoryCard(item: lead),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _NewsStoryCard(item: rest[index]),
                  childCount: rest.length,
                ),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: math.max(1, columns),
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: columns == 1 ? 0.92 : 0.82,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _NewspaperMasthead extends StatelessWidget {
  const _NewspaperMasthead({
    required this.title,
    required this.edition,
    required this.generatedAt,
  });

  final String title;
  final String edition;
  final String generatedAt;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: color.onSurface, width: 2),
              bottom: BorderSide(color: color.onSurface, width: 1),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              title.toUpperCase(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Georgia',
                fontSize: 28,
                height: 1.0,
                fontWeight: FontWeight.w900,
                color: color.onSurface,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _Hairline(color: color.outlineVariant)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                '$edition  |  $generatedAt',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: color.onSurfaceVariant,
                ),
              ),
            ),
            Expanded(child: _Hairline(color: color.outlineVariant)),
          ],
        ),
      ],
    );
  }
}

class _LeadStoryCard extends StatelessWidget {
  const _LeadStoryCard({required this.item});

  final CyberNewsItem item;

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 760;

    return Card(
      elevation: 1,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: wide
          ? IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(flex: 5, child: _NewsImage(url: item.imageUrl)),
                  Expanded(flex: 6, child: _StoryText(item: item, lead: true)),
                ],
              ),
            )
          : Column(
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: _NewsImage(url: item.imageUrl),
                ),
                _StoryText(item: item, lead: true),
              ],
            ),
    );
  }
}

class _NewsStoryCard extends StatelessWidget {
  const _NewsStoryCard({required this.item});

  final CyberNewsItem item;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(flex: 4, child: _NewsImage(url: item.imageUrl)),
          Expanded(flex: 6, child: _StoryText(item: item)),
        ],
      ),
    );
  }
}

class _StoryText extends StatelessWidget {
  const _StoryText({required this.item, this.lead = false});

  final CyberNewsItem item;
  final bool lead;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final published = DateFormat(
      'd MMM, h:mm a',
    ).format(item.publishedDate.toLocal());

    return Padding(
      padding: EdgeInsets.all(lead ? 18 : 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _SeverityChip(label: item.severityTag),
              _CategoryChip(label: item.category),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            item.headline,
            maxLines: lead ? 3 : 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'Georgia',
              fontSize: lead ? 24 : 18,
              height: 1.08,
              fontWeight: FontWeight.w900,
              color: color.onSurface,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            item.summary,
            maxLines: lead ? 7 : 5,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              height: 1.35,
              color: color.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            published,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: color.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _NewsImage extends StatelessWidget {
  const _NewsImage({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
      placeholder: (context, url) => const _ImageSkeleton(),
      errorWidget: (context, url, error) => const _CyberVectorFallback(),
    );
  }
}

class _SeverityChip extends StatelessWidget {
  const _SeverityChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final color = switch (label) {
      'CRITICAL' => Colors.red.shade700,
      'WARNING' => Colors.amber.shade800,
      _ => Colors.blueGrey.shade700,
    };

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}

class _NewsLoadingState extends StatelessWidget {
  const _NewsLoadingState();

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 4,
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 420,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 0.85,
      ),
      itemBuilder: (context, index) {
        return Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: const Padding(
            padding: EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(flex: 4, child: _ImageSkeleton()),
                SizedBox(height: 16),
                _TextSkeleton(widthFactor: 0.9),
                SizedBox(height: 8),
                _TextSkeleton(widthFactor: 0.7),
                SizedBox(height: 12),
                Expanded(flex: 3, child: _ImageSkeleton()),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _NewsErrorState extends StatelessWidget {
  const _NewsErrorState({
    required this.onRetry,
    this.title = 'Could not load the cyber desk',
    this.message = 'Check your connection and try again.',
  });

  final VoidCallback onRetry;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox.square(
                  dimension: 72,
                  child: _CyberVectorFallback(),
                ),
                const SizedBox(height: 18),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 18),
                FilledButton(onPressed: onRetry, child: const Text('Retry')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CyberVectorFallback extends StatelessWidget {
  const _CyberVectorFallback();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFF101820),
      child: CustomPaint(
        painter: _CyberShieldPainter(
          accent: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}

class _CyberShieldPainter extends CustomPainter {
  const _CyberShieldPainter({required this.accent});

  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(2, size.shortestSide * 0.025)
      ..strokeCap = StrokeCap.round
      ..color = accent;

    final shield = Path()
      ..moveTo(size.width * 0.5, size.height * 0.18)
      ..lineTo(size.width * 0.76, size.height * 0.30)
      ..quadraticBezierTo(
        size.width * 0.73,
        size.height * 0.70,
        size.width * 0.5,
        size.height * 0.84,
      )
      ..quadraticBezierTo(
        size.width * 0.27,
        size.height * 0.70,
        size.width * 0.24,
        size.height * 0.30,
      )
      ..close();
    canvas.drawPath(shield, paint);

    final nodePaint = Paint()..color = accent;
    final center = Offset(size.width * 0.5, size.height * 0.52);
    final nodes = [
      Offset(size.width * 0.38, size.height * 0.43),
      Offset(size.width * 0.62, size.height * 0.43),
      Offset(size.width * 0.38, size.height * 0.65),
      Offset(size.width * 0.62, size.height * 0.65),
    ];
    for (final node in nodes) {
      canvas.drawLine(center, node, paint);
      canvas.drawCircle(node, size.shortestSide * 0.025, nodePaint);
    }
    canvas.drawCircle(center, size.shortestSide * 0.04, nodePaint);
  }

  @override
  bool shouldRepaint(covariant _CyberShieldPainter oldDelegate) {
    return oldDelegate.accent != accent;
  }
}

class _ImageSkeleton extends StatelessWidget {
  const _ImageSkeleton();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }
}

class _TextSkeleton extends StatelessWidget {
  const _TextSkeleton({required this.widthFactor});

  final double widthFactor;

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      alignment: Alignment.centerLeft,
      widthFactor: widthFactor,
      child: const SizedBox(height: 12, child: _ImageSkeleton()),
    );
  }
}

class _Hairline extends StatelessWidget {
  const _Hairline({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Divider(height: 1, thickness: 1, color: color);
  }
}
