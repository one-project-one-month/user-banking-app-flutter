import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:banking_app/screens/Settings/controllers/settings_bloc.dart';
import 'package:banking_app/screens/Settings/controllers/settings_event.dart';
import 'package:banking_app/screens/Settings/controllers/settings_state.dart';

class SetPinDialog extends StatefulWidget {
  const SetPinDialog({super.key});

  @override
  State<SetPinDialog> createState() => _SetPinDialogState();
}

class _SetPinDialogState extends State<SetPinDialog> {
  String _newPin = '';
  String _confirmPin = '';
  bool _isSettingNewPin = true;
  final int _pinLength = 6;

  void _onKeyPressed(String digit) {
    setState(() {
      if (_isSettingNewPin) {
        if (_newPin.length < _pinLength) {
          _newPin += digit;
          if (_newPin.length == _pinLength) {
            // Move to confirmation
            Future.delayed(const Duration(milliseconds: 300), () {
              if (mounted) {
                setState(() {
                  _isSettingNewPin = false;
                });
              }
            });
          }
        }
      } else {
        if (_confirmPin.length < _pinLength) {
          _confirmPin += digit;
          if (_confirmPin.length == _pinLength) {
            // Verify and submit
            _verifyAndSubmit();
          }
        }
      }
    });
  }

  void _onBackspace() {
    setState(() {
      if (_isSettingNewPin) {
        if (_newPin.isNotEmpty) {
          _newPin = _newPin.substring(0, _newPin.length - 1);
        }
      } else {
        if (_confirmPin.isNotEmpty) {
          _confirmPin = _confirmPin.substring(0, _confirmPin.length - 1);
        }
      }
    });
  }

  void _verifyAndSubmit() {
    if (_newPin == _confirmPin) {
      // PINs match, submit to API
      context.read<SettingsBloc>().add(SettingsSetPin(_newPin));
    } else {
      // PINs don't match
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'PINs do not match. Please try again.',
            style: GoogleFonts.inter(),
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      
      // Reset
      setState(() {
        _newPin = '';
        _confirmPin = '';
        _isSettingNewPin = true;
      });
    }
  }

  void _reset() {
    setState(() {
      _newPin = '';
      _confirmPin = '';
      _isSettingNewPin = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: BlocListener<SettingsBloc, SettingsState>(
        listener: (context, state) {
          if (state.isSuccess && state.message != null && state.message!.contains('PIN')) {
            // Success - close dialog
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.message!,
                  style: GoogleFonts.inter(),
                ),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
          } else if (state.hasError && state.errorMessage != null) {
            // Error - show message and reset
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.errorMessage!,
                  style: GoogleFonts.inter(),
                ),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
              ),
            );
            _reset();
          }
        },
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Set Transaction PIN',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: theme.textTheme.titleLarge?.color ?? Colors.black,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Lock Icon
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: const Color(0xFF3366FF).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.lock_outline,
                  size: 32,
                  color: Color(0xFF3366FF),
                ),
              ),

              const SizedBox(height: 24),

              // Instructions
              Text(
                _isSettingNewPin ? 'Enter new 6-digit PIN' : 'Confirm your PIN',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: theme.textTheme.titleLarge?.color ?? Colors.black87,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                _isSettingNewPin
                    ? 'Choose a secure PIN for transactions'
                    : 'Enter your PIN again to confirm',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 32),

              // PIN Display
              _buildPinDisplay(),

              const SizedBox(height: 32),

              // Numeric Keypad
              _buildNumericKeypad(),

              const SizedBox(height: 16),

              // Reset button (only show during confirmation)
              if (!_isSettingNewPin)
                TextButton(
                  onPressed: _reset,
                  child: Text(
                    'Start Over',
                    style: GoogleFonts.inter(
                      color: const Color(0xFF3366FF),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

              // Loading indicator
              BlocBuilder<SettingsBloc, SettingsState>(
                builder: (context, state) {
                  if (state.isLoading) {
                    return const Padding(
                      padding: EdgeInsets.only(top: 16),
                      child: CircularProgressIndicator(),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPinDisplay() {
    final currentPin = _isSettingNewPin ? _newPin : _confirmPin;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_pinLength, (index) {
        final isFilled = index < currentPin.length;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isFilled ? const Color(0xFF3366FF) : Colors.transparent,
            border: Border.all(
              color: isFilled ? const Color(0xFF3366FF) : Colors.grey.shade300,
              width: 2,
            ),
          ),
        );
      }),
    );
  }

  Widget _buildNumericKeypad() {
    return Column(
      children: [
        // Rows 1-3: Numbers 1-9
        for (int row = 0; row < 3; row++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (int col = 0; col < 3; col++)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: _buildKeypadButton('${row * 3 + col + 1}'),
                  ),
              ],
            ),
          ),

        // Row 4: Empty space, 0, Backspace
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Empty space
              const SizedBox(width: 64 + 24),

              // 0 button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: _buildKeypadButton('0'),
              ),

              // Backspace button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: _buildKeypadButton(
                  '',
                  icon: Icons.backspace_outlined,
                  onPressed: _onBackspace,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildKeypadButton(String text, {IconData? icon, VoidCallback? onPressed}) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        if (onPressed != null) {
          onPressed();
        } else {
          _onKeyPressed(text);
        }
      },
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.grey.shade100,
        ),
        child: Center(
          child: icon != null
              ? Icon(icon, size: 24, color: Colors.grey.shade700)
              : Text(
                  text,
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade800,
                  ),
                ),
        ),
      ),
    );
  }
}