import 'package:banking_app/Routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../controllers/auth_bloc.dart';
import '../controllers/auth_event.dart';
import '../controllers/auth_state.dart';
import '../services/cache_service.dart';
import '../models/registration_options.dart';
import 'package:banking_app/screens/auth/widgets/app_logo.dart';
import 'package:banking_app/screens/auth/widgets/button.dart';
import 'package:banking_app/screens/auth/widgets/flushbar.dart';
import 'package:banking_app/screens/auth/widgets/size.dart';
import 'package:banking_app/screens/auth/widgets/textfield.dart';

/// ---------------------------------------------------------------
///  PersonalInfoScreen – receives the SAME AuthBloc from OTP screen
/// ---------------------------------------------------------------
class PersonalInfoScreen extends StatefulWidget {
  final AuthBloc authBloc; // <-- SAME instance

  const PersonalInfoScreen({super.key, required this.authBloc});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> with SingleTickerProviderStateMixin {
  // ──────────────────────────────────────────────────────────────────────
  // Controllers & Form
  // ──────────────────────────────────────────────────────────────────────
  final _fullNameController = TextEditingController();
  final _dayController = TextEditingController();
  final _monthController = TextEditingController();
  final _yearController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  // ──────────────────────────────────────────────────────────────────────
  // Dropdown data
  // ──────────────────────────────────────────────────────────────────────
  int? _selectedGenderId;
  int? _selectedNationalityId;
  List<OptionItem> _genderOptions = [];
  List<OptionItem> _nationalityOptions = [];

  // ──────────────────────────────────────────────────────────────────────
  // State helpers
  // ──────────────────────────────────────────────────────────────────────
  String? _verificationToken;
  bool _isLoadingOptions = true;

  // ──────────────────────────────────────────────────────────────────────
  // Animations (exactly as you had them)
  // ──────────────────────────────────────────────────────────────────────
  late final AnimationController _controller;
  late final Animation<double> _logoFade;
  late final Animation<double> _contentFade;
  late final Animation<double> _fieldsFade;
  late final Animation<double> _buttonFade;
  late final Animation<Offset> _logoSlide;
  late final Animation<Offset> _contentSlide;
  late final Animation<Offset> _fieldsSlide;
  late final Animation<Offset> _buttonSlide;

  @override
  void initState() {
    super.initState();

    // ---------- animations ----------
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2));

