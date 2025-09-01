import 'package:blocx_core/blocx_core.dart';
import 'package:blocx_flutter/list_widget.dart';
import 'package:example/src/screens/note_tags/data/models/note_tag.dart';
import 'package:example/src/screens/notes/bloc/notes_bloc.dart';
import 'package:example/src/screens/notes/data/models/note.dart';
import 'package:example/src/screens/notes/presentation/widgets/note_card.dart';
import 'package:example/src/screens/users/data/models/user.dart';
import 'package:flutter/material.dart';

class NotesScreen extends ListWidget<(NoteTag, User)> {
  const NotesScreen({super.key, super.payload});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends CollectionWidgetState<NotesScreen, Note, (NoteTag, User)> {
  _NotesScreenState() : super(bloc: NotesBloc());

  @override
  Widget itemBuilder(BuildContext context, Note item) {
    return NoteCard(item: item);
  }

  @override
  bool get wrapInScaffold => true;

  @override
  Scaffold scaffoldWidget(BuildContext context, Widget body) {
    return Scaffold(
      appBar: AppBar(leadingWidth: 40, titleSpacing: 4, title: appBarTitle(context)),
      body: body,
    );
  }

  @override
  Widget? topWidget(BuildContext context, ListState<Note> state) {
    return Column(
      children: [
        TextButton(
          onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => NotesScreen())),
          child: Text("show all notes"),
        ),
      ],
    );
  }

  appBarTitle(BuildContext context) {
    if (payload == null) {
      return Text('Notes');
    }
    return Text(
      "Notes for ${payload!.$2.displayName} with tag '${payload!.$1.name}'",
      maxLines: 2,
      style: Theme.of(context).textTheme.bodyMedium,
    );
  }
}
