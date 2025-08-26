import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  static const String dir = 'assets/gallery/'; // folder with your images
  List<String> _assets = [];
  final Set<String> _selected = {}; // multi-select

  @override
  void initState() {
    super.initState();
    _loadAssets();
  }

  Future<void> _loadAssets() async {
    // pubspec.yaml must include:
    // flutter:
    //   assets:
    //     - assets/gallery/
    final manifestJson = await rootBundle.loadString('AssetManifest.json');
    final Map<String, dynamic> manifest = json.decode(manifestJson);

    final images = manifest.keys.where((k) {
      final lower = k.toLowerCase();
      return lower.startsWith(dir) &&
          (lower.endsWith('.png') ||
              lower.endsWith('.jpg') ||
              lower.endsWith('.jpeg') ||
              lower.endsWith('.webp') ||
              lower.endsWith('.gif'));
    }).toList()
      ..sort();

    setState(() => _assets = images);
  }

  void _toggle(String path) {
    setState(() {
      if (_selected.contains(path)) {
        _selected.remove(path);
      } else {
        _selected.add(path);
      }
    });
  }

  void _clearSelection() => setState(() => _selected.clear());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assets / Gallery'),
        actions: [
          if (_selected.isNotEmpty)
            IconButton(
              tooltip: 'Clear selection',
              onPressed: _clearSelection,
              icon: const Icon(Icons.clear),
            ),
        ],
      ),
      body: _assets.isEmpty
          ? const Center(
              child: Text(
                'No assets found.\nCheck pubspec.yaml (assets/gallery/) & reload.',
                textAlign: TextAlign.center,
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: _assets.length,
                    itemBuilder: (context, i) {
                      final path = _assets[i];
                      final isSelected = _selected.contains(path);

                      return InkWell(
                        onTap: () => _toggle(path),
                        borderRadius: BorderRadius.circular(10),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.asset(path, fit: BoxFit.cover),
                            ),
                            Positioned.fill(
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 120),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    width: isSelected ? 3 : 0.6,
                                    color: isSelected
                                        ? Theme.of(context).colorScheme.primary
                                        : Colors.grey.shade400,
                                  ),
                                ),
                              ),
                            ),
                            if (isSelected)
                              Positioned(
                                right: 6,
                                top: 6,
                                child: CircleAvatar(
                                  radius: 12,
                                  backgroundColor:
                                      Theme.of(context).colorScheme.primary,
                                  child: const Icon(Icons.check,
                                      size: 16, color: Colors.white),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Row(
                    children: [
                      Text('Selected: ${_selected.length}'),
                      const Spacer(),
                      FilledButton(
                        onPressed: _selected.isEmpty
                            ? null
                            : () {
                                // Use selected paths in `_selected`
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          'Using ${_selected.length} image(s)')),
                                );
                              },
                        child: const Text('Use selected'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
