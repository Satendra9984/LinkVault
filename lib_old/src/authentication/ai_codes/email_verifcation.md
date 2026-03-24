// 1. First, update your RoutePaths to include email verification routes
class RoutePaths {
  // ... your existing routes
  static const String verifyEmail = 'verify-email';
  static const String emailVerified = '/email-verified'; // New route for successful verification
  static const String emailVerificationError = '/email-verification-error'; // New route for errors
}

// 2. Update your auth_routes.dart
final authRoutesProvider = Provider(
  (ref) {
    return [
      GoRoute(
        path: RoutePaths.authHome,
        builder: (context, state) => const AuthHome(),
      ),
      GoRoute(
        path: RoutePaths.login,
        builder: (context, state) {
          final returnPath = state.pathParameters[RouteParams.returnToPath];

          return BlocProvider.value(
            value: ref.watch(loginBlocProvider),
            child: LoginPage(
              returnPath: returnPath,
            ),
          );
        },
        routes: [
          GoRoute(
            path: RoutePaths.forgetPassword,
            builder: (context, state) {
              final email = state.uri.queryParameters['email'];
              return BlocProvider.value(
                value: ref.watch(forgetPasswordBlocProvider),
                child: ForgetPasswordResetPage(
                  email: email,
                ),
              );
            },
          ),
          GoRoute(
            path: RoutePaths.checkEmail,
            builder: (context, state) {
              final email = state.pathParameters['email'] ?? '';
              return ForgetPasswordCheckEmailPage(
                email: email,
              );
            },
          ),
        ],
      ),
      GoRoute(
        path: RoutePaths.signUp,
        builder: (context, state) => BlocProvider.value(
          value: ref.watch(signupBlocProvider),
          child: const SignUpPage(),
        ),
        routes: [
          GoRoute(
            path: RoutePaths.verifyEmail,
            builder: (context, state) {
              final email = state.uri.queryParameters['email'] ?? '';
              return BlocProvider.value(
                value: ref.watch(emailVerificationBlocProvider),
                child: VerifyEmailPage(
                  email: email,
                ),
              );
            },
          ),
        ],
      ),
      // New routes for email verification deeplinks
      GoRoute(
        path: RoutePaths.emailVerified,
        builder: (context, state) {
          final token = state.uri.queryParameters['token'];
          final type = state.uri.queryParameters['type'];
          
          return BlocProvider.value(
            value: ref.watch(emailVerificationBlocProvider),
            child: EmailVerifiedPage(
              token: token,
              type: type,
            ),
          );
        },
      ),
      GoRoute(
        path: RoutePaths.emailVerificationError,
        builder: (context, state) {
          final error = state.uri.queryParameters['error'];
          final errorDescription = state.uri.queryParameters['error_description'];
          
          return EmailVerificationErrorPage(
            error: error,
            errorDescription: errorDescription,
          );
        },
      ),
    ];
  },
);

// 3. Email Verification Bloc
class EmailVerificationBloc extends Bloc<EmailVerificationEvent, EmailVerificationState> {
  final AuthRepository _authRepository;

  EmailVerificationBloc({
    required AuthRepository authRepository,
  })  : _authRepository = authRepository,
        super(EmailVerificationInitial()) {
    on<ResendVerificationEmail>(_onResendVerificationEmail);
    on<VerifyEmailToken>(_onVerifyEmailToken);
  }

  Future<void> _onResendVerificationEmail(
    ResendVerificationEmail event,
    Emitter<EmailVerificationState> emit,
  ) async {
    emit(EmailVerificationLoading());
    
    try {
      await _authRepository.resendEmailVerification(event.email);
      emit(EmailVerificationResent());
    } catch (e) {
      emit(EmailVerificationError(e.toString()));
    }
  }

  Future<void> _onVerifyEmailToken(
    VerifyEmailToken event,
    Emitter<EmailVerificationState> emit,
  ) async {
    emit(EmailVerificationLoading());
    
    try {
      final result = await _authRepository.verifyEmailToken(
        token: event.token,
        type: event.type,
      );
      
      if (result.isSuccess) {
        emit(EmailVerificationSuccess());
      } else {
        emit(EmailVerificationError(result.error ?? 'Verification failed'));
      }
    } catch (e) {
      emit(EmailVerificationError(e.toString()));
    }
  }
}

