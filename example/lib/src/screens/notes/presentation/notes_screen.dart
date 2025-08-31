import 'package:example/src/screens/note_tags/data/models/note_tag.dart';
import 'package:example/src/screens/notes/bloc/notes_bloc.dart';
import 'package:example/src/screens/notes/data/models/note.dart';
import 'package:flutter/material.dart';
import 'package:blocx_flutter/list_widget.dart';

class NotesScreen extends ListWidget<NoteTag> {
  const NotesScreen({super.key, required super.payload});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends CollectionWidgetState<NotesScreen, Note, NoteTag> {
  _NotesScreenState() : super(bloc: NotesBloc());

  @override
  Widget itemBuilder(BuildContext context, Note item) {
    // TODO: implement itemBuilder
    throw UnimplementedError();
  }
}
