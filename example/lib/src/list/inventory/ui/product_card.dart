import 'package:flutter/material.dart';
import 'package:blocx_flutter/list_widget.dart';
import 'package:blocx_flutter_example/src/list/inventory/data/models/product.dart';
import 'package:blocx_flutter_example/src/list/users/data/models/user.dart';

class ProductCard extends BlocxListItem<Product, User> {
  const ProductCard({super.key, required super.item});

  @override
  Widget buildContent(BuildContext context, Product item) {
    final theme = Theme.of(context);

    final disabled = isBeingRemoved(context);
    final bg = disabled
        ? theme.colorScheme.error.withValues(alpha: 0.10)
        : isHighlighted(context)
        ? theme.colorScheme.primaryContainer
        : theme.cardColor;
    final BorderSide? borderSide = isSelected(context)
        ? BorderSide(color: theme.colorScheme.primary, width: 2)
        : null;
    return Card(
      clipBehavior: Clip.antiAlias,
      color: bg,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      shape: RoundedRectangleBorder(
        side: borderSide ?? BorderSide.none,
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
      child: InkWell(
        onLongPress: disabled ? null : () => removeItem(context),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              // ClipRRect(
              //   borderRadius: BorderRadius.circular(8),
              //   child: Image.network(
              //     item.imageUrl,
              //     width: 80,
              //     height: 80,
              //     fit: BoxFit.cover,
              //     errorBuilder: (_, __, ___) => Container(
              //       width: 80,
              //       height: 80,
              //       color: Colors.grey.shade200,
              //       child: const Icon(Icons.image_not_supported),
              //     ),
              //   ),
              // ),
              const SizedBox(width: 12),

              // Texts
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name + actions row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            item.name,
                            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Action buttons
                        Wrap(
                          spacing: 4,
                          children: [
                            // Highlight toggle
                            IconButton(
                              tooltip: isHighlighted(context) ? 'Unhighlight' : 'Highlight',
                              onPressed: disabled
                                  ? null
                                  : () => isHighlighted(context)
                                        ? clearHighlightedItem(context)
                                        : highlightItem(context),
                              icon: Icon(isHighlighted(context) ? Icons.star : Icons.star_border),
                            ),
                            // Select toggle
                            IconButton(
                              tooltip: isSelected(context) ? 'Deselect' : 'Select',
                              onPressed: disabled
                                  ? null
                                  : () => isSelected(context) ? deselectItem(context) : selectItem(context),
                              icon: Icon(
                                isSelected(context) ? Icons.check_box : Icons.check_box_outline_blank,
                              ),
                            ),
                            // Delete
                            IconButton(
                              tooltip: 'Delete',
                              onPressed: disabled ? null : () => removeItem(context),
                              icon: const Icon(Icons.delete_outline),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 4),
                    Text(
                      item.description,
                      style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[700]),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),

                    Row(
                      children: [
                        Text(
                          "\$${item.price.toStringAsFixed(2)}",
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          item.stock > 0 ? "In stock" : "Out of stock",
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: item.stock > 0 ? Colors.green : Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
