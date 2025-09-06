import 'package:blocx_core/blocx_core.dart';
import 'package:blocx_flutter/list_widget.dart';
import 'package:example/src/screens/note_tags/data/models/note_tag.dart';
import 'package:example/src/screens/notes/bloc/notes_bloc.dart';
import 'package:example/src/screens/notes/data/models/note.dart';
import 'package:example/src/screens/notes/presentation/widgets/note_card.dart';
import 'package:example/src/screens/notes/presentation/widgets/number_nudge.dart';
import 'package:example/src/screens/users/data/models/user.dart';
import 'package:flutter/material.dart';

class NotesScreen extends CollectionWidget<(NoteTag, User)> {
  const NotesScreen({super.key, super.payload});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends CollectionWidgetState<NotesScreen, Note, (NoteTag, User)> {
  late final TextEditingController searchController;

  @override
  void initState() {
    super.initState();
    searchController = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    searchController.dispose();
  }

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
      backgroundColor: colorScheme.surfaceContainer,
      appBar: AppBar(
        leadingWidth: 40,
        titleSpacing: 4,
        title: appBarTitle(context),
        backgroundColor: Colors.white,
      ),
      body: body,
    );
  }

  @override
  Widget? topWidget(BuildContext context, ListState<Note> state) {
    return Card(
      margin: EdgeInsets.zero,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(bottom: Radius.circular(16))),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: BlocxSearchField<Note, (NoteTag, User)>(
          controller: searchController,
          options: BlocxSearchFieldOptions(hintText: "Type to search"),
        ),
      ),
    );
  }

  @override
  Widget? bottomWidget(BuildContext context, ListState<Note> state) {
    return AnimatedSize(
      duration: Duration(milliseconds: 200),
      child: Card(
        margin: EdgeInsets.zero,
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              NumberNudge(
                min: 0,
                max: state.list.length - 1,
                buttonLabel: "Scroll to this item",
                onSubmit: (index) => scrollToItem(state.list[index], highlightItem: true),
              ),
              AnimatedContainer(
                width: MediaQuery.sizeOf(context).width,
                duration: Duration(milliseconds: 200),
                child: Row(
                  children: [
                    if (state.selectedCount > 0) ...[
                      Expanded(
                        child: Text("${state.selectedCount} items are selected", textAlign: TextAlign.center),
                      ),
                      IconButton(
                        onPressed: () => deleteMultipleItems(state.selectedItems),
                        icon: state.beingRemovedItemIds.isNotEmpty
                            ? SizedBox.square(dimension: 16, child: CircularProgressIndicator())
                            : Icon(Icons.delete, color: Colors.red),
                      ),
                      IconButton(
                        onPressed: () => deselectMultipleItems(state.selectedItems),
                        icon: Icon(Icons.deselect, color: colorScheme.primary),
                      ),
                    ],
                  ],
                ),
              ),
              if (payload != null) ...[
                SizedBox(height: 16),
                FilledButton(
                  style: FilledButton.styleFrom(shape: RoundedRectangleBorder(), padding: EdgeInsets.all(24)),
                  onPressed: () =>
                      Navigator.of(context).push(MaterialPageRoute(builder: (_) => NotesScreen())),
                  child: Text("show all notes"),
                ),
              ],
            ],
          ),
        ),
      ),
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
