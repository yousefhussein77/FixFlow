import 'package:flutter/material.dart';

import '../../accounts/repositories/account_request_repository.dart';
import '../../accounts/screens/account_requests_screen.dart';
import '../../auth/models/auth_models.dart';
import '../../auth/state/auth_controller.dart';
import '../../design_system/brand/fixflow_logo.dart';
import '../../design_system/components/content/fixflow_surfaces.dart';
import '../../design_system/components/feedback/fixflow_state_view.dart';
import '../../design_system/components/navigation/fixflow_navigation.dart';
import '../../design_system/components/tickets/fixflow_ticket_badges.dart';
import '../../design_system/layout/responsive_constraints.dart';
import '../../design_system/theme/fixflow_colors.dart';
import '../../design_system/theme/fixflow_theme_controller.dart';
import '../../design_system/tokens/fixflow_motion.dart';
import '../../design_system/tokens/fixflow_spacing.dart';
import '../../reference_data/screens/category_screen.dart';
import '../../reference_data/screens/department_screen.dart';
import '../../reference_data/state/reference_controller.dart';
import '../../notifications/widgets/notification_bell.dart';
import '../../notifications/widgets/notification_host.dart';
import '../models/admin_ticket_models.dart';
import '../repositories/admin_ticket_repository.dart';
import '../repositories/ticket_comment_repository.dart';
import '../state/admin_ticket_list_controller.dart';
import 'admin_ticket_list_screen.dart';

class AdministratorDashboardScreen extends StatefulWidget {
  const AdministratorDashboardScreen({
    required this.authController,
    required this.repository,
    this.referenceController,
    this.commentRepository,
    this.themeController,
    this.accountRequestRepository,
    super.key,
  });

  final AuthController authController;
  final AdminTicketRepository repository;
  final ReferenceController? referenceController;
  final TicketCommentRepository? commentRepository;
  final ThemeController? themeController;
  final AccountRequestRepository? accountRequestRepository;

  @override
  State<AdministratorDashboardScreen> createState() =>
      _AdministratorDashboardScreenState();
}

