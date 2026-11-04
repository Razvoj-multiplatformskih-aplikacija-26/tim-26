import 'package:flutter/material.dart';

import '../location_service.dart';

class AddressDialog extends StatefulWidget {
  const AddressDialog({super.key});

  @override
  State<AddressDialog> createState() => _AddressDialogState();
}

class _AddressDialogState extends State<AddressDialog> {
  final _controller = TextEditingController();
  List<FoundAddress> _results = [];
  bool _loading = false;
  String? _message;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final query = _controller.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _loading = true;
      _message = null;
    });
    try {
      final found = await searchAddress(query);
      if (!mounted) return;
      setState(() {
        _results = found;
        _loading = false;
        _message = found.isEmpty ? 'Nema rezultata.' : null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _message = 'Pretraga nije uspela. Proverite internet vezu.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Izaberi adresu'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _controller,
              autofocus: true,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _search(),
              decoration: InputDecoration(
                hintText: 'Npr. Knez Mihailova 5, Beograd',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _search,
                ),
              ),
            ),
            const SizedBox(height: 8),
            if (_loading) const CircularProgressIndicator(),
            if (_message != null) Text(_message!),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (final result in _results)
                    ListTile(
                      leading: const Icon(Icons.place),
                      title: Text(
                        result.label,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: () => Navigator.of(context).pop(result),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Odustani'),
        ),
      ],
    );
  }
}