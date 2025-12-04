import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:banking_app/Routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:banking_app/screens/auth/widgets/size.dart';
import 'package:banking_app/screens/auth/widgets/button.dart';
import 'package:banking_app/screens/Settings/controllers/settings_bloc.dart';
import 'package:banking_app/screens/Settings/controllers/settings_event.dart';
import 'package:banking_app/screens/Settings/controllers/settings_state.dart';
import 'package:banking_app/screens/Nickname/controllers/nickname_bloc.dart';
import 'package:banking_app/screens/Nickname/controllers/nickname_event.dart';
import 'package:banking_app/screens/Nickname/controllers/nickname_state.dart';
import 'package:banking_app/screens/Nickname/views/nickname_create.dart';
import 'package:path_provider/path_provider.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'widgets/transaction_info_row.dart';
import 'widgets/account_info_card.dart';
import 'widgets/nickname_bottom_sheet.dart';

class TransactionSuccessScreen extends StatefulWidget {
  final Map<String, dynamic>? transactionData;

  const TransactionSuccessScreen({super.key, this.transactionData});

  @override
  State<TransactionSuccessScreen> createState() => _TransactionSuccessScreenState();
}

class _TransactionSuccessScreenState extends State<TransactionSuccessScreen> {
  String? _nickname;
  final GlobalKey _receiptKey = GlobalKey();
  bool _isSavingReceipt = false;
  bool _hasSavedReceipt = false; // Track if receipt has been saved

