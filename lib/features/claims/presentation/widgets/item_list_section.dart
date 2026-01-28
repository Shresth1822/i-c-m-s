import 'package:flutter/material.dart';

class ItemListSection<T> extends StatelessWidget {
  final String title;
  final List<T> items;
  final Widget Function(BuildContext, T) itemBuilder;
  final VoidCallback? onAdd;
  final Function(T)? onDelete;

  const ItemListSection({
    super.key,
    required this.title,
    required this.items,
    required this.itemBuilder,
    this.onAdd,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            if (onAdd != null)
              IconButton(
                onPressed: onAdd,
                icon: const Icon(Icons.add_circle_outline),
                tooltip: 'Add $title',
              ),
          ],
        ),
        if (items.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              'No $title added yet.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final item = items[index];
              return Row(
                children: [
                  Expanded(child: itemBuilder(context, item)),
                  if (onDelete != null)
                    IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        size: 20,
                        color: Colors.red,
                      ),
                      onPressed: () => onDelete!(item),
                    ),
                ],
              );
            },
          ),
      ],
    );
  }
}
