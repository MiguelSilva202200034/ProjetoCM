import 'package:flutter/material.dart';
import 'package:harvestly/core/models/consumer_user.dart';
import 'package:harvestly/core/services/auth/auth_service.dart';
import 'package:provider/provider.dart';

import '../../core/services/chat/chat_list_notifier.dart';
import '../../utils/app_routes.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  Future<void> _confirmLogout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text("Confirmar"),
            content: const Text(
              "Tem a certeza que pretende terminar a sessão?",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text("Não"),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text("Sim"),
              ),
            ],
          ),
    );

    if (shouldLogout == true) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        context.read<ChatListNotifier>().clearChats();
        await AuthService().logout();
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil(AppRoutes.AUTH_OR_APP_PAGE, (route) => false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = AuthService().currentUser! as ConsumerUser;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Nome",
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
              ),
              Text(
                "${currentUser.firstName} ${currentUser.lastName}",
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
              ),
            ],
          ),
          const Divider(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Email",
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
              ),
              Text(
                "${currentUser.email}",
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
              ),
            ],
          ),

          const Divider(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Número de contribuinte",
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
              ),
              Text(
                "${currentUser.taxpayerNumber!}",
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
              ),
            ],
          ),
          const Divider(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Morada",
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
              ),
              Text(
                "${currentUser.address!}",
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
              ),
            ],
          ),
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                foregroundColor:
                    Theme.of(context).colorScheme.onSecondaryContainer,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(width: 0.5),
                ),
                elevation: 0,
              ),
              onPressed: () => _confirmLogout(context),
              child: Text(
                "Terminar Sessão",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.red,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
