import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/result_parser.dart';
import '../data/analysis_result.dart';

class ResultCard extends StatefulWidget {
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
  State<ResultCard> createState() => _ResultCardState();
}

class _ResultCardState extends State<ResultCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  AnalysisResult get _r => widget.result;
  bool get _isProduct => _r.category == 'product';
  bool get _hasLinks =>
      _r.productLinks.isNotEmpty || _r.streamingLinks.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE9ECEF)),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.06),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _GradientAccent(isProduct: _isProduct),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _BadgesRow(
                      category: _r.category,
                      confidence: _r.confidence,
                    ),
                    const SizedBox(height: 14),
                    Text(
                      _r.description,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                      ),
                    ),
                    if (_r.tags.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      _TagsWrap(tags: _r.tags),
                    ],
                    if (_hasLinks) ...[
                      const SizedBox(height: 20),
                      const Divider(height: 1),
                      const SizedBox(height: 16),
                      if (_r.productLinks.isNotEmpty) ...[
                        _SectionHeader(
                          title: 'Buy',
                          icon: Icons.shopping_bag_outlined,
                          color: AppColors.primary,
                        ),
                        const SizedBox(height: 8),
                        ..._r.productLinks.map(
                          (link) => _PrimaryActionTile(
                            label: 'Buy on ${link.source}',
                            price: link.price,
                            url: link.url,
                            isProduct: true,
                            source: link.source,
                          ),
                        ),
                      ],
                      if (_r.streamingLinks.isNotEmpty) ...[
                        if (_r.productLinks.isNotEmpty)
                          const SizedBox(height: 12),
                        _SectionHeader(
                          title: 'Watch',
                          icon: Icons.play_circle_outline,
                          color: AppColors.secondary,
                        ),
                        const SizedBox(height: 8),
                        ..._r.streamingLinks.map(
                          (link) => _PrimaryActionTile(
                            label: '${_streamingVerb(link.type)} on ${link.platform}',
                            price: null,
                            url: link.url,
                            isProduct: false,
                            source: link.platform,
                            subtitle: link.type,
                          ),
                        ),
                      ],
                    ],
                    const SizedBox(height: 20),
                    _SecondaryActionsRow(
                      saved: _saved,
                      onSave: () {
                        setState(() => _saved = true);
                        HapticFeedback.mediumImpact();
                        widget.onSave();
                      },
                      onShare: () => _shareResult(context),
                      onRetry: widget.onRetry,
                    ),
                    const SizedBox(height: 12),
                    _ProcessingFooter(processingTimeMs: _r.processingTimeMs),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _streamingVerb(String type) {
    switch (type) {
      case 'rent':
        return 'Rent';
      case 'buy':
        return 'Buy';
      default:
        return 'Stream';
    }
  }

  Future<void> _shareResult(BuildContext context) async {
    final text = _r.description;
    await Clipboard.setData(ClipboardData(text: text));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Description copied to clipboard'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }
}

// ─── Gradient accent strip ──────────────────────────────────────────────────

class _GradientAccent extends StatelessWidget {
  final bool isProduct;
  const _GradientAccent({required this.isProduct});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 4,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        gradient: LinearGradient(
          colors: isProduct
              ? [AppColors.primary, AppColors.primary.withOpacity(0.5)]
              : [AppColors.secondary, AppColors.primary],
        ),
      ),
    );
  }
}

// ─── Badges row ─────────────────────────────────────────────────────────────

class _BadgesRow extends StatelessWidget {
  final String category;
  final double confidence;
  const _BadgesRow({required this.category, required this.confidence});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _CategoryBadge(category: category),
        const SizedBox(width: 8),
        _ConfidenceBadge(confidence: confidence),
      ],
    );
  }
}

class _CategoryBadge extends StatelessWidget {
  final String category;
  const _CategoryBadge({required this.category});

  @override
  Widget build(BuildContext context) {
    final (icon, label) = switch (category) {
      'product' => (Icons.shopping_bag_outlined, 'Product'),
      'movie' => (Icons.movie_outlined, 'Movie'),
      'show' => (Icons.tv_outlined, 'TV Show'),
      'restaurant' => (Icons.restaurant_outlined, 'Restaurant'),
      'location' => (Icons.location_on_outlined, 'Location'),
      _ => (Icons.help_outline, 'Content'),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.primary),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
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

// ─── Tags ───────────────────────────────────────────────────────────────────

class _TagsWrap extends StatelessWidget {
  final List<String> tags;
  const _TagsWrap({required this.tags});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: tags
          .map(
            (tag) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.textSecondary.withOpacity(0.07),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                tag,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

// ─── Section header ─────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  const _SectionHeader({
    required this.title,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 6),
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}

// ─── Primary action tile ────────────────────────────────────────────────────

class _PrimaryActionTile extends StatelessWidget {
  final String label;
  final String? price;
  final String url;
  final bool isProduct;
  final String source;
  final String? subtitle;

  const _PrimaryActionTile({
    required this.label,
    this.price,
    required this.url,
    required this.isProduct,
    required this.source,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () async {
            final uri = Uri.parse(url);
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE9ECEF)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: (isProduct ? AppColors.primary : AppColors.secondary)
                      .withOpacity(0.1),
                  child: Text(
                    source.isEmpty ? '?' : source[0].toUpperCase(),
                    style: TextStyle(
                      color: isProduct ? AppColors.primary : AppColors.secondary,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (subtitle != null)
                        Text(
                          subtitle!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                    ],
                  ),
                ),
                if (price != null)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      price!,
                      style: const TextStyle(
                        color: AppColors.success,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                const SizedBox(width: 10),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: AppColors.textSecondary.withOpacity(0.4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Secondary actions row ──────────────────────────────────────────────────

class _SecondaryActionsRow extends StatelessWidget {
  final bool saved;
  final VoidCallback onSave;
  final VoidCallback onShare;
  final VoidCallback onRetry;
  const _SecondaryActionsRow({
    required this.saved,
    required this.onSave,
    required this.onShare,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ActionButton(
            icon: saved ? Icons.bookmark : Icons.bookmark_outline,
            label: saved ? 'Saved' : 'Save',
            onTap: saved ? null : onSave,
            isActive: saved,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _ActionButton(
            icon: Icons.share_outlined,
            label: 'Share',
            onTap: onShare,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _ActionButton(
            icon: Icons.refresh,
            label: 'Try another',
            onTap: onRetry,
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool isActive;

  const _ActionButton({
    required this.icon,
    required this.label,
    this.onTap,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;

    return Material(
      color: isActive
          ? AppColors.primary.withOpacity(0.08)
          : AppColors.textSecondary.withOpacity(0.05),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 20,
                color: isActive
                    ? AppColors.primary
                    : enabled
                        ? AppColors.textPrimary
                        : AppColors.textSecondary.withOpacity(0.4),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: isActive
                      ? AppColors.primary
                      : enabled
                          ? AppColors.textPrimary
                          : AppColors.textSecondary.withOpacity(0.4),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Processing footer ──────────────────────────────────────────────────────

class _ProcessingFooter extends StatelessWidget {
  final double processingTimeMs;
  const _ProcessingFooter({required this.processingTimeMs});

  @override
  Widget build(BuildContext context) {
    final secs = (processingTimeMs / 1000).toStringAsFixed(1);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.bolt_outlined,
          size: 14,
          color: AppColors.textSecondary.withOpacity(0.4),
        ),
        const SizedBox(width: 4),
        Text(
          'Processed in ${secs}s',
          style: TextStyle(
            color: AppColors.textSecondary.withOpacity(0.5),
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}
