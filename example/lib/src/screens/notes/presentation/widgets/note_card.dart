import 'package:blocx_flutter/list_widget.dart';
import 'package:example/src/screens/note_tags/data/models/note_tag.dart';
import 'package:example/src/screens/notes/data/models/note.dart';
import 'package:example/src/screens/users/data/models/user.dart';
import 'package:flutter/material.dart';

class NoteCard extends BlocxCollectionWidget<Note, (NoteTag, User)> {
  const NoteCard({super.key, required super.item, this.onEdit, this.onOpen});

  final VoidCallback? onEdit;
  final VoidCallback? onOpen;

  @override
  Widget buildContent(BuildContext context, Note item) {
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    final canDelete = bloc(context).isDeletable;
    final tagColor = Color((item.noteTag?.colorArgb) ?? cs.primary.value);
    final userName = item.user?.displayName ?? '';
    final avatarUrl = item.user?.avatarUrl ?? '';
    final tagName = item.noteTag?.name ?? '';

    return Card(
      color: isSelected(context) ? cs.primaryContainer : Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onOpen ?? () => isSelected(context) ? deselectItem(context) : selectItem(context),
        onLongPress: () => isHighlighted(context) ? clearHighlightedItem(context) : highlightItem(context),
        borderRadius: BorderRadius.circular(12),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          leading: _Avatar(
            titleFallback: item.title,
            name: userName.isNotEmpty ? userName : null,
            url: avatarUrl.isNotEmpty ? avatarUrl : null,
            tint: tagColor,
          ),
          title: Text(item.title, style: t.titleSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if ((item.content ?? '').trim().isNotEmpty)
                Text(
                  item.content!.trim(),
                  style: t.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  if (userName.isNotEmpty)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.person_outline, size: 14),
                        const SizedBox(width: 4),
                        Text(userName, style: t.labelSmall),
                      ],
                    ),
                  if (userName.isNotEmpty && tagName.isNotEmpty) Text('•', style: t.labelSmall),
                  if (tagName.isNotEmpty) _TagChip(name: tagName, color: tagColor),
                  Opacity(
                    opacity: 0.8,
                    child: Text('Updated ${_fmtShort(item.updatedAt)}', style: t.labelSmall),
                  ),
                ],
              ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (onEdit != null)
                IconButton(
                  tooltip: 'Edit',
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    highlightItem(context);
                    onEdit!.call();
                  },
                ),
              if (canDelete)
                IconButton(
                  tooltip: 'Delete',
                  icon: const Icon(Icons.delete),
                  color: cs.error,
                  onPressed: () => removeItem(context),
                ),
              if (isSelected(context))
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Icon(Icons.check_circle, color: cs.primary),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _fmtShort(DateTime d) {
    final x = d.toLocal();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${x.year}-${two(x.month)}-${two(x.day)} ${two(x.hour)}:${two(x.minute)}';
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.titleFallback, this.name, this.url, required this.tint});

  final String titleFallback;
  final String? name;
  final String? url;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    final hasUrl = (url ?? '').isNotEmpty;
    final label = (name ?? titleFallback).trim();
    return CircleAvatar(
      radius: 22,
      backgroundColor: tint.withAlpha(50),
      foregroundColor: Theme.of(context).colorScheme.onSecondaryContainer,
      backgroundImage: hasUrl ? NetworkImage(url!) : null,
      child: hasUrl ? null : Text(_initials(label), style: const TextStyle(fontWeight: FontWeight.w600)),
    );
  }

  String _initials(String s) {
    final parts = s.split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      final t = parts.first;
      return (t.length >= 2 ? '${t[0]}${t[1]}' : t[0]).toUpperCase();
    }
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip({required this.name, required this.color});
  final String name;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(50),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withAlpha(80)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(name, style: Theme.of(context).textTheme.labelSmall),
        ],
      ),
    );
  }
}
