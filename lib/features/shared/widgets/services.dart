import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:push_app_notification/features/auth/providers/auth_provider.dart';
import 'package:push_app_notification/features/shared/providers/loader_provider.dart';
import 'package:push_app_notification/features/shared/widgets/loader.dart';

class Services extends ConsumerStatefulWidget {
  const Services({super.key, required this.child});
  final Widget child;

  @override
  ServicesState createState() => ServicesState();
}

class ServicesState extends ConsumerState<Services> {

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await ref.read(authProvider.notifier).initAutoLogout();
    });
  }

  @override
  Widget build(BuildContext context) {
    final loader = ref.watch(loaderProvider);    

    return Directionality(
      textDirection: TextDirection.ltr, // Puedes ajustar esto según la dirección de tu aplicación
      child: Stack(
        alignment: AlignmentDirectional.topStart,
        children: [
          widget.child,
          if (loader.loading) Loader(message: loader.title),
        ],
      ),
    );
  }
}
