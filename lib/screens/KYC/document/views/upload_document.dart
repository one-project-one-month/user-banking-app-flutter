import 'package:banking_app/Routes/app_routes.dart';
import 'package:banking_app/screens/KYC/document/controllers/upload/upload_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../document/controllers/upload/upload_bloc.dart';
import '../../document/controllers/upload/upload_state.dart';

class UploadDocument extends StatefulWidget {
  const UploadDocument({super.key});

  @override
  _UploadDocumentState createState() => _UploadDocumentState();
}

class _UploadDocumentState extends State<UploadDocument> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _titleFade;
  late Animation<double> _contentFade;
  late Animation<Offset> _titleSlide;
  late Animation<Offset> _contentSlide;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2));

    _titleFade = CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.4));
    _contentFade = CurvedAnimation(parent: _controller, curve: const Interval(0.3, 0.7));

    _titleSlide = Tween(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.4)));
    _contentSlide = Tween(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: const Interval(0.3, 0.7)));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => UploadBloc()..add(UploadInitialEvent()),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF227DBE), Color.fromARGB(255, 10, 89, 146), Color(0xFF0A3D62)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16.0),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 600),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      FadeTransition(
                        opacity: _titleFade,
                        child: SlideTransition(
                          position: _titleSlide,
                          child: Text(
                            'Upload Document',
                            style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      FadeTransition(
                        opacity: _contentFade,
                        child: SlideTransition(
                          position: _contentSlide,
                          child: Column(
                            children: [
                              Container(
                                width: 200,
                                height: 200,
                                child: SvgPicture.asset('assets/svg/Scan.svg', fit: BoxFit.contain),
                              ),
                              SizedBox(height: 20),
                              Text(
                                'Select your identity',
                                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 20),
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: Colors.white),
                                      ),
                                      child: BlocBuilder<UploadBloc, UploadState>(
                                        builder: (context, state) {
                                          return RadioListTile(
                                            title: Text('Driving License', style: TextStyle(color: Colors.white)),
                                            value: 'driving_license',
                                            groupValue: state.selectedIdentity,
                                            onChanged: (value) {
                                              context.read<UploadBloc>().add(UploadIdentitySelected(value as String));
                                            },
                                            activeColor: Colors.white,
                                            fillColor: MaterialStateProperty.all(Colors.white),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: Colors.white),
                                      ),
                                      child: BlocBuilder<UploadBloc, UploadState>(
                                        builder: (context, state) {
                                          return RadioListTile(
                                            title: Text('Passport', style: TextStyle(color: Colors.white)),
                                            value: 'passport',
                                            groupValue: state.selectedIdentity,
                                            onChanged: (value) {
                                              context.read<UploadBloc>().add(UploadIdentitySelected(value as String));
                                            },
                                            activeColor: Colors.white,
                                            fillColor: MaterialStateProperty.all(Colors.white),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 20),
                              SizedBox(
                                width: double.infinity,
                                child: BlocBuilder<UploadBloc, UploadState>(
                                  builder: (context, state) {
                                    return ElevatedButton(
                                      onPressed: () {
                                        if (state.selectedIdentity == 'driving_license') {
                                          AppRoutes.navigateTo(context, AppRoutes.uploadDocumentDL);
                                        } else if (state.selectedIdentity == 'passport') {
                                          AppRoutes.navigateTo(context, AppRoutes.uploadDocumentPP);
                                        }
                                      },
                                      child: Text('Next'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        foregroundColor: Color(0xFF0A3D62),
                                        padding: EdgeInsets.symmetric(vertical: 15),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
