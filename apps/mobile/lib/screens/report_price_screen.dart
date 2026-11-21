import 'package:blocs/blocs.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../texts.dart';

/// Kupac javlja cenu koju je video u prodavnici. Cena ceka potvrdu u
/// backoffice-u, pa se tek tada racuna u poredjenju korpe.
class ReportPriceScreen extends StatefulWidget {
  const ReportPriceScreen({super.key});

  @override
  State<ReportPriceScreen> createState() => _ReportPriceScreenState();
}

class _ReportPriceScreenState extends State<ReportPriceScreen> {
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
    context.read<ShoppingListsBloc>().add(
      PriceReported(
        product: _product!,
        store: _store!,
        price: int.parse(_priceController.text.trim()),
      ),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.read<ShoppingListsBloc>().state;
    final Catalog? catalog = switch (state) {
      ListsLoaded(:final catalog) => catalog,
      ListsEmpty(:final catalog) => catalog,
      _ => null,
    };

    return Scaffold(
      appBar: AppBar(title: const Text('Prijavi cenu')),
      body: catalog == null
          ? const Center(child: Text('Katalog još nije učitan.'))
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    DropdownButtonFormField<Product>(
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Proizvod (pakovanje)',
                      ),
                      items: [
                        for (final product in catalog.products)
                          DropdownMenuItem(
                            value: product,
                            child: Text('${product.name} (${product.packaging})'),
                          ),
                      ],
                      onChanged: (product) => _product = product,
                      validator: (product) =>
                          product == null ? 'Izaberite proizvod.' : null,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<Store>(
                      isExpanded: true,
                      decoration: const InputDecoration(labelText: 'Prodavnica'),
                      items: [
                        for (final store in catalog.stores)
                          DropdownMenuItem(value: store, child: Text(store.name)),
                      ],
                      onChanged: (store) => _store = store,
                      validator: (store) =>
                          store == null ? 'Izaberite prodavnicu.' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Cena (RSD)',
                        helperText: 'Cena se prikazuje kupcima kada je administrator potvrdi.',
                      ),
                      validator: (value) => switch (PriceValue.parse(value ?? '')) {
                        Success() => null,
                        Failure(:final error) => errorMessage(error),
                      },
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _save,
                        child: const Text('Pošalji'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