class _AdministratorDashboardScreenState
    extends State<AdministratorDashboardScreen> {
  late final AdminTicketListController controller;
  late final PageController _pageController;
  late final List<GlobalKey<NavigatorState>> _navigatorKeys;
  int _selectedDestination = 0;
  Future<void>? _dashboardRefreshInFlight;

  @override
  void initState() {
    super.initState();
    controller = AdminTicketListController(widget.repository)
      ..addListener(_changed)
      ..load();
    _pageController = PageController();
    _navigatorKeys = List.generate(
      widget.accountRequestRepository == null ? 4 : 5,
      (_) => GlobalKey<NavigatorState>(),
    );
  }

  @override
  void dispose() {
    controller.removeListener(_changed);
    controller.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _changed() {
    if (mounted) setState(() {});
  }

  Future<void> _refreshDashboard() {
    final active = _dashboardRefreshInFlight;
    if (active != null) return active;
    if (controller.state.status == AdminTicketListStatus.loading ||
        controller.state.status == AdminTicketListStatus.loadingMore) {
      return Future<void>.value();
    }
    final operation = controller.load();
    _dashboardRefreshInFlight = operation;
    return operation.whenComplete(() {
      if (identical(_dashboardRefreshInFlight, operation)) {
        _dashboardRefreshInFlight = null;
      }
    });
  }

  Future<void> _select(int index) async {
    if ((index == 2 || index == 3) && widget.referenceController == null) {
      return;
    }
    if (index == _selectedDestination) {
      _navigatorKeys[index].currentState?.popUntil((route) => route.isFirst);
      return;
    }
    setState(() => _selectedDestination = index);
    await _pageController.animateToPage(
      index,
      duration: FixFlowMotion.standard,
      curve: Curves.easeOutCubic,
    );
  }

  Widget _destination(int index, UserProfile? profile, bool wide) =>
      switch (index) {
        0 => SafeArea(
          child: RefreshIndicator(
            key: const Key('administrator_pull_to_refresh'),
            color: FixFlowColors.brandPrimary,
            onRefresh: _refreshDashboard,
            child: SingleChildScrollView(
              key: const PageStorageKey('administrator_dashboard_scroll'),
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(FixFlowSpacing.lg),
              child: FixFlowConstrainedContent(
                maxWidth: 1120,
                child: _DashboardContent(
                  profile: profile,
                  controller: controller,
                  onRefresh: controller.load,
                  onAllTickets: () => _select(1),
                  onDepartments: () => _select(2),
                  onCategories: () => _select(3),
                  onTeam: _showTechnicians,
                  onAccounts: widget.accountRequestRepository == null
                      ? null
                      : () => _select(4),
                  onSignOut: widget.authController.logout,
                  themeController: widget.themeController,
                  showThemeControl: MediaQuery.sizeOf(context).width >= 900,
                  showAccountControl: MediaQuery.sizeOf(context).width >= 900,
                  showNotificationControl: wide,
                ),
              ),
            ),
          ),
        ),
        1 => AdminTicketListScreen(
          repository: widget.repository,
          commentRepository: widget.commentRepository,
        ),
        2 =>
          widget.referenceController == null
              ? const _UnavailableDestination()
              : DepartmentScreen(controller: widget.referenceController!),
        3 =>
          widget.referenceController == null
              ? const _UnavailableDestination()
              : CategoryScreen(controller: widget.referenceController!),
        _ =>
          widget.accountRequestRepository == null
              ? const _UnavailableDestination()
              : AccountRequestsScreen(
                  repository: widget.accountRequestRepository!,
                ),
      };

  Future<void> _showTechnicians() async {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('الفريق / الفنيون'),
        content: FutureBuilder<List<TechnicianOption>>(
          future: widget.repository.technicians(),
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const SizedBox(
                height: 96,
                child: Center(child: CircularProgressIndicator()),
              );
            }
            if (snapshot.hasError) {
              return const Text('قائمة الفنيين غير متاحة.');
            }
            final technicians = snapshot.data ?? const <TechnicianOption>[];
            if (technicians.isEmpty)
              return const Text('لم يتم العثور على فنيين.');
            return SizedBox(
              width: (MediaQuery.sizeOf(context).width - 64).clamp(240, 360),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: technicians.length,
                itemBuilder: (_, index) => ListTile(
                  leading: CircleAvatar(
                    child: Text(technicians[index].name[0]),
                  ),
                  title: Text(technicians[index].name),
                ),
              ),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmSignOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تسجيل الخروج؟'),
        content: const Text('ستحتاج إلى تسجيل الدخول مجدداً للمتابعة.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            key: const Key('confirm_sign_out'),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('تسجيل الخروج'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await widget.authController.logout();
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = widget.authController.state.profile;
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 900;
        return Scaffold(
          appBar: wide || _selectedDestination != 0
              ? null
              : AppBar(
                  titleSpacing: 8,
                  title: Row(
                    children: [
                      const FixFlowBitmapLogo.mark(size: 48),
                      const SizedBox(width: 8),
                      Flexible(child: Text('لوحة تحكم المسؤول')),
                    ],
                  ),
                  actions: [
                    if (NotificationScope.maybeOf(context) != null)
                      const NotificationBell(),
                    if (widget.themeController != null)
                      _ThemeToggle(controller: widget.themeController!),
                    if (profile != null)
                      PopupMenuButton<String>(
                        tooltip: 'قائمة الحساب',
                        itemBuilder: (_) => [
                          PopupMenuItem<String>(
                            enabled: false,
                            child: Text(profile.name),
                          ),
                          const PopupMenuItem<String>(
                            value: 'signout',
                            child: Text('تسجيل الخروج'),
                          ),
                        ],
                        onSelected: (value) {
                          if (value == 'signout') _confirmSignOut();
                        },
                      ),
                  ],
                ),
          drawer: wide || _selectedDestination != 0
              ? null
              : _DashboardDrawer(
                  selected: _selectedDestination,
                  onSelect: _select,
                  onSignOut: _confirmSignOut,
                  showAccountRequests: widget.accountRequestRepository != null,
                ),
          body: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (wide)
                _DashboardSidebar(
                  selected: _selectedDestination,
                  onSelect: _select,
                  onSignOut: _confirmSignOut,
                  showAccountRequests: widget.accountRequestRepository != null,
                ),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _navigatorKeys.length,
                  itemBuilder: (context, index) => MediaQuery.removePadding(
                    context: context,
                    removeBottom: true,
                    child: Navigator(
                      key: _navigatorKeys[index],
                      onGenerateRoute: (_) => MaterialPageRoute<void>(
                        builder: (_) => _destination(index, profile, wide),
                        settings: RouteSettings(name: '/administrator/$index'),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          bottomNavigationBar: wide
              ? null
              : _DashboardBottomNavigation(
                  selected: _selectedDestination,
                  onSelect: _select,
                  showAccountRequests: widget.accountRequestRepository != null,
                ),
        );
      },
    );
  }
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent({
    required this.profile,
    required this.controller,
    required this.onRefresh,
    required this.onAllTickets,
    required this.onDepartments,
    required this.onCategories,
    required this.onTeam,
    this.onAccounts,
    required this.onSignOut,
    this.themeController,
    this.showThemeControl = true,
    this.showAccountControl = true,
    this.showNotificationControl = false,
  });

  final UserProfile? profile;
  final AdminTicketListController controller;
  final VoidCallback onRefresh;
  final VoidCallback onAllTickets;
  final VoidCallback onDepartments;
  final VoidCallback onCategories;
  final VoidCallback onTeam;
  final VoidCallback? onAccounts;
  final VoidCallback onSignOut;
  final ThemeController? themeController;
  final bool showThemeControl;
  final bool showAccountControl;
  final bool showNotificationControl;

  @override
  Widget build(BuildContext context) {
    final status = controller.state.status;
    if (status == AdminTicketListStatus.loading && controller.tickets.isEmpty) {
      return const FixFlowStateView(
        kind: FixFlowStateKind.loading,
        title: 'جارٍ تحميل لوحة تحكم المسؤول',
      );
    }
    if (status == AdminTicketListStatus.unauthorized ||
        status == AdminTicketListStatus.offline ||
        status == AdminTicketListStatus.serverError) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Header(
            profile: profile,
            onSignOut: onSignOut,
            themeController: themeController,
            showThemeControl: showThemeControl,
            showAccountControl: showAccountControl,
            showNotificationControl: showNotificationControl,
          ),
          const SizedBox(height: FixFlowSpacing.lg),
          FixFlowStateView(
            kind: switch (status) {
              AdminTicketListStatus.unauthorized =>
                FixFlowStateKind.unauthorized,
              AdminTicketListStatus.offline => FixFlowStateKind.offline,
              _ => FixFlowStateKind.serverError,
            },
            title: status == AdminTicketListStatus.unauthorized
                ? 'الوصول إلى لوحة التحكم غير متاح'
                : 'تعذر تحميل بيانات لوحة التحكم',
            message: controller.state.message,
            actionLabel: 'إعادة المحاولة',
            actionKey: const Key('admin_dashboard_retry'),
            onAction: onRefresh,
          ),
        ],
      );
    }
    final tickets = [...controller.tickets]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final pending = tickets.where((t) => t.canAssign).length;
    final inProgress = tickets.where((t) => t.status == 'in_progress').length;
    final completed = tickets.where((t) => t.status == 'completed').length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Header(
          profile: profile,
          onSignOut: onSignOut,
          themeController: themeController,
          showThemeControl: showThemeControl,
          showAccountControl: showAccountControl,
          showNotificationControl: showNotificationControl,
        ),
        const SizedBox(height: FixFlowSpacing.lg),
        _MetricGrid(
          children: [
            _MetricCard(
              label: 'إجمالي التذاكر',
              value: tickets.length,
              icon: Icons.inbox_outlined,
            ),
            _MetricCard(
              label: 'بانتظار الإسناد',
              value: pending,
              icon: Icons.person_add_alt_1_outlined,
              color: FixFlowColors.brandAccent,
            ),
            _MetricCard(
              label: 'قيد التنفيذ',
              value: inProgress,
              icon: Icons.handyman_outlined,
              color: FixFlowColors.brandSecondary,
            ),
            _MetricCard(
              label: 'مكتملة',
              value: completed,
              icon: Icons.task_alt_outlined,
              color: FixFlowColors.brandSuccess,
            ),
          ],
        ),
        const SizedBox(height: FixFlowSpacing.lg),
        Text('إجراءات سريعة', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: FixFlowSpacing.sm),
        Wrap(
          spacing: FixFlowSpacing.sm,
          runSpacing: FixFlowSpacing.sm,
          children: [
            _ActionButton(
              key: const Key('dashboard_all_tickets'),
              label: 'كل التذاكر',
              icon: Icons.inbox_outlined,
              onPressed: onAllTickets,
            ),
            _ActionButton(
              key: const Key('dashboard_departments'),
              label: 'إدارة الأقسام',
              icon: Icons.apartment_outlined,
              onPressed: onDepartments,
            ),
            _ActionButton(
              key: const Key('dashboard_categories'),
              label: 'إدارة الفئات',
              icon: Icons.category_outlined,
              onPressed: onCategories,
            ),
            _ActionButton(
              key: const Key('dashboard_team'),
              label: 'الفريق / الفنيون',
              icon: Icons.groups_outlined,
              onPressed: onTeam,
            ),
            if (onAccounts != null)
              _ActionButton(
                key: const Key('dashboard_account_requests'),
                label: 'طلبات الحسابات',
                icon: Icons.how_to_reg_outlined,
                onPressed: onAccounts!,
              ),
          ],
        ),
        const SizedBox(height: FixFlowSpacing.lg),
        Text('النشاط الأخير', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: FixFlowSpacing.sm),
        if (tickets.isEmpty)
          const FixFlowStateView(
            kind: FixFlowStateKind.empty,
            title: 'لا توجد أنشطة تذاكر بعد.',
          )
        else
          for (final ticket in tickets.take(5)) _RecentTicket(ticket: ticket),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.profile,
    required this.onSignOut,
    this.themeController,
    this.showThemeControl = true,
    this.showAccountControl = true,
    this.showNotificationControl = false,
  });
  final UserProfile? profile;
  final VoidCallback onSignOut;
  final ThemeController? themeController;
  final bool showThemeControl;
  final bool showAccountControl;
  final bool showNotificationControl;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final account = profile == null
          ? null
          : PopupMenuButton<String>(
              tooltip: 'قائمة الحساب',
              itemBuilder: (_) => [
                PopupMenuItem(value: 'signout', child: Text(profile!.name)),
              ],
              onSelected: (_) => onSignOut(),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    child: Text(
                      profile!.name.isEmpty
                          ? '?'
                          : profile!.name[0].toUpperCase(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(profile!.name, overflow: TextOverflow.ellipsis),
                  ),
                ],
              ),
            );
      const heading = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('مرحباً بعودتك', key: Key('dashboard_welcome')),
          SizedBox(height: 4),
          Text('إليك ملخص أعمال الصيانة الحالية'),
        ],
      );
      if (constraints.maxWidth < 500) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            heading,
            if (showAccountControl && account != null) ...[
              const SizedBox(height: 8),
              account,
            ],
          ],
        );
      }
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: heading),
          if (showThemeControl && themeController != null)
            _ThemeToggle(controller: themeController!),
          if (showNotificationControl) const NotificationBell(),
          if (showAccountControl && account != null) account,
        ],
      );
    },
  );
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
    this.color,
  });
  final String label;
  final int value;
  final IconData icon;
  final Color? color;
  @override
  Widget build(BuildContext context) => FixFlowSurface(
    child: Row(
      children: [
        CircleAvatar(
          backgroundColor: (color ?? Theme.of(context).colorScheme.primary)
              .withValues(alpha: .12),
          foregroundColor: color ?? Theme.of(context).colorScheme.primary,
          child: Icon(icon),
        ),
        const SizedBox(width: FixFlowSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$value', style: Theme.of(context).textTheme.headlineMedium),
              Text(label),
            ],
          ),
        ),
      ],
    ),
  );
}

