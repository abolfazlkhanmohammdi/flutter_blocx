import 'package:blocx_flutter/list_widget.dart';
import 'package:example/src/screens/note_tags/data/models/note_tag.dart';
import 'package:example/src/screens/notes/presentation/notes_screen.dart';
import 'package:example/src/screens/users/data/models/user.dart';
import 'package:flutter/material.dart';

class NoteTagCard extends BlocxCollectionWidget<NoteTag, User> {
  final User user;
  const NoteTagCard({super.key, required this.user, required super.item, this.onEdit});

  final VoidCallback? onEdit;

  @override
  Widget buildContent(BuildContext context, NoteTag item) {
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    final canDelete = bloc(context).isDeletable;
    final color = Color(item.colorArgb ?? cs.primary.value);

    return Card(
      color: isSelected(context) ? cs.primaryContainer : Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (context) => NotesScreen(payload: (item, user)))),
        onLongPress: () => isHighlighted(context) ? clearHighlightedItem(context) : highlightItem(context),
        borderRadius: BorderRadius.circular(12),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          leading: _Swatch(color: color),
          title: Text(item.name, style: t.titleSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
          subtitle: Text(
            'Updated ${item.updatedAt.toLocal()}',
            style: t.bodySmall?.copyWith(color: cs.onSurfaceVariant),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
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
}

class _Swatch extends StatelessWidget {
  const _Swatch({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    final border = Theme.of(context).colorScheme.outlineVariant;
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: border),
      ),
    );
  }
}
