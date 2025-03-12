import 'package:flutter/material.dart';
import 'package:homecare/core/theme/themes.dart';

class CustomDropdown<T> extends StatefulWidget {
  final T? selectedValue;
  final List<T> items;
  final String title; // Dynamic title passed by the user
  final Function(T?) onChanged;

  const CustomDropdown({
    super.key,
    required this.selectedValue,
    required this.items,
    required this.onChanged,
    required this.title,
  });

  @override
  State<CustomDropdown<T>> createState() => _CustomDropdownState<T>();
}

class _CustomDropdownState<T> extends State<CustomDropdown<T>> {
  final LayerLink _layerLink = LayerLink();
  bool _isDropdownOpen = false;

  OverlayEntry? _overlayEntry;

  void _toggleDropdown() {
    if (_isDropdownOpen) {
      _closeDropdown();
    } else {
      _openDropdown();
    }
  }

  void _openDropdown() {
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
    _isDropdownOpen = true;
  }

  void _closeDropdown() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _isDropdownOpen = false;
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    var size = renderBox.size;
    var offset = renderBox.localToGlobal(Offset.zero);

    return OverlayEntry(
      builder: (context) => Stack(
        children: [
          GestureDetector(
            onTap: _closeDropdown,
            behavior: HitTestBehavior.opaque,
            child: Container(
              color: Colors.transparent,
            ),
          ),
          Positioned(
            width: 200,
            left: offset.dx,
            top: offset.dy + size.height,
            child: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(10.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxHeight: 200,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: widget.items.map((item) {
                      return ListTile(
                        title: Text(item.toString()), // Display the string representation
                        onTap: () {
                          widget.onChanged(item);
                          _closeDropdown();
                        },
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    if (_isDropdownOpen) {
      _closeDropdown();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // If no value is selected, display the title
    final displayTitle = widget.selectedValue == null
        ? widget.title  // Show the dynamic title if no value is selected
        : widget.selectedValue.toString();  // Display the name of the selected item

    return GestureDetector(
      onTap: _toggleDropdown,
      child: CompositedTransformTarget(
        link: _layerLink,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          decoration: BoxDecoration(
            color: HomeCareTheme.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(25.0),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                displayTitle,  // Display the correct title based on selection
                style: const TextStyle(color: Colors.black),
              ),
              Image.asset('assets/icons/arrow_down.png', scale: 2.0),
            ],
          ),
        ),
      ),
    );
  }
}
