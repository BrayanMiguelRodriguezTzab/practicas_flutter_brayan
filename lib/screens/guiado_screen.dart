import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/contador_provider.dart';
import '../widgets/contador_card.dart';

class GuiadoScreen extends StatelessWidget {
  const GuiadoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ContadorProvider(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Práctica 07 - Guiado')),
        body: Center(
          child: Consumer<ContadorProvider>(
            builder: (context, provider, child) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ContadorCard(valor: provider.valor),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => provider.incrementar(),
                    icon: const Icon(Icons.add),
                    label: const Text('Incrementar'),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}