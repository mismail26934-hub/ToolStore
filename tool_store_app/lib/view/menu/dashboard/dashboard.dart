import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:tool_store_app/controller/cont_crud/redux/state.dart';
import 'package:tool_store_app/controller/cont_crud/redux/store.dart';
import 'package:tool_store_app/model/post_get_data.dart';
import 'package:tool_store_app/view/custom/routes/page_routes.dart';
import 'package:tool_store_app/view/menu/drawer/drawer.dart';
import 'package:tool_store_app/view/var/var.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  static const _milestoneCheckByToolStore = 'CHECK BY TOOL STORE';
  static const _milestoneSuperiorApproved = 'SUPERIOR APPROVED';
  static const _milestoneReviewedByServiceAdmin = 'REVIEWED BY SERVICE ADMIN';
  static const _milestoneApprovedByServiceDeptHead =
      'APPROVED BY SERVICE DEPT. HEAD';
  static const _milestoneReceivedByWhGa = 'RECEIVED BY WH/GA';

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
        backgroundColor: const Color(0xFFF7F8FA),
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
                    final cardHeight =
                        (constraints.maxHeight - (mainAxisSpacing * 2)) / 3;
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
                              onTap: () {
                                PageRoutes.routeLazyListExample(context, '');
                              },
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
                              onTap: () {},
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
                              onTap: () {},
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
                              onTap: () {},
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
                              subtitle: 'Sedang diproses oleh Counter atau GA.',
                              icon: Icons.inventory_2_outlined,
                              value: vm.displayValue,
                              iconColor: Colors.amber.shade800,
                              onTap: () {},
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
                              title: 'Tool Received at Warehouse/GA',
                              subtitle:
                                  'Tool sudah tiba dan follow up ke Warehouse/GA.',
                              icon: Icons.task_alt_outlined,
                              value: vm.displayValue,
                              iconColor: Colors.green,
                              onTap: () {},
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

  static const _headerRadius = 28.0;
  static const _buttonRadius = 16.0;
  static const _logoRadius = 20.0;
  static const _notificationCount = '6';

  final VoidCallback onMenuTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [clrOrange, const Color.fromARGB(255, 255, 184, 76)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(_headerRadius),
          bottomRight: Radius.circular(_headerRadius),
        ),
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
    return Container(
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
            _notificationCount,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: iconColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14),
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
                        color: const Color(0xFFF7F8FA),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        value,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          height: 1.15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade700,
                          height: 1.2,
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