  @override
  void initState() {
    super.initState();
    // Load auto-save receipt setting from API
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Load auto-save receipt setting
      try {
        context.read<SettingsBloc>().add(const LoadAutoSaveReceipt());
      } catch (e) {
        print('⚠️ Error loading auto-save receipt: $e');
      }
      
      // Wait a bit for the setting to load, then check
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          final settingsState = context.read<SettingsBloc>().state;
          // Only auto-save if API returns true
          if (settingsState.autoSaveReceipt) {
            _saveReceiptAsImage(autoSave: true);
          }
        }
      });
    });
  }

  void _showNicknameBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => NicknameBottomSheet(
            onSave: (nickname) {
              setState(() {
                _nickname = nickname;
              });
            },
          ),
    );
  }

  Future<void> _saveReceiptAsImage({bool autoSave = false}) async {
    if (_isSavingReceipt || _hasSavedReceipt) return; // Prevent saving if already saved

    setState(() {
      _isSavingReceipt = true;
    });

    try {
      // Different permission strategies for different Android versions
      bool permissionGranted = false;

      if (Platform.isAndroid) {
        // Get Android version
        final androidInfo = await DeviceInfoPlugin().androidInfo;
        final sdkInt = androidInfo.version.sdkInt;

        if (sdkInt >= 33) {
          // Android 13+ (API 33+) - Use photos/media permissions
          PermissionStatus photosStatus = await Permission.photos.status;
          if (!photosStatus.isGranted) {
            photosStatus = await Permission.photos.request();
          }
          permissionGranted = photosStatus.isGranted || photosStatus.isLimited;
        } else {
          // Android 12 and below - Use storage permission
          PermissionStatus storageStatus = await Permission.storage.status;
          if (!storageStatus.isGranted) {
            storageStatus = await Permission.storage.request();
          }
          permissionGranted = storageStatus.isGranted;
        }

        if (!permissionGranted) {
          if (mounted && context.mounted) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Storage permission is required to save receipt'),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
            });
          }
          setState(() {
            _isSavingReceipt = false;
          });
          return;
        }
      } else {
        // iOS
        PermissionStatus photosStatus = await Permission.photos.status;
        if (!photosStatus.isGranted) {
          photosStatus = await Permission.photos.request();
        }
        permissionGranted = photosStatus.isGranted || photosStatus.isLimited;

        if (!permissionGranted) {
          if (mounted && context.mounted) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Photos permission is required to save receipt'),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
            });
          }
          setState(() {
            _isSavingReceipt = false;
          });
          return;
        }
      }

      // Wait for widget to be fully rendered
      await Future.delayed(const Duration(milliseconds: 100));

      // Check if context is still valid before accessing render object
      if (!mounted || !context.mounted) {
        print('⚠️ Widget disposed before capturing receipt');
        return;
      }

      final renderObject = _receiptKey.currentContext?.findRenderObject();
      if (renderObject == null || !(renderObject is RenderRepaintBoundary)) {
        throw Exception('Receipt widget not ready for capture');
      }

      // Capture the receipt as image
      RenderRepaintBoundary boundary = renderObject as RenderRepaintBoundary;

      // Capture at high quality
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      // Generate filename with timestamp
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'receipt_$timestamp';

      // Save to gallery
      final result = await ImageGallerySaverPlus.saveImage(pngBytes, quality: 100, name: fileName);

      // Check again before showing success message
      if (mounted && context.mounted) {
        if (result != null && result['isSuccess'] == true) {
          // Mark as saved
          setState(() {
            _hasSavedReceipt = true;
          });

          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    autoSave ? 'Receipt auto-saved to gallery successfully!' : 'Receipt saved to gallery successfully!',
                  ),
                  backgroundColor: const Color(0xFF16A34A),
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          });

          // Update auto-save preference if manually saved
          if (!autoSave && mounted && context.mounted) {
            context.read<SettingsBloc>().add(const SettingsAutoSaveReceipt(true));
          }

          // Navigate back to home after a short delay
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted && context.mounted) {
              AppRoutes.navigateAndRemoveUntil(context, AppRoutes.home_screen);
            }
          });
        } else {
          throw Exception('Failed to save to gallery');
        }
      }
    } catch (e) {
      print('❌ Error saving receipt: $e');
      if (mounted && context.mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to save receipt: ${e.toString()}'),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSavingReceipt = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: context.read<SettingsBloc>()),
        BlocProvider(create: (_) => NicknameBloc()..add(const LoadNicknames())),
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<SettingsBloc, SettingsState>(
            listener: (context, state) {
              if (!mounted || !context.mounted) return;
              
              if (state.isSuccess && state.message != null) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message!),
                        backgroundColor: const Color(0xFF16A34A),
                      ),
                    );
                  }
                });
              } else if (state.hasError && state.errorMessage != null) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.errorMessage!),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                });
              }
            },
          ),
          BlocListener<NicknameBloc, NicknameState>(
            listener: (context, state) {
              // Reload nicknames after successful creation to update the UI
              if (state.isSuccess && state.message != null && state.items.isNotEmpty) {
                // Nicknames were loaded/created, UI will update automatically via BlocBuilder
                print('✅ Nicknames updated: ${state.items.length} items');
              }
            },
          ),
        ],
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    final data =
        widget.transactionData ??
        {
          'fromName': 'Ms. San',
          'fromAccount': '234-1-56643-6',
          'toName': 'Mr. Jhon',
          'toAccount': '671-2-67452-2',
          'amount': '588,000',
          'currency': 'Ks',
          'note': 'Testing',
        };

    return Scaffold(
      backgroundColor: const Color(0xFF002D62),
      appBar: AppBar(
        backgroundColor: const Color(0xFF002D62),
        elevation: 0,
        leading: IconButton(
          onPressed: () => AppRoutes.navigateAndRemoveUntil(context, AppRoutes.home_screen),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: const Text(''),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Main transaction card - scrollable content
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(CommonSize.s20(context)),
                child: RepaintBoundary(
                  key: _receiptKey,
                  child: Card(
                    elevation: 4,
                    color: Colors.grey[50],
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(CommonSize.s16(context))),
                    child: Padding(
                      padding: EdgeInsets.all(CommonSize.s16(context)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header
                          Center(
                            child: Text(
                              'Transfer Successful',
                              style: TextStyle(
                                color: const Color(0xFF002D62),
                                fontSize: CommonSize.s18(context),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                          SizedBox(height: CommonSize.s16(context)),

                          // From Section
                          Text(
                            'From:',
                            style: TextStyle(
                              color: const Color(0xFF002D62),
                              fontSize: CommonSize.s14(context),
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          SizedBox(height: CommonSize.s8(context)),

                          AccountInfoCard(
                            name: data['fromName'] ?? 'Ms. San',
                            accountNumber: data['fromAccount'] ?? '234-1-56643-6',
                            amount: '${data['amount'] ?? '588,000'} ${data['currency'] ?? 'Ks'}',
                            amountColor: const Color(0xFFFFA726),
                          ),

                          SizedBox(height: CommonSize.s20(context)),

                          // Direction Arrow
                          Center(
                            child: Container(
                              padding: EdgeInsets.all(CommonSize.s6(context)),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFFFFA726).withOpacity(0.1),
                              ),
                              child: Icon(
                                Icons.arrow_downward,
                                color: const Color(0xFFFFA726),
                                size: CommonSize.s20(context),
                              ),
                            ),
                          ),

                          SizedBox(height: CommonSize.s20(context)),

                          // To Section
                          Text(
                            'To:',
                            style: TextStyle(
                              color: const Color(0xFF002D62),
                              fontSize: CommonSize.s14(context),
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          SizedBox(height: CommonSize.s8(context)),

                          AccountInfoCard(
                            name: data['toName'] ?? 'Mr. Jhon',
                            accountNumber: data['toAccount'] ?? '671-2-67452-2',
                          ),

                          SizedBox(height: CommonSize.s16(context)),

                          // Divider
                          Container(
                            height: 1,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.transparent, const Color(0xFFFFA726), Colors.transparent],
                              ),
                            ),
                          ),

                          SizedBox(height: CommonSize.s12(context)),

                          // Amount Section
                          Container(
                            padding: EdgeInsets.symmetric(
                              vertical: CommonSize.s8(context),
                              horizontal: CommonSize.s12(context),
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8F9FA),
                              borderRadius: BorderRadius.circular(CommonSize.s6(context)),
                            ),
                            child: TransactionInfoRow(
                              label: 'Amount (Ks)',
                              value: '${data['amount'] ?? '588,000'} ${data['currency'] ?? 'Ks'}',
                              valueFontWeight: FontWeight.bold,
                              valueFontSize: CommonSize.s16(context),
                              labelFontSize: CommonSize.s14(context),
                              labelColor: const Color(0xFF002D62),
                              valueColor: const Color(0xFF002D62),
                            ),
                          ),

                          SizedBox(height: CommonSize.s8(context)),

                          // Transfer Fee
                          TransactionInfoRow(
                            label: 'Transfer fee',
                            value: '0 ${data['currency'] ?? 'Ks'}',
                            labelColor: const Color(0xFF6B7280),
                            valueColor: const Color(0xFF6B7280),
                            labelFontSize: CommonSize.s12(context),
                            valueFontSize: CommonSize.s12(context),
                          ),

                          SizedBox(height: CommonSize.s8(context)),

                          // Note
                          Container(
                            padding: EdgeInsets.symmetric(
                              vertical: CommonSize.s8(context),
                              horizontal: CommonSize.s12(context),
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFA726).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(CommonSize.s6(context)),
                            ),
                            child: TransactionInfoRow(
                              label: 'Note',
                              value: data['note'] ?? 'Testing',
                              labelColor: const Color(0xFFFFA726),
                              valueColor: const Color(0xFFFFA726),
                              labelFontSize: CommonSize.s12(context),
                              valueFontSize: CommonSize.s12(context),
                            ),
                          ),

                          // Timestamp footer
                          SizedBox(height: CommonSize.s16(context)),
                          Center(
                            child: Text(
                              'Saved: ${DateTime.now().toString().substring(0, 19)}',
                              style: TextStyle(
                                color: const Color(0xFF6B7280),
                                fontSize: CommonSize.s10(context),
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Set up nickname button - only show if user has no nicknames
          BlocBuilder<NicknameBloc, NicknameState>(
            builder: (context, nicknameState) {
              // Only show button if no nicknames exist and not loading
              final hasNicknames = nicknameState.items.isNotEmpty;
              final isLoading = nicknameState.isLoading && nicknameState.items.isEmpty;
              
              if (isLoading) {
                return Container(
                  height: 135,
                  child: const Center(child: CircularProgressIndicator(color: Colors.white)),
                );
              }

              if (hasNicknames) {
                // Don't show button if user already has nicknames
                return const SizedBox.shrink();
              }

              // Show button only if no nicknames exist
              return Container(
                height: 135,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () async {
                          // Navigate to create nickname screen
                          final res = await Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const NicknameCreateScreen()),
                          );

                          if (res is Map<String, dynamic>) {
                            final toAccountId = res['account']?.toString() ?? '';
                            final nickname = res['nickname']?.toString() ?? '';

                            if (toAccountId.isNotEmpty && nickname.isNotEmpty) {
                              // Create the nickname
                              context.read<NicknameBloc>().add(
                                CreateNickname(toAccountId: toAccountId, nickname: nickname),
                              );
                            }
                          }
                        },
                        child: Container(
                          width: CommonSize.s48(context),
                          height: CommonSize.s48(context),
                          decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFF0A3D62)),
                          child: const Icon(Icons.add, color: Colors.white, size: 20),
                        ),
                      ),

                      SizedBox(height: CommonSize.s6(context)),

                      Text(
                        'Set up nickname',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: CommonSize.s12(context),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.symmetric(horizontal: CommonSize.s40(context), vertical: CommonSize.s20(context)),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, -2))],
        ),
        child: customElevatedButton(
          context: context,
          onPressed: (_isSavingReceipt || _hasSavedReceipt) ? null : () => _saveReceiptAsImage(autoSave: false),
          text: _hasSavedReceipt ? 'Receipt Saved' : 'Save Receipt',
          color: const Color(0xFF0A3D62),
          textColor: Colors.white,
          borderRadius: BorderRadius.circular(CommonSize.s12(context)),
          height: CommonSize.s48(context),
          width: double.infinity,
          fontSize: CommonSize.s18(context),
          fontWeight: FontWeight.w600,
          isLoading: _isSavingReceipt,
        ),
      ),
    );
  }
}
