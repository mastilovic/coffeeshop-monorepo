import 'package:flutter/material.dart';

class FormSelect<T> extends StatelessWidget {
  const FormSelect({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.itemLabel,
    required this.onChanged,
    this.hint,
    this.prefixIcon,
    this.onTap,
  });

  final String label;
  final T? value;
  final List<T> items;
  final String Function(T) itemLabel;
  final ValueChanged<T?> onChanged;
  final String? hint;
  final IconData? prefixIcon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      items: items.map((item) {
        return DropdownMenuItem<T>(
          value: item,
          child: Text(itemLabel(item)),
        );
      }).toList(),
      onChanged: onChanged,
      onTap: onTap,
    );
  }
}

class FormMultiSelect<T> extends StatelessWidget {
  const FormMultiSelect({
    super.key,
    required this.label,
    required this.selectedValues,
    required this.items,
    required this.itemLabel,
    required this.onChanged,
    this.prefixIcon,
  });

  final String label;
  final List<T> selectedValues;
  final List<T> items;
  final String Function(T) itemLabel;
  final ValueChanged<List<T>> onChanged;
  final IconData? prefixIcon;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _showPicker(context),
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Wrap(
          spacing: 4,
          children: selectedValues.isEmpty
              ? [Text('None selected', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant))]
              : selectedValues.map((v) {
                  return Chip(
                    label: Text(itemLabel(v), style: const TextStyle(fontSize: 12)),
                    onDeleted: () {
                      onChanged(selectedValues.where((e) => e != v).toList());
                    },
                  );
                }).toList(),
        ),
      ),
    );
  }

  void _showPicker(BuildContext context) {
    showDialog<List<T>>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(label),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView(
              shrinkWrap: true,
              children: items.map((item) {
                final isSelected = selectedValues.contains(item);
                return CheckboxListTile(
                  title: Text(itemLabel(item)),
                  value: isSelected,
                  onChanged: (checked) {
                    if (checked == true) {
                      onChanged([...selectedValues, item]);
                    } else {
                      onChanged(selectedValues.where((e) => e != item).toList());
                    }
                  },
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Done'),
            ),
          ],
        );
      },
    );
  }
}
