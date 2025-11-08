import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:banking_app/screens/Nickname/controllers/nickname_bloc.dart';
import 'package:banking_app/screens/Nickname/controllers/nickname_event.dart';
import 'package:banking_app/screens/Nickname/controllers/nickname_state.dart';
import 'package:banking_app/screens/Nickname/views/nickname_create.dart';
import 'package:banking_app/screens/Nickname/views/nickname_edit.dart';
import 'package:banking_app/screens/Nickname/models/nickname.dart';

class NicknameListScreen extends StatelessWidget {
  const NicknameListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => NicknameBloc()..add(const LoadNicknames()),
      child: const _NicknameListView(),
    );
  }
}

class _NicknameListView extends StatelessWidget {
  const _NicknameListView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Favorites', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
        backgroundColor: theme.appBarTheme.backgroundColor ?? theme.colorScheme.surface,
      ),
      body: BlocConsumer<NicknameBloc, NicknameState>(
        listener: (context, state) {
          if (state.status == NicknameStatus.failure && state.message != null) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message!)));
          }
        },
        builder: (context, state) {
          if (state.status == NicknameStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          final items = state.items;
          if (items.isEmpty) {
            return Center(child: Text('No favorites yet', style: GoogleFonts.inter()));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final item = items[index];
              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: ListTile(
                  title: Text(item.nickname, style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
                  subtitle: Text(item.toaccountDetail.accountNumber, style: GoogleFonts.inter()),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () async {
                          final res = await Navigator.of(context).push(MaterialPageRoute(
                              builder: (_) => NicknameEditScreen(option: item)));
                          if (res is Map<String, dynamic>) {
                            final id = res['id']?.toString() ?? item.id;
                            final toaccountId = res['toaccountId']?.toString() ?? item.toaccountDetail.id;
                            final nickname = res['nickname']?.toString() ?? item.nickname;
                            context.read<NicknameBloc>().add(UpdateNickname(id: id, toaccountId: toaccountId, nickname: nickname));
                          }
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          final ok = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Delete favorite'),
                              content: const Text('Are you sure you want to delete this favorite?'),
                              actions: [
                                TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
                                TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Delete')),
                              ],
                            ),
                          );
                          if (ok == true) {
                            context.read<NicknameBloc>().add(DeleteNickname(item.id));
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final res = await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const NicknameCreateScreen()));
          if (res is Map<String, dynamic>) {
            final toaccountId = res['account']?.toString() ?? '';
            final nickname = res['nickname']?.toString() ?? '';
            if (toaccountId.isNotEmpty && nickname.isNotEmpty) {
              context.read<NicknameBloc>().add(CreateNickname(toaccountId: toaccountId, nickname: nickname));
            }
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
