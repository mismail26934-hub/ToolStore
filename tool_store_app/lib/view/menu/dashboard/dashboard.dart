import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:tool_store_app/controller/api_url/post_list.dart';
import 'package:tool_store_app/controller/cont_crud/redux/state.dart';
import 'package:tool_store_app/controller/cont_crud/redux/store.dart';
import 'package:tool_store_app/model/post_get_data.dart';
import 'package:tool_store_app/view/custom/routes/page_routes.dart';
import 'package:tool_store_app/theme/app_theme.dart';
import 'package:tool_store_app/view/menu/drawer/drawer.dart';
import 'package:tool_store_app/view/var/var.dart';

const _milestoneCheckByToolStore = 'CHECK BY TOOL STORE';
const _milestoneSuperiorApproved = 'SUPERIOR APPROVED';
const _milestoneReviewedByServiceAdmin = 'REVIEWED BY SERVICE ADMIN';
const _milestoneApprovedByServiceDeptHead = 'APPROVED BY SERVICE DEPT. HEAD';
const _milestoneReceivedByWhGa = 'RECEIVED BY WH/GA';
const _milestoneOrderProcessed = 'ORDER PROCESSED';

const _trackedMilestones = <String>{
  _milestoneCheckByToolStore,
  _milestoneSuperiorApproved,
  _milestoneReviewedByServiceAdmin,
  _milestoneApprovedByServiceDeptHead,
  _milestoneReceivedByWhGa,
};

