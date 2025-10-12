import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../controllers/auth_bloc.dart';
import '../controllers/auth_event.dart';
import '../controllers/auth_state.dart';
import 'package:banking_app/screens/auth/widgets/app_logo.dart';
import 'package:banking_app/screens/auth/widgets/button.dart';
import 'package:banking_app/screens/auth/widgets/flushbar.dart';
import 'package:banking_app/screens/auth/widgets/size.dart';
import 'package:banking_app/screens/auth/widgets/textfield.dart';
import '../../home/home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _fullNameController = TextEditingController();
  final _dayController = TextEditingController();
  final _monthController = TextEditingController();
  final _yearController = TextEditingController();

  String? _gender;
  String _nationality = 'NRC';
  final _formKey = GlobalKey<FormState>();

  late AnimationController _controller;
  late Animation<double> _logoFade;
  late Animation<double> _contentFade;
  late Animation<double> _buttonFade;
  late Animation<double> _fieldsFade;
  late Animation<Offset> _logoSlide;
  late Animation<Offset> _contentSlide;
  late Animation<Offset> _buttonSlide;
  late Animation<Offset> _fieldsSlide;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _logoFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.3),
    );
    _contentFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.2, 0.6),
    );
    _fieldsFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.5, 0.85),
    );
    _buttonFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.8, 1.0),
    );

    _logoSlide = Tween(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.3)),
    );
    _contentSlide = Tween(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.2, 0.6)),
    );
    _fieldsSlide = Tween(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.5, 0.85)),
    );
    _buttonSlide = Tween(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.8, 1.0)),
    );

    _controller.forward();
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

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final payload = {
      'fullName': _fullNameController.text.trim(),
      'dob':
          '${_dayController.text}-${_monthController.text}-${_yearController.text}',
      'gender': _gender,
      'nationality': _nationality,
    };

    context.read<AuthBloc>().add(AuthRegisterSubmitted(payload));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AuthBloc(),
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF227DBE),
                Color.fromARGB(255, 10, 89, 146),
                Color(0xFF0A3D62),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.all(CommonSize.s20(context)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Align(
                    alignment: AlignmentGeometry.topLeft,
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Theme.of(context).platform == TargetPlatform.iOS
                            ? Icons.arrow_back_ios
                            : Icons.arrow_back,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  FadeTransition(
                    opacity: _logoFade,
                    child: SlideTransition(
                      position: _logoSlide,
                      child: AppLogo(width: 90, height: 90, borderRadius: 20),
                    ),
                  ),
                  SizedBox(height: CommonSize.s20(context)),
                  FadeTransition(
                    opacity: _contentFade,
                    child: SlideTransition(
                      position: _contentSlide,
                      child: Text(
                        'Create your account',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: CommonSize.s24(context),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: CommonSize.s20(context)),
                  Form(
                    key: _formKey,
                    child: FadeTransition(
                      opacity: _fieldsFade,
                      child: SlideTransition(
                        position: _fieldsSlide,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Full name',
                              style: TextStyle(color: Colors.white),
                            ),
                            SizedBox(height: CommonSize.s8(context)),
                            customTextField(
                              controller: _fullNameController,
                              hintText: 'Mr/Mrs/Miss',
                              textStyle: const TextStyle(color: Colors.white),
                              hintStyle: const TextStyle(color: Colors.white),
                              prefixIcon: const Icon(
                                Icons.person,
                                color: Colors.white,
                              ),
                              borderColor: Colors.white,
                              validator: (v) {
                                if (v == null || v.isEmpty)
                                  return 'Enter your full name';
                                return null;
                              },
                            ),
                            SizedBox(height: CommonSize.s12(context)),

                            Text(
                              'Date of birth',
                              style: TextStyle(color: Colors.white),
                            ),
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
                                    hintStyle: const TextStyle(
                                      color: Colors.white,
                                    ),
                                    textStyle: const TextStyle(
                                      color: Colors.white,
                                    ),
                                    borderColor: Colors.white,
                                    validator: (v) {
                                      if (v == null || v.isEmpty) return 'DD';
                                      final val = int.tryParse(v);
                                      if (val == null || val < 1 || val > 31)
                                        return 'Invalid';
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
                                    hintStyle: const TextStyle(
                                      color: Colors.white,
                                    ),
                                    textStyle: const TextStyle(
                                      color: Colors.white,
                                    ),
                                    borderColor: Colors.white,
                                    validator: (v) {
                                      if (v == null || v.isEmpty) return 'MM';
                                      final val = int.tryParse(v);
                                      if (val == null || val < 1 || val > 12)
                                        return 'Invalid';
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
                                    hintStyle: const TextStyle(
                                      color: Colors.white,
                                    ),
                                    textStyle: const TextStyle(
                                      color: Colors.white,
                                    ),
                                    borderColor: Colors.white,
                                    validator: (v) {
                                      if (v == null || v.isEmpty) return 'YYYY';
                                      final val = int.tryParse(v);
                                      final current = DateTime.now().year;
                                      if (val == null ||
                                          val < 1900 ||
                                          val > current)
                                        return 'Invalid';
                                      return null;
                                    },
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: CommonSize.s12(context)),
                            DropdownButtonFormField<String>(
                              value: _gender,
                              items:
                                  ['Male', 'Female', 'Other']
                                      .map(
                                        (g) => DropdownMenuItem(
                                          value: g,
                                          child: Text(g),
                                        ),
                                      )
                                      .toList(),
                              onChanged: (v) => setState(() => _gender = v),
                              decoration: InputDecoration(
                                labelText: 'Gender',
                                labelStyle: const TextStyle(
                                  color: Colors.white,
                                ),
                                prefixIcon: const Icon(
                                  Icons.wc,
                                  color: Colors.white,
                                ),
                                enabledBorder: UnderlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                  borderSide: const BorderSide(
                                    color: Colors.white,
                                  ),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: const BorderSide(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                ),
                              ),
                              icon: const Icon(
                                Icons.arrow_drop_down,
                                color: Colors.white,
                              ),
                              dropdownColor: const Color(0xFF0A3D62),
                              style: const TextStyle(color: Colors.white),
                              validator: (v) {
                                if (v == null || v.isEmpty)
                                  return 'Select gender';
                                return null;
                              },
                            ),

                            SizedBox(height: CommonSize.s12(context)),
                            Text(
                              'Nationality',
                              style: TextStyle(color: Colors.white),
                            ),
                            SizedBox(height: CommonSize.s8(context)),
                            Wrap(
                              spacing: 8,
                              children:
                                  ['NRC', 'Passport'].map((opt) {
                                    final selected = _nationality == opt;
                                    return ChoiceChip(
                                      label: Text(
                                        opt,
                                        style: TextStyle(
                                          color:
                                              selected
                                                  ? Colors.white
                                                  : Colors.black,
                                        ),
                                      ),
                                      selected: selected,
                                      onSelected: (sel) {
                                        if (sel)
                                          setState(() => _nationality = opt);
                                      },
                                      selectedColor: Colors.blueAccent,
                                      backgroundColor: Colors.white,
                                    );
                                  }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: CommonSize.s32(context)),
                  FadeTransition(
                    opacity: _buttonFade,
                    child: SlideTransition(
                      position: _buttonSlide,
                      child: Padding(
                        padding: EdgeInsets.only(
                          bottom: CommonSize.s8(context),
                        ),
                        child: BlocConsumer<AuthBloc, AuthState>(
                          listener: (context, state) {
                            // if (state.status == AuthStatus.success) {
                            //   customFlushbar(
                            //     context: context,
                            //     message: 'Registration successful',
                            //     backgroundColor: Colors.green,
                            //     icon: const Icon(
                            //       Icons.check_circle,
                            //       color: Colors.white,
                            //     ),
                            //   );
                            //   Navigator.of(context).pushReplacement(
                            //     MaterialPageRoute(
                            //       builder: (_) => const HomeScreen(),
                            //     ),
                            //   );
                            // } else if (state.status == AuthStatus.failure) {
                            //   customFlushbar(
                            //     context: context,
                            //     message: state.message ?? 'Registration failed',
                            //   );
                            // }
                          },
                          builder: (context, state) {
                            final isLoading =
                                state.status == AuthStatus.loading;
                            return customElevatedButton(
                              onPressed: () {}, //_submit,
                              text: 'Next',
                              color: Colors.white,
                              textColor: const Color(0xFF0A3D62),
                              borderRadius: BorderRadius.circular(
                                CommonSize.s10(context),
                              ),
                              height: CommonSize.s48(context),
                              width: double.infinity,
                              fontSize: CommonSize.s18(context),
                              fontWeight: FontWeight.w600,
                              // isLoading: isLoading,
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
