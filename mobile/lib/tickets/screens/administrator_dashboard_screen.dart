import 'package:flutter/material.dart';

import '../../auth/models/auth_models.dart';
import '../../auth/state/auth_controller.dart';
import '../../design_system/brand/fixflow_logo.dart';
import '../../design_system/components/content/fixflow_surfaces.dart';
import '../../design_system/components/feedback/fixflow_state_view.dart';
import '../../design_system/components/tickets/fixflow_ticket_badges.dart';
import '../../design_system/layout/responsive_constraints.dart';
import '../../design_system/theme/fixflow_colors.dart';
import '../../design_system/theme/fixflow_theme_controller.dart';
import '../../design_system/tokens/fixflow_spacing.dart';
import '../../reference_data/screens/category_screen.dart';
import '../../reference_data/screens/department_screen.dart';
import '../../reference_data/state/reference_controller.dart';
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
    super.key,
  });

  final AuthController authController;
  final AdminTicketRepository repository;
  final ReferenceController? referenceController;
  final TicketCommentRepository? commentRepository;
  final ThemeController? themeController;

  @override
  State<AdministratorDashboardScreen> createState() =>
      _AdministratorDashboardScreenState();
}

class _AdministratorDashboardScreenState
    extends State<AdministratorDashboardScreen> {
  late final AdminTicketListController controller;
  int _selectedDestination = 0;

  @override
  void initState() {
    super.initState();
    controller = AdminTicketListController(widget.repository)
      ..addListener(_changed)
      ..load();
  }

  @override
  void dispose() {
    controller.removeListener(_changed);
    controller.dispose();
    super.dispose();
  }

  void _changed() {
    if (mounted) setState(() {});
  }

  void _open(Widget page) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }

  void _select(int index) {
    setState(() => _selectedDestination = index);
    if (index == 0) return;
    if (index == 1) {
      _open(
        AdminTicketListScreen(
          repository: widget.repository,
          commentRepository: widget.commentRepository,
        ),
      );
    }
    if (index == 2 && widget.referenceController != null) {
      _open(DepartmentScreen(controller: widget.referenceController!));
    }
    if (index == 3 && widget.referenceController != null) {
      _open(CategoryScreen(controller: widget.referenceController!));
    }
  }

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
              width: 360,
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
        final dark = Theme.of(context).brightness == Brightness.dark;
        final dashboardTheme = Theme.of(context).copyWith(
          scaffoldBackgroundColor: dark
              ? const Color(0xFF000000)
              : const Color(0xFFF8FAFC),
          colorScheme: Theme.of(context).colorScheme.copyWith(
            surface: dark ? const Color(0xFF0A0A0A) : Colors.white,
            surfaceContainerHighest: dark
                ? const Color(0xFF171717)
                : const Color(0xFFF1F5F9),
          ),
        );
        return Theme(
          data: dashboardTheme,
          child: Scaffold(
            appBar: wide
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
                      if (widget.themeController != null)
                        _ThemeToggle(controller: widget.themeController!),
                      IconButton(
                        tooltip: 'تحديث لوحة التحكم',
                        onPressed: controller.load,
                        icon: const Icon(Icons.refresh),
                      ),
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
            drawer: wide
                ? null
                : _DashboardDrawer(
                    onSelect: _select,
                    onSignOut: _confirmSignOut,
                  ),
            body: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (wide)
                  _DashboardSidebar(
                    onSelect: _select,
                    onSignOut: _confirmSignOut,
                  ),
                Expanded(
                  child: SafeArea(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(FixFlowSpacing.lg),
                      child: FixFlowConstrainedContent(
                        child: _DashboardContent(
                          profile: profile,
                          controller: controller,
                          onRefresh: controller.load,
                          onAllTickets: () => _select(1),
                          onDepartments: () => _select(2),
                          onCategories: () => _select(3),
                          onTeam: _showTechnicians,
                          onSignOut: widget.authController.logout,
                          themeController: widget.themeController,
                          showThemeControl: wide,
                          showAccountControl: wide,
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
                  ),
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
    required this.onSignOut,
    this.themeController,
    this.showThemeControl = true,
    this.showAccountControl = true,
  });

  final UserProfile? profile;
  final AdminTicketListController controller;
  final VoidCallback onRefresh;
  final VoidCallback onAllTickets;
  final VoidCallback onDepartments;
  final VoidCallback onCategories;
  final VoidCallback onTeam;
  final VoidCallback onSignOut;
  final ThemeController? themeController;
  final bool showThemeControl;
  final bool showAccountControl;

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
        ),
        const SizedBox(height: FixFlowSpacing.lg),
        Wrap(
          spacing: FixFlowSpacing.sm,
          runSpacing: FixFlowSpacing.sm,
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
              color: Colors.deepPurple,
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
          ],
        ),
        const SizedBox(height: FixFlowSpacing.lg),
        Row(
          children: [
            Expanded(
              child: Text(
                'النشاط الأخير',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            IconButton(
              onPressed: onRefresh,
              tooltip: 'تحديث لوحة التحكم',
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
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
  });
  final UserProfile? profile;
  final VoidCallback onSignOut;
  final ThemeController? themeController;
  final bool showThemeControl;
  final bool showAccountControl;
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
          Text('لوحة تحكم المسؤول'),
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
  Widget build(BuildContext context) => SizedBox(
    width: 220,
    child: FixFlowSurface(
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
                Text(
                  '$value',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                Text(label),
              ],
            ),
          ),
        ],
      ),
    ),
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
  const _DashboardSidebar({required this.onSelect, required this.onSignOut});
  final ValueChanged<int> onSelect;
  final VoidCallback onSignOut;
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
              selectedIndex: 0,
              onDestinationSelected: onSelect,
              labelType: NavigationRailLabelType.all,
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.dashboard_outlined),
                  selectedIcon: Icon(Icons.dashboard),
                  label: Text('لوحة التحكم'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.inbox_outlined),
                  label: Text('كل التذاكر'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.apartment_outlined),
                  label: Text('الأقسام'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.category_outlined),
                  label: Text('الفئات'),
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
  const _DashboardDrawer({required this.onSelect, required this.onSignOut});
  final ValueChanged<int> onSelect;
  final VoidCallback onSignOut;
  @override
  Widget build(BuildContext context) => Drawer(
    child: ListView(
      children: [
        const DrawerHeader(child: FixFlowBitmapLogo.mark(size: 120)),
        ListTile(
          leading: const Icon(Icons.dashboard),
          title: const Text('لوحة التحكم'),
          onTap: () {
            Navigator.pop(context);
            onSelect(0);
          },
        ),
        ListTile(
          leading: const Icon(Icons.inbox_outlined),
          title: const Text('كل التذاكر'),
          onTap: () {
            Navigator.pop(context);
            onSelect(1);
          },
        ),
        ListTile(
          leading: const Icon(Icons.apartment_outlined),
          title: const Text('الأقسام'),
          onTap: () {
            Navigator.pop(context);
            onSelect(2);
          },
        ),
        ListTile(
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
  );
}

class _DashboardBottomNavigation extends StatelessWidget {
  const _DashboardBottomNavigation({
    required this.selected,
    required this.onSelect,
  });
  final int selected;
  final ValueChanged<int> onSelect;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => NavigationBar(
      selectedIndex: selected.clamp(0, 3),
      onDestinationSelected: onSelect,
      labelBehavior: constraints.maxWidth < 500
          ? NavigationDestinationLabelBehavior.alwaysHide
          : NavigationDestinationLabelBehavior.onlyShowSelected,
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.dashboard_outlined),
          selectedIcon: Icon(Icons.dashboard),
          label: 'لوحة التحكم',
        ),
        NavigationDestination(
          icon: Icon(Icons.inbox_outlined),
          label: 'التذاكر',
        ),
        NavigationDestination(
          icon: Icon(Icons.apartment_outlined),
          label: 'الأقسام',
        ),
        NavigationDestination(
          icon: Icon(Icons.category_outlined),
          label: 'الفئات',
        ),
      ],
    ),
  );
}
