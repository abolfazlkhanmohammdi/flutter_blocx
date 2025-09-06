import 'package:flutter_blocx/list_widget.dart';
import 'package:example/src/screens/note_tags/data/models/note_tag.dart';
import 'package:example/src/screens/note_tags/data/models/note_tag_form_payload.dart';
import 'package:example/src/screens/note_tags/presentation/form/note_tag_form.dart';
import 'package:example/src/screens/notes/presentation/notes_screen.dart';
import 'package:example/src/screens/users/data/models/user.dart';
import 'package:flutter/material.dart';

class NoteTagCard extends BlocxCollectionWidget<NoteTag, User> {
  final User user;
  const NoteTagCard({super.key, required this.user, required super.item});

  @override
  Widget buildContent(BuildContext context, NoteTag item) {
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    final canDelete = bloc(context).isDeletable;
    final color = Color(item.colorArgb ?? cs.primary.value);

    return Card(
      color: isHighlighted(context) || isSelected(context)
          ? cs.primaryContainer
          : Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: isBeingRemoved(context)
            ? null
            : () => Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (context) => NotesScreen(payload: (item, user)))),
        onLongPress: () => isHighlighted(context) ? clearHighlightedItem(context) : highlightItem(context),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: _Swatch(color: color),
                title: Text(item.name, style: t.titleSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                subtitle: Text(
                  'Updated ${item.updatedAt.toLocal()}',
                  style: t.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: isSelected(context) ? Icon(Icons.check_circle, color: cs.primary) : null,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.tonalIcon(
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit'),
                      onPressed: () {
                        launchEditFlow(context);
                      },
                    ),
                  ),
                  if (canDelete) const SizedBox(width: 8),
                  if (canDelete)
                    Expanded(
                      child: FilledButton.icon(
                        icon: isBeingRemoved(context)
                            ? SizedBox.square(
                                dimension: 16,
                                child: CircularProgressIndicator(color: Colors.red),
                              )
                            : const Icon(Icons.delete, size: 16),
                        label: Text(
                          isBeingRemoved(context) ? "Deleting..." : 'Delete',
                          style: textTheme(
                            context,
                          ).titleSmall?.copyWith(color: isBeingRemoved(context) ? Colors.red : Colors.white),
                        ),
                        style: FilledButton.styleFrom(backgroundColor: cs.error, foregroundColor: cs.onError),
                        onPressed: isBeingRemoved(context) ? null : () => removeItem(context),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  bool get confirmBeforeDelete => false;

  Future<void> launchEditFlow(BuildContext context) async {
    var result = await showModalBottomSheet<NoteTag>(
      backgroundColor: Colors.white,
      isScrollControlled: true,
      context: context,
      builder: (_) => NoteTagForm(
        payload: NoteTagFormPayload(userId: user.id, toBeEdited: item),
      ),
    );
    if (result == null) return;
    updateItem(context, result);
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
