import 'dart:async';

import 'package:flutter/material.dart';

abstract class CommandPaletteItem {
  String get itemName;
}

/// A generic overlay command palette that can be called from anywhere.
class CommandPalette {
  static OverlayEntry? _overlayEntry;
  static final TextEditingController _searchController =
      TextEditingController();
  static final TextEditingController _controller = TextEditingController();

  /// Show the palette.
  /// [context]: BuildContext to get the overlay.
  /// [items]: List of items of type T.
  /// [itemBuilder]: How to render each item in the list.
  /// [onSelected]: Called when an item is selected.
  static void showOption<T extends CommandPaletteItem>({
    required BuildContext context,
    required List<T> items,
    required Widget Function(BuildContext context, T item) itemBuilder,
    required void Function(T item) onSelected,
    String hintText = 'Type to search…',
    double width = 600,
    double maxHeight = 300,
  }) {
    _searchController.clear();

    _overlayEntry = OverlayEntry(
      builder: (context) {
        List<T> filteredItems = items
            .where(
              (item) => item.itemName.toLowerCase().contains(
                _searchController.text.toLowerCase(),
              ),
            )
            .toList();

        return GestureDetector(
          onTap: hide,
          child: Material(
            color: Colors.black54,
            child: Center(
              child: Material(
                color: Colors.grey[900],
                elevation: 12,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: width,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: _searchController,
                        autofocus: true,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: hintText,
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          filled: true,
                          fillColor: Colors.grey[850],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onChanged: (_) => _overlayEntry?.markNeedsBuild(),
                      ),
                      const SizedBox(height: 12),
                      ConstrainedBox(
                        constraints: BoxConstraints(maxHeight: maxHeight),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: filteredItems.length,
                          itemBuilder: (context, index) {
                            final item = filteredItems[index];
                            return InkWell(
                              onTap: () {
                                onSelected(item);
                                hide();
                              },
                              child: itemBuilder(context, item),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  static Future<String?> showRename(
    BuildContext context, {
    String initialValue = '',
    String hintText = 'Enter name…',
    double width = 400,
  }) {
    _controller.text = initialValue;

    final completer = Completer<String?>();

    _overlayEntry = OverlayEntry(
      builder: (context) {
        return GestureDetector(
          onTap: hide,
          child: Material(
            color: Colors.black54,
            child: Center(
              child: Material(
                color: Colors.grey[900],
                elevation: 12,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: width,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: _controller,
                        autofocus: true,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: hintText,
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          filled: true,
                          fillColor: Colors.grey[850],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onSubmitted: (value) {
                          completer.complete(value);
                          hide();
                        },
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () {
                              completer.complete(null);
                              hide();
                            },
                            child: const Text('Cancel'),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () {
                              completer.complete(_controller.text);
                              hide();
                            },
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );

    Overlay.of(context).insert(_overlayEntry!);

    return completer.future;
  }

  /// Hide the palette
  static void hide() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _searchController.clear();
  }
}
