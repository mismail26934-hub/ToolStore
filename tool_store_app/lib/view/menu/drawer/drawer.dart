import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tool_store_app/controller/function/funct.dart';
import 'package:tool_store_app/l10n/l10n_ext.dart';
import 'package:tool_store_app/l10n/locale_controller.dart';
import 'package:tool_store_app/theme/app_theme.dart';
import 'package:tool_store_app/theme/theme_controller.dart';
import 'package:tool_store_app/view/custom/routes/page_routes.dart';
import 'package:tool_store_app/view/custom/show_dialog/show_dialog.dart';
import 'package:tool_store_app/view/var/var.dart';

Future<String> _drawerReadPrefLevel() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('level') ?? '';
}

bool _drawerIsSuperAdmin(String raw) =>
    raw.trim().toUpperCase() == 'SUPERADMIN';

class DrawerMenu extends StatefulWidget {
  const DrawerMenu({super.key, required this.title});

  final String title;

  @override
  State<DrawerMenu> createState() => _DrawerMenuState();
}

class _DrawerMenuState extends State<DrawerMenu> {
  late Future<String> _levelFuture;

  @override
  void initState() {
    super.initState();
    _levelFuture = _drawerReadPrefLevel();
  }

  @override
  void didUpdateWidget(DrawerMenu oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.title != widget.title) {
      _levelFuture = _drawerReadPrefLevel();
    }
  }

  bool get _isLoggedIn => widget.title.trim().isNotEmpty;

  String _displayName(BuildContext context) => _isLoggedIn
      ? widget.title.trim().toUpperCase()
      : context.s.guestUser;

  Widget _buildSectionTitle(BuildContext context, String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: context.textSecondary,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardSurface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: context.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: context.isDarkMode ? 0.25 : 0.05),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: clrOrange.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              _isLoggedIn ? Icons.verified_user_outlined : Icons.person_outline,
              color: clrOrange,
              size: 28,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isLoggedIn ? context.s.activeAccess : context.s.guestMode,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  _isLoggedIn
                      ? context.s.activeAccessDesc
                      : context.s.guestModeDesc,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: context.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Ink(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: context.cardSurface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: context.cardBorder),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: iconColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: context.textSecondary,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: context.textSecondary),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [clrOrange, const Color.fromARGB(255, 255, 184, 76)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: SafeArea(
        bottom: true,
        child: FutureBuilder<String>(
          future: _levelFuture,
          builder: (context, snapshot) {
            final s = context.s;
            final levelSubtitle = !_isLoggedIn
                ? s.pleaseLoginContinue
                : (snapshot.connectionState == ConnectionState.waiting
                      ? s.loadingEllipsis
                      : ((snapshot.data ?? '').trim().isEmpty
                            ? '—'
                            : (snapshot.data ?? '').trim()));
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.22),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.handyman,
                        color: Colors.white,
                        size: 34,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _displayName(context),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            levelSubtitle,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.92),
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ],
                      ),
                    ),
                    if (_isLoggedIn)
                      IconButton(
                        tooltip: 'Edit data user $superiorId',
                        onPressed: () => _openEditProfile(context),
                        icon: const Icon(
                          Icons.edit_outlined,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.18),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.tips_and_updates_outlined,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          s.drawerTip,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: Colors.white, height: 1.35),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _openEditProfile(BuildContext context) async {
    if (!_isLoggedIn) return;
    final prefs = await SharedPreferences.getInstance();
    if (!context.mounted) return;
    final idUsers = (prefs.getString('idUsersApp') ?? '').trim();
    if (idUsers.isEmpty) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.s.incompleteUserData),
        ),
      );
      return;
    }
    statusFormCont.text = prefs.getString('status') ?? '';
    final lvl = (prefs.getString('level') ?? '').trim().toUpperCase();
    postContUser(
      idUsers,
      prefs.getString('username') ?? '',
      prefs.getString('password') ?? '',
      prefs.getString('name') ?? '',
      prefs.getString('noTelp') ?? '',
      prefs.getString('idTu') ?? '',
      lvl,
      prefs.getString('superiorId') ?? '',
      prefs.getString('namaSuperior') ?? '',
      context,
      levelReadOnly: true,
      popOnSuccess: true,
    );
    if (context.mounted) Navigator.pop(context);
  }

  Future<void> _handleLogout(BuildContext context) async {
    final s = context.s;
    ShowDialogBox.show(
      context: context,
      title: s.logoutTitle,
      contentTitle: s.logoutConfirm,
      onPressedNo: (dialogContext) {
        if (!dialogContext.mounted) return;
        Navigator.pop(dialogContext);
      },
      onPressedYes: (dialogContext) async {
        if (dialogContext.mounted) Navigator.pop(dialogContext);
        final prefs = await SharedPreferences.getInstance();
        await ThemeController.preserveOnPrefsClear(prefs);
        if (!context.mounted) return;
        PageRoutes.routeLoginFast(context);
      },
      textNo: s.back,
      textYes: s.yes,
      textColorNo: clrBlack,
      textColorYes: clrRed,
    );
  }

  Widget _buildThemeToggle(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListenableBuilder(
        listenable: ThemeController.instance,
        builder: (context, _) {
          final isDark = ThemeController.instance.isDarkMode;
          return Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () => ThemeController.instance.toggle(),
              child: Ink(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: context.cardSurface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: context.cardBorder),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: clrOrange.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        isDark
                            ? Icons.dark_mode_outlined
                            : Icons.light_mode_outlined,
                        color: clrOrange,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.s.darkMode,
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            isDark
                                ? context.s.darkModeOn
                                : context.s.darkModeOff,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: context.textSecondary,
                                  height: 1.35,
                                ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: isDark,
                      onChanged: ThemeController.instance.setDarkMode,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLocaleToggle(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListenableBuilder(
        listenable: LocaleController.instance,
        builder: (context, _) {
          final isEnglish = LocaleController.instance.isEnglish;
          return Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () => LocaleController.instance.toggle(),
              child: Ink(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: context.cardSurface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: context.cardBorder),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: clrOrange.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        isEnglish
                            ? Icons.translate_outlined
                            : Icons.language_outlined,
                        color: clrOrange,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.s.language,
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            isEnglish
                                ? context.s.languageEn
                                : context.s.languageId,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: context.textSecondary,
                                  height: 1.35,
                                ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: isEnglish,
                      onChanged: LocaleController.instance.setEnglish,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSuperAdminUserSection(BuildContext context) {
    return FutureBuilder<String>(
      future: _levelFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox.shrink();
        }
        final raw = snapshot.data ?? '';
        if (!_drawerIsSuperAdmin(raw)) {
          return const SizedBox.shrink();
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSectionTitle(context, context.s.account),
            _buildMenuTile(
              context: context,
              icon: Icons.person_outline,
              title: context.s.user,
              subtitle: context.s.userSubtitle,
              iconColor: Colors.purple,
              onTap: () {
                PageRoutes.routeUser(context);
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: context.pageBackground,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          _buildHeader(context),
          _buildInfoCard(context),
          _buildSectionTitle(context, context.s.mainMenu),
          _buildMenuTile(
            context: context,
            icon: Icons.dashboard_customize_outlined,
            title: context.s.dashboard,
            subtitle: context.s.dashboardSubtitle,
            iconColor: Colors.deepOrange,
            onTap: () {
              PageRoutes.routeDashboard(context, '');
            },
          ),
          _buildMenuTile(
            context: context,
            icon: Icons.handyman_outlined,
            title: context.s.dataTool,
            subtitle: context.s.dataToolSubtitle,
            iconColor: Colors.blue,
            onTap: () {
              PageRoutes.routeTool(
                context,
                title: context.s.dataTool,
                excludeFormMilestoneFilters: const <String>[
                  'RECEIVED TOOL STORE',
                  'HOLD BY SERVICE ADMIN',
                  'REJECTED BY SUPERIOR',
                  'REJECTED BY SERVICE DEPT. HEAD',
                ],
              );
              Navigator.pop(context);
            },
          ),
          _buildMenuTile(
            context: context,
            icon: Icons.task_alt_outlined,
            title: context.s.completed,
            subtitle: context.s.completedSubtitle,
            iconColor: Colors.green,
            onTap: () {
              PageRoutes.routeTool(
                context,
                title: context.s.completed,
                formMilestoneFilter: 'RECEIVED TOOL STORE',
              );
            },
          ),
          _buildMenuTile(
            context: context,
            icon: Icons.stop_circle_outlined,
            title: context.s.holdOrder,
            subtitle: context.s.holdOrderSubtitle,
            iconColor: Colors.orange,
            onTap: () {
              PageRoutes.routeTool(
                context,
                title: context.s.holdOrder,
                formMilestoneFilter: 'HOLD BY SERVICE ADMIN',
              );
              Navigator.pop(context);
            },
          ),
          _buildMenuTile(
            context: context,
            icon: Icons.cancel_outlined,
            title: context.s.rejectedSuperior,
            subtitle: context.s.rejectedSuperiorSubtitle,
            iconColor: Colors.red,
            onTap: () {
              PageRoutes.routeTool(
                context,
                title: context.s.rejectedSuperior,
                formMilestoneFilter: 'REJECTED BY SUPERIOR',
              );
              Navigator.pop(context);
            },
          ),
          _buildMenuTile(
            context: context,
            icon: Icons.cancel_rounded,
            title: context.s.rejectedDeptHead,
            subtitle: context.s.rejectedDeptHeadSubtitle,
            iconColor: Colors.red,
            onTap: () {
              PageRoutes.routeTool(
                context,
                title: context.s.rejectedDeptHead,
                formMilestoneFilter: 'REJECTED BY SERVICE DEPT. HEAD',
              );
              Navigator.pop(context);
            },
          ),
          // _buildMenuTile(
          //   context: context,
          //   icon: Icons.history_outlined,
          //   title: 'History',
          //   subtitle: 'Pantau data request sebelumnya dan progres terbaru.',
          //   iconColor: Colors.teal,
          //   onTap: () {
          //     Navigator.pop(context);
          //   },
          // ),
          _buildSuperAdminUserSection(context),
          _buildSectionTitle(context, context.s.appearance),
          _buildThemeToggle(context),
          _buildLocaleToggle(context),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 20),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  if (_isLoggedIn) {
                    _handleLogout(context);
                    return;
                  }
                  PageRoutes.routeLoginFast(context);
                },
                child: Ink(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _isLoggedIn
                        ? clrRed.withValues(alpha: 0.08)
                        : Colors.blue.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _isLoggedIn
                          ? clrRed.withValues(alpha: 0.16)
                          : Colors.blue.withValues(alpha: 0.16),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: _isLoggedIn
                              ? clrRed.withValues(alpha: 0.14)
                              : Colors.blue.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          _isLoggedIn
                              ? Icons.logout_outlined
                              : Icons.login_outlined,
                          color: _isLoggedIn ? clrRed : Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _isLoggedIn
                                  ? context.s.logout
                                  : context.s.login,
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _isLoggedIn
                                  ? context.s.logoutDesc
                                  : context.s.loginDesc,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: context.textSecondary,
                                    height: 1.35,
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
        ],
      ),
    );
  }
}
