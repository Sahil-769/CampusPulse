import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:campus_pulse_client/campus_pulse_client.dart';

import 'campus_pulse_api.dart';

void main() {
  runApp(const ProviderScope(child: CampusPulseApp()));
}

const Color kPrimaryBlue = Color(0xFF1D4ED8);
const Color kDeepNavy = Color(0xFF0F172A);
const Color kCanvas = Color(0xFFF5F7FB);
const Color kCard = Color(0xFFFFFFFF);
const Color kSuccess = Color(0xFF16A34A);
const Color kWarning = Color(0xFFF59E0B);
const Color kError = Color(0xFFEF4444);
const Color kMutedText = Color(0xFF667085);
const Color kBorder = Color(0xFFE4E7EC);

final appSessionProvider =
    StateNotifierProvider<AppSessionController, AppSession>((ref) {
      return AppSessionController();
    });

enum BackendConnectionStatus { connecting, connected, offline }

final backendConnectionProvider = StateProvider<BackendConnectionStatus>(
  (ref) => BackendConnectionStatus.connecting,
);

final campusDataProvider =
    StateNotifierProvider<CampusDataController, CampusData>((ref) {
      final controller = CampusDataController(api: CampusPulseApi());
      unawaited(
        controller.refreshFromBackend().then((connected) {
          ref.read(backendConnectionProvider.notifier).state = connected
              ? BackendConnectionStatus.connected
              : BackendConnectionStatus.offline;
        }),
      );
      return controller;
    });

final appTabIndexProvider = StateProvider<int>((ref) => 0);
final exploreSavedOnlyProvider = StateProvider<bool>((ref) => false);

class ExploreSavedFilterButton extends ConsumerWidget {
  const ExploreSavedFilterButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savedOnly = ref.watch(exploreSavedOnlyProvider);
    return IconButton(
      tooltip: savedOnly ? 'Show all events' : 'Show saved events',
      onPressed: () =>
          ref.read(exploreSavedOnlyProvider.notifier).state = !savedOnly,
      icon: Icon(
        savedOnly ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
      ),
    );
  }
}

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
      GoRoute(path: '/login', builder: (context, state) => const AuthScreen()),
      GoRoute(
        path: '/app',
        builder: (context, state) => const CampusPulseShell(),
      ),
      GoRoute(
        path: '/event/:id',
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 1;
          return EventDetailScreen(eventId: id);
        },
      ),
      GoRoute(
        path: '/match/:id',
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 1;
          final bud = demoBuddies.firstWhere(
            (item) => item.id == id,
            orElse: () => demoBuddies.first,
          );
          return MatchDetailScreen(buddy: bud);
        },
      ),
      GoRoute(
        path: '/organizer',
        builder: (context, state) => const OrganizerDashboard(),
      ),
      GoRoute(
        path: '/organizer/event/:id',
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 1;
          return OrganizerEventManagementScreen(eventId: id);
        },
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/profile/edit',
        builder: (context, state) => const ProfileEditorScreen(),
      ),
      GoRoute(
        path: '/match-request',
        builder: (context, state) => const MatchRequestsScreen(),
      ),
    ],
  );
});

class CampusPulseApp extends ConsumerWidget {
  const CampusPulseApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    return MaterialApp.router(
      title: 'Campus Pulse',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: kCanvas,
        colorScheme: ColorScheme.fromSeed(
          seedColor: kPrimaryBlue,
          brightness: Brightness.light,
        ),
        textTheme: const TextTheme(
          headlineSmall: TextStyle(
            fontSize: 26,
            height: 1.15,
            fontWeight: FontWeight.w700,
            color: kDeepNavy,
          ),
          titleLarge: TextStyle(
            fontSize: 20,
            height: 1.2,
            fontWeight: FontWeight.w700,
            color: kDeepNavy,
          ),
          titleMedium: TextStyle(
            fontSize: 16,
            height: 1.25,
            fontWeight: FontWeight.w700,
            color: kDeepNavy,
          ),
          bodyLarge: TextStyle(fontSize: 16, height: 1.45, color: kDeepNavy),
          bodyMedium: TextStyle(fontSize: 14, height: 1.4, color: kMutedText),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: kCanvas,
          foregroundColor: kDeepNavy,
          elevation: 0,
          centerTitle: false,
          scrolledUnderElevation: 0,
          titleTextStyle: TextStyle(
            color: kDeepNavy,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: kBorder),
          ),
          color: kCard,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 15,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: kBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: kBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: kPrimaryBlue, width: 1.5),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            minimumSize: const Size(0, 40),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            textStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(0, 40),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            side: const BorderSide(color: kBorder),
            textStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            minimumSize: const Size(0, 40),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            textStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        iconButtonTheme: IconButtonThemeData(
          style: IconButton.styleFrom(
            minimumSize: const Size(40, 40),
            maximumSize: const Size(40, 40),
            padding: const EdgeInsets.all(8),
            visualDensity: VisualDensity.compact,
          ),
        ),
        chipTheme: ChipThemeData(
          side: BorderSide.none,
          backgroundColor: const Color(0xFFE8EEF9),
          labelStyle: const TextStyle(fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Roboto',
        colorScheme: ColorScheme.fromSeed(
          seedColor: kPrimaryBlue,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF0B1220),
      ),
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}

class AppSession {
  final bool isAuthenticated;
  final bool isOrganizer;
  final String displayName;
  final String email;
  final String role;

  const AppSession({
    this.isAuthenticated = false,
    this.isOrganizer = false,
    this.displayName = 'Student',
    this.email = '',
    this.role = 'student',
  });

  AppSession copyWith({
    bool? isAuthenticated,
    bool? isOrganizer,
    String? displayName,
    String? email,
    String? role,
  }) {
    return AppSession(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isOrganizer: isOrganizer ?? this.isOrganizer,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      role: role ?? this.role,
    );
  }
}

class AppSessionController extends StateNotifier<AppSession> {
  AppSessionController() : super(const AppSession());

  void signIn({required String email, required String password}) {
    final lower = email.trim().toLowerCase();
    final isOrganizer = lower == 'organizer@campuspulse.edu';
    final displayName = isOrganizer ? 'Campus Crew' : 'Aanya Sharma';
    state = AppSession(
      isAuthenticated: true,
      isOrganizer: isOrganizer,
      displayName: displayName,
      email: lower,
      role: isOrganizer ? 'organizer' : 'student',
    );
  }

  void signOut() {
    state = const AppSession();
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );
    _controller.forward();
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (!mounted) return;
      context.go('/login');
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ScaleTransition(
          scale: _animation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: kPrimaryBlue,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.school_rounded,
                  size: 52,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Campus Pulse',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                  color: kDeepNavy,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Discover opportunities. Find your people.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade700, fontSize: 15),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final emailController = TextEditingController(
    text: 'student@campuspulse.edu',
  );
  final passwordController = TextEditingController(text: 'campus123');
  final nameController = TextEditingController();
  bool isRegistering = false;
  bool showPassword = false;
  bool loading = false;
  String? errorText;

  String get demoAccountHint =>
      'Demo: student@campuspulse.edu / campus123 or organizer@campuspulse.edu / campus123';

  Future<void> handleAuth() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final name = nameController.text.trim();

    if (email.isEmpty || password.isEmpty || (isRegistering && name.isEmpty)) {
      setState(() => errorText = 'Please complete all required fields.');
      return;
    }

    if (!email.contains('@')) {
      setState(() => errorText = 'Enter a valid email address.');
      return;
    }

    setState(() {
      loading = true;
      errorText = null;
    });

    await Future<void>.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    ref
        .read(appSessionProvider.notifier)
        .signIn(email: email, password: password);

    final session = ref.read(appSessionProvider);
    ref.read(backendConnectionProvider.notifier).state =
        BackendConnectionStatus.connecting;
    unawaited(
      ref
          .read(campusDataProvider.notifier)
          .refreshFromBackend(
            prototypeStudentId: session.email,
            studentName: session.displayName,
          )
          .then((connected) {
            if (!mounted) return;
            ref.read(backendConnectionProvider.notifier).state = connected
                ? BackendConnectionStatus.connected
                : BackendConnectionStatus.offline;
          }),
    );
    if (session.isOrganizer) {
      context.go('/organizer');
    } else {
      context.go('/app');
    }