// 4. Email Verification Events
abstract class EmailVerificationEvent {}

class ResendVerificationEmail extends EmailVerificationEvent {
  final String email;
  ResendVerificationEmail(this.email);
}

class VerifyEmailToken extends EmailVerificationEvent {
  final String token;
  final String type;
  
  VerifyEmailToken({
    required this.token,
    required this.type,
  });
}

// 5. Email Verification States
abstract class EmailVerificationState {}

class EmailVerificationInitial extends EmailVerificationState {}
class EmailVerificationLoading extends EmailVerificationState {}
class EmailVerificationResent extends EmailVerificationState {}
class EmailVerificationSuccess extends EmailVerificationState {}

class EmailVerificationError extends EmailVerificationState {
  final String message;
  EmailVerificationError(this.message);
}

// 6. Repository method for email verification
abstract class AuthRepository {
  // ... your existing methods
  
  Future<void> resendEmailVerification(String email);
  Future<AuthResult> verifyEmailToken({
    required String token,
    required String type,
  });
}

class AuthRepositoryImpl implements AuthRepository {
  final SupabaseClient _supabase;
  
  AuthRepositoryImpl(this._supabase);
  
  @override
  Future<void> resendEmailVerification(String email) async {
    final response = await _supabase.auth.resend(
      type: OtpType.signup,
      email: email,
    );
    
    if (response.error != null) {
      throw Exception(response.error!.message);
    }
  }
  
  @override
  Future<AuthResult> verifyEmailToken({
    required String token,
    required String type,
  }) async {
    try {
      final response = await _supabase.auth.verifyOTP(
        token: token,
        type: OtpType.signup,
      );
      
      if (response.error != null) {
        return AuthResult.failure(response.error!.message);
      }
      
      return AuthResult.success(response.user);
    } catch (e) {
      return AuthResult.failure(e.toString());
    }
  }
}

// 7. VerifyEmailPage (the page shown after signup)
class VerifyEmailPage extends StatelessWidget {
  final String email;
  
