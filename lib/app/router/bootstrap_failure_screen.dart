import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'app_routes.dart';
import 'bootstrap_gate.dart';

class BootstrapFailureScreen extends ConsumerWidget {
  const BootstrapFailureScreen({
    super.key,
    this.arguments = const BootstrapRouteArguments(),
  });

  final BootstrapRouteArguments arguments;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Unable to initialize local data.'),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  ref
                      .read(bootstrapGateProvider.notifier)
                      .set(BootstrapGateState.initializing);
                  context.go(AppRoutes.splashWith(arguments));
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
