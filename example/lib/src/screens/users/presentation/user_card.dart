import 'package:blocx_flutter/list_widget.dart';
import 'package:example/src/screens/users/data/models/user.dart';
import 'package:flutter/material.dart';

/// Grid-ready user tile.
/// - Nice in 2–4 column grids
/// - Optional selection badge
class UserCard extends BlocxCollectionWidget<User, dynamic> {
  const UserCard({super.key, required super.item});

  @override
  Widget buildContent(BuildContext context, User item) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Card(
      color: isSelected(context) ? cs.primaryContainer : Theme.of(context).cardColor,
      shape: RoundedSuperellipseBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: LayoutBuilder(
            builder: (context, box) {
              final side = box.biggest.shortestSide;
              final radius = (side * 0.22).clamp(20.0, 36.0);

              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                    children: [
                      Center(
                        child: _Avatar(
                          url: item.avatarUrl,
                          name: item.displayName,
                          radius: radius.toDouble(),
                        ),
                      ),
                      if (isSelected(context))
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Icon(Icons.check_circle, size: 18, color: cs.primary),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    item.displayName,
                    style: t.titleSmall,
                    maxLines: 1,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (item.email.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Opacity(
                      opacity: 0.75,
                      child: Text(
                        item.email,
                        style: t.bodySmall,
                        maxLines: 1,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  _StatusPill(active: item.isActive),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  void onLongPress() {}

  void onTap() {}
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.url, required this.name, required this.radius});

  final String? url;
  final String name;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final bg = Theme.of(context).colorScheme.secondaryContainer;
    final fg = Theme.of(context).colorScheme.onSecondaryContainer;
    final hasUrl = (url ?? '').isNotEmpty;

    return CircleAvatar(
      radius: radius,
      backgroundColor: bg,
      foregroundColor: fg,
      backgroundImage: hasUrl ? NetworkImage(url!) : null,
      child: hasUrl ? null : Text(_initials(name), style: const TextStyle(fontWeight: FontWeight.w600)),
    );
  }

  String _initials(String s) {
    final parts = s.trim().split(RegExp(r'\\s+'));
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      final t = parts.first;
      return (t.isNotEmpty ? t.characters.take(2).toString() : '?').toUpperCase();
    }
    return (parts.first.characters.first + parts.last.characters.first).toUpperCase();
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.active});
  final bool active;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bg = active ? cs.primaryContainer : cs.surfaceContainerHighest;
    final fg = active ? cs.onPrimaryContainer : cs.onSurfaceVariant;
    final label = active ? 'Active' : 'Inactive';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: fg, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(label, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: fg)),
        ],
      ),
    );
  }
}