class _MetricGrid extends StatelessWidget {
  const _MetricGrid({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final columns = constraints.maxWidth >= 960
          ? 4
          : constraints.maxWidth >= 360
          ? 2
          : 1;
      final width =
          (constraints.maxWidth - FixFlowSpacing.sm * (columns - 1)) / columns;
      return Wrap(
        spacing: FixFlowSpacing.sm,
        runSpacing: FixFlowSpacing.sm,
        children: [
          for (final child in children) SizedBox(width: width, child: child),
        ],
      );
    },
  );
}

class _ThemeToggle extends StatelessWidget {
  const _ThemeToggle({required this.controller});
  final ThemeController controller;

  @override
  Widget build(BuildContext context) {
    final dark = controller.isDark;
    return IconButton(
      key: const Key('dashboard_theme_toggle'),
      tooltip: dark ? 'التبديل إلى الوضع الفاتح' : 'التبديل إلى الوضع الداكن',
      onPressed: controller.toggle,
      icon: Icon(dark ? Icons.light_mode_outlined : Icons.dark_mode_outlined),
      color: Theme.of(context).colorScheme.onSurface,
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
  });
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) => OutlinedButton.icon(
    onPressed: onPressed,
    icon: Icon(icon),
    label: Text(label),
  );
}

class _RecentTicket extends StatelessWidget {
  const _RecentTicket({required this.ticket});
  final AdminTicketSummary ticket;
  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: FixFlowSpacing.xs),
    child: Padding(
      padding: const EdgeInsets.all(FixFlowSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(ticket.title, maxLines: 2, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          Text('${ticket.reference} • ${ticket.createdAt.toLocal()}'),
          const SizedBox(height: 4),
          Wrap(
            spacing: 4,
            runSpacing: 4,
            children: [
              FixFlowStatusChip(status: ticket.status),
              FixFlowPriorityBadge(priority: ticket.priority),
            ],
          ),
        ],
      ),
    ),
  );
}

