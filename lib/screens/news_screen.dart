import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/api.dart';
import '../design_system/theme_colors.dart';
import '../design_system/app_radius.dart';
import '../design_system/app_spacing.dart';
import '../design_system/app_typography.dart';
import '../design_system/app_elevation.dart';
import '../widgets/app_empty_state.dart';
import '../models/news_article.dart';
import '../models/campaign_activity.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});
  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  String _selectedCategory = 'All';
  final _categories = ['All', 'Health', 'Announcements', 'Maritime', 'System'];
  late Future<List<NewsArticle>> _newsFuture;
  final _searchController = TextEditingController();
  String _searchQuery = '';
  List<NewsArticle> _allNews = [];

  /// What is coming up, shown above the stories.
  ///
  /// Kept out of [_newsFuture] deliberately: this is a second, independent
  /// call, and a news outage should not take the activities down with it or
  /// the other way round. Its own failure is quiet — the section simply does
  /// not appear — because it is an addition to the screen, not the screen.
  List<CampaignActivity> _activities = [];

  @override
  void initState() {
    super.initState();
    _newsFuture = _fetchNews();
    _loadActivities();
  }

  Future<void> _loadActivities() async {
    try {
      final data = await Api.get('get_activities.php');
      if (data['status'] == 'success') {
        final rows = (data['data'] as List? ?? [])
            .map((e) =>
                CampaignActivity.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
        if (mounted) setState(() => _activities = rows);
      }
    } catch (_) {
      // Left as it was. See the field doc above.
    }
  }
  @override void dispose() { _searchController.dispose(); super.dispose(); }

  /// Throws rather than returning an empty list on failure.
  ///
  /// It used to swallow everything, which told a member with no signal the
  /// same thing it told a member on a quiet news week: 'No News'. One of those
  /// is worth retrying and the other is not, and the screen was hiding which.
  Future<List<NewsArticle>> _fetchNews() async {
    // getList, not get: this endpoint answers with a bare array rather than
    // the {status, data} envelope the rest of the API uses.
    final data = await Api.getList('get_news.php');
    _allNews = data.map((e) => NewsArticle.fromJson(e)).toList();
    return _allNews;
  }

  Future<void> _onRefresh() async {
    // A block body, not an arrow: `() => _newsFuture = _fetchNews()` returns
    // the assigned Future, and setState asserts against a callback that
    // returns one. Every pull-to-refresh here threw in debug builds.
    setState(() {
      _newsFuture = _fetchNews();
    });
    // Both, not just the news. A member pulling this screen down is asking it
    // to be current, and a strip of activities that never moved would be the
    // one stale thing left on a screen that just refreshed.
    //
    // The FutureBuilder is what reports a news failure; this await only holds
    // the refresh spinner open, so its copy of the error is absorbed here
    // rather than surfacing as an unhandled rejection. _loadActivities keeps
    // its own failure quiet by design.
    await Future.wait([
      _newsFuture.catchError((_) => <NewsArticle>[]),
      _loadActivities(),
    ]);
  }

  /// The server's own words where there are any — 'check your connection'
  /// tells a member what to do, where a bare failure does not.
  String _failureText(Object? error) => error is ApiException
      ? error.message
      : 'Something went wrong loading the news.';

  List<NewsArticle> _filtered(List<NewsArticle> news) {
    return news.where((a) {
      final catOk = _selectedCategory == 'All' || a.category == _selectedCategory;
      if (!catOk) return false; if (_searchQuery.isEmpty) return true;
      final q = _searchQuery.toLowerCase(); return a.title.toLowerCase().contains(q) || a.content.toLowerCase().contains(q);
    }).toList();
  }

  void _showDetails(NewsArticle news) {
    final date = DateFormat('MMMM dd, yyyy').format(news.publishedDate);
    showModalBottomSheet(context: context, isScrollControlled: true, useSafeArea: true, showDragHandle: true,
      builder: (context) => DraggableScrollableSheet(initialChildSize: 0.7, maxChildSize: 0.92, minChildSize: 0.4, expand: false,
        builder: (context, scrollController) => ListView(controller: scrollController, padding: const EdgeInsets.fromLTRB(AppSpacing.xxl, 0, AppSpacing.xxl, AppSpacing.xxxl), children: [
          Container(padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs), decoration: BoxDecoration(color: Theme.of(context).colorScheme.primaryContainer, borderRadius: BorderRadius.circular(999)), child: Text(news.category.toUpperCase(), style: AppTypography.labelSmall.copyWith(color: Theme.of(context).colorScheme.primary, letterSpacing: 1))),
          const SizedBox(height: AppSpacing.lg), Text(news.title, style: AppTypography.headlineMedium), const SizedBox(height: AppSpacing.sm),
          Text('Published on $date by ${news.author}', style: AppTypography.caption), const Divider(height: AppSpacing.xxxl),
          Text(news.content, style: AppTypography.bodyLarge.copyWith(height: 1.7)),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);
    return Scaffold(
      backgroundColor: tc.scaffoldBg, appBar: AppBar(title: const Text('News Corner')),
      body: Column(children: [
        Padding(padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.sm),
          child: TextField(controller: _searchController, onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()), decoration: InputDecoration(hintText: 'Search news...', prefixIcon: const Icon(Icons.search_rounded, size: 22), suffixIcon: _searchQuery.isNotEmpty ? IconButton(icon: const Icon(Icons.clear_rounded, size: 20), onPressed: () { _searchController.clear(); setState(() => _searchQuery = ''); }) : null, filled: true, fillColor: tc.surface, border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.md), borderSide: BorderSide.none)))),
        // Intrinsic height so the chips grow with the system font size rather
        // than clipping inside a fixed 44dp box.
        SingleChildScrollView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md), child: Row(children: List.generate(_categories.length, (i) {
          final sel = _selectedCategory == _categories[i];
          return Padding(padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs), child: FilterChip(label: Text(_categories[i]), selected: sel, onSelected: (_) => setState(() => _selectedCategory = _categories[i]), backgroundColor: tc.surface, selectedColor: tc.primarySurface, checkmarkColor: tc.primary, labelStyle: AppTypography.labelMedium.copyWith(color: sel ? tc.primaryText : tc.textSecondary), side: BorderSide.none, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.full))));
        }))),
        const SizedBox(height: AppSpacing.sm),
        _activitiesSection(tc),
        Expanded(child: FutureBuilder<List<NewsArticle>>(future: _newsFuture, builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          // A failure is its own answer, and a retryable one. Falling through
          // to 'No News' here is what made an unreachable server look like a
          // quiet news week.
          if (snapshot.hasError) {
            return RefreshIndicator(onRefresh: _onRefresh, child: ListView(children: [
              // minHeight, not a fixed height: this state carries a button as
              // well as the message, and a rigid fraction of a short screen
              // clips it. Asking for the space rather than insisting on it
              // lets it grow when the text or the system font does.
              ConstrainedBox(
                constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height * 0.4),
                child: AppEmptyState(
                  icon: Icons.cloud_off_rounded,
                  title: 'Could not load the news',
                  subtitle: _failureText(snapshot.error),
                  actionLabel: 'Try Again',
                  onAction: _onRefresh,
                ),
              ),
            ]));
          }
          final newsList = _filtered(snapshot.hasData ? snapshot.data! : []);
          if (newsList.isEmpty) return RefreshIndicator(onRefresh: _onRefresh, child: ListView(children: [SizedBox(height: MediaQuery.of(context).size.height * 0.4, child: AppEmptyState(icon: _searchQuery.isNotEmpty ? Icons.search_off_rounded : Icons.newspaper_rounded, title: _searchQuery.isNotEmpty ? 'No Results' : 'No News', subtitle: _searchQuery.isNotEmpty ? 'Try a different search term.' : 'Stay tuned for the latest updates.'))]));
          return RefreshIndicator(onRefresh: _onRefresh, child: ListView.builder(padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.xxxl), itemCount: newsList.length, itemBuilder: (context, i) {
            final news = newsList[i]; final date = DateFormat('MMM dd, yyyy').format(news.publishedDate);
            return Padding(padding: const EdgeInsets.only(bottom: AppSpacing.md), child: Material(color: tc.surface, borderRadius: BorderRadius.circular(AppRadius.lg), child: InkWell(onTap: () => _showDetails(news), borderRadius: BorderRadius.circular(AppRadius.lg), child: Container(padding: const EdgeInsets.all(AppSpacing.md), decoration: BoxDecoration(borderRadius: BorderRadius.circular(AppRadius.lg), boxShadow: AppElevation.subtle), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              ClipRRect(borderRadius: BorderRadius.circular(AppRadius.md), child: news.imageUrl.isNotEmpty ? Image.network(news.imageUrl, width: 80, height: 80, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _placeholder(tc)) : _placeholder(tc)),
              const SizedBox(width: AppSpacing.md),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(news.title, style: AppTypography.titleMedium.copyWith(color: tc.neutral100), maxLines: 2, overflow: TextOverflow.ellipsis), const SizedBox(height: AppSpacing.xs), Text('$date \u00b7 ${news.category}', style: AppTypography.caption.copyWith(color: tc.textSecondary)), const SizedBox(height: AppSpacing.sm), Text(news.content, style: AppTypography.bodySmall.copyWith(color: tc.neutral70), maxLines: 2, overflow: TextOverflow.ellipsis)])),
Icon(Icons.chevron_right, color: tc.neutral50, size: 20),
            ])))));
          }));
        })),
      ]),
    );
  }

  Widget _placeholder(ThemeColors tc) => Container(width: 80, height: 80, decoration: BoxDecoration(color: tc.neutral20, borderRadius: BorderRadius.circular(AppRadius.sm)), child: Icon(Icons.article_rounded, color: tc.primary, size: 32));

  /// The upcoming-activities strip that sits above the stories.
  ///
  /// Horizontal, so it costs the news a fixed band rather than however many
  /// activities happen to be scheduled. Hidden while a search is running: the
  /// member is looking for a story, and a row that ignores what they typed
  /// would read as a broken search.
  Widget _activitiesSection(ThemeColors tc) {
    if (_activities.isEmpty || _searchQuery.isNotEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.sm),
          child: Row(
            children: [
              Icon(Icons.event_available_rounded, size: 18, color: tc.primary),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text('Upcoming Activities',
                    style: AppTypography.titleMedium.copyWith(color: tc.neutral100)),
              ),
            ],
          ),
        ),
        SizedBox(
          // Scaled, not fixed. The cards are sized to their text, so a band
          // that ignores the system font setting is one that clips at the
          // first notch above default.
          height: 132 * _textScale(context),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            itemCount: _activities.length,
            itemBuilder: (context, i) => _activityCard(tc, _activities[i]),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
      ],
    );
  }

  /// How far the member has turned the system font up, capped so a very large
  /// setting stretches the band without swallowing the screen.
  double _textScale(BuildContext context) =>
      MediaQuery.textScaleFactorOf(context).clamp(1.0, 1.6);

  Widget _activityCard(ThemeColors tc, CampaignActivity a) {
    final start = DateTime.tryParse(a.scheduledAt);
    final end = a.hasEndDate ? DateTime.tryParse(a.endsAt) : null;
    final format = DateFormat('MMM dd');

    // One string rather than several widgets sharing a row, so a range can
    // ellipsize as a unit when the system font is scaled up instead of
    // overflowing the card.
    final date = start == null
        ? a.scheduledAt
        : end == null
            ? format.format(start)
            : '${format.format(start)} – ${format.format(end)}';

    return Container(
      width: 220 * _textScale(context),
      margin: const EdgeInsets.only(right: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: tc.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppElevation.subtle,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Still ellipsizing: a scaled-up font turns 'Aug 17 – Aug 21' into
          // more than the card's width whether or not anything sits beside it.
          Text(date,
              style: AppTypography.labelMedium.copyWith(color: tc.primary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
          const SizedBox(height: AppSpacing.xs),
          Text(a.title,
              style: AppTypography.titleMedium.copyWith(color: tc.neutral100),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
          const SizedBox(height: 2),
          if (a.typeLabel.isNotEmpty)
            Text(a.typeLabel,
                style: AppTypography.caption.copyWith(color: tc.textSecondary)),
          const Spacer(),
          if (a.where.isNotEmpty)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.place_outlined, size: 14, color: tc.neutral50),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(a.where,
                      style: AppTypography.caption.copyWith(color: tc.textSecondary),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
        ],
      ),
    );
  }
}