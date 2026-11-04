import 'package:blocs/blocs.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../texts.dart';
import '../widgets/radius_toggle.dart';

class AddItemScreen extends StatefulWidget {
  const AddItemScreen({super.key, required this.listId});

  final ShoppingListId listId;

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController(text: '1');
  Product? _selected;

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final quantity = int.parse(_quantityController.text.trim());
    context.read<ShoppingListsBloc>().add(
      ItemAdded(
        listId: widget.listId,
        product: _selected!,
        quantity: quantity,
      ),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.read<ShoppingListsBloc>().state;
    final products = state is ListsLoaded ? state.catalog.products : <Product>[];

    return Scaffold(
      appBar: AppBar(title: const Text('Dodaj stavku')),
      body: Padding(
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
                  for (final product in products)
                    DropdownMenuItem(
                      value: product,
                      child: Text('${product.name} (${product.packaging})'),
                    ),
                ],
                onChanged: (product) => _selected = product,
                validator: (product) =>
                product == null ? 'Izaberite proizvod.' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _quantityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Količina',
                  helperText:
                  'Ako proizvod već postoji na listi, količine se sabiraju.',
                ),
                validator: (value) => switch (Quantity.parse(value ?? '')) {
                  Success() => null,
                  Failure(:final error) => errorMessage(error),
                },
              ),
              const SizedBox(height: 8),
              const RadiusToggle(
                note: 'Važi za poređenje cena na listi.',
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _save,
                  child: const Text('Dodaj'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}