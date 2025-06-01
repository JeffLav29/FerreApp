import 'package:flutter/material.dart';

class CategoriaChip extends StatelessWidget {
  final String categoria;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoriaChip({
    Key? key,
    required this.categoria,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: 8.0),
      child: FilterChip(
        label: Text(categoria),
        selected: isSelected,
        onSelected: (_) => onTap(),
        backgroundColor: Colors.grey[200],
        selectedColor: Colors.blue[100],
        checkmarkColor: Colors.blue[800],
      ),
    );
  }
}
