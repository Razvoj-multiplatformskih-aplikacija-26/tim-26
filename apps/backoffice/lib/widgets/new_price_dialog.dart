import 'package:domain/domain.dart';
import 'package:flutter/material.dart';

import '../texts.dart';

class NewPriceData {
  const NewPriceData(this.product, this.store, this.price);

  final Product product;
  final Store store;
  final int price;
}

class NewPriceDialog extends StatefulWidget {
  const NewPriceDialog({super.key, required this.catalog});

  final Catalog catalog;

  @override
  State<NewPriceDialog> createState() => _NewPriceDialogState();
}

class _NewPriceDialogState extends State<NewPriceDialog> {
  final _formKey = GlobalKey<FormState>();
  final _priceController = TextEditingController();
  Product? _product;
  Store? _store;

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final price = int.parse(_priceController.text.trim());
    Navigator.of(context).pop(NewPriceData(_product!, _store!, price));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nova cena'),
      content: SizedBox(
        width: 380,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<Product>(
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Proizvod'),
                  items: [
                    for (final product in widget.catalog.products)
                      DropdownMenuItem(
                        value: product,
                        child: Text('${product.name} (${product.packaging})'),
                      ),
                  ],
                  onChanged: (product) => _product = product,
                  validator: (product) =>
                      product == null ? 'Izaberite proizvod.' : null,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<Store>(
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Prodavnica'),
                  items: [
                    for (final store in widget.catalog.stores)
                      DropdownMenuItem(value: store, child: Text(store.name)),
                  ],
                  onChanged: (store) => _store = store,
                  validator: (store) =>
                      store == null ? 'Izaberite prodavnicu.' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Cena (RSD)'),
                  onFieldSubmitted: (_) => _save(),
                  validator: (value) => switch (PriceValue.parse(value ?? '')) {
                    Success() => null,
                    Failure(:final error) => errorMessage(error),
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Odustani'),
        ),
        FilledButton(onPressed: _save, child: const Text('Sačuvaj')),
      ],
    );
  }
}
