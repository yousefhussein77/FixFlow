import 'package:fixflow/auth/models/auth_models.dart';
import 'package:fixflow/accounts/models/account_request_models.dart';
import 'package:fixflow/accounts/repositories/account_request_repository.dart';
import 'package:fixflow/auth/repositories/auth_repository.dart';
import 'package:fixflow/auth/state/auth_controller.dart';
import 'package:fixflow/design_system/theme/fixflow_theme.dart';
import 'package:fixflow/design_system/theme/fixflow_theme_controller.dart';
import 'package:fixflow/tickets/models/admin_ticket_models.dart';
import 'package:fixflow/tickets/models/ticket_models.dart';
import 'package:fixflow/tickets/repositories/admin_ticket_repository.dart';
import 'package:fixflow/tickets/screens/administrator_dashboard_screen.dart';
import 'package:fixflow/notifications/models/notification_models.dart';
import 'package:fixflow/notifications/repositories/notification_repository.dart';
import 'package:fixflow/notifications/widgets/notification_host.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('administrator dashboard header exposes unread notifications', (
    tester,
  ) async {
    final auth = AuthController(_AuthRepository())..restore();
    await tester.pumpAndSettle();
    await tester.binding.setSurfaceSize(const Size(1440, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        theme: FixFlowTheme.light(),
        home: NotificationHost(
          repository: _NotificationRepository(),
          refreshInterval: const Duration(days: 1),
          onNavigate: (_, _) async => null,
          child: AdministratorDashboardScreen(
            authController: auth,
            repository: _AdminRepository(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('notification_bell')), findsOneWidget);
    expect(find.byKey(const Key('notification_badge')), findsOneWidget);
  });

  testWidgets('administrator dashboard presents real counts and actions', (
    tester,
  ) async {
    final auth = AuthController(_AuthRepository())..restore();
    final repository = _AdminRepository();
    await tester.pumpAndSettle();
    await tester.pumpWidget(
      MaterialApp(
        theme: FixFlowTheme.light(),
        home: AdministratorDashboardScreen(
          authController: auth,
          repository: repository,
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('dashboard_welcome')), findsOneWidget);
    expect(find.text('إجمالي التذاكر'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    expect(find.text('بانتظار الإسناد'), findsOneWidget);
    expect(find.byKey(const Key('dashboard_all_tickets')), findsOneWidget);
    expect(find.text('النشاط الأخير'), findsOneWidget);
    expect(find.byIcon(Icons.refresh), findsNothing);
    expect(repository.listCalls, 1);
    final pull = find.byKey(const Key('administrator_pull_to_refresh'));
    expect(pull, findsOneWidget);
    await tester.drag(pull, const Offset(0, 300));
    await tester.pumpAndSettle();
    expect(repository.listCalls, 2);
  });

  testWidgets('dashboard renders the approved bitmap logo variants', (
    tester,
  ) async {
    final auth = AuthController(_AuthRepository())..restore();
    await tester.pumpAndSettle();
    await tester.binding.setSurfaceSize(const Size(1440, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        theme: FixFlowTheme.light(),
        home: AdministratorDashboardScreen(
          authController: auth,
          repository: _AdminRepository(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final assets = tester
        .widgetList<Image>(find.byType(Image))
        .map((image) => image.image)
        .whereType<AssetImage>()
        .map((image) => image.assetName)
        .toSet();
    expect(assets, contains('assets/brand/fixflow_logo_wordmark.png'));
    final desktopLogo = tester
        .widgetList<Image>(find.byType(Image))
        .firstWhere(
          (image) =>
              (image.image as AssetImage).assetName ==
              'assets/brand/fixflow_logo_wordmark.png',
        );
    expect(desktopLogo.height, 120);

    await tester.binding.setSurfaceSize(const Size(390, 844));
    await tester.pumpWidget(
      MaterialApp(
        theme: FixFlowTheme.light(),
        home: AdministratorDashboardScreen(
          authController: auth,
          repository: _AdminRepository(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final mobileAssets = tester
        .widgetList<Image>(find.byType(Image))
        .map((image) => image.image)
        .whereType<AssetImage>()
        .map((image) => image.assetName)
        .toSet();
    expect(mobileAssets, contains('assets/brand/fixflow_logo_mark.png'));
    final mobileLogo = tester
        .widgetList<Image>(find.byType(Image))
        .firstWhere(
          (image) =>
              (image.image as AssetImage).assetName ==
              'assets/brand/fixflow_logo_mark.png',
        );
    expect(mobileLogo.width, 48);
    expect(mobileLogo.height, 48);
    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();
    final drawerLogo = tester
        .widgetList<Image>(find.byType(Image))
        .toList()
        .reversed
        .firstWhere(
          (image) =>
              (image.image as AssetImage).assetName ==
              'assets/brand/fixflow_logo_mark.png',
        );
    expect(drawerLogo.width, 120);
    expect(drawerLogo.height, 120);
  });

  testWidgets('dashboard remains usable at 320px with RTL and 200% text', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 700));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final auth = AuthController(_AuthRepository())..restore();
    await tester.pumpAndSettle();
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(2)),
        child: MaterialApp(
          theme: FixFlowTheme.dark(),
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: AdministratorDashboardScreen(
              authController: auth,
              repository: _AdminRepository(),
              accountRequestRepository: _EmptyAccountRequestRepository(),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('dashboard_welcome')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('dashboard exposes offline recovery state', (tester) async {
    final auth = AuthController(_AuthRepository())..restore();
    await tester.pumpAndSettle();
    await tester.pumpWidget(
      MaterialApp(
        home: AdministratorDashboardScreen(
          authController: auth,
          repository: _AdminRepository(failure: TicketFailureKind.offline),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('admin_dashboard_retry')), findsOneWidget);
    expect(find.text('تعذر تحميل بيانات لوحة التحكم'), findsOneWidget);
  });

  testWidgets('desktop and mobile dashboard expose the theme control', (
    tester,
  ) async {
    final auth = AuthController(_AuthRepository())..restore();
    final theme = ThemeController(_MemoryThemeStore());
    await tester.pumpAndSettle();
    await tester.pumpWidget(
      MaterialApp(
        theme: FixFlowTheme.light(),
        darkTheme: FixFlowTheme.dark(),
        themeMode: theme.mode,
        home: AdministratorDashboardScreen(
          authController: auth,
          repository: _AdminRepository(),
          themeController: theme,
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('dashboard_theme_toggle')), findsOneWidget);
    await tester.tap(find.byKey(const Key('dashboard_theme_toggle')));
    await tester.pumpAndSettle();
    expect(theme.mode, ThemeMode.dark);

    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        theme: FixFlowTheme.light(),
        darkTheme: FixFlowTheme.dark(),
        themeMode: theme.mode,
        home: AdministratorDashboardScreen(
          authController: auth,
          repository: _AdminRepository(),
          themeController: theme,
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('dashboard_theme_toggle')), findsOneWidget);
  });

  testWidgets('desktop sign out is visible and requires confirmation', (
    tester,
  ) async {
    final auth = AuthController(_AuthRepository())..restore();
    await tester.pumpAndSettle();
    await tester.binding.setSurfaceSize(const Size(1440, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        theme: FixFlowTheme.light(),
        home: AdministratorDashboardScreen(
          authController: auth,
          repository: _AdminRepository(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('تسجيل الخروج'), findsOneWidget);
    await tester.tap(find.text('تسجيل الخروج'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('confirm_sign_out')), findsOneWidget);
    await tester.tap(find.byKey(const Key('confirm_sign_out')));
    await tester.pumpAndSettle();
    expect(auth.state.status, AuthViewStatus.signedOut);
  });

  testWidgets('mobile account menu exposes confirmed sign out', (tester) async {
    final auth = AuthController(_AuthRepository())..restore();
    await tester.pumpAndSettle();
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        theme: FixFlowTheme.light(),
        home: AdministratorDashboardScreen(
          authController: auth,
          repository: _AdminRepository(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('قائمة الحساب').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('تسجيل الخروج'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('confirm_sign_out')), findsOneWidget);
    await tester.tap(find.byKey(const Key('confirm_sign_out')));
    await tester.pumpAndSettle();
    expect(auth.state.status, AuthViewStatus.signedOut);
  });

  for (final brightness in Brightness.values) {
    for (final direction in TextDirection.values) {
      testWidgets(
        'administrator dashboard desktop golden ${brightness.name} ${direction.name}',
        (tester) async {
          await tester.binding.setSurfaceSize(const Size(1440, 900));
          addTearDown(() => tester.binding.setSurfaceSize(null));
          final auth = AuthController(_AuthRepository())..restore();
          await tester.pumpAndSettle();
          await tester.pumpWidget(
            MaterialApp(
              theme: FixFlowTheme.light(),
              darkTheme: FixFlowTheme.dark(),
              themeMode: brightness == Brightness.dark
                  ? ThemeMode.dark
                  : ThemeMode.light,
              home: Directionality(
                textDirection: direction,
                child: AdministratorDashboardScreen(
                  authController: auth,
                  repository: _AdminRepository(),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();
          await expectLater(
            find.byType(AdministratorDashboardScreen),
            matchesGoldenFile(
              'goldens/administrator_dashboard_desktop_${brightness.name}_${direction.name}.png',
            ),
          );
        },
      );
    }
    testWidgets('administrator dashboard mobile golden ${brightness.name}', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final auth = AuthController(_AuthRepository())..restore();
      await tester.pumpAndSettle();
      await tester.pumpWidget(
        MaterialApp(
          theme: FixFlowTheme.light(),
          darkTheme: FixFlowTheme.dark(),
          themeMode: brightness == Brightness.dark
              ? ThemeMode.dark
              : ThemeMode.light,
          home: AdministratorDashboardScreen(
            authController: auth,
            repository: _AdminRepository(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(AdministratorDashboardScreen),
        matchesGoldenFile(
          'goldens/administrator_dashboard_mobile_${brightness.name}.png',
        ),
      );
    });
  }
}

class _AdminRepository implements AdminTicketRepository {
  _AdminRepository({this.failure});
  final TicketFailureKind? failure;
  int listCalls = 0;
  @override
  Future<AdminTicketPage> list({int page = 1, int perPage = 20}) async {
    listCalls++;
    if (failure != null) {
      throw TicketFailure(failure!, 'Network unavailable.');
    }
    return AdminTicketPage(
      [
        AdminTicketSummary(
          reference: 'TKT-001',
          title: 'Leaking tap',
          reporter: const UserSummary(1, 'Reporter'),
          priority: 'high',
          department: const TicketOption(1, 'Facilities'),
          category: const TicketOption(2, 'Plumbing'),
          status: 'new',
          assignedTechnician: null,
          createdAt: DateTime.utc(2026, 1, 2),
        ),
        AdminTicketSummary(
          reference: 'TKT-002',
          title: 'Broken light',
          reporter: const UserSummary(2, 'Another reporter'),
          priority: 'medium',
          department: const TicketOption(1, 'Facilities'),
          category: const TicketOption(3, 'Electrical'),
          status: 'completed',
          assignedTechnician: const UserSummary(4, 'Technician'),
          createdAt: DateTime.utc(2026, 1, 1),
        ),
      ],
      currentPage: 1,
      lastPage: 1,
      total: 2,
    );
  }

  @override
  Future<List<TechnicianOption>> technicians() async => const [];

  @override
  Future<AdminTicketSummary> assign(String reference, int technicianId) =>
      throw UnimplementedError();
}

class _AuthRepository implements AuthRepository {
  final value = UserProfile(
    id: 1,
    name: 'Admin User',
    email: 'admin@example.com',
    role: 'administrator',
    isActive: true,
    createdAt: DateTime.utc(2026),
  );
  @override
  Future<UserProfile?> restore() async => value;
  @override
  Future<UserProfile> profile() async => value;
  @override
  Future<void> logout() async {}

  @override
  Future<UserProfile> login({
    required String email,
    required String password,
  }) => Future.value(value);
  @override
  Future<UserProfile> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    String role = 'reporter',
  }) => Future.value(value);
}

class _EmptyAccountRequestRepository implements AccountRequestRepository {
  @override
  Future<List<AccountRequest>> list(AccountRequestStatus status) async => [];

  @override
  Future<AccountRequest> approve(int id) => throw UnimplementedError();

  @override
  Future<AccountRequest> reject(int id, {String? reason}) =>
      throw UnimplementedError();
}

class _MemoryThemeStore implements ThemePreferenceStore {
  String? value;
  @override
  Future<String?> read() async => value;
  @override
  Future<void> write(String next) async => value = next;
}

class _NotificationRepository implements NotificationRepository {
  final item = AppNotification(
    id: 1,
    type: 'account_request.created',
    title: 'طلب حساب جديد',
    message: 'وصل طلب حساب جديد.',
    navigationTarget: 'admin.account_requests',
    payload: const {'account_id': 2},
    createdAt: DateTime.utc(2026, 8, 1),
  );

  @override
  Future<List<AppNotification>> list() async => [item];
  @override
  Future<int> unreadCount() async => 1;
  @override
  Future<AppNotification> markRead(int id) async =>
      item.copyWith(readAt: DateTime.utc(2026, 8, 1));
  @override
  Future<int> markAllRead() async => 1;
}
