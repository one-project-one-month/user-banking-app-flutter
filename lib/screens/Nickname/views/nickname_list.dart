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
    return BlocProvider(create: (_) => NicknameBloc()..add(const LoadNicknames()), child: const _NicknameListView());
  }
}

class _NicknameListView extends StatelessWidget {
  const _NicknameListView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Favorites',
          style: GoogleFonts.inter(
            color: theme.textTheme.titleLarge?.color ?? Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: theme.appBarTheme.backgroundColor ?? theme.colorScheme.surface,
        iconTheme: theme.iconTheme,
      ),
      body: BlocConsumer<NicknameBloc, NicknameState>(
        listener: (context, state) {
          if (state.hasError && state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 3),
              ),
            );
          } else if (state.isSuccess && state.message != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message!),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 2),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.isLoading && state.items.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          final items = state.items;
          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 80, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'No favorites yet',
                    style: GoogleFonts.inter(fontSize: 18, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add your favorite accounts for quick access',
                    style: GoogleFonts.inter(fontSize: 14, color: Colors.grey.shade500),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final item = items[index];
              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 2,
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFF3366FF).withOpacity(0.1),
                    child: Icon(Icons.person, color: const Color(0xFF3366FF)),
                  ),
                  title: Text(item.nickname, style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 16)),
                  subtitle: Text(
                    item.toaccountDetail.accountNumber,
                    style: GoogleFonts.inter(fontSize: 14, color: Colors.grey.shade600),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Color(0xFF3366FF), size: 22),
                        onPressed: () async {
                          final res = await Navigator.of(
                            context,
                          ).push(MaterialPageRoute(builder: (_) => NicknameEditScreen(option: item)));

                          if (res is Map<String, dynamic>) {
                            final id = res['id']?.toString() ?? item.id;
                            // Use the ID from toaccountDetail, not the account number
                            final toAccountId = res['toAccountId']?.toString() ?? item.toaccountDetail.id;
                            final nickname = res['nickname']?.toString() ?? item.nickname;

                            print('🔄 Updating nickname with:');
                            print('   id: $id');
                            print('   toAccountId: $toAccountId');
                            print('   nickname: $nickname');

                            context.read<NicknameBloc>().add(
                              UpdateNickname(id: id, toAccountId: toAccountId, nickname: nickname),
                            );
                          }
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red, size: 22),
                        onPressed: () async {
                          final ok = await showDialog<bool>(
                            context: context,
                            builder:
                                (ctx) => AlertDialog(
                                  title: const Text('Delete favorite'),
                                  content: Text('Are you sure you want to delete "${item.nickname}"?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(ctx).pop(false),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.of(ctx).pop(true),
                                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                                      child: const Text('Delete'),
                                    ),
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
        backgroundColor: const Color(0xFF3366FF),
        onPressed: () async {
          final res = await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const NicknameCreateScreen()));

          if (res is Map<String, dynamic>) {
            final toAccountId = res['account']?.toString() ?? '';
            final nickname = res['nickname']?.toString() ?? '';

            if (toAccountId.isNotEmpty && nickname.isNotEmpty) {
              context.read<NicknameBloc>().add(CreateNickname(toAccountId: toAccountId, nickname: nickname));
            }
          }
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
