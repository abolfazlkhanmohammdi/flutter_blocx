import 'package:flutter_blocx/list_widget.dart';
import 'package:example/src/screens/note_tags/bloc/note_tags_bloc.dart';
import 'package:example/src/screens/note_tags/data/models/note_tag.dart';
import 'package:example/src/screens/note_tags/data/models/note_tag_form_payload.dart';
import 'package:example/src/screens/note_tags/presentation/form/note_tag_form.dart';
import 'package:example/src/screens/note_tags/presentation/widgets/note_tag_card.dart';
import 'package:example/src/screens/users/data/models/user.dart';
import 'package:flutter/material.dart';

class NoteTagsScreen extends CollectionWidget<User> {
  const NoteTagsScreen({super.key, required super.payload});

  @override
  State<NoteTagsScreen> createState() => _NoteTagsScreenState();
}

class _NoteTagsScreenState extends CollectionWidgetState<NoteTagsScreen, NoteTag, User>
    with HideOnScrollFabMixin {
  _NoteTagsScreenState() : super(bloc: NoteTagsBloc());

  @override
  Widget itemBuilder(BuildContext context, NoteTag item) {
    return NoteTagCard(item: item, user: payload!, key: ValueKey(item));
  }

  @override
  bool get wrapInScaffold => true;

  @override
  Scaffold scaffoldWidget(BuildContext context, Widget body) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        titleSpacing: 8,
        leadingWidth: 32,
        title: Row(
          children: [
            Hero(
              tag: "user-${payload!.id}",
              child: Container(
                margin: EdgeInsets.all(8),
                child: CircleAvatar(foregroundImage: NetworkImage(payload!.avatarUrl!)),
              ),
            ),
            Expanded(child: Text("Note tags for '${payload!.displayName}'", style: textTheme.bodyMedium)),
          ],
        ),
      ),
      body: NotificationListener<UserScrollNotification>(onNotification: onScrollNotification, child: body),
      floatingActionButton: getFloatingActionButton(context),
    );
  }

  @override
  Future<void> onFabPressed(data) async {
    var result = await showModalBottomSheet<NoteTag>(
      context: context,
      builder: (_) => NoteTagForm(payload: NoteTagFormPayload(userId: payload!.id)),
    );
    if (result == null) return;
    addToList(result);
  }

  @override
  CollectionInput get settings => CollectionInput(
    type: CollectionWidgetStateType.animatedList,
    options: AnimatedInfiniteListOptions.defaultOptions(),
  );
}
