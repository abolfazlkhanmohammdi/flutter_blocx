import 'package:flutter_blocx/flutter_blocx.dart';
import 'package:flutter_blocx/list_widget.dart';
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
    final tagColor = item.noteTag?.colorArgb != null ? Color(item.noteTag!.colorArgb!) : cs.primary;
    final userName = item.user?.displayName ?? '';
    final avatarUrl = item.user?.avatarUrl ?? '';
    final tagName = item.noteTag?.name ?? '';

    return Card(
      color: isHighlighted(context)
          ? Colors.blue.shade100
          : isSelected(context)
          ? cs.primaryContainer
          : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => toggleExpansion(context),
        onLongPress: () => isHighlighted(context) ? clearHighlightedItem(context) : highlightItem(context),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          children: [
            ListTile(
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
                      maxLines: 5,
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
                ],
              ),
            ),
            AnimatedSize(
              duration: Duration(milliseconds: 300),
              child: isExpanded(context) ? noteActionRow(context) : SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  String _fmtShort(DateTime d) {
    final x = d.toLocal();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${x.year}-${two(x.month)}-${two(x.day)} ${two(x.hour)}:${two(x.minute)}';
  }

  Widget noteActionRow(BuildContext context) {
    final selected = isSelected(context);
    final highlighted = isHighlighted(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _ActionBtn(
            isInProgress: isHighlighted(context),
            tooltip: highlighted ? 'Highlighted' : 'Highlight',
            icon: highlighted ? Icons.highlight_off : Icons.highlight_alt_outlined,
            label: highlighted ? 'Highlighted' : 'Highlight',
            onPressed: () {
              highlighted ? clearHighlightedItem(context) : highlightItem(context);
            },
          ),
          _ActionBtn(
            isInProgress: isBeingSelected(context),
            tooltip: selected ? 'Deselect' : 'Select',
            icon: selected ? Icons.check_circle : Icons.radio_button_unchecked,
            label: selected ? 'Deselect' : 'Select',
            onPressed: () {
              // Uses blocx's selection toggler
              toggleSelection(context);
            },
          ),
          _ActionBtn(
            backgroundColor: Colors.red,
            isInProgress: isBeingRemoved(context),
            tooltip: 'Delete',
            icon: Icons.delete_outline,
            label: isBeingRemoved(context) ? 'Deleting' : 'Delete',
            foregroundColor: Colors.white,
            onPressed: () => removeItem(context),
          ),
        ],
      ),
    );
  }

  @override
  ConfirmActionOptions get confirmDeleteOptions => ConfirmActionOptions(
    title: 'Delete Note ${item.title}?',
    question: 'Are you sure you want to delete this note?',
    confirmText: 'Delete',
    cancelText: 'Cancel',
    deleteWord: "Delete",
    imageUrl: item.user!.avatarUrl,
  );
}

class _ActionBtn extends BlocxStatelessWidget {
  const _ActionBtn({
    required this.icon,
    required this.label,
    required this.onPressed,
    required this.isInProgress,
    this.tooltip,
    this.foregroundColor,
    this.backgroundColor,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final String? tooltip;
  final Color? foregroundColor;
  final Color? backgroundColor;
  final bool isInProgress;
  @override
  Widget build(BuildContext context) {
    final btn = FilledButton.icon(
      icon: isInProgress
          ? SizedBox.square(
              dimension: 16,
              child: CircularProgressIndicator(color: colorScheme(context).onPrimary),
            )
          : Icon(icon, size: 18),
      label: Text(label, style: textTheme(context).bodyMedium?.copyWith(color: Colors.white)),
      style: OutlinedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: const StadiumBorder(),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
      ),
      onPressed: isInProgress ? null : onPressed,
    );

    return tooltip == null ? btn : Tooltip(message: tooltip!, child: btn);
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
          Expanded(
            child: Text(name, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.labelSmall),
          ),
        ],
      ),
    );
  }
}
