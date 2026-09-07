import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/result_parser.dart';
import '../data/analysis_result.dart';

class ResultCard extends StatelessWidget {
  final AnalysisResult result;
  final VoidCallback onSave;
  final VoidCallback onRetry;

  const ResultCard({
    super.key,
    required this.result,
    required this.onSave,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _CategoryBadge(category: result.category),
                const Spacer(),
                _ConfidenceBadge(confidence: result.confidence),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              result.description,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            if (result.productLinks.isNotEmpty) ...[
              const SizedBox(height: 16),
              const _SectionHeader(
                title: 'Buy Links',
                icon: Icons.shopping_bag_outlined,
              ),
              ...result.productLinks.map(
                (link) => _LinkTile(
                  title: link.title,
                  subtitle: link.price,
                  source: link.source,
                  url: link.url,
                ),
              ),
            ],
            if (result.streamingLinks.isNotEmpty) ...[
              const SizedBox(height: 16),
              const _SectionHeader(
                title: 'Watch Now',
                icon: Icons.play_circle_outline,
              ),
              ...result.streamingLinks.map(
                (link) => _LinkTile(
                  title: link.title,
                  subtitle: link.type,
                  source: link.platform,
                  url: link.url,
                ),
              ),
            ],
            if (result.tags.isNotEmpty) ...[
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: result.tags
                    .map((tag) => Chip(
                          label: Text(tag),
                          visualDensity: VisualDensity.compact,
                        ))
                    .toList(),
              ),
            ],
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: onSave,
                    icon: const Icon(Icons.bookmark_add_outlined),
                    label: const Text('Save'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryBadge extends StatelessWidget {
  final String category;
  const _CategoryBadge({required this.category});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        ResultParser.categoryLabel(category),
        style: const TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _ConfidenceBadge extends StatelessWidget {
  final double confidence;
  const _ConfidenceBadge({required this.confidence});

  @override
  Widget build(BuildContext context) {
    final color = confidence >= 0.7
        ? AppColors.success
        : confidence >= 0.4
            ? Colors.orange
            : AppColors.error;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        ResultParser.confidenceLabel(confidence),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ],
      ),
    );
  }
}

class _LinkTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String source;
  final String url;

  const _LinkTile({
    required this.title,
    this.subtitle,
    required this.source,
    required this.url,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: AppColors.primary.withOpacity(0.1),
        child: Text(
          source.isEmpty ? '?' : source[0].toUpperCase(),
          style: const TextStyle(color: AppColors.primary),
        ),
      ),
      title: Text(title, maxLines: 2, overflow: TextOverflow.ellipsis),
      subtitle: subtitle == null
          ? null
          : Text(subtitle, style: const TextStyle(fontSize: 12)),
      trailing: const Icon(Icons.open_in_new, size: 18),
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Opening: $source')),
        );
        // TODO: Launch URL
      },
    );
  }
}