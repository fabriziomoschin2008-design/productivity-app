import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class MediaCard extends StatefulWidget {
  final String title;
  final String? posterUrl;
  final String? year;
  final double? rating;
  final String? subtitle; // genres
  final List<int>? watchedSeasons; // null for movies
  final bool inOriginalLanguage;
  final VoidCallback onTap;

  const MediaCard({
    super.key,
    required this.title,
    required this.onTap,
    this.posterUrl,
    this.year,
    this.rating,
    this.subtitle,
    this.watchedSeasons,
    this.inOriginalLanguage = false,
  });

  @override
  State<MediaCard> createState() => _MediaCardState();
}

class _MediaCardState extends State<MediaCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _hovered ? 1.03 : 1.0,
          duration: const Duration(milliseconds: 150),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: AspectRatio(
              aspectRatio: 2 / 3,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _Poster(url: widget.posterUrl, title: widget.title),
                  // Bottom gradient
                  const _BottomGradient(),
                  // Bottom info
                  Positioned(
                    left: 8,
                    right: 8,
                    bottom: 8,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.watchedSeasons != null)
                          _SeasonBadges(widget.watchedSeasons!),
                        Text(
                          widget.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            shadows: [
                              Shadow(color: Colors.black54, blurRadius: 4)
                            ],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (widget.year != null && widget.year!.isNotEmpty)
                          Text(
                            widget.year!,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 10,
                            ),
                          ),
                      ],
                    ),
                  ),
                  // Hover overlay
                  AnimatedOpacity(
                    opacity: _hovered ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 150),
                    child: _HoverOverlay(
                      rating: widget.rating,
                      subtitle: widget.subtitle,
                      inOriginalLanguage: widget.inOriginalLanguage,
                    ),
                  ),
                  // OL badge
                  if (widget.inOriginalLanguage)
                    Positioned(
                      top: 6,
                      left: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withValues(alpha: 0.93),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.language_rounded,
                                color: Colors.white, size: 9),
                            SizedBox(width: 2),
                            Text('OL',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 8,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.3)),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Poster extends StatelessWidget {
  final String? url;
  final String title;
  const _Poster({required this.url, required this.title});

  @override
  Widget build(BuildContext context) {
    if (url != null) {
      return Image.network(
        url!,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _Placeholder(title: title),
        loadingBuilder: (_, child, progress) {
          if (progress == null) return child;
          return _Placeholder(title: title);
        },
      );
    }
    return _Placeholder(title: title);
  }
}

class _Placeholder extends StatelessWidget {
  final String title;
  const _Placeholder({required this.title});

  @override
  Widget build(BuildContext context) {
    final letter = title.isNotEmpty ? title[0].toUpperCase() : '?';
    return Container(
      color: AppColors.surfaceElevated,
      child: Center(
        child: Text(letter,
            style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.w700,
                color: AppColors.primary.withValues(alpha: 0.5))),
      ),
    );
  }
}

class _BottomGradient extends StatelessWidget {
  const _BottomGradient();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: const [0.5, 1.0],
            colors: [Colors.transparent, Colors.black.withValues(alpha: 0.80)],
          ),
        ),
      ),
    );
  }
}

class _HoverOverlay extends StatelessWidget {
  final double? rating;
  final String? subtitle;
  final bool inOriginalLanguage;
  const _HoverOverlay(
      {this.rating, this.subtitle, required this.inOriginalLanguage});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.30),
      alignment: Alignment.topLeft,
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (rating != null)
            Row(
              children: [
                const Icon(Icons.star_rounded, color: Colors.amber, size: 13),
                const SizedBox(width: 3),
                Text(rating!.toStringAsFixed(1),
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          if (subtitle != null && subtitle!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(subtitle!,
                style: const TextStyle(color: Colors.white70, fontSize: 10),
                maxLines: 2,
                overflow: TextOverflow.ellipsis),
          ],
        ],
      ),
    );
  }
}

class _SeasonBadges extends StatelessWidget {
  final List<int> seasons;
  const _SeasonBadges(this.seasons);

  @override
  Widget build(BuildContext context) {
    if (seasons.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Wrap(
        spacing: 3,
        runSpacing: 2,
        children: seasons
            .map((s) => Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Text('S$s',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w700)),
                ))
            .toList(),
      ),
    );
  }
}

// ─── Status label helpers ────────────────────────────────────────────────────

String statusLabel(String status) => switch (status) {
      'watched' => 'Visto',
      'want_to_watch' => 'Da vedere',
      'watching' => 'In corso',
      _ => status,
    };

Color statusColor(String status) => switch (status) {
      'watched' => AppColors.income,
      'want_to_watch' => AppColors.accent,
      'watching' => AppColors.primary,
      _ => AppColors.textSecondary,
    };

// ─── Rating stars ────────────────────────────────────────────────────────────

class StarRating extends StatelessWidget {
  final int? value;
  final ValueChanged<int> onChanged;

  const StarRating({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final filled = value != null && i < value!;
        return GestureDetector(
          onTap: () => onChanged(value == i + 1 ? 0 : i + 1),
          child: Padding(
            padding: const EdgeInsets.only(right: 2),
            child: Icon(
              filled ? Icons.star_rounded : Icons.star_outline_rounded,
              color: filled ? Colors.amber : AppColors.textDisabled,
              size: 20,
            ),
          ),
        );
      }),
    );
  }
}

// ─── Filter chip row ─────────────────────────────────────────────────────────

class StatusFilterRow extends StatelessWidget {
  final String current;
  final ValueChanged<String> onChanged;

  const StatusFilterRow(
      {super.key, required this.current, required this.onChanged});

  static const _filters = {
    'all': 'Tutti',
    'watched': 'Visti',
    'watching': 'In corso',
    'want_to_watch': 'Da vedere',
  };

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _filters.entries.map((e) {
          final active = current == e.key;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(e.value,
                  style: AppTextStyles.label.copyWith(
                      color: active ? Colors.white : AppColors.textSecondary)),
              selected: active,
              onSelected: (_) => onChanged(e.key),
              selectedColor: AppColors.primary,
              backgroundColor: AppColors.surfaceElevated,
              side: const BorderSide(color: AppColors.border),
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            ),
          );
        }).toList(),
      ),
    );
  }
}