class _DashboardSidebar extends StatelessWidget {
  const _DashboardSidebar({
    required this.selected,
    required this.onSelect,
    required this.onSignOut,
    required this.showAccountRequests,
  });
  final int selected;
  final ValueChanged<int> onSelect;
  final VoidCallback onSignOut;
  final bool showAccountRequests;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: 232,
    child: Material(
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(FixFlowSpacing.md),
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: FixFlowBitmapLogo.wordmark(size: 120),
            ),
          ),
          Expanded(
            child: NavigationRail(
              selectedIndex: selected,
              onDestinationSelected: onSelect,
              labelType: NavigationRailLabelType.all,
              destinations: [
                const NavigationRailDestination(
                  icon: Icon(Icons.dashboard_outlined),
                  selectedIcon: Icon(Icons.dashboard),
                  label: Text('لوحة التحكم'),
                ),
                const NavigationRailDestination(
                  icon: Icon(Icons.inbox_outlined),
                  label: Text('كل التذاكر'),
                ),
                const NavigationRailDestination(
                  icon: Icon(Icons.apartment_outlined),
                  label: Text('الأقسام'),
                ),
                const NavigationRailDestination(
                  icon: Icon(Icons.category_outlined),
                  label: Text('الفئات'),
                ),
                if (showAccountRequests)
                  const NavigationRailDestination(
                    icon: Icon(Icons.how_to_reg_outlined),
                    label: Text('طلبات الحسابات'),
                  ),
              ],
            ),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('تسجيل الخروج'),
            onTap: onSignOut,
          ),
          const SizedBox(height: FixFlowSpacing.sm),
        ],
      ),
    ),
  );
}