int _calculateDashboardTotal(List<PostList> forms) {
  return forms.where((f) {
    final milestone = f.formMilestone.trim().toUpperCase();
    return milestone.isEmpty || _trackedMilestones.contains(milestone);
  }).length;
}

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Future<void> _refreshDashboardData() async {
    await store.dispatch(
      getDataTool(
        param: paramViewDataForm,
        idForm: '',
        formNo: '',
        formServName: '',
        formCheckBy: '',
        formDateCheckBy: '',
        formDateServName: '',
        formServComment: '',
        formSuperiorAprd: '',
        formSuperiorComment: '',
        formSadminComment: '',
        formMilestone: '',
        formStatusOrder: '',
        formSheadAprd: '',
        formSheadComment: '',
        fromDateUpdate: '',
        formUserUpdate: '',
        page: 1,
        limit: kToolFormDashboardFetchLimit,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshDashboardData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: true,
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: context.pageBackground,
        drawer: DrawerMenu(title: name),
        body: Column(
          children: [
            _DashboardHeader(
              onMenuTap: () => _scaffoldKey.currentState?.openDrawer(),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    const crossAxisSpacing = 12.0;
                    const mainAxisSpacing = 12.0;
                    final cardWidth =
                        (constraints.maxWidth - crossAxisSpacing) / 2;
                    final autoCardHeight =
                        (constraints.maxHeight - (mainAxisSpacing * 2)) / 3;
                    final cardHeight = autoCardHeight.clamp(170.0, 182.0);
                    final childAspectRatio = cardWidth / cardHeight;

                    return RefreshIndicator(
                      color: clrOrange,
                      onRefresh: _refreshDashboardData,
                      child: GridView.count(
                        shrinkWrap: false,
                        physics: const AlwaysScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        crossAxisSpacing: crossAxisSpacing,
                        mainAxisSpacing: mainAxisSpacing,
                        childAspectRatio: childAspectRatio,
                        children: [
                          StoreConnector<AppState, _ToolFormsCountVm>(
                            distinct: true,
                            converter: (store) {
                              final forms = store.state.formsState.forms;
                              final draftCount = forms
                                  .where((f) => f.formMilestone.trim().isEmpty)
                                  .length;
                              return _ToolFormsCountVm(
                                count: draftCount,
                                isLoading: store.state.formsState.isLoadingTool,
                              );
                            },
                            builder: (context, vm) => _DashboardCard(
                              title: 'Draft',
                              subtitle: 'Request baru yang masih perlu dicek.',
                              icon: Icons.drafts_outlined,
                              value: vm.displayValue,
                              iconColor: Colors.deepOrange,
                              onTap: vm.isLoading || vm.count == 0
                                  ? null
                                  : () => PageRoutes.routeTool(
                                      context,
                                      title: 'Draft',
                                      formMilestoneFilter: '',
                                      filterBlankFormMilestone: true,
                                    ),
                            ),
                          ),
                          StoreConnector<AppState, _ToolFormsCountVm>(
                            distinct: true,
                            converter: (store) {
                              final forms = store.state.formsState.forms;
                              final superiorCount = forms
                                  .where(
                                    (f) =>
                                        f.formMilestone.trim().toUpperCase() ==
                                        _milestoneCheckByToolStore,
                                  )
                                  .length;
                              return _ToolFormsCountVm(
                                count: superiorCount,
                                isLoading: store.state.formsState.isLoadingTool,
                              );
                            },
                            builder: (context, vm) => _DashboardCard(
                              title: 'Superior Approval',
                              subtitle: 'Menunggu persetujuan atasan terkait.',
                              icon: Icons.fact_check_outlined,
                              value: vm.displayValue,
                              iconColor: Colors.blue,
                              onTap: vm.isLoading || vm.count == 0
                                  ? null
                                  : () => PageRoutes.routeTool(
                                      context,
                                      title: 'Superior Approval',
                                      formMilestoneFilter:
                                          _milestoneCheckByToolStore,
                                    ),
                            ),
                          ),
                          StoreConnector<AppState, _ToolFormsCountVm>(
                            distinct: true,
                            converter: (store) {
                              final forms = store.state.formsState.forms;
                              final serviceAdminCount = forms
                                  .where(
                                    (f) =>
                                        f.formMilestone.trim().toUpperCase() ==
                                        _milestoneSuperiorApproved,
                                  )
                                  .length;
                              return _ToolFormsCountVm(
                                count: serviceAdminCount,
                                isLoading: store.state.formsState.isLoadingTool,
                              );
                            },
                            builder: (context, vm) => _DashboardCard(
                              title: 'Service Admin',
                              subtitle:
                                  'Masuk ke proses validasi admin service.',
                              icon: Icons.playlist_add_check_circle_outlined,
                              value: vm.displayValue,
                              iconColor: Colors.purple,
                              onTap: vm.isLoading || vm.count == 0
                                  ? null
                                  : () => PageRoutes.routeTool(
                                      context,
                                      title: 'Service Admin',
                                      formMilestoneFilter:
                                          _milestoneSuperiorApproved,
                                    ),
                            ),
                          ),
                          StoreConnector<AppState, _ToolFormsCountVm>(
                            distinct: true,
                            converter: (store) {
                              final forms = store.state.formsState.forms;
                              final deptHeadCount = forms
                                  .where(
                                    (f) =>
                                        f.formMilestone.trim().toUpperCase() ==
                                        _milestoneReviewedByServiceAdmin,
                                  )
                                  .length;
                              return _ToolFormsCountVm(
                                count: deptHeadCount,
                                isLoading: store.state.formsState.isLoadingTool,
                              );
                            },
                            builder: (context, vm) => _DashboardCard(
                              title: 'Dept. Head Approval',
                              subtitle:
                                  'Perlu persetujuan dari kepala departemen.',
                              icon: Icons.approval_outlined,
                              value: vm.displayValue,
                              iconColor: Colors.teal,
                              onTap: vm.isLoading || vm.count == 0
                                  ? null
                                  : () => PageRoutes.routeTool(
                                      context,
                                      title: 'Dept. Head Approval',
                                      formMilestoneFilter:
                                          _milestoneReviewedByServiceAdmin,
                                    ),
                            ),
                          ),
                          StoreConnector<AppState, _ToolFormsCountVm>(
                            distinct: true,
                            converter: (store) {
                              final forms = store.state.formsState.forms;
                              final counterGaCount = forms
                                  .where(
                                    (f) =>
                                        f.formMilestone.trim().toUpperCase() ==
                                        _milestoneApprovedByServiceDeptHead,
                                  )
                                  .length;
                              return _ToolFormsCountVm(
                                count: counterGaCount,
                                isLoading: store.state.formsState.isLoadingTool,
                              );
                            },
                            builder: (context, vm) => _DashboardCard(
                              title: 'Counter / GA Processing',
                              subtitle: 'Menunggu Proses Counter atau GA.',
                              icon: Icons.inventory_2_outlined,
                              value: vm.displayValue,
                              iconColor: Colors.amber.shade800,
                              onTap: vm.isLoading || vm.count == 0
                                  ? null
                                  : () => PageRoutes.routeTool(
                                      context,
                                      title: 'Counter / GA Processing',
                                      formMilestoneFilter:
                                          _milestoneApprovedByServiceDeptHead,
                                    ),
                            ),
                          ),
                          StoreConnector<AppState, _ToolFormsCountVm>(
                            distinct: true,
                            converter: (store) {
                              final forms = store.state.formsState.forms;
                              final receivedWhCount = forms
                                  .where(
                                    (f) =>
                                        f.formMilestone.trim().toUpperCase() ==
                                        _milestoneReceivedByWhGa,
                                  )
                                  .length;
                              return _ToolFormsCountVm(
                                count: receivedWhCount,
                                isLoading: store.state.formsState.isLoadingTool,
                              );
                            },
                            builder: (context, vm) => _DashboardCard(
                              title: 'Tool Received at Warehouse / GA',
                              subtitle:
                                  'Tool sudah tiba dan follow up ke Warehouse / GA.',
                              icon: Icons.task_alt_outlined,
                              value: vm.displayValue,
                              iconColor: Colors.green,
                              onTap: vm.isLoading || vm.count == 0
                                  ? null
                                  : () => PageRoutes.routeTool(
                                      context,
                                      title: 'Order Processed',
                                      formMilestoneFilter:
                                          _milestoneOrderProcessed,
                                    ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader({required this.onMenuTap});

  static const _buttonRadius = 16.0;
  static const _logoRadius = 20.0;

  final VoidCallback onMenuTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 22),
      decoration: const BoxDecoration(
        gradient: AppTheme.dashboardHeaderGradient,
        borderRadius: AppTheme.dashboardHeaderBottomRadius,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildMenuButton(),
              const Spacer(),
              _buildSearchButton(),
              const SizedBox(width: 8),
              _buildNotificationBadge(context),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildLogo(),
              const SizedBox(width: 10),
              Expanded(
                flex: 5,
                child: Hero(
                  tag: 'text-app',
                  child: Material(
                    color: Colors.transparent,
                    child: Text(
                      'Dashboard Tool Monitoring',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenuButton() {
    return Material(
      color: Colors.white.withValues(alpha: 0.18),
      borderRadius: BorderRadius.circular(_buttonRadius),
      child: InkWell(
        borderRadius: BorderRadius.circular(_buttonRadius),
        onTap: onMenuTap,
        child: const Padding(
          padding: EdgeInsets.all(12),
          child: Icon(Icons.menu, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildNotificationBadge(BuildContext context) {
    return StoreConnector<AppState, _ToolFormsCountVm>(
      distinct: true,
      converter: (store) => _ToolFormsCountVm(
        count: _calculateDashboardTotal(store.state.formsState.forms),
        isLoading: store.state.formsState.isLoadingTool,
      ),
      builder: (context, vm) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(_buttonRadius),
          border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.notifications_none_rounded,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 6),
            Text(
              vm.displayValue,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchButton() {
    return Material(
      color: Colors.white.withValues(alpha: 0.16),
      borderRadius: BorderRadius.circular(_buttonRadius),
      child: InkWell(
        borderRadius: BorderRadius.circular(_buttonRadius),
        onTap: () {},
        child: const Padding(
          padding: EdgeInsets.all(10),
          child: Icon(Icons.search_rounded, color: Colors.white, size: 20),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Hero(
      tag: 'logo-app',
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.22),
          borderRadius: BorderRadius.circular(_logoRadius),
        ),
        child: const Icon(Icons.handyman, color: Colors.white, size: 24),
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  const _DashboardCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.value,
    required this.iconColor,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final String value;
  final Color iconColor;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(context).textTheme.titleSmall?.copyWith(
      fontWeight: FontWeight.w700,
      height: 1.2,
      color: context.textPrimary,
    );
    final subtitleStyle = Theme.of(
      context,
    ).textTheme.bodySmall?.copyWith(color: context.textSecondary, height: 1.25);

    return LayoutBuilder(
      builder: (context, constraints) {
        final compactMode = constraints.maxHeight < 176;
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(22),
            child: Ink(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [context.cardGradientStart, context.cardGradientEnd],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: context.cardBorder),
                boxShadow: [
                  BoxShadow(
                    color: iconColor.withValues(alpha: 0.11),
                    blurRadius: 22,
                    offset: const Offset(0, 10),
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 3,
                      width: 48,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        gradient: LinearGradient(
                          colors: [
                            iconColor.withValues(alpha: 0.90),
                            iconColor.withValues(alpha: 0.45),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                iconColor.withValues(alpha: 0.18),
                                iconColor.withValues(alpha: 0.08),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(13),
                            border: Border.all(
                              color: iconColor.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Icon(icon, color: iconColor, size: 22),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: iconColor.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: iconColor.withValues(alpha: 0.25),
                            ),
                          ),
                          child: Text(
                            value,
                            style: TextStyle(
                              color: iconColor.withValues(alpha: 0.95),
                              fontSize: 12.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: titleStyle,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                subtitle,
                                maxLines: compactMode ? 1 : 2,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: subtitleStyle,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          if (compactMode)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Lihat detail',
                                  style: Theme.of(context).textTheme.labelSmall
                                      ?.copyWith(
                                        color: iconColor.withValues(alpha: 0.9),
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 16,
                                  color: iconColor.withValues(alpha: 0.8),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ToolFormsCountVm {
  const _ToolFormsCountVm({required this.count, required this.isLoading});

  final int count;
  final bool isLoading;

  String get displayValue => isLoading ? '...' : '$count';

  @override
  bool operator ==(Object other) =>
      other is _ToolFormsCountVm &&
      other.count == count &&
      other.isLoading == isLoading;

  @override
  int get hashCode => Object.hash(count, isLoading);
}