    setState(() => loading = false);
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1220) : kCanvas,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE9F0FF),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Icon(
                      Icons.school_rounded,
                      size: 38,
                      color: kPrimaryBlue,
                    ),
                  ),
                  const SizedBox(height: 22),
                  Text(
                    isRegistering
                        ? 'Create your campus profile'
                        : 'Welcome back',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : kDeepNavy,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isRegistering
                        ? 'Join Campus Pulse and start discovering events and study buddies.'
                        : 'Sign in to unlock campus discovery and student connections.',
                    style: Theme.of(context).textTheme.bodyLarge
                        ?.copyWith(color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 24),
                  if (isRegistering) ...[
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'Full name',
                        prefixIcon: const Icon(Icons.person_outline_rounded),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        filled: true,
                        fillColor: isDark
                            ? const Color(0xFF111B2D)
                            : Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon: const Icon(Icons.email_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      filled: true,
                      fillColor: isDark
                          ? const Color(0xFF111B2D)
                          : Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: passwordController,
                    obscureText: !showPassword,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outline_rounded),
                      suffixIcon: IconButton(
                        onPressed: () =>
                            setState(() => showPassword = !showPassword),
                        icon: Icon(
                          showPassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      filled: true,
                      fillColor: isDark
                          ? const Color(0xFF111B2D)
                          : Colors.white,
                    ),
                  ),
                  const SizedBox(height: 18),
                  if (errorText != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: kError.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        errorText!,
                        style: const TextStyle(
                          color: kError,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: loading ? null : handleAuth,
                      icon: loading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.login_rounded),
                      label: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        child: Text(
                          isRegistering ? 'Create account' : 'Sign in',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: const [
                      Expanded(child: Divider()),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Text('or'),
                      ),
                      Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        setState(() {
                          isRegistering = !isRegistering;
                          errorText = null;
                        });
                      },
                      icon: const Icon(Icons.swap_horiz_rounded),
                      label: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          isRegistering ? 'Back to sign in' : 'Create account',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.info_outline_rounded,
                          color: Color(0xFFB45309),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            demoAccountHint,
                            style: const TextStyle(
                              color: Color(0xFF92400E),
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
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

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({
    required this.radius,
    this.iconSize = 24,
    this.backgroundColor = const Color(0xFFDBEAFE),
    this.iconColor = kPrimaryBlue,
  });

  final double radius;
  final double iconSize;
  final Color backgroundColor;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor,
      child: Icon(Icons.person_rounded, size: iconSize, color: iconColor),
    );
  }
}

class CampusPulseShell extends ConsumerStatefulWidget {
  const CampusPulseShell({super.key});

  @override
  ConsumerState<CampusPulseShell> createState() => _CampusPulseShellState();
}

class _CampusPulseShellState extends ConsumerState<CampusPulseShell> {
  final List<Widget> _pages = [
    const HomeScreen(),
    const ExploreEventsScreen(),
    const StudyBuddiesScreen(),
    const ActivityScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(appSessionProvider);
    final index = ref.watch(appTabIndexProvider);
    final compactPhone = MediaQuery.sizeOf(context).shortestSide < 390;
    final title = switch (index) {
      0 => 'Campus Pulse',
      1 => 'Explore events',
      2 => 'Study buddies',
      3 => 'My activity',
      _ => 'Profile',
    };
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actionsPadding: const EdgeInsets.only(right: 12),
        actions: [
          if (index == 1) const ExploreSavedFilterButton(),
          PopupMenuButton<String>(
            tooltip: 'Profile menu',
            offset: const Offset(0, 20),
            popUpAnimationStyle: const AnimationStyle(
              duration: Duration(milliseconds: 300),
              reverseDuration: Duration(milliseconds: 220),
              curve: Curves.easeOutQuart,
              reverseCurve: Curves.easeInCubic,
            ),
            onSelected: (value) {
              if (value == 'edit') {
                context.push('/profile/edit');
              } else if (value == 'notifications') {
                context.push('/settings');
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.person_outline_rounded),
                    SizedBox(width: 12),
                    Text('Edit profile'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'notifications',
                child: Row(
                  children: [
                    Icon(Icons.notifications_none_rounded),
                    SizedBox(width: 12),
                    Text('Notifications & settings'),
                  ],
                ),
              ),
            ],
            child: const _ProfileAvatar(radius: 21, iconSize: 28),
          ),
        ],
      ),
      body: IndexedStack(index: index, children: _pages),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 0, 8, 4),
          child: NavigationBar(
            height: compactPhone ? 64 : 72,
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            selectedIndex: index,
            onDestinationSelected: (value) =>
                ref.read(appTabIndexProvider.notifier).state = value,
            labelBehavior: compactPhone
                ? NavigationDestinationLabelBehavior.onlyShowSelected
                : NavigationDestinationLabelBehavior.alwaysShow,
            indicatorColor: const Color(0xFFE8EEF9),
            indicatorShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined, size: 24),
                selectedIcon: Icon(Icons.home_rounded, size: 24),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(Icons.explore_outlined, size: 22),
                selectedIcon: Icon(Icons.explore_rounded, size: 22),
                label: 'Explore',
              ),
              NavigationDestination(
                icon: Icon(Icons.groups_outlined, size: 22),
                selectedIcon: Icon(Icons.groups_rounded, size: 22),
                label: 'Buddies',
              ),
              NavigationDestination(
                icon: Icon(Icons.fact_check_outlined, size: 22),
                selectedIcon: Icon(Icons.fact_check_rounded, size: 22),
                label: 'Activity',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline_rounded, size: 22),
                selectedIcon: Icon(Icons.person_rounded, size: 22),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: session.isOrganizer
          ? FloatingActionButton.extended(
              onPressed: () => context.push('/organizer'),
              icon: const Icon(Icons.dashboard_customize_rounded),
              label: const Text('Organizer'),
            )
          : null,
    );
  }
}

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(appSessionProvider);
    final campusData = ref.watch(campusDataProvider);
    final backendStatus = ref.watch(backendConnectionProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final headingColor = isDark ? Colors.white : kDeepNavy;
    final secondaryColor = isDark ? Colors.white70 : const Color(0xFF475467);
    final firstName = session.displayName.split(' ').first;
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Good morning'
        : hour < 18
        ? 'Good afternoon'
        : 'Good evening';
    final registeredCount = campusData
        .registeredEventsFor(session.email)
        .length;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Discover your campus edge',
                          style: TextStyle(fontSize: 14, color: secondaryColor),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '$greeting, $firstName',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: headingColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              if (backendStatus == BackendConnectionStatus.connecting) ...[
                const _BackendConnectionBanner(),
                const SizedBox(height: 16),
              ],
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: kPrimaryBlue,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'YOUR CAMPUS, AT A GLANCE',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                        Icon(Icons.insights_rounded, color: Colors.white),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Make this week count.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Find events, connect with people, and keep your plans moving.',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        _StatsPill(
                          label: 'Events',
                          value: campusData.events.length.toString(),
                        ),
                        const SizedBox(width: 10),
                        _StatsPill(
                          label: 'Registered',
                          value: registeredCount.toString(),
                        ),
                        const SizedBox(width: 10),
                        _StatsPill(
                          label: 'Requests',
                          value: campusData.matchRequests.length.toString(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Quick actions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: headingColor,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 160,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    QuickActionCard(
                      icon: Icons.explore_rounded,
                      title: 'Explore Events',
                      subtitle: '${campusData.events.length} available',
                      onTap: () =>
                          ref.read(appTabIndexProvider.notifier).state = 1,
                    ),
                    QuickActionCard(
                      icon: Icons.groups_rounded,
                      title: 'Find a Study Buddy',
                      subtitle: '${demoBuddies.length} profiles',
                      onTap: () =>
                          ref.read(appTabIndexProvider.notifier).state = 2,
                    ),
                    QuickActionCard(
                      icon: Icons.campaign_rounded,
                      title: 'Announcements',
                      subtitle: '${announcementItems.length} updates',
                      onTap: () => showDialog<void>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Campus announcements'),
                          content: const Text(
                            'Stay up to date with events, clubs, and campus opportunities in your feed.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Close'),
                            ),
                          ],
                        ),
                      ),
                    ),
                    QuickActionCard(
                      icon: Icons.event_available_rounded,
                      title: 'My Activity',
                      subtitle: '$registeredCount registered',
                      onTap: () =>
                          ref.read(appTabIndexProvider.notifier).state = 3,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Featured event',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: headingColor,
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.push('/event/1'),
                    child: const Text('View all'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              FeaturedEventCard(onTap: () => context.push('/event/1')),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Suggested study buddies',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: headingColor,
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.push('/match/2'),
                    child: const Text('See more'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...demoBuddies
                  .take(2)
                  .map((buddy) => BuddySummaryCard(buddy: buddy)),
              const SizedBox(height: 12),
              Text(
                'Campus announcements',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: headingColor,
                ),
              ),
              const SizedBox(height: 12),
              ...announcementItems.map((item) => AnnouncementCard(item: item)),
            ],
          ),
        ),
      ),
    );
  }
}

class ExploreEventsScreen extends ConsumerStatefulWidget {
  const ExploreEventsScreen({super.key});

  @override
  ConsumerState<ExploreEventsScreen> createState() =>
      _ExploreEventsScreenState();
}