class _DashboardDrawer extends StatelessWidget {
  const _DashboardDrawer({
    required this.selected,
    required this.onSelect,
    required this.onSignOut,
    required this.showAccountRequests,
  });
  final int selected;
  final ValueChanged<int> onSelect;
  final VoidCallback onSignOut;
  final bool showAccountRequests;
  @override
  Widget build(BuildContext context) => Drawer(
    width: (MediaQuery.sizeOf(context).width * .84).clamp(248, 304),
    child: SafeArea(
      child: ListView(
        children: [
          const DrawerHeader(child: FixFlowBitmapLogo.mark(size: 120)),
          ListTile(
            selected: selected == 0,
            leading: const Icon(Icons.dashboard),
            title: const Text('لوحة التحكم'),
            onTap: () {
              Navigator.pop(context);
              onSelect(0);
            },
          ),
          if (showAccountRequests)
            ListTile(
              selected: selected == 4,
              leading: const Icon(Icons.how_to_reg_outlined),
              title: const Text('طلبات الحسابات'),
              onTap: () {
                Navigator.pop(context);
                onSelect(4);
              },
            ),
          ListTile(
            selected: selected == 1,
            leading: const Icon(Icons.inbox_outlined),
            title: const Text('كل التذاكر'),
            onTap: () {
              Navigator.pop(context);
              onSelect(1);
            },
          ),
          ListTile(
            selected: selected == 2,
            leading: const Icon(Icons.apartment_outlined),
            title: const Text('الأقسام'),
            onTap: () {
              Navigator.pop(context);
              onSelect(2);
            },
          ),
          ListTile(
            selected: selected == 3,
            leading: const Icon(Icons.category_outlined),
            title: const Text('الفئات'),
            onTap: () {
              Navigator.pop(context);
              onSelect(3);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('تسجيل الخروج'),
            onTap: () {
              Navigator.pop(context);
              onSignOut();
            },
          ),
        ],
      ),
    ),
  );
}

class _UnavailableDestination extends StatelessWidget {
  const _UnavailableDestination();