  const VerifyEmailPage({
    Key? key,
    required this.email,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Your Email'),
      ),
      body: BlocConsumer<EmailVerificationBloc, EmailVerificationState>(
        listener: (context, state) {
          if (state is EmailVerificationResent) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Verification email sent! Please check your inbox.'),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is EmailVerificationError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.email_outlined,
                  size: 80,
                  color: Colors.blue,
                ),
                const SizedBox(height: 24),
                Text(
                  'Check Your Email',
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'We\'ve sent a verification link to\n$email',
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Click the link in the email to verify your account.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                if (state is EmailVerificationLoading)
                  const CircularProgressIndicator()
                else
                  Column(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          context.read<EmailVerificationBloc>().add(
                            ResendVerificationEmail(email),
                          );
                        },
                        child: const Text('Resend Email'),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () {
                          context.go(RoutePaths.login);
                        },
                        child: const Text('Back to Login'),
                      ),
                    ],
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// 8. EmailVerifiedPage (deeplink destination for successful verification)
class EmailVerifiedPage extends StatefulWidget {
  final String? token;
  final String? type;
  
  const EmailVerifiedPage({
    Key? key,
    this.token,
    this.type,
  }) : super(key: key);

  @override
  State<EmailVerifiedPage> createState() => _EmailVerifiedPageState();
}

class _EmailVerifiedPageState extends State<EmailVerifiedPage> {
  @override
  void initState() {
    super.initState();
    // Automatically verify the token when the page loads
    if (widget.token != null && widget.type != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<EmailVerificationBloc>().add(
          VerifyEmailToken(
            token: widget.token!,
            type: widget.type!,
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<EmailVerificationBloc, EmailVerificationState>(
        listener: (context, state) {
          if (state is EmailVerificationSuccess) {
            // Show success message and navigate to login after delay
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Email verified successfully!'),
                backgroundColor: Colors.green,
              ),
            );
            Future.delayed(const Duration(seconds: 2), () {
              context.go(RoutePaths.login);
            });
          } else if (state is EmailVerificationError) {
            // Navigate to error page
            context.go('${RoutePaths.emailVerificationError}?error=${Uri.encodeComponent(state.message)}');
          }
        },
        builder: (context, state) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (state is EmailVerificationLoading) ...[
                    const CircularProgressIndicator(),
                    const SizedBox(height: 24),
                    const Text('Verifying your email...'),
                  ] else if (state is EmailVerificationSuccess) ...[
                    const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 80,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Email Verified!',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Your email has been successfully verified.\nRedirecting to login...',
                      textAlign: TextAlign.center,
                    ),
                  ] else ...[
                    const Icon(
                      Icons.error_outline,
                      color: Colors.orange,
                      size: 80,
                    ),
                    const SizedBox(height: 24),
                    const Text('Verifying...'),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// 9. EmailVerificationErrorPage (deeplink destination for failed verification)
class EmailVerificationErrorPage extends StatelessWidget {
  final String? error;
  final String? errorDescription;
  
  const EmailVerificationErrorPage({
    Key? key,
    this.error,
    this.errorDescription,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verification Error'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 80,
              ),
              const SizedBox(height: 24),
              Text(
                'Verification Failed',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 16),
              Text(
                errorDescription ?? error ?? 'An error occurred during email verification.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  context.go(RoutePaths.login);
                },
                child: const Text('Back to Login'),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  context.go(RoutePaths.signUp);
                },
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 10. Update your signup flow
class SignUpBloc extends Bloc<SignUpEvent, SignUpState> {
  final AuthRepository _authRepository;

  SignUpBloc({
    required AuthRepository authRepository,
  })  : _authRepository = authRepository,
        super(SignUpInitial()) {
    on<SignUpSubmitted>(_onSignUpSubmitted);
  }

  Future<void> _onSignUpSubmitted(
    SignUpSubmitted event,
    Emitter<SignUpState> emit,
  ) async {
    emit(SignUpLoading());
    
    try {
      await _authRepository.signUp(
        email: event.email,
        password: event.password,
      );
      
      emit(SignUpSuccess(email: event.email));
    } catch (e) {
      emit(SignUpError(e.toString()));
    }
  }
}

// Update SignUpSuccess state to include email
class SignUpSuccess extends SignUpState {
  final String email;
  SignUpSuccess({required this.email});
}

// In your SignUpPage, handle navigation in the BlocListener
class SignUpPage extends StatelessWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<SignUpBloc, SignUpState>(
        listener: (context, state) {
          if (state is SignUpSuccess) {
            // Navigate to verify email page after successful signup
            context.go('${RoutePaths.signUp}/${RoutePaths.verifyEmail}?email=${Uri.encodeComponent(state.email)}');
          } else if (state is SignUpError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          // Your signup form UI here
          return const Center(child: Text('Signup Form'));
        },
      ),
    );
  }
}

// 11. Supabase Configuration
// In your Supabase dashboard, configure the email verification redirect URL to:
// For development: your-app-scheme://email-verified
// For production: your-app-scheme://email-verified
// 
// The URL should be: your-app-scheme://email-verified?token={token}&type={type}

// 12. Provider for EmailVerificationBloc
final emailVerificationBlocProvider = Provider(
  (ref) => EmailVerificationBloc(
    authRepository: ref.watch(authRepositoryProvider),
    navigationService: ref.watch(appNavigationProvider),
  ),
);

// 13. DeepLink Service (Clean Architecture Approach)
abstract class DeepLinkService {
  Stream<String> get linkStream;
  Future<String?> getInitialLink();
  void dispose();
}

class DeepLinkServiceImpl implements DeepLinkService {
  StreamSubscription<String>? _linkSubscription;
  final StreamController<String> _linkController = StreamController<String>.broadcast();

  @override
  Stream<String> get linkStream => _linkController.stream;

  DeepLinkServiceImpl() {
    _initialize();
  }

  void _initialize() {
    // Handle incoming links while app is running
    _linkSubscription = uni_links.linkStream.listen(
      (String link) {
        _linkController.add(link);
      },
      onError: (err) {
        // Log error or handle gracefully
      },
    );
  }

  @override
  Future<String?> getInitialLink() async {
    try {
      return await uni_links.getInitialLink();
    } catch (e) {
      return null;
    }
  }

  @Override
  void dispose() {
    _linkSubscription?.cancel();
    _linkController.close();
  }
}

// 14. DeepLink Handler (Business Logic)
class DeepLinkHandler {
  final DeepLinkService _deepLinkService;
  final GlobalKey<NavigatorState> _navigatorKey;

  DeepLinkHandler({
    required DeepLinkService deepLinkService,
    required GlobalKey<NavigatorState> navigatorKey,
  })  : _deepLinkService = deepLinkService,
        _navigatorKey = navigatorKey;

  void initialize() {
    _handleInitialLink();
    _handleIncomingLinks();
  }

  Future<void> _handleInitialLink() async {
    final initialLink = await _deepLinkService.getInitialLink();
    if (initialLink != null) {
      _processDeepLink(initialLink);
    }
  }

  void _handleIncomingLinks() {
    _deepLinkService.linkStream.listen(
      (String link) {
        _processDeepLink(link);
      },
    );
  }

  void _processDeepLink(String link) {
    final uri = Uri.parse(link);
    final context = _navigatorKey.currentContext;
    
    if (context == null) return;
    
    switch (uri.path) {
      case '/email-verified':
        _handleEmailVerification(context, uri);
        break;
      case '/password-reset':
        _handlePasswordReset(context, uri);
        break;
      // Add more deeplink handlers as needed
      default:
        // Handle unknown deeplinks or navigate to home
        break;
    }
  }

  void _handleEmailVerification(BuildContext context, Uri uri) {
    final token = uri.queryParameters['token'];
    final type = uri.queryParameters['type'];
    
    if (token != null && type != null) {
      context.go('${RoutePaths.emailVerified}?token=${Uri.encodeComponent(token)}&type=${Uri.encodeComponent(type)}');
    } else {
      // Handle malformed verification link
      context.go('${RoutePaths.emailVerificationError}?error=${Uri.encodeComponent('Invalid verification link')}');
    }
  }

  void _handlePasswordReset(BuildContext context, Uri uri) {
    // Handle password reset deeplinks
    final token = uri.queryParameters['token'];
    if (token != null) {
      context.go('${RoutePaths.login}/${RoutePaths.forgetPassword}?token=${Uri.encodeComponent(token)}');
    }
  }

  void dispose() {
    _deepLinkService.dispose();
  }
}

// 15. App Initialization Service
class AppInitializationService {
  final DeepLinkHandler _deepLinkHandler;
  
  AppInitializationService({
    required DeepLinkHandler deepLinkHandler,
  }) : _deepLinkHandler = deepLinkHandler;

  Future<void> initialize() async {
    // Initialize deeplink handling
    _deepLinkHandler.initialize();
    
    // Add other app initialization logic here
    // - Firebase initialization
    // - Analytics setup
    // - Crash reporting setup
    // etc.
  }

  void dispose() {
    _deepLinkHandler.dispose();
  }
}

// 16. Providers
final deepLinkServiceProvider = Provider<DeepLinkService>(
  (ref) => DeepLinkServiceImpl(),
);

final deepLinkHandlerProvider = Provider<DeepLinkHandler>(
  (ref) => DeepLinkHandler(
    deepLinkService: ref.watch(deepLinkServiceProvider),
    navigationService: ref.watch(appNavigationProvider),
  ),
);

final appInitializationServiceProvider = Provider<AppInitializationService>(
  (ref) => AppInitializationService(
    deepLinkHandler: ref.watch(deepLinkHandlerProvider),
  ),
);

// 17. Clean Main.dart
class MyApp extends ConsumerStatefulWidget {
  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  late final AppInitializationService _appInitService;

  @override
  void initState() {
    super.initState();
    _appInitService = ref.read(appInitializationServiceProvider);
    _appInitService.initialize();
  }

  @override
  void dispose() {
    _appInitService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: ref.watch(routeProvider),
      title: 'Your App Name',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
    );
  }
}