import 'package:flutter/material.dart';
import 'package:flutter_blocx/list_widget.dart';
import 'package:flutter_blocx_example/src/list/inventory/ui/inventory_screen.dart';
import 'package:flutter_blocx_example/src/list/users/data/models/user.dart';

class UserCard extends BlocxListItem<User, dynamic> {
  const UserCard({super.key, required super.item});

  @override
  Widget buildContent(BuildContext context, User user) {
    final highlighted = isHighlighted(context);

    final theme = Theme.of(context);
    final borderColor = highlighted ? theme.colorScheme.primary : theme.dividerColor;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: InkWell(
        onTap: () =>
            Navigator.of(context).push(MaterialPageRoute(builder: (c) => InventoryScreen(payload: user))),
        onLongPress: () {
          // Toggle highlight (will throw a clear error if highlight isn’t enabled)
          highlighted ? clearHighlightedItem(context) : highlightItem(context);
        },
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor, width: highlighted ? 2 : 1),
            color: highlighted ? theme.colorScheme.primary.withAlpha(50) : Colors.transparent,
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: CircleAvatar(backgroundImage: NetworkImage(user.image)),
            title: Text(user.name, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
            subtitle: Text('@${user.username}', style: theme.textTheme.bodySmall),
          ),
        ),
      ),
    );
  }
}