class _ExploreEventsScreenState extends ConsumerState<ExploreEventsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final campusData = ref.watch(campusDataProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final savedOnly = ref.watch(exploreSavedOnlyProvider);
    final query = _searchController.text.trim().toLowerCase();
    final events = campusData.events.where((event) {
      final matchesCategory = switch (_selectedCategory) {
        'All' => true,
        'Clubs' =>
          event.category.toLowerCase().contains('club') ||
              event.organizer.toLowerCase().contains('club'),
        _ => event.category.toLowerCase() == _selectedCategory.toLowerCase(),
      };
      final matchesQuery =
          query.isEmpty ||
          [
            event.title,
            event.category,
            event.organizer,
            event.venue,
            event.description,
          ].any((value) => value.toLowerCase().contains(query));
      final matchesSaved =
          !savedOnly || campusData.bookmarkedEventIds.contains(event.id);
      return matchesCategory && matchesQuery && matchesSaved;
    }).toList();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Search events, clubs, talks...',
                  hintStyle: TextStyle(
                    color: isDark ? Colors.white70 : kMutedText,
                  ),
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: _searchController.text.isEmpty
                      ? null
                      : IconButton(
                          tooltip: 'Clear search',
                          onPressed: () {
                            _searchController.clear();
                            setState(() {});
                          },
                          icon: const Icon(Icons.close_rounded),
                        ),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF111B2D) : Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                height: 42,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    for (final category in const [
                      'All',
                      'Hackathons',
                      'Workshops',
                      'Clubs',
                      'Sports',
                    ])
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(
                            category,
                            style: TextStyle(
                              color: _selectedCategory == category
                                  ? Colors.white
                                  : isDark
                                  ? Colors.white
                                  : kDeepNavy,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          selected: _selectedCategory == category,
                          selectedColor: kPrimaryBlue,
                          backgroundColor: isDark
                              ? const Color(0xFF1F2937)
                              : Colors.white,
                          side: BorderSide(
                            color: isDark ? Colors.white38 : kBorder,
                          ),
                          showCheckmark: false,
                          onSelected: (_) =>
                              setState(() => _selectedCategory = category),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Expanded(
                child: events.isEmpty
                    ? _EventEmptyState(
                        savedOnly: savedOnly,
                        onClear: () => setState(() {
                          ref.read(exploreSavedOnlyProvider.notifier).state =
                              false;
                          _selectedCategory = 'All';
                          _searchController.clear();
                        }),
                      )
                    : ListView.builder(
                        itemCount: events.length,
                        itemBuilder: (context, index) =>
                            EventCard(event: events[index]),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EventCard extends ConsumerWidget {
  final DemoEvent event;

  const EventCard({super.key, required this.event});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final campusData = ref.watch(campusDataProvider);
    final isBookmarked = campusData.bookmarkedEventIds.contains(event.id);
    final session = ref.watch(appSessionProvider);
    final isRegistered = campusData.isRegistered(event.id, session.email);
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: const Border.fromBorderSide(BorderSide(color: kBorder)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: event.color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.event_rounded,
                  color: kPrimaryBlue,
                  size: 30,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: kDeepNavy,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${event.category} • ${event.date}',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${event.venue} • by ${event.organizer}',
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: isBookmarked ? 'Remove bookmark' : 'Bookmark event',
                onPressed: () => ref
                    .read(campusDataProvider.notifier)
                    .toggleBookmark(event.id),
                icon: Icon(
                  isBookmarked
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_border_rounded,
                  color: kPrimaryBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: isRegistered
                      ? const Color(0xFFE6F7ED)
                      : const Color(0xFFE8EEF9),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  isRegistered ? 'Registered' : 'Open',
                  style: TextStyle(
                    color: isRegistered ? kSuccess : kPrimaryBlue,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${event.seatsLeft} seats left',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ),
              FilledButton(
                onPressed: () => context.push('/event/${event.id}'),
                child: const Text('Open'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EventEmptyState extends StatelessWidget {
  final bool savedOnly;
  final VoidCallback onClear;

  const _EventEmptyState({required this.savedOnly, required this.onClear});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              savedOnly
                  ? Icons.bookmark_border_rounded
                  : Icons.search_off_rounded,
              size: 40,
              color: kMutedText,
            ),
            const SizedBox(height: 12),
            Text(
              savedOnly ? 'No saved events yet' : 'No events match your search',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: kDeepNavy,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              savedOnly
                  ? 'Bookmark an event to find it here.'
                  : 'Try a different search or category.',
              style: const TextStyle(color: kMutedText),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            TextButton(onPressed: onClear, child: const Text('Clear filters')),
          ],
        ),
      ),
    );
  }
}

class EventDetailScreen extends ConsumerStatefulWidget {
  final int eventId;

  const EventDetailScreen({super.key, required this.eventId});

  @override
  ConsumerState<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends ConsumerState<EventDetailScreen> {
  bool isSubmitting = false;

  Future<void> submitRegistration(DemoEvent event) async {
    setState(() => isSubmitting = true);
    final session = ref.read(appSessionProvider);
    try {
      final accepted = await ref
          .read(campusDataProvider.notifier)
          .registerForEventWithBackend(
            event.id,
            studentName: session.displayName,
            email: session.email,
          );
      if (!mounted) return;
      ref.read(backendConnectionProvider.notifier).state =
          BackendConnectionStatus.connected;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            accepted ? 'You are registered for ${event.title}.' : 'Registration could not be completed. Check availability or your existing registration.',
          ),
        ),
      );
    } on Exception catch (error) {
      if (!mounted) return;
      ref.read(backendConnectionProvider.notifier).state =
          BackendConnectionStatus.offline;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Serverpod registration failed: $error')),
      );
    } finally {
      if (mounted) setState(() => isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final campusData = ref.watch(campusDataProvider);
    final session = ref.watch(appSessionProvider);
    final event = campusData.eventById(widget.eventId);
    if (event == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Event unavailable')),
        body: const Center(child: Text('This event is no longer available.')),
      );
    }
    final isRegistered = campusData.isRegistered(event.id, session.email);

    return Scaffold(
      appBar: AppBar(
        title: Text(event.title, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: event.color.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: Icon(
                    Icons.event_available_rounded,
                    size: 70,
                    color: kPrimaryBlue,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8EEF9),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      event.category,
                      style: const TextStyle(
                        color: kPrimaryBlue,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (isRegistered)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE6F7ED),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Text(
                        'Registered',
                        style: TextStyle(
                          color: kSuccess,
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                event.title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: kDeepNavy,
                ),
              ),
              const SizedBox(height: 12),
              _InfoRow(icon: Icons.calendar_month_rounded, label: event.date),
              _InfoRow(icon: Icons.access_time_rounded, label: event.time),
              _InfoRow(icon: Icons.location_on_rounded, label: event.venue),
              _InfoRow(
                icon: Icons.person_outline_rounded,
                label: 'Organizer: ${event.organizer}',
              ),
              _InfoRow(
                icon: Icons.event_seat_rounded,
                label: '${event.seatsLeft} seats remaining',
              ),
              const SizedBox(height: 16),
              const Text(
                'About this event',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: kDeepNavy,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                event.description,
                style: const TextStyle(color: Color(0xFF475467), height: 1.6),
              ),
              const SizedBox(height: 18),
              const Text(
                'Why you may like it',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: kDeepNavy,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: const [
                  TagChip(label: 'Design thinking'),
                  TagChip(label: 'Networking'),
                  TagChip(label: 'Career growth'),
                ],
              ),
              const SizedBox(height: 22),
              if (isRegistered)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE6F7ED),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Text(
                    'You are successfully registered for this event.',
                    style: TextStyle(
                      color: kSuccess,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                )
              else
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: isSubmitting || event.seatsLeft == 0
                        ? null
                        : () => submitRegistration(event),
                    icon: isSubmitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.check_circle_rounded),
                    label: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: Text(
                        event.seatsLeft == 0
                            ? 'Event full'
                            : isSubmitting
                            ? 'Registering...'
                            : 'Register now',
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class StudyBuddiesScreen extends ConsumerStatefulWidget {
  const StudyBuddiesScreen({super.key});

  @override
  ConsumerState<StudyBuddiesScreen> createState() => _StudyBuddiesScreenState();
}

class _StudyBuddiesScreenState extends ConsumerState<StudyBuddiesScreen> {
  List<DemoBuddy> _buddies = demoBuddies;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadMatches());
  }

  Future<void> _loadMatches() async {
    final matches = await ref
        .read(campusDataProvider.notifier)
        .loadStudyBuddyMatches();
    if (!mounted) return;
    ref.read(backendConnectionProvider.notifier).state = matches == null
        ? BackendConnectionStatus.offline
        : BackendConnectionStatus.connected;
    if (matches != null && matches.isNotEmpty) {
      setState(() => _buddies = matches);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Recommended for you',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: kDeepNavy,
                ),
              ),
              const SizedBox(height: 14),
              Expanded(
                child: ListView.builder(
                  itemCount: _buddies.length,
                  itemBuilder: (context, index) {
                    final buddy = _buddies[index];
                    return StudyBuddyCard(buddy: buddy);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class StudyBuddyCard extends ConsumerWidget {
  final DemoBuddy buddy;

  const StudyBuddyCard({super.key, required this.buddy});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final campusData = ref.watch(campusDataProvider);
    final calculatedScore = calculateStudyMatchBreakdown(
      subjectsA: demoStudentSubjects,
      subjectsB: buddy.subjects.toSet(),
      skillsA: demoStudentSkills,
      skillsB: buddy.skills.toSet(),
      goalsA: demoStudentGoals,
      goalsB: buddy.goals.toSet(),
      availabilityA: demoStudentAvailability,
      availabilityB: buddy.availability.toSet(),
    ).score;
    final score = buddy.matchScore ?? calculatedScore;
    final requestSent = campusData.hasOutgoingMatchRequest(buddy.id);
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: const Border.fromBorderSide(BorderSide(color: kBorder)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _ProfileAvatar(
                radius: 28,
                backgroundColor: buddy.color,
                iconColor: Colors.white,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      buddy.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: kDeepNavy,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${buddy.branch} • ${buddy.year}',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8EEF9),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '$score%',
                  style: const TextStyle(
                    color: kPrimaryBlue,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ...buddy.subjects
                  .take(2)
                  .map((subject) => TagChip(label: subject)),
              ...buddy.skills.take(2).map((skill) => TagChip(label: skill)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.schedule_rounded, size: 18, color: kPrimaryBlue),
              const SizedBox(width: 6),
              Text(
                buddy.availabilitySummary,
                style: TextStyle(color: Colors.grey.shade700),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => context.push('/match/${buddy.id}'),
                  child: const Text('Why match?'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: requestSent
                      ? null
                      : () => _sendMatchRequest(context, ref),
                  child: Text(requestSent ? 'Request sent' : 'Send request'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _sendMatchRequest(BuildContext context, WidgetRef ref) {
    final session = ref.read(appSessionProvider);
    final sent = ref
        .read(campusDataProvider.notifier)
        .sendMatchRequest(buddy, senderName: session.displayName);
    if (!sent) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Match request sent'),
        content: Text(
          'Your request to connect with ${buddy.name} has been sent.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Okay'),
          ),
        ],
      ),
    );
  }
}

class MatchDetailScreen extends ConsumerWidget {
  final DemoBuddy buddy;

  const MatchDetailScreen({super.key, required this.buddy});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final breakdown = calculateStudyMatchBreakdown(
      subjectsA: demoStudentSubjects,
      subjectsB: buddy.subjects.toSet(),
      skillsA: demoStudentSkills,
      skillsB: buddy.skills.toSet(),
      goalsA: demoStudentGoals,
      goalsB: buddy.goals.toSet(),
      availabilityA: demoStudentAvailability,
      availabilityB: buddy.availability.toSet(),
    );

    final reasons = <String>[...buddy.matchReasons];
    final sharedSubjects = demoStudentSubjects
        .intersection(buddy.subjects.toSet())
        .toList();
    final sharedSkills = demoStudentSkills
        .intersection(buddy.skills.toSet())
        .toList();
    final sharedGoals = demoStudentGoals
        .intersection(buddy.goals.toSet())
        .toList();
    final sharedAvailability = demoStudentAvailability
        .intersection(buddy.availability.toSet())
        .toList();

    if (reasons.isEmpty) {
      if (sharedSubjects.isNotEmpty) {
        reasons.add('You both study ${sharedSubjects.first}.');
      }
      if (sharedSkills.isNotEmpty) {
        reasons.add(
          'You both bring ${sharedSkills.first} skills to a study session.',
        );
      }
      if (sharedGoals.isNotEmpty) {
        reasons.add(
          'You share the goal of ${sharedGoals.first.toLowerCase()}.',
        );
      }
      if (sharedAvailability.isNotEmpty) {
        reasons.add('You are both available on ${sharedAvailability.first}.');
      }
      if (reasons.isEmpty) {
        reasons.add('Your different strengths could complement each other.');
      }
    }

    return Scaffold(
      appBar: AppBar(title: Text('${buddy.name} match')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  _ProfileAvatar(
                    radius: 36,
                    backgroundColor: buddy.color,
                    iconColor: Colors.white,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          buddy.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: kDeepNavy,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${buddy.branch} • ${buddy.year}',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedScoreRing(score: buddy.matchScore ?? breakdown.score),
                ],
              ),
              const SizedBox(height: 20),
              _ScoreBar(
                label: 'Subjects & skills',
                value: breakdown.studyContribution,
                maximum: 50,
              ),
              const SizedBox(height: 12),
              _ScoreBar(
                label: 'Goals',
                value: breakdown.goalContribution,
                maximum: 30,
              ),
              const SizedBox(height: 12),
              _ScoreBar(
                label: 'Availability',
                value: breakdown.availabilityContribution,
                maximum: 20,
              ),
              const SizedBox(height: 10),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Weights: study fit 50% • goals 30% • availability 20%',
                  style: TextStyle(fontSize: 12, color: Color(0xFF667085)),
                ),
              ),
              const SizedBox(height: 22),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Why this match works',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: kDeepNavy,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ...reasons.map(
                (reason) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.check_circle_rounded,
                        color: kSuccess,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          reason,
                          style: const TextStyle(
                            color: Color(0xFF475467),
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    final session = ref.read(appSessionProvider);
                    final sent = ref
                        .read(campusDataProvider.notifier)
                        .sendMatchRequest(
                          buddy,
                          senderName: session.displayName,
                        );
                    if (!sent) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('You have already sent this request.'),
                        ),
                      );
                      return;
                    }
                    _showMatchSentDialog(context, buddy);
                  },
                  icon: const Icon(Icons.send_rounded),
                  label: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    child: Text('Send match request'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showMatchSentDialog(BuildContext context, DemoBuddy buddy) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Request sent'),
        content: Text(
          'You sent a match request to ${buddy.name}. They will see it in their activity inbox.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class ActivityScreen extends ConsumerWidget {
  const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(appSessionProvider);
    final campusData = ref.watch(campusDataProvider);
    final registeredEvents = campusData.registeredEventsFor(session.email);
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Registered events',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: kDeepNavy,
                ),
              ),
              const SizedBox(height: 12),
              if (registeredEvents.isEmpty)
                const _InlineEmptyState(
                  message: 'You have not registered for any events yet.',
                )
              else
                ...registeredEvents.map(
                  (event) => ActivityEventTile(event: event),
                ),
              const SizedBox(height: 20),
              const Text(
                'Match requests',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: kDeepNavy,
                ),
              ),
              const SizedBox(height: 12),
              if (campusData.matchRequests.isEmpty)
                const _InlineEmptyState(message: 'No match requests yet.')
              else
                ...campusData.matchRequests.map(
                  (request) => ActivityMatchTile(request: request),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BackendConnectionBanner extends StatelessWidget {
  const _BackendConnectionBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: kPrimaryBlue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Connecting to the Serverpod backend...',
              style: const TextStyle(
                color: kPrimaryBlue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InlineEmptyState extends StatelessWidget {
  final String message;

  const _InlineEmptyState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: const Border.fromBorderSide(BorderSide(color: kBorder)),
      ),
      child: Text(message, style: const TextStyle(color: kMutedText)),
    );
  }
}

class MatchRequestsScreen extends ConsumerWidget {
  const MatchRequestsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requests = ref.watch(campusDataProvider).matchRequests;
    return Scaffold(
      appBar: AppBar(title: const Text('Match requests')),
      body: SafeArea(
        child: requests.isEmpty
            ? const Padding(
                padding: EdgeInsets.all(16),
                child: _InlineEmptyState(message: 'No match requests yet.'),
              )
            : ListView(
                padding: const EdgeInsets.all(16),
                children: requests
                    .map((r) => MatchRequestCard(request: r))
                    .toList(),
              ),
      ),
    );
  }
}

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(appSessionProvider);
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: const Border.fromBorderSide(
                    BorderSide(color: kBorder),
                  ),
                ),
                child: Column(
                  children: [
                    const _ProfileAvatar(radius: 42, iconSize: 32),
                    const SizedBox(height: 14),
                    Text(
                      session.displayName,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: kDeepNavy,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'B.Tech CSE • Semester 6',
                      style: TextStyle(color: Color(0xFF475467)),
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 10,
                      runSpacing: 8,
                      children: const [
                        TagChip(label: 'DSA'),
                        TagChip(label: 'App Development'),
                        TagChip(label: 'UI/UX Design'),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: const Border.fromBorderSide(
                    BorderSide(color: kBorder),
                  ),
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.person_outline_rounded),
                      title: const Text('Edit profile'),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () => context.push('/profile/edit'),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.visibility_outlined),
                      title: const Text('Profile visibility'),
                      trailing: Switch(value: true, onChanged: (_) {}),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.dark_mode_outlined),
                      title: const Text('Theme'),
                      trailing: const Text(
                        'System',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.notifications_none_rounded),
                      title: const Text('Notifications'),
                      trailing: Switch(value: true, onChanged: (_) {}),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.logout_rounded, color: kError),
                      title: const Text(
                        'Sign out',
                        style: TextStyle(color: kError),
                      ),
                      onTap: () {
                        ref.read(appSessionProvider.notifier).signOut();
                        context.go('/login');
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: const [
            ListTile(
              leading: Icon(Icons.notifications_none_rounded),
              title: Text('Alerts & updates'),
              trailing: Icon(Icons.chevron_right_rounded),
            ),
            ListTile(
              leading: Icon(Icons.dark_mode_rounded),
              title: Text('Appearance'),
              trailing: Icon(Icons.chevron_right_rounded),
            ),
            ListTile(
              leading: Icon(Icons.security_rounded),
              title: Text('Privacy & security'),
              trailing: Icon(Icons.chevron_right_rounded),
            ),
            ListTile(
              leading: Icon(Icons.support_agent_rounded),
              title: Text('Help center'),
              trailing: Icon(Icons.chevron_right_rounded),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileEditorScreen extends StatefulWidget {
  const ProfileEditorScreen({super.key});

  @override
  State<ProfileEditorScreen> createState() => _ProfileEditorScreenState();
}

class _ProfileEditorScreenState extends State<ProfileEditorScreen> {
  final nameController = TextEditingController(text: 'Aanya Sharma');
  final bioController = TextEditingController(
    text:
        'Looking for a project partner and a study buddy for DSA and app dev.',
  );
  bool visible = true;

  @override
  void dispose() {
    nameController.dispose();
    bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit profile')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Display name',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'About you',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: bioController,
                maxLines: 4,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Subjects',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: const [
                  TagChip(label: 'DSA'),
                  TagChip(label: 'App Development'),
                  TagChip(label: 'UI/UX Design'),
                  TagChip(label: 'Machine Learning'),
                ],
              ),
              const SizedBox(height: 18),
              SwitchListTile(
                title: const Text('Make profile visible to other students'),
                value: visible,
                onChanged: (value) => setState(() => visible = value),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Profile saved successfully.'),
                      ),
                    );
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text('Save changes'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OrganizerDashboard extends ConsumerWidget {
  const OrganizerDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final campusData = ref.watch(campusDataProvider);
    final checkedInCount = campusData.registrations
        .where((item) => item.checkedIn)
        .length;
    return Scaffold(
      appBar: AppBar(title: const Text('Organizer workspace')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Overview',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: kDeepNavy,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OrganizerMetricCard(
                      label: 'Published events',
                      value: campusData.events.length.toString(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OrganizerMetricCard(
                      label: 'Registrations',
                      value: campusData.registrations.length.toString(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              OrganizerMetricCard(
                label: 'Checked in',
                value: checkedInCount.toString(),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Text(
                    'Events',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: kDeepNavy,
                    ),
                  ),
                  const Spacer(),
                  FilledButton.icon(
                    onPressed: () async {
                      final event = await showDialog<DemoEvent>(
                        context: context,
                        builder: (_) => const OrganizerEventEditorDialog(),
                      );
                      if (event == null || !context.mounted) return;
                      try {
                        await ref
                            .read(campusDataProvider.notifier)
                            .createEventWithBackend(event);
                        if (!context.mounted) return;
                        ref.read(backendConnectionProvider.notifier).state =
                            BackendConnectionStatus.connected;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Event published.')),
                        );
                      } on Exception catch (error) {
                        if (!context.mounted) return;
                        ref.read(backendConnectionProvider.notifier).state =
                            BackendConnectionStatus.offline;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Serverpod publish failed: $error'),
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('New event'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...campusData.events.map(
                (event) => OrganizerEventTile(
                  event: event,
                  registrantCount: campusData.registrationsFor(event.id).length,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OrganizerMetricCard extends StatelessWidget {
  final String label;
  final String value;

  const OrganizerMetricCard({
    super.key,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: kDeepNavy,
            ),
          ),
        ],
      ),
    );
  }
}

class OrganizerEventTile extends StatelessWidget {
  final DemoEvent event;
  final int registrantCount;

  const OrganizerEventTile({
    super.key,
    required this.event,
    required this.registrantCount,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => context.push('/organizer/event/${event.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: event.color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(Icons.event_rounded, color: event.color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: kDeepNavy,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${event.date} • ${event.venue} • $registrantCount registered',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFE6F7ED),
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Text(
                'Published',
                style: TextStyle(
                  color: kSuccess,
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OrganizerEventManagementScreen extends ConsumerWidget {
  final int eventId;

  const OrganizerEventManagementScreen({super.key, required this.eventId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final campusData = ref.watch(campusDataProvider);
    final event = campusData.eventById(eventId);
    if (event == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Event unavailable')),
        body: const Center(child: Text('This event is no longer available.')),
      );
    }

    final registrations = campusData.registrationsFor(event.id);
    return Scaffold(
      appBar: AppBar(title: const Text('Registration management')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              event.title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: kDeepNavy,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '${event.date} • ${registrations.length} registered',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 18),
            if (registrations.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(18),
                  child: Text('No registrations yet.'),
                ),
              )
            else
              ...registrations.map(
                (registration) => Card(
                  child: ListTile(
                    leading: const _ProfileAvatar(radius: 20),
                    title: Text(registration.studentName),
                    subtitle: Text(registration.email),
                    trailing: registration.checkedIn
                        ? const Chip(
                            label: Text('Checked in'),
                            avatar: Icon(
                              Icons.check_circle_rounded,
                              color: kSuccess,
                              size: 18,
                            ),
                          )
                        : FilledButton.tonal(
                            onPressed: () => ref
                                .read(campusDataProvider.notifier)
                                .checkIn(registration.id),
                            child: const Text('Check in'),
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

class OrganizerEventEditorDialog extends StatefulWidget {
  const OrganizerEventEditorDialog({super.key});

  @override
  State<OrganizerEventEditorDialog> createState() =>
      _OrganizerEventEditorDialogState();
}

class _OrganizerEventEditorDialogState
    extends State<OrganizerEventEditorDialog> {
  final _titleController = TextEditingController();
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();
  final _venueController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _category = 'Clubs';
  String? _errorText;

  @override
  void dispose() {
    _titleController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _venueController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Publish a campus event'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Event name'),
            ),
            TextField(
              controller: _dateController,
              decoration: const InputDecoration(labelText: 'Date'),
            ),
            TextField(
              controller: _timeController,
              decoration: const InputDecoration(labelText: 'Time'),
            ),
            TextField(
              controller: _venueController,
              decoration: const InputDecoration(labelText: 'Venue'),
            ),
            DropdownButtonFormField<String>(
              initialValue: _category,
              decoration: const InputDecoration(labelText: 'Category'),
              items: const ['Clubs', 'Hackathons', 'Workshops', 'Sports']
                  .map(
                    (category) => DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) setState(() => _category = value);
              },
            ),
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            if (_errorText != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(_errorText!, style: const TextStyle(color: kError)),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            final title = _titleController.text.trim();
            final venue = _venueController.text.trim();
            if (title.isEmpty || venue.isEmpty) {
              setState(() => _errorText = 'Event name and venue are required.');
              return;
            }
            Navigator.pop(
              context,
              DemoEvent(
                id: 0,
                title: title,
                date: _dateController.text.trim().isEmpty
                    ? 'Date to be announced'
                    : _dateController.text.trim(),
                time: _timeController.text.trim().isEmpty
                    ? 'Time to be announced'
                    : _timeController.text.trim(),
                venue: venue,
                organizer: 'Campus Crew',
                category: _category,
                color: _category == 'Sports'
                    ? const Color(0xFF22C55E)
                    : _category == 'Workshops'
                    ? const Color(0xFF7C3AED)
                    : _category == 'Clubs'
                    ? const Color(0xFF14B8A6)
                    : kPrimaryBlue,
                isRegistered: false,
                seatsLeft: 50,
                description: _descriptionController.text.trim().isEmpty
                    ? 'Details coming soon.'
                    : _descriptionController.text.trim(),
              ),
            );
          },
          child: const Text('Publish'),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: kPrimaryBlue),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Color(0xFF475467)),
            ),
          ),
        ],
      ),
    );
  }
}

class AnimatedScoreRing extends StatelessWidget {
  final int score;

  const AnimatedScoreRing({super.key, required this.score});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: score / 100),
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return SizedBox(
          width: 170,
          height: 170,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 150,
                height: 150,
                child: CircularProgressIndicator(
                  value: value,
                  strokeWidth: 12,
                  backgroundColor: const Color(0xFFE5E7EB),
                  color: kPrimaryBlue,
                ),
              ),
              Text(
                '$score%',
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  color: kDeepNavy,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ScoreBar extends StatelessWidget {
  final String label;
  final int value;
  final int maximum;

  const _ScoreBar({
    required this.label,
    required this.value,
    this.maximum = 100,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: kDeepNavy,
              ),
            ),
            const Spacer(),
            Text(
              '$value/$maximum',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: kPrimaryBlue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            minHeight: 10,
            value: maximum == 0 ? 0 : value / maximum,
            backgroundColor: const Color(0xFFE5E7EB),
            color: kPrimaryBlue,
          ),
        ),
      ],
    );
  }
}

class FeaturedEventCard extends StatelessWidget {
  final VoidCallback onTap;

  const FeaturedEventCard({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: const Border.fromBorderSide(BorderSide(color: kBorder)),
        ),
        child: Row(
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: const Color(0xFFE8EEF9),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.flash_on_rounded,
                color: kPrimaryBlue,
                size: 32,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Campus Hackathon 2026',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: kDeepNavy,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '28 Oct • 10:00 AM • Innovation Hall',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  const Row(
                    children: [
                      TagChip(label: 'Hackathon'),
                      SizedBox(width: 8),
                      TagChip(label: 'Open'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const QuickActionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 160,
          margin: const EdgeInsets.only(right: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: const Border.fromBorderSide(BorderSide(color: kBorder)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFE0ECFF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: kPrimaryBlue),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: kDeepNavy,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BannerCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color color;

  const BannerCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withValues(alpha: 0.65)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class TagChip extends StatelessWidget {
  final String label;

  const TagChip({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFE8EEF9),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: kPrimaryBlue,
          fontWeight: FontWeight.w700,
          fontSize: 11,
        ),
      ),
    );
  }
}

class _StatsPill extends StatelessWidget {
  final String label;
  final String value;

  const _StatsPill({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 10, color: Colors.white70),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class BuddySummaryCard extends StatelessWidget {
  final DemoBuddy buddy;

  const BuddySummaryCard({super.key, required this.buddy});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          _ProfileAvatar(
            radius: 22,
            backgroundColor: buddy.color,
            iconColor: Colors.white,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  buddy.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: kDeepNavy,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  buddy.subjects.join(', '),
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
          ),
          FilledButton(
            onPressed: () => context.push('/match/${buddy.id}'),
            child: const Text('View'),
          ),
        ],
      ),
    );
  }
}

class AnnouncementCard extends StatelessWidget {
  final AnnouncementItem item;

  const AnnouncementCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.campaign_rounded, color: kPrimaryBlue),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: kDeepNavy,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.message,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ActivityEventTile extends StatelessWidget {
  final DemoEvent event;

  const ActivityEventTile({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: event.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.event, color: event.color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: kDeepNavy,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${event.date} • ${event.venue}',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFE6F7ED),
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Text(
              'Confirmed',
              style: TextStyle(
                color: kSuccess,
                fontWeight: FontWeight.w700,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ActivityMatchTile extends StatelessWidget {
  final MatchRequest request;

  const ActivityMatchTile({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    final statusColor = switch (request.status) {
      'Accepted' => kSuccess,
      'Pending' => kWarning,
      _ => kError,
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          const _ProfileAvatar(radius: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  request.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: kDeepNavy,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  request.message,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              request.status,
              style: TextStyle(
                color: statusColor,
                fontWeight: FontWeight.w700,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MatchRequestCard extends StatelessWidget {
  final MatchRequest request;

  const MatchRequestCard({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const _ProfileAvatar(radius: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        color: kDeepNavy,
                      ),
                    ),
                    Text(
                      request.message,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8EEF9),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  request.status,
                  style: const TextStyle(
                    color: kPrimaryBlue,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class DemoEvent {
  final int id;
  final String title;
  final String date;
  final String time;
  final String venue;
  final String organizer;
  final String category;
  final Color color;
  final bool isRegistered;
  final int seatsLeft;
  final String description;

  const DemoEvent({
    required this.id,
    required this.title,
    required this.date,
    required this.time,
    required this.venue,
    required this.organizer,
    required this.category,
    required this.color,
    required this.isRegistered,
    required this.seatsLeft,
    required this.description,
  });

  DemoEvent copyWith({int? id, bool? isRegistered, int? seatsLeft}) {
    return DemoEvent(
      id: id ?? this.id,
      title: title,
      date: date,
      time: time,
      venue: venue,
      organizer: organizer,
      category: category,
      color: color,
      isRegistered: isRegistered ?? this.isRegistered,
      seatsLeft: seatsLeft ?? this.seatsLeft,
      description: description,
    );
  }
}

class DemoBuddy {
  final int id;
  final String name;
  final String branch;
  final String year;
  final List<String> subjects;
  final List<String> skills;
  final List<String> goals;
  final List<String> availability;
  final Color color;
  final String availabilitySummary;
  final int? matchScore;
  final List<String> matchReasons;

  const DemoBuddy({
    required this.id,
    required this.name,
    required this.branch,
    required this.year,
    required this.subjects,
    required this.skills,
    required this.goals,
    required this.availability,
    required this.color,
    required this.availabilitySummary,
    this.matchScore,
    this.matchReasons = const [],
  });
}

class MatchRequest {
  final String name;
  final String message;
  final String status;
  final int? buddyId;
  final bool isOutgoing;

  const MatchRequest({
    required this.name,
    required this.message,
    required this.status,
    this.buddyId,
    this.isOutgoing = false,
  });
}

class AnnouncementItem {
  final String title;
  final String message;

  const AnnouncementItem({required this.title, required this.message});
}

class EventRegistration {
  final int id;
  final int eventId;
  final String studentName;
  final String email;
  final bool checkedIn;

  const EventRegistration({
    required this.id,
    required this.eventId,
    required this.studentName,
    required this.email,
    this.checkedIn = false,
  });

  EventRegistration copyWith({bool? checkedIn}) {
    return EventRegistration(
      id: id,
      eventId: eventId,
      studentName: studentName,
      email: email,
      checkedIn: checkedIn ?? this.checkedIn,
    );
  }
}

class CampusData {
  final List<DemoEvent> events;
  final Set<int> bookmarkedEventIds;
  final List<EventRegistration> registrations;
  final List<MatchRequest> matchRequests;

  const CampusData({
    required this.events,
    required this.bookmarkedEventIds,
    required this.registrations,
    required this.matchRequests,
  });

  DemoEvent? eventById(int eventId) {
    for (final event in events) {
      if (event.id == eventId) return event;
    }
    return null;
  }

  bool isRegistered(int eventId, String email) {
    return registrations.any(
      (registration) =>
          registration.eventId == eventId &&
          registration.email.toLowerCase() == email.toLowerCase(),
    );
  }

  List<DemoEvent> registeredEventsFor(String email) {
    final registeredIds = registrations
        .where(
          (registration) =>
              registration.email.toLowerCase() == email.toLowerCase(),
        )
        .map((registration) => registration.eventId)
        .toSet();
    return events.where((event) => registeredIds.contains(event.id)).toList();
  }

  List<EventRegistration> registrationsFor(int eventId) {
    return registrations
        .where((registration) => registration.eventId == eventId)
        .toList();
  }

  bool hasOutgoingMatchRequest(int buddyId) {
    return matchRequests.any(
      (request) => request.isOutgoing && request.buddyId == buddyId,
    );
  }
}

class CampusDataController extends StateNotifier<CampusData> {
  CampusDataController({CampusPulseApi? api})
    : _api = api,
      super(
        CampusData(
          events: List.unmodifiable(demoEvents),
          bookmarkedEventIds: const {},
          registrations: api == null
              ? const [
                  EventRegistration(
                    id: 1,
                    eventId: 1,
                    studentName: 'Aanya Sharma',
                    email: 'student@campuspulse.edu',
                  ),
                  EventRegistration(
                    id: 2,
                    eventId: 1,
                    studentName: 'Riya Nair',
                    email: 'riya.nair@campuspulse.edu',
                  ),
                  EventRegistration(
                    id: 3,
                    eventId: 1,
                    studentName: 'Kabir Shah',
                    email: 'kabir.shah@campuspulse.edu',
                  ),
                  EventRegistration(
                    id: 4,
                    eventId: 2,
                    studentName: 'Aanya Sharma',
                    email: 'student@campuspulse.edu',
                  ),
                  EventRegistration(
                    id: 5,
                    eventId: 2,
                    studentName: 'Meera Patel',
                    email: 'meera.patel@campuspulse.edu',
                  ),
                ]
              : const [],
          matchRequests: List.unmodifiable(demoMatchRequests),
        ),
      );

  final CampusPulseApi? _api;

  Future<bool> refreshFromBackend({
    String? prototypeStudentId,
    String? studentName,
  }) async {
    final api = _api;
    if (api == null) return false;
    try {
      final remoteEvents = await api.listEvents();
      final registeredEvents = prototypeStudentId == null
          ? null
          : await api.myRegistrations(prototypeStudentId);
      state = CampusData(
        events: List.unmodifiable(remoteEvents.map(_toDemoEvent)),
        bookmarkedEventIds: state.bookmarkedEventIds,
        registrations: registeredEvents == null
            ? state.registrations
            : List.unmodifiable([
                for (var index = 0; index < registeredEvents.length; index++)
                  EventRegistration(
                    id: index + 1,
                    eventId: registeredEvents[index].id,
                    studentName: studentName ?? prototypeStudentId ?? 'Student',
                    email: prototypeStudentId ?? '',
                  ),
              ]),
        matchRequests: state.matchRequests,
      );
      return true;
    } on Exception catch (error) {
      debugPrint('Campus Pulse backend unavailable: $error');
      return false;
    }
  }

  Future<bool> registerForEventWithBackend(
    int eventId, {
    required String studentName,
    required String email,
  }) async {
    final api = _api;
    if (api == null) {
      return registerForEvent(eventId, studentName: studentName, email: email);
    }
    if (email.trim().isEmpty || state.isRegistered(eventId, email)) {
      return false;
    }
    final normalizedEmail = email.trim().toLowerCase();
    await api.registerForEvent(eventId, normalizedEmail);
    final nextRegistrationId = state.registrations.isEmpty
        ? 1
        : state.registrations
                  .map((registration) => registration.id)
                  .reduce((left, right) => left > right ? left : right) +
              1;
    state = CampusData(
      events: [
        for (final item in state.events)
          if (item.id == eventId)
            item.copyWith(seatsLeft: item.seatsLeft - 1)
          else
            item,
      ],
      bookmarkedEventIds: state.bookmarkedEventIds,
      registrations: List.unmodifiable([
        ...state.registrations,
        EventRegistration(
          id: nextRegistrationId,
          eventId: eventId,
          studentName: studentName,
          email: normalizedEmail,
        ),
      ]),
      matchRequests: state.matchRequests,
    );
    await refreshFromBackend(
      prototypeStudentId: normalizedEmail,
      studentName: studentName,
    );
    return true;
  }

  void toggleBookmark(int eventId) {
    if (state.eventById(eventId) == null) return;
    final updatedBookmarks = {...state.bookmarkedEventIds};
    if (!updatedBookmarks.add(eventId)) updatedBookmarks.remove(eventId);
    state = CampusData(
      events: state.events,
      bookmarkedEventIds: Set.unmodifiable(updatedBookmarks),
      registrations: state.registrations,
      matchRequests: state.matchRequests,
    );
  }

  bool registerForEvent(
    int eventId, {
    required String studentName,
    required String email,
  }) {
    final event = state.eventById(eventId);
    if (event == null ||
        event.seatsLeft <= 0 ||
        email.trim().isEmpty ||
        state.isRegistered(eventId, email)) {
      return false;
    }

    final nextRegistrationId = state.registrations.isEmpty
        ? 1
        : state.registrations
                  .map((registration) => registration.id)
                  .reduce((left, right) => left > right ? left : right) +
              1;
    final registrations = [
      ...state.registrations,
      EventRegistration(
        id: nextRegistrationId,
        eventId: eventId,
        studentName: studentName,
        email: email.trim().toLowerCase(),
      ),
    ];
    state = CampusData(
      events: [
        for (final item in state.events)
          if (item.id == eventId)
            item.copyWith(seatsLeft: item.seatsLeft - 1)
          else
            item,
      ],
      bookmarkedEventIds: state.bookmarkedEventIds,
      registrations: List.unmodifiable(registrations),
      matchRequests: state.matchRequests,
    );
    return true;
  }

  DemoEvent createEvent(DemoEvent event) {
    final nextId = state.events.isEmpty
        ? 1
        : state.events
                  .map((item) => item.id)
                  .reduce((left, right) => left > right ? left : right) +
              1;
    final createdEvent = event.copyWith(id: nextId, isRegistered: false);
    state = CampusData(
      events: List.unmodifiable([...state.events, createdEvent]),
      bookmarkedEventIds: state.bookmarkedEventIds,
      registrations: state.registrations,
      matchRequests: state.matchRequests,
    );
    return createdEvent;
  }

  Future<DemoEvent> createEventWithBackend(DemoEvent event) async {
    final api = _api;
    if (api == null) return createEvent(event);
    final created = await api.createEvent(
      title: event.title,
      category: event.category,
      startsAt: _parseDemoEventDate(event),
      venue: event.venue,
      organizer: event.organizer,
      description: event.description,
      capacity: event.seatsLeft,
      tags: [event.category],
    );
    final refreshed = await refreshFromBackend();
    final createdEvent = _toDemoEvent(created);
    if (!refreshed && state.eventById(createdEvent.id) == null) {
      state = CampusData(
        events: List.unmodifiable([...state.events, createdEvent]),
        bookmarkedEventIds: state.bookmarkedEventIds,
        registrations: state.registrations,
        matchRequests: state.matchRequests,
      );
    }
    return createdEvent;
  }

  Future<List<DemoBuddy>?> loadStudyBuddyMatches() async {
    final api = _api;
    if (api == null) return null;
    try {
      final matches = await api.matchStudyBuddies(
        subjects: demoStudentSubjects.toList(),
        goals: demoStudentGoals.toList(),
        availability: demoStudentAvailability.toList(),
      );
      return [
        for (final match in matches)
          DemoBuddy(
            id: match.profile.id,
            name: match.profile.name,
            branch: match.profile.major,
            year: match.profile.year,
            subjects: match.profile.subjects,
            skills: const [],
            goals: match.profile.goals,
            availability: match.profile.availability,
            color: _buddyColorForId(match.profile.id),
            availabilitySummary: match.profile.availability.join(' • '),
            matchScore: match.score,
            matchReasons: match.reasons,
          ),
      ];
    } on Exception catch (error) {
      debugPrint('Campus Pulse buddy matching unavailable: $error');
      return null;
    }
  }

  bool checkIn(int registrationId) {
    var changed = false;
    final registrations = state.registrations.map((registration) {
      if (registration.id != registrationId || registration.checkedIn) {
        return registration;
      }
      changed = true;
      return registration.copyWith(checkedIn: true);
    }).toList();
    if (!changed) return false;
    state = CampusData(
      events: state.events,
      bookmarkedEventIds: state.bookmarkedEventIds,
      registrations: List.unmodifiable(registrations),
      matchRequests: state.matchRequests,
    );
    return true;
  }

  bool sendMatchRequest(DemoBuddy buddy, {required String senderName}) {
    if (state.hasOutgoingMatchRequest(buddy.id)) return false;
    state = CampusData(
      events: state.events,
      bookmarkedEventIds: state.bookmarkedEventIds,
      registrations: state.registrations,
      matchRequests: List.unmodifiable([
        ...state.matchRequests,
        MatchRequest(
          name: buddy.name,
          message: '$senderName sent a study buddy request.',
          status: 'Sent',
          buddyId: buddy.id,
          isOutgoing: true,
        ),
      ]),
    );
    return true;
  }
}

DemoEvent _toDemoEvent(CampusEvent event) {
  final localDate = event.startsAt.toLocal();
  final month = const [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ][localDate.month - 1];
  final hour = localDate.hour % 12 == 0 ? 12 : localDate.hour % 12;
  final minute = localDate.minute.toString().padLeft(2, '0');
  final meridiem = localDate.hour >= 12 ? 'PM' : 'AM';
  return DemoEvent(
    id: event.id,
    title: event.title,
    date:
        '${localDate.day.toString().padLeft(2, '0')} $month ${localDate.year}',
    time: '$hour:$minute $meridiem',
    venue: event.venue,
    organizer: event.organizer,
    category: event.category,
    color: _colorForCategory(event.category),
    isRegistered: false,
    seatsLeft: event.capacity,
    description: event.description,
  );
}

DateTime _parseDemoEventDate(DemoEvent event) {
  final parts = event.date.split(' ');
  final day = int.parse(parts[0]);
  final month = const {
    'Jan': 1,
    'Feb': 2,
    'Mar': 3,
    'Apr': 4,
    'May': 5,
    'Jun': 6,
    'Jul': 7,
    'Aug': 8,
    'Sep': 9,
    'Oct': 10,
    'Nov': 11,
    'Dec': 12,
  }[parts[1]]!;
  final time = event.time.split(' ');
  final clock = time[0].split(':');
  var hour = int.parse(clock[0]);
  final minute = int.parse(clock[1]);
  if (time[1] == 'PM' && hour != 12) hour += 12;
  if (time[1] == 'AM' && hour == 12) hour = 0;
  return DateTime(int.parse(parts[2]), month, day, hour, minute);
}

Color _colorForCategory(String category) {
  return switch (category.toLowerCase()) {
    'hackathons' => const Color(0xFF2563EB),
    'workshops' => const Color(0xFF7C3AED),
    'sports' => const Color(0xFF22C55E),
    _ => const Color(0xFF14B8A6),
  };
}

Color _buddyColorForId(int id) {
  const colors = [
    Color(0xFF1D4ED8),
    Color(0xFF7C3AED),
    Color(0xFF0F766E),
    Color(0xFFEA580C),
    Color(0xFF0891B2),
    Color(0xFFCA8A04),
    Color(0xFFDB2777),
  ];
  return colors[(id - 1) % colors.length];
}

double jaccardPercent(Set<String> a, Set<String> b) {
  if (a.isEmpty && b.isEmpty) return 0;
  if (a.isEmpty || b.isEmpty) return 0;
  final intersection = a.intersection(b).length;
  final union = a.union(b).length;
  return (intersection / union) * 100;
}

double calculateCompatibilityScore({
  required Set<String> subjectsA,
  required Set<String> subjectsB,
  required Set<String> goalsA,
  required Set<String> goalsB,
  required Set<String> availabilityA,
  required Set<String> availabilityB,
}) {
  final subjectSimilarity = jaccardPercent(subjectsA, subjectsB);
  final goalSimilarity = jaccardPercent(goalsA, goalsB);
  final availabilitySimilarity = jaccardPercent(availabilityA, availabilityB);

  final score =
      (subjectSimilarity * 0.50) +
      (goalSimilarity * 0.30) +
      (availabilitySimilarity * 0.20);
  return score.clamp(0, 100);
}

const Set<String> demoStudentSubjects = {
  'DSA',
  'Web Development',
  'UI/UX Design',
};
const Set<String> demoStudentSkills = {'Flutter', 'Problem Solving', 'Figma'};
const Set<String> demoStudentGoals = {'Placement Preparation', 'Project Work'};
const Set<String> demoStudentAvailability = {
  'Mon Morning',
  'Wed Evening',
  'Sat Afternoon',
};

class StudyMatchBreakdown {
  final int studyContribution;
  final int goalContribution;
  final int availabilityContribution;

  const StudyMatchBreakdown({
    required this.studyContribution,
    required this.goalContribution,
    required this.availabilityContribution,
  });

  int get score =>
      studyContribution + goalContribution + availabilityContribution;
}

StudyMatchBreakdown calculateStudyMatchBreakdown({
  required Set<String> subjectsA,
  required Set<String> subjectsB,
  required Set<String> skillsA,
  required Set<String> skillsB,
  required Set<String> goalsA,
  required Set<String> goalsB,
  required Set<String> availabilityA,
  required Set<String> availabilityB,
}) {
  final studySimilarity = jaccardPercent(
    {...subjectsA, ...skillsA},
    {...subjectsB, ...skillsB},
  );
  final goalSimilarity = jaccardPercent(goalsA, goalsB);
  final availabilitySimilarity = jaccardPercent(availabilityA, availabilityB);
  return StudyMatchBreakdown(
    studyContribution: (studySimilarity * 0.50).round(),
    goalContribution: (goalSimilarity * 0.30).round(),
    availabilityContribution: (availabilitySimilarity * 0.20).round(),
  );
}

final demoEvents = [
  DemoEvent(
    id: 1,
    title: 'Campus Hackathon 2026',
    date: '28 Oct 2026',
    time: '10:00 AM',
    venue: 'Innovation Hall',
    organizer: 'Tech Club',
    category: 'Hackathons',
    color: const Color(0xFF2563EB),
    isRegistered: true,
    seatsLeft: 35,
    description: 'A full-day innovation sprint with product ideation, rapid prototyping, mentoring, and final presentations from campus builders across disciplines.',
  ),
  DemoEvent(
    id: 2,
    title: 'Design Systems Workshop',
    date: '30 Oct 2026',
    time: '12:00 PM',
    venue: 'Creative Lab',
    organizer: 'Design Circle',
    category: 'Workshops',
    color: const Color(0xFF7C3AED),
    isRegistered: true,
    seatsLeft: 18,
    description: 'Learn how teams build scalable design systems, reusable components, and consistent product experiences for student-led projects and startups.',
  ),
  DemoEvent(
    id: 3,
    title: 'AI for Social Impact',
    date: '02 Nov 2026',
    time: '6:00 PM',
    venue: 'Seminar Block',
    organizer: 'Campus Labs',
    category: 'Workshops',
    color: const Color(0xFF14B8A6),
    isRegistered: false,
    seatsLeft: 21,
    description: 'Explore AI-powered social good use cases, campus innovation, and the ethics behind responsible AI design in real-world problem solving.',
  ),
  DemoEvent(
    id: 4,
    title: 'Inter-College Sports Fest',
    date: '05 Nov 2026',
    time: '9:00 AM',
    venue: 'Main Turf',
    organizer: 'Sports Council',
    category: 'Sports',
    color: const Color(0xFF22C55E),
    isRegistered: false,
    seatsLeft: 42,
    description: 'A vibrant sports weekend with team events, open trials, and student networking opportunities across multiple sporting disciplines.',
  ),
  DemoEvent(
    id: 5,
    title: 'Build for Good: Civic Tech Sprint',
    date: '08 Nov 2026',
    time: '9:30 AM',
    venue: 'Innovation Hall',
    organizer: 'Tech Club',
    category: 'Hackathons',
    color: const Color(0xFF2563EB),
    isRegistered: false,
    seatsLeft: 28,
    description: 'Team up to prototype practical digital tools for campus and local community challenges, with mentor reviews throughout the day.',
  ),
  DemoEvent(
    id: 6,
    title: 'Product Design Critique Night',
    date: '10 Nov 2026',
    time: '5:30 PM',
    venue: 'Creative Lab',
    organizer: 'Design Circle',
    category: 'Clubs',
    color: const Color(0xFF14B8A6),
    isRegistered: false,
    seatsLeft: 24,
    description: 'Bring a project in progress for a friendly peer critique covering user flows, accessibility, and visual design decisions.',
  ),
  DemoEvent(
    id: 7,
    title: 'Git and GitHub for Team Projects',
    date: '12 Nov 2026',
    time: '4:00 PM',
    venue: 'Engineering Lab 2',
    organizer: 'Developer Society',
    category: 'Workshops',
    color: const Color(0xFF7C3AED),
    isRegistered: false,
    seatsLeft: 32,
    description: 'Practice branches, pull requests, and code reviews in a guided workshop designed for students building their first team project.',
  ),
  DemoEvent(
    id: 8,
    title: 'Open Mic on the Quad',
    date: '14 Nov 2026',
    time: '6:30 PM',
    venue: 'Central Quad',
    organizer: 'Arts and Culture Club',
    category: 'Clubs',
    color: const Color(0xFFF97316),
    isRegistered: false,
    seatsLeft: 60,
    description: 'An evening of student music, poetry, and short performances. Sign up for a spot or come along to support campus artists.',
  ),
  DemoEvent(
    id: 9,
    title: 'Data Science Case Challenge',
    date: '18 Nov 2026',
    time: '10:00 AM',
    venue: 'Business School Auditorium',
    organizer: 'Analytics Society',
    category: 'Hackathons',
    color: const Color(0xFF2563EB),
    isRegistered: false,
    seatsLeft: 36,
    description: 'Work in small teams to explore a real-world dataset, develop a clear insight, and present your findings to faculty and industry guests.',
  ),
  DemoEvent(
    id: 10,
    title: 'Sunrise 5K Campus Run',
    date: '21 Nov 2026',
    time: '7:00 AM',
    venue: 'North Gate Track',
    organizer: 'Running Club',
    category: 'Sports',
    color: const Color(0xFF22C55E),
    isRegistered: false,
    seatsLeft: 75,
    description: 'A relaxed campus 5K for all experience levels, with warm-up groups, water stations, and a post-run breakfast at the student center.',
  ),
];

final demoBuddies = [
  DemoBuddy(
    id: 1,
    name: 'Riya Nair',
    branch: 'CSE',
    year: '3rd Year',
    subjects: ['DSA', 'Web Development', 'UI/UX Design'],
    skills: ['Flutter', 'Problem Solving', 'Figma'],
    goals: ['Placement Preparation', 'Project Work'],
    availability: ['Mon Morning', 'Wed Evening', 'Sat Afternoon'],
    color: const Color(0xFF1D4ED8),
    availabilitySummary: 'Mon morning • Sat afternoon',
  ),
  DemoBuddy(
    id: 2,
    name: 'Arjun Mehta',
    branch: 'ECE',
    year: '2nd Year',
    subjects: ['DSA', 'Machine Learning', 'App Development'],
    skills: ['Flutter', 'Machine Learning', 'Teamwork'],
    goals: ['Project Work', 'Learning New Skills'],
    availability: ['Tue Evening', 'Sat Afternoon', 'Sun Morning'],
    color: const Color(0xFF7C3AED),
    availabilitySummary: 'Tue evening • Sat afternoon',
  ),
  DemoBuddy(
    id: 3,
    name: 'Samaira Shah',
    branch: 'IT',
    year: '3rd Year',
    subjects: ['UI/UX Design', 'Web Development'],
    skills: ['Figma', 'Prototyping', 'UI/UX Research'],
    goals: ['Exam Revision', 'Placement Preparation'],
    availability: ['Thu Morning', 'Fri Evening'],
    color: const Color(0xFF10B981),
    availabilitySummary: 'Thu morning • Fri evening',
  ),
  DemoBuddy(
    id: 4,
    name: 'Dev Malhotra',
    branch: 'CSE',
    year: '2nd Year',
    subjects: ['Data Science', 'Machine Learning', 'Python'],
    skills: ['Python', 'Pandas', 'Data Visualization'],
    goals: ['Research Experience', 'Project Work'],
    availability: ['Mon Evening', 'Wed Afternoon', 'Sat Morning'],
    color: const Color(0xFFEA580C),
    availabilitySummary: 'Mon evening • Sat morning',
  ),
  DemoBuddy(
    id: 5,
    name: 'Anika Bose',
    branch: 'ECE',
    year: '3rd Year',
    subjects: ['Embedded Systems', 'IoT', 'Digital Logic'],
    skills: ['Arduino', 'C++', 'Circuit Design'],
    goals: ['Project Work', 'Placement Preparation'],
    availability: ['Tue Afternoon', 'Thu Evening', 'Sun Morning'],
    color: const Color(0xFF0891B2),
    availabilitySummary: 'Tue afternoon • Thu evening',
  ),
  DemoBuddy(
    id: 6,
    name: 'Kabir Khanna',
    branch: 'Mechanical',
    year: '2nd Year',
    subjects: ['CAD', 'Robotics', 'Manufacturing'],
    skills: ['Fusion 360', 'Prototyping', 'Public Speaking'],
    goals: ['Competition Preparation', 'Learning New Skills'],
    availability: ['Wed Evening', 'Fri Afternoon', 'Sat Morning'],
    color: const Color(0xFFCA8A04),
    availabilitySummary: 'Wed evening • Sat morning',
  ),
  DemoBuddy(
    id: 7,
    name: 'Mira Iyer',
    branch: 'IT',
    year: '4th Year',
    subjects: ['Cybersecurity', 'Networking', 'Cloud Computing'],
    skills: ['Linux', 'Docker', 'Technical Writing'],
    goals: ['Placement Preparation', 'Research Experience'],
    availability: ['Mon Afternoon', 'Thu Morning', 'Sun Evening'],
    color: const Color(0xFFDB2777),
    availabilitySummary: 'Mon afternoon • Sun evening',
  ),
];

final demoMatchRequests = [
  const MatchRequest(
    name: 'Riya Nair',
    message: 'Want to prep for interview rounds together.',
    status: 'Accepted',
  ),
  const MatchRequest(
    name: 'Arjun Mehta',
    message: 'Would love to review DSA questions together.',
    status: 'Pending',
  ),
  const MatchRequest(
    name: 'Samaira Shah',
    message: 'Looking for a design critique partner.',
    status: 'Pending',
  ),
  const MatchRequest(
    name: 'Neel Joshi',
    message: 'Would you like to form a team for the civic tech sprint?',
    status: 'Pending',
  ),
  const MatchRequest(
    name: 'Ishita Rao',
    message: 'I am looking for a partner to practice system design.',
    status: 'Accepted',
  ),
];

final announcementItems = [
  const AnnouncementItem(
    title: 'Hackathon registrations are live',
    message: 'The student innovation sprint opens registration for the next 48 hours.',
  ),
  const AnnouncementItem(
    title: 'Campus club recruitment',
    message: 'Apply to join the product, design, and media clubs before this Saturday.',
  ),
  const AnnouncementItem(
    title: 'Career fair reminder',
    message: 'The campus placement fair starts on Monday at 9:30 AM in the auditorium.',
  ),
  const AnnouncementItem(
    title: 'Library hours extended during project week',
    message: 'The central library will stay open until midnight from 9 to 20 November. Bring your campus ID for late entry.',
  ),
  const AnnouncementItem(
    title: 'Volunteer sign-ups are open',
    message: 'Join the student volunteer team for the inter-college sports fest. Briefing is on 3 November at the main turf.',
  ),
  const AnnouncementItem(
    title: 'Student project showcase submissions',
    message: 'Submit a short project summary by 16 November to be considered for a demo booth at the semester showcase.',
  ),
];
