import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:blocx/blocx.dart';
import 'package:flutter_blocx_example/src/list/users/bloc/users_bloc.dart';
import 'package:flutter_blocx_example/src/list/users/data/models/user.dart';

class ScrollControllerBar extends StatefulWidget {
  final int currentIndex;

  const ScrollControllerBar({super.key, required this.currentIndex});

  @override
  State<ScrollControllerBar> createState() => _ScrollControllerBarState();
}

class _ScrollControllerBarState extends State<ScrollControllerBar> {
  bool _highlightOnScroll = false;

  @override
  Widget build(BuildContext context) {
    final listBloc = BlocProvider.of<ListBloc<User, dynamic>>(context);
    final theme = Theme.of(context);
    final list = listBloc.state.list;

    final idx = widget.currentIndex;
    return Container(
      decoration: BoxDecoration(
        color: theme.primaryColor.withAlpha(20),
        border: Border.all(color: theme.colorScheme.primary),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(Icons.swap_vert, color: theme.colorScheme.primary),
            const SizedBox(width: 12),
            Text(
              "Scroll to index",
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const Spacer(),

            // -1
            _CounterButton(
              icon: Icons.remove,
              onTap: () => listBloc.add(UsersEventChangeScrollIndex(index: idx - 1)),
            ),

            // current index
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                idx.toString(),
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // +1
            _CounterButton(
              icon: Icons.add,
              onTap: () => listBloc.add(UsersEventChangeScrollIndex(index: idx + 1)),
            ),

            const SizedBox(width: 16),

            // highlight toggle (internal state)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Checkbox.adaptive(
                  value: _highlightOnScroll,
                  onChanged: (v) => setState(() => _highlightOnScroll = v ?? false),
                ),
                const SizedBox(width: 4),
                Text("Highlight", style: theme.textTheme.bodyMedium),
              ],
            ),

            const SizedBox(width: 12),

            // start
            FilledButton.icon(
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                if (list.isEmpty) return;
                final clamped = idx.clamp(0, list.length - 1);
                final item = list[clamped];
                listBloc.add(ListEventScrollToItem(item: item, highlightItem: _highlightOnScroll));
              },
              icon: const Icon(Icons.play_arrow),
              label: const Text("Start"),
            ),
          ],
        ),
      ),
    );
  }
}

class _CounterButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CounterButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.all(6),
        child: Icon(icon, size: 20, color: theme.colorScheme.primary),
      ),
    );
  }
}