    _logoFade = CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.3));
    _contentFade = CurvedAnimation(parent: _controller, curve: const Interval(0.2, 0.6));
    _fieldsFade = CurvedAnimation(parent: _controller, curve: const Interval(0.5, 0.85));
    _buttonFade = CurvedAnimation(parent: _controller, curve: const Interval(0.8, 1.0));

    _logoSlide = Tween(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.3)));
    _contentSlide = Tween(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: const Interval(0.2, 0.6)));
    _fieldsSlide = Tween(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: const Interval(0.5, 0.85)));
    _buttonSlide = Tween(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: const Interval(0.8, 1.0)));

    _controller.forward();

    // ---------- load data ----------
    _loadInitialData();
  }

  // ──────────────────────────────────────────────────────────────────────
  // Load verification token + registration options
  // ──────────────────────────────────────────────────────────────────────
  Future<void> _loadInitialData() async {
    // 1. Token – from the SAME BLoC state
    final state = widget.authBloc.state;
    _verificationToken = state.verificationToken;

    if (_verificationToken == null || _verificationToken!.isEmpty) {
      _showError('Verification token missing – please start registration again.');
      return;
    }

    // 2. Options – try cache first
    final cache = CacheService();
    final cached = await cache.getRegistrationOptions();

    if (cached != null && cached.genderOptions.isNotEmpty) {
      _applyCachedOptions(cached);
    } else {
      // No cache → ask the SAME BLoC to fetch them
      widget.authBloc.add(AuthFetchRegistrationOptions());
    }
  }

  void _applyCachedOptions(RegistrationOptions opts) {
    setState(() {
      _genderOptions = opts.genderOptions;
      _nationalityOptions = opts.nationalityOptions;
      _selectedGenderId = _genderOptions.isNotEmpty ? _genderOptions.first.id : null;
      _selectedNationalityId = _nationalityOptions.isNotEmpty ? _nationalityOptions.first.id : null;
      _isLoadingOptions = false;
    });
  }

  void _showError(String msg) {
    customFlushbar(
      context: context,
      message: msg,
      backgroundColor: Colors.redAccent,
      icon: const Icon(Icons.error_outline, color: Colors.white),
    );
    setState(() => _isLoadingOptions = false);
  }

  // ──────────────────────────────────────────────────────────────────────
  // Submit
  // ──────────────────────────────────────────────────────────────────────
  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    if (_verificationToken == null) {
      _showError('Verification token missing.');
      return;
    }

    final day = _dayController.text.padLeft(2, '0');
    final month = _monthController.text.padLeft(2, '0');
    final year = _yearController.text;
    final dob = '$year-$month-$day';

    widget.authBloc.add(
      AuthSubmitPersonalDetails(
        verificationToken: _verificationToken!,
        fullname: _fullNameController.text.trim(),
        dateOfBirth: dob,
        genderId: _selectedGenderId!,
        nationalityId: _selectedNationalityId!,
        kycType: 'passport',
        kycData: '',
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────
  // UI
  // ──────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: widget.authBloc, // <-- SAME BLoC
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
          leading: IconButton(
            icon: Icon(
              Theme.of(context).platform == TargetPlatform.iOS ? Icons.arrow_back_ios : Icons.arrow_back,
              color: Colors.white,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Container(
          constraints: BoxConstraints.expand(height: MediaQuery.of(context).size.height),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF227DBE), Color.fromARGB(255, 10, 89, 146), Color(0xFF0A3D62)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(CommonSize.s20(context)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // ───── LOGO ─────
                    FadeTransition(
                      opacity: _logoFade,
                      child: SlideTransition(
                        position: _logoSlide,
                        child: AppLogo(width: 90, height: 90, borderRadius: 20),
                      ),
                    ),
                    SizedBox(height: CommonSize.s20(context)),

                    // ───── TITLE ─────
                    FadeTransition(
                      opacity: _contentFade,
                      child: SlideTransition(
                        position: _contentSlide,
                        child: Column(
                          children: [
                            Text(
                              'Personal Details',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: CommonSize.s24(context),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Tell us about yourself!',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: CommonSize.s14(context),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: CommonSize.s20(context)),

                    // ───── LOADING / FORM ─────
                    if (_isLoadingOptions)
                      const CircularProgressIndicator(color: Colors.white)
                    else
                      Form(
                        key: _formKey,
                        child: FadeTransition(
                          opacity: _fieldsFade,
                          child: SlideTransition(
                            position: _fieldsSlide,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // ── Full name ──
                                Text('Full name', style: TextStyle(color: Colors.white)),
                                SizedBox(height: CommonSize.s8(context)),
                                customTextField(
                                  controller: _fullNameController,
                                  hintText: 'Mr/Mrs/Miss Full Name',
                                  textStyle: const TextStyle(color: Colors.white),
                                  hintStyle: const TextStyle(color: Colors.white),
                                  prefixIcon: const Icon(Icons.person, color: Colors.white),
                                  borderColor: Colors.white,
                                  errorStyle: const TextStyle(color: Color.fromARGB(255, 240, 252, 2)),
                                  onEditingComplete: () => FocusScope.of(context).nextFocus(),
                                  validator: (v) => v?.isEmpty ?? true ? 'Enter your full name' : null,
                                ),
                                SizedBox(height: CommonSize.s12(context)),

                                // ── Date of birth ──
                                Text('Date of birth', style: TextStyle(color: Colors.white)),
                                SizedBox(height: CommonSize.s8(context)),
                                Row(
                                  children: [
                                    Expanded(
                                      child: customTextField(
                                        controller: _dayController,
                                        hintText: 'DD',
                                        keyboardType: TextInputType.number,
                                        inputFormatters: [
                                          FilteringTextInputFormatter.digitsOnly,
                                          LengthLimitingTextInputFormatter(2),
                                        ],
                                        borderColor: Colors.white,
                                        hintStyle: const TextStyle(color: Colors.white),
                                        textStyle: const TextStyle(color: Colors.white),
                                        errorStyle: const TextStyle(color: Color.fromARGB(255, 240, 252, 2)),
                                        onEditingComplete: () => FocusScope.of(context).nextFocus(),
                                        validator: (v) {
                                          if (v == null || v.isEmpty) return 'DD';
                                          final n = int.tryParse(v);
                                          if (n == null || n < 1 || n > 31) return 'Invalid';
                                          return null;
                                        },
                                      ),
                                    ),
                                    SizedBox(width: CommonSize.s8(context)),
                                    Expanded(
                                      child: customTextField(
                                        controller: _monthController,
                                        hintText: 'MM',
                                        keyboardType: TextInputType.number,
                                        inputFormatters: [
                                          FilteringTextInputFormatter.digitsOnly,
                                          LengthLimitingTextInputFormatter(2),
                                        ],
                                        borderColor: Colors.white,
                                        hintStyle: const TextStyle(color: Colors.white),
                                        textStyle: const TextStyle(color: Colors.white),
                                        errorStyle: const TextStyle(color: Color.fromARGB(255, 240, 252, 2)),
                                        onEditingComplete: () => FocusScope.of(context).nextFocus(),
                                        validator: (v) {
                                          if (v == null || v.isEmpty) return 'MM';
                                          final n = int.tryParse(v);
                                          if (n == null || n < 1 || n > 12) return 'Invalid';
                                          return null;
                                        },
                                      ),
                                    ),
                                    SizedBox(width: CommonSize.s8(context)),
                                    Expanded(
                                      child: customTextField(
                                        controller: _yearController,
                                        hintText: 'YYYY',
                                        keyboardType: TextInputType.number,
                                        inputFormatters: [
                                          FilteringTextInputFormatter.digitsOnly,
                                          LengthLimitingTextInputFormatter(4),
                                        ],
                                        borderColor: Colors.white,
                                        hintStyle: const TextStyle(color: Colors.white),
                                        textStyle: const TextStyle(color: Colors.white),
                                        errorStyle: const TextStyle(color: Color.fromARGB(255, 240, 252, 2)),
                                        onEditingComplete: () => FocusScope.of(context).unfocus(),
                                        validator: (v) {
                                          if (v == null || v.isEmpty) return 'YYYY';
                                          final n = int.tryParse(v);
                                          final now = DateTime.now().year;
                                          if (n == null || n < 1900 || n > now) return 'Invalid';
                                          return null;
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: CommonSize.s12(context)),

                                // ── Gender ──
                                DropdownButtonFormField<int>(
                                  value: _selectedGenderId,
                                  items:
                                      _genderOptions
                                          .map((g) => DropdownMenuItem(value: g.id, child: Text(g.name)))
                                          .toList(),
                                  onChanged: (v) => setState(() => _selectedGenderId = v),
                                  decoration: InputDecoration(
                                    labelText: 'Gender',
                                    labelStyle: const TextStyle(color: Colors.white),
                                    prefixIcon: const Icon(Icons.wc, color: Colors.white),
                                    enabledBorder: UnderlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: const BorderSide(color: Colors.white),
                                    ),
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide: const BorderSide(color: Colors.white, width: 2),
                                    ),
                                  ),
                                  icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                                  dropdownColor: const Color(0xFF0A3D62),
                                  style: const TextStyle(color: Colors.white),
                                  validator: (v) => v == null ? 'Select gender' : null,
                                ),
                                SizedBox(height: CommonSize.s12(context)),

                                // ── Nationality ──
                                DropdownButtonFormField<int>(
                                  value: _selectedNationalityId,
                                  items:
                                      _nationalityOptions
                                          .map((n) => DropdownMenuItem(value: n.id, child: Text(n.name)))
                                          .toList(),
                                  onChanged: (v) => setState(() => _selectedNationalityId = v),
                                  decoration: InputDecoration(
                                    labelText: 'Nationality',
                                    labelStyle: const TextStyle(color: Colors.white),
                                    prefixIcon: const Icon(Icons.people, color: Colors.white),
                                    enabledBorder: UnderlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: const BorderSide(color: Colors.white),
                                    ),
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide: const BorderSide(color: Colors.white, width: 2),
                                    ),
                                  ),
                                  icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                                  dropdownColor: const Color(0xFF0A3D62),
                                  style: const TextStyle(color: Colors.white),
                                  validator: (v) => v == null ? 'Select nationality' : null,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    SizedBox(height: CommonSize.s32(context)),

                    // ───── SUBMIT BUTTON ─────
                    FadeTransition(
                      opacity: _buttonFade,
                      child: SlideTransition(
                        position: _buttonSlide,
                        child: BlocConsumer<AuthBloc, AuthState>(
                          listener: (context, state) {
                            // ---- Options fetched from server ----
                            if (state.status == AuthStatus.success && _genderOptions.isEmpty) {
                              CacheService().getRegistrationOptions().then((opts) {
                                if (opts != null) _applyCachedOptions(opts);
                              });
                            }

                            // ---- Registration finished ----
                            if (state.status == AuthStatus.success &&
                                state.message == 'Registration completed successfully') {
                              customFlushbar(
                                context: context,
                                message: 'Registration successful!',
                                backgroundColor: Colors.green,
                                icon: const Icon(Icons.check_circle, color: Colors.white),
                              );

                              Future.delayed(const Duration(seconds: 1), () {
                                AppRoutes.navigateTo(context, AppRoutes.home_screen);
                              });
                            }

                            // ---- Errors ----
                            if (state.status == AuthStatus.failure) {
                              customFlushbar(
                                context: context,
                                message: state.message ?? 'Registration failed',
                                backgroundColor: Colors.redAccent,
                              );
                            }
                          },
                          builder: (context, state) {
                            final isLoading = state.status == AuthStatus.loading;

                            return customElevatedButton(
                              onPressed: () {
                                if (!isLoading) {
                                  _submit();
                                }
                              },
                              text: 'Next',
                              color: Colors.white,
                              textColor: const Color(0xFF0A3D62),
                              borderRadius: BorderRadius.circular(CommonSize.s10(context)),
                              height: CommonSize.s48(context),
                              width: double.infinity,
                              fontSize: CommonSize.s18(context),
                              fontWeight: FontWeight.w600,
                              isLoading: isLoading,
                            );
                          },
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
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _fullNameController.dispose();
    _dayController.dispose();
    _monthController.dispose();
    _yearController.dispose();
    super.dispose();
  }
}