  @override
  Widget build(BuildContext context) => const Scaffold(
    body: SafeArea(
      child: FixFlowStateView(
        kind: FixFlowStateKind.empty,
        title: 'هذه الوجهة غير متاحة حاليًا.',
      ),
    ),
  );
}

class _DashboardBottomNavigation extends StatelessWidget {
  const _DashboardBottomNavigation({
    required this.selected,
    required this.onSelect,
    required this.showAccountRequests,
  });
  final int selected;
  final ValueChanged<int> onSelect;
  final bool showAccountRequests;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => FixFlowBottomNavigation(
      selectedIndex: selected,
      onDestinationSelected: onSelect,
      labelBehavior: constraints.maxWidth < 360
          ? NavigationDestinationLabelBehavior.alwaysHide
          : NavigationDestinationLabelBehavior.onlyShowSelected,
      destinations: [
        const NavigationDestination(
          icon: Icon(Icons.dashboard_outlined),
          selectedIcon: Icon(Icons.dashboard),
          label: 'لوحة التحكم',
        ),
        const NavigationDestination(
          icon: Icon(Icons.inbox_outlined),
          label: 'التذاكر',
        ),
        const NavigationDestination(
          icon: Icon(Icons.apartment_outlined),
          label: 'الأقسام',
        ),
        const NavigationDestination(
          icon: Icon(Icons.category_outlined),
          label: 'الفئات',
        ),
        if (showAccountRequests)
          const NavigationDestination(
            icon: Icon(Icons.how_to_reg_outlined),
            label: 'الحسابات',
          ),
      ],
    ),
  );
}
