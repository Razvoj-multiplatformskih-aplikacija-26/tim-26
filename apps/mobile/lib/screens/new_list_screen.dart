import 'package:blocs/blocs.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../texts.dart';
import '../widgets/radius_toggle.dart';

class NewListScreen extends StatefulWidget {
  const NewListScreen({super.key});

  @override
  State<NewListScreen> createState() => _NewListScreenState();
}

class _NewListScreenState extends State<NewListScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    context.read<ShoppingListsBloc>().add(ListCreated(_nameController.text));
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nova lista')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Naziv liste'),
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _save(),
                validator: (value) => switch (ListName.parse(value ?? '')) {
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
                  child: const Text('Sačuvaj'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}