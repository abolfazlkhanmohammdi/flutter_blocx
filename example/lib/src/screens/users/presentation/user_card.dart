import 'package:flutter_blocx/flutter_blocx.dart';
import 'package:flutter_blocx/list_widget.dart';
import 'package:example/src/screens/note_tags/presentation/note_tags_screen.dart';
import 'package:example/src/screens/users/data/models/user.dart';
import 'package:flutter/material.dart';

class UserCard extends BlocxCollectionWidget<User, dynamic> {
  const UserCard({super.key, required super.item, this.onEdit});

  final VoidCallback? onEdit;

  @override
  Widget buildContent(BuildContext context, User item) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final canDelete = bloc(context).isDeletable;
    final canHighlight = bloc(context).isHighlightable;

    return Card(
      color: isHighlighted(context)
          ? Colors.green.shade100
          : isBeingRemoved(context)
          ? Colors.red.shade100
          : isSelected(context)
          ? cs.primaryContainer
          : Theme.of(context).cardColor,
      shape: RoundedSuperellipseBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () =>
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => NoteTagsScreen(payload: item))),
        onLongPress: () => isSelected(context) ? deselectItem(context) : selectItem(context),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: LayoutBuilder(
            builder: (context, box) {
              final side = box.biggest.shortestSide;
              final radius = (side * 0.22).clamp(20.0, 36.0).toDouble();

              return Column(
                spacing: 4,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                    children: [
                      Center(
                        child: Hero(
                          tag: "user-${item.id}",
                          child: _Avatar(url: item.avatarUrl, name: item.displayName, radius: radius),
                        ),
                      ),
                      if (isSelected(context))
                        Positioned(
                          right: 0,
                          top: 0,
                          left: 0,
                          bottom: 0,

                          child: CircleAvatar(
                            backgroundColor: cs.secondary.withAlpha(160),
                            child: Icon(Icons.check_circle, size: 24, color: cs.primary),
                          ),
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
                  Center(child: _StatusPill(active: item.isActive)),
                  const SizedBox(height: 10),
                  if (onEdit != null)
                    FilledButton.tonalIcon(
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit'),
                      onPressed: () {
                        highlightItem(context);
                        onEdit!.call();
                      },
                    ),
                  if (onEdit != null && canDelete) const SizedBox(width: 8),
                  if (canDelete)
                    FilledButton.icon(
                      icon: isBeingRemoved(context)
                          ? SizedBox.square(
                              dimension: 16,
                              child: CircularProgressIndicator(color: Colors.red),
                            )
                          : const Icon(Icons.delete),
                      label: Text(
                        isBeingRemoved(context) ? "Deleting" : 'Delete',
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: isBeingRemoved(context) ? Colors.red : Colors.white,
                        ),
                      ),
                      style: FilledButton.styleFrom(backgroundColor: cs.error, foregroundColor: cs.onError),
                      onPressed: isBeingRemoved(context) ? null : () => removeItem(context),
                    ),
                  if (canHighlight)
                    FilledButton.icon(
                      icon: const Icon(Icons.highlight),
                      label: const Text('highlight'),
                      style: FilledButton.styleFrom(
                        backgroundColor: cs.primary,
                        foregroundColor: cs.onPrimary,
                      ),
                      onPressed: () => highlightItem(context),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  ConfirmActionOptions get confirmDeleteOptions => ConfirmActionOptions(
    title: "Delete ${item.displayName}",
    question: "Are you sure you want to delete the user ${item.displayName}?",
    imageUrl: item.avatarUrl,
  );
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
    final parts = s.trim().split(RegExp(r'\s+'));
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
