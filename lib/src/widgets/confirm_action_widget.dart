import 'package:flutter/material.dart';

class ConfirmActionWidget extends StatefulWidget {
  const ConfirmActionWidget({super.key, required this.options});

  final ConfirmActionOptions options;

  static Future<bool?> show(
    BuildContext context, {
    required ConfirmActionOptions options,
    bool isScrollControlled = false,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: isScrollControlled,
      useSafeArea: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) => ConfirmActionWidget(options: options),
    );
  }

  @override
  State<ConfirmActionWidget> createState() => _ConfirmDeleteSheetState();
}

class _ConfirmDeleteSheetState extends State<ConfirmActionWidget> {
  String _typed = '';
  bool _isDeleting = false;

  bool get _canConfirm =>
      !_isDeleting && (!widget.options.requireTyping || _typed.trim() == widget.options.deleteWord);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final options = widget.options;

    final leading = (options.imageUrl != null && options.imageUrl!.isNotEmpty)
        ? ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              options.imageUrl!,
              width: 48,
              height: 48,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: cs.errorContainer, borderRadius: BorderRadius.circular(12)),
                child: Icon(options.icon, color: cs.onErrorContainer),
              ),
            ),
          )
        : Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: cs.errorContainer, borderRadius: BorderRadius.circular(12)),
            child: Icon(options.icon, color: cs.onErrorContainer),
          );

    return Padding(
      padding: MediaQuery.viewInsetsOf(context).add(const EdgeInsets.all(16)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(color: cs.outlineVariant, borderRadius: BorderRadius.circular(2)),
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              leading,
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(options.title, style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    Text(options.question, style: textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
                  ],
                ),
              ),
            ],
          ),
          if (options.requireTyping) ...[
            const SizedBox(height: 16),
            TextField(
              autofocus: true,
              onChanged: (v) => setState(() => _typed = v),
              decoration: InputDecoration(
                labelText: 'Type "${options.deleteWord}" to confirm',
                border: const OutlineInputBorder(),
              ),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _isDeleting
                      ? null
                      : () {
                          Navigator.of(context).pop(false);
                        },
                  child: Text(options.cancelText),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  style: ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(cs.error),
                    foregroundColor: WidgetStatePropertyAll(cs.onError),
                  ),
                  onPressed: _canConfirm
                      ? () async {
                          setState(() => _isDeleting = true);
                          try {
                            Navigator.of(context).pop(true);
                          } finally {
                            if (mounted) setState(() => _isDeleting = false);
                          }
                        }
                      : null,
                  child: _isDeleting
                      ? SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(cs.onError),
                          ),
                        )
                      : Text(options.confirmText),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const SafeArea(top: false, child: SizedBox(height: 4)),
        ],
      ),
    );
  }
}

class ConfirmActionOptions {
  final String title;
  final String question;
  final String confirmText;
  final String cancelText;
  final IconData icon;
  final bool requireTyping;
  final String deleteWord;
  final String? imageUrl;

  const ConfirmActionOptions({
    this.title = 'Delete item',
    this.question = 'This action cannot be undone. Are you sure?',
    this.confirmText = 'Delete',
    this.cancelText = 'Cancel',
    this.icon = Icons.delete_outline,
    this.requireTyping = false,
    this.deleteWord = 'DELETE',
    this.imageUrl,
  });
}
