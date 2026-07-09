import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/home_shared_widgets.dart';
import '../../../services/firebase_service.dart';
import '../../../services/hacker_news_service.dart';

class CyberNewsPage extends StatelessWidget {
  const CyberNewsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final mobile = MediaQuery.sizeOf(context).width < 960;

    return ListView(
      children: [
        const HeroBanner(
          title: 'Stay aware with recent cybercrime news and citizen updates.',
          subtitle:
              'One block for verified recent news and one block for user-submitted awareness updates sent to the team for review.',
        ),
        const SizedBox(height: 18),
        mobile
            ? const Column(
                children: [
                  RecentNewsCard(),
                  SizedBox(height: 14),
                  HackerNewsCard(),
                  SizedBox(height: 14),
                  CreateNewsCard(),
                ],
              )
            : const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 6, child: RecentNewsCard()),
                  SizedBox(width: 14),
                  Expanded(
                    flex: 5,
                    child: Column(
                      children: [
                        HackerNewsCard(),
                        SizedBox(height: 14),
                        CreateNewsCard(),
                      ],
                    ),
                  ),
                ],
              ),
      ],
    );
  }
}

class RecentNewsCard extends StatelessWidget {
  const RecentNewsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Recent news',
      subtitle:
          'Daily awareness feed for cyber fraud, fake lottery cases, and phishing alerts.',
      child: StreamBuilder<List<Map<String, dynamic>>>(
        stream: FirebaseService.instance.getCyberNews(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final news = snapshot.data ?? [];
          if (news.isEmpty) return const Text('No news published yet.');

          return Column(
            children: news
                .map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: _NewsTile(
                      headline: item['headline'] ?? 'News Alert',
                      meta: 'By: ${item['author']} - Verified',
                    ),
                  ),
                )
                .toList(),
          );
        },
      ),
    );
  }
}

class HackerNewsCard extends StatefulWidget {
  const HackerNewsCard({super.key});

  @override
  State<HackerNewsCard> createState() => _HackerNewsCardState();
}

class _HackerNewsCardState extends State<HackerNewsCard> {
  late Future<List<HackerNewsStory>> _storiesFuture;

  @override
  void initState() {
    super.initState();
    _storiesFuture = HackerNewsService.instance.getTopStories();
  }

  void _refreshStories() {
    setState(() {
      _storiesFuture = HackerNewsService.instance.getTopStories();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Hacker News',
      subtitle: 'Live technology and security links from Hacker News.',
      child: FutureBuilder<List<HackerNewsStory>>(
        future: _storiesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Unable to load Hacker News right now.'),
                const SizedBox(height: 12),
                ActionChipWidget(
                  label: 'Try Again',
                  icon: Icons.refresh_rounded,
                  onTap: _refreshStories,
                ),
              ],
            );
          }

          final stories = snapshot.data ?? [];
          if (stories.isEmpty) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('No Hacker News stories available.'),
                const SizedBox(height: 12),
                ActionChipWidget(
                  label: 'Refresh',
                  icon: Icons.refresh_rounded,
                  onTap: _refreshStories,
                ),
              ],
            );
          }

          return Column(
            children: [
              ...stories.map(
                (story) => Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: _NewsTile(
                    headline: story.title,
                    meta:
                        '${story.score} points - ${story.commentCount} comments - by ${story.author}',
                    url: story.storyUrl,
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: ActionChipWidget(
                  label: 'Refresh',
                  icon: Icons.refresh_rounded,
                  onTap: _refreshStories,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class CreateNewsCard extends StatefulWidget {
  const CreateNewsCard({super.key});

  @override
  State<CreateNewsCard> createState() => _CreateNewsCardState();
}

class _CreateNewsCardState extends State<CreateNewsCard> {
  final _headlineController = TextEditingController();
  final _contentController = TextEditingController();
  bool _isSubmitting = false;

  Future<void> _submitNews() async {
    if (_headlineController.text.isEmpty || _contentController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please fill all fields.')));
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await FirebaseService.instance.submitNews({
        'headline': _headlineController.text,
        'content': _contentController.text,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'News submitted for review! It will appear once approved by admin.',
            ),
          ),
        );
        _headlineController.clear();
        _contentController.clear();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
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
          ),
          const SizedBox(height: 12),
          FieldPlaceholder(
            label: 'What happened and where',
            controller: _contentController,
          ),
          const SizedBox(height: 12),
          ActionChipWidget(
            label: 'Submit to Team',
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
  const _NewsTile({required this.headline, required this.meta, this.url});

  final String headline;
  final String meta;
  final String? url;

  Future<void> _openLink(BuildContext context) async {
    final link = url;
    if (link == null) return;

    final uri = Uri.tryParse(link);
    if (uri == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Invalid news link.')));
      return;
    }

    final opened = await launchUrl(uri, mode: LaunchMode.platformDefault);
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open news link.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tile = Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF1E4A67)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  headline,
                  style: theme.textTheme.titleMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  meta,
                  style: theme.textTheme.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (url != null) ...[
            const SizedBox(width: 10),
            const Icon(
              Icons.open_in_new_rounded,
              color: Color(0xFF3FFFD7),
              size: 18,
            ),
          ],
        ],
      ),
    );

    if (url == null) return tile;

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => _openLink(context),
      child: tile,
    );
  }
}
