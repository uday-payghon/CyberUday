// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../models/news_model.dart';
import '../../../repositories/news_repository.dart';
import '../widgets/home_shared_widgets.dart';

class CyberNewsScreen extends StatelessWidget {
  const CyberNewsScreen({super.key, NewsRepository? repository})
    : _repository = repository;

  final NewsRepository? _repository;

  NewsRepository get repository => _repository ?? NewsRepository();

  @override
  Widget build(BuildContext context) {
    final mobile = MediaQuery.sizeOf(context).width < 960;
    final newsRepository = repository;

    return ListView(
      children: [
        const HeroBanner(
          title: 'Stay aware with recent cybercrime news and citizen updates.',
          subtitle:
              'One block for verified recent news and one block for user-submitted awareness updates sent to the team for review.',
        ),
        const SizedBox(height: 18),
        mobile
            ? Column(
                children: [
                  RecentNewsCard(repository: newsRepository),
                  const SizedBox(height: 14),
                  CreateNewsCard(repository: newsRepository),
                ],
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: RecentNewsCard(repository: newsRepository)),
                  const SizedBox(width: 14),
                  Expanded(child: CreateNewsCard(repository: newsRepository)),
                ],
              ),
      ],
    );
  }
}

class RecentNewsCard extends StatelessWidget {
  const RecentNewsCard({super.key, required this.repository});

  final NewsRepository repository;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Recent news',
      subtitle:
          'Daily awareness feed for cyber fraud, fake lottery cases, and phishing alerts.',
      child: StreamBuilder<List<NewsModel>>(
        stream: repository.getVerifiedNews(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 22),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          if (snapshot.hasError) {
            return _NewsErrorMessage(message: _errorMessage(snapshot.error));
          }

          final news = snapshot.data ?? const <NewsModel>[];
          if (news.isEmpty) {
            return const Text('No verified news published yet.');
          }

          return Column(
            children: news
                .map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _NewsTile(item: item),
                  ),
                )
                .toList(growable: false),
          );
        },
      ),
    );
  }

  static String _errorMessage(Object? error) {
    if (error is NewsRepositoryException) {
      return error.message;
    }
    return 'Unable to load recent news. Please refresh and try again.';
  }
}

class CreateNewsCard extends StatefulWidget {
  const CreateNewsCard({super.key, required this.repository});

  final NewsRepository repository;

  @override
  State<CreateNewsCard> createState() => _CreateNewsCardState();
}

class _CreateNewsCardState extends State<CreateNewsCard> {
  final _headlineController = TextEditingController();
  final _detailsController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _headlineController.dispose();
    _detailsController.dispose();
    super.dispose();
  }

  Future<void> _submitNews() async {
    final headline = _headlineController.text.trim();
    final details = _detailsController.text.trim();

    if (headline.isEmpty || details.isEmpty) {
      _showSnackBar('Please fill headline and details.');
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await widget.repository.submitUserReport(headline, details);
      if (!mounted) {
        return;
      }
      _headlineController.clear();
      _detailsController.clear();
      _showSnackBar('Report submitted for review');
    } catch (error) {
      if (!mounted) {
        return;
      }
      final message = error is NewsRepositoryException
          ? error.message
          : 'Unable to submit report. Please try again.';
      _showSnackBar(message);
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Create new news',
      subtitle:
          'Users can submit local scam alerts or suspicious patterns to the team before public posting.',
      child: Column(
        children: [
          FieldPlaceholder(
            label: 'Headline or fraud pattern',
            controller: _headlineController,
            maxLines: 1,
          ),
          const SizedBox(height: 12),
          FieldPlaceholder(
            label: 'What happened and where',
            controller: _detailsController,
            maxLines: 4,
          ),
          const SizedBox(height: 12),
          ActionChipWidget(
            label: _isSubmitting ? 'Submitting...' : 'Submit to Team',
            icon: Icons.send_rounded,
            isLoading: _isSubmitting,
            onTap: _submitNews,
          ),
        ],
      ),
    );
  }
}

class _NewsTile extends StatelessWidget {
  const _NewsTile({required this.item});

  final NewsModel item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timestamp = item.timestamp;
    final dateLabel = timestamp == null
        ? 'Verified'
        : '${DateFormat('d MMM yyyy, h:mm a').format(timestamp)} • Verified';
    final author = item.author == null ? '' : ' • ${item.author}';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF1E4A67)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(item.headline, style: theme.textTheme.titleMedium),
          const SizedBox(height: 6),
          Text(
            item.details,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 8),
          Text(
            '$dateLabel$author',
            style: theme.textTheme.bodySmall?.copyWith(
              color: const Color(0xFFB6C9D9),
            ),
          ),
        ],
      ),
    );
  }
}

class _NewsErrorMessage extends StatelessWidget {
  const _NewsErrorMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.redAccent.withValues(alpha: 0.55)),
        color: Colors.redAccent.withValues(alpha: 0.08),
      ),
      child: Text(message),
    );
  }
}
