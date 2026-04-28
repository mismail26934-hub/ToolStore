import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:tool_store_app/controller/api_url/post_list.dart';
import 'package:tool_store_app/controller/cont_crud/redux/state.dart';
import 'package:tool_store_app/controller/cont_crud/redux/store.dart';
import 'package:tool_store_app/controller/function/funct.dart';
import 'package:tool_store_app/model/post_get_data.dart';
import 'package:tool_store_app/view/custom/mixin/mixin_pref.dart';
import 'package:tool_store_app/view/custom/navbar/sliver_appbars.dart';
import 'package:tool_store_app/view/custom/navbar/sliver_fill_remaining.dart';
import 'package:tool_store_app/view/custom/routes/page_routes.dart';
import 'package:tool_store_app/view/custom/show_dialog/show_dialog.dart';
import 'package:tool_store_app/view/menu/drawer/drawer.dart';
import 'package:tool_store_app/view/var/var.dart';

class ToolData extends StatefulWidget {
  const ToolData({super.key});
  @override
  State<ToolData> createState() => _ToolDataState();
}

class _ToolDataState extends State<ToolData> with MixinPref {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final Set<String> _expandedForms = <String>{};
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _searchField = 'all';

  static const Map<String, String> _searchFieldLabels = {
    'all': 'Semua',
    'formNo': 'Form No',
    'serviceman': 'Serviceman',
    'status': 'Status',
    'idForm': 'Category',
  };

  @override
  void initState() {
    super.initState();
    refreshPref();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refreshData() async {
    await store.dispatch(
      getDataTool(
        param: paramViewDataForm,
        idFrom: '',
        formNo: '',
        formServName: '',
        formCheckBy: '',
        formDateCheckBy: '',
        formDateServName: '',
        formServComment: '',
        formSuperiorAprd: '',
        formSuperiorComment: '',
        formSadminComment: '',
        formSheadAprd: '',
        formSheadComment: '',
        fromDateUpdate: '',
        formUserUpdate: '',
      ),
    );
  }

  void _onSearchChanged(String value) {
    setState(() {
      _searchQuery = value.trim();
    });
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
      _searchField = 'all';
    });
  }

  bool _matchesSearch(PostList form) {
    if (_searchQuery.isEmpty) return true;
    final query = _searchQuery.toLowerCase();

    String normalize(String value) => value.toLowerCase();

    switch (_searchField) {
      case 'formNo':
        return normalize(form.formNo).contains(query);
      case 'serviceman':
        return normalize(form.formServName).contains(query);
      case 'status':
        return normalize(form.formServComment).contains(query);
      case 'idForm':
        return normalize(form.idForm).contains(query);
      case 'all':
      default:
        final candidates = <String>[
          form.formNo,
          form.formServName,
          form.formServComment,
          form.idForm,
        ];
        return candidates.any((value) => normalize(value).contains(query));
    }
  }

  Color _statusColor(String value) {
    final status = value.toLowerCase();
    if (status.contains('approve') || status.contains('done')) {
      return Colors.green;
    }
    if (status.contains('reject') || status.contains('cancel')) {
      return Colors.red;
    }
    if (status.contains('process') || status.contains('pending')) {
      return Colors.orange;
    }
    return const Color.fromARGB(255, 231, 169, 14);
  }

  String _displayValue(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '-';
    }
    return value.trim();
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: clrOrange.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: clrOrange),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                SelectableText(
                  _displayValue(value),
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    String title, {
    IconData icon = Icons.label_outline,
    Widget? trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: clrOrange),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          trailing ?? const SizedBox.shrink(),
        ],
      ),
    );
  }

  Widget _buildMetaChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color backgroundColor,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      height: 42,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildLineItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: Colors.orange.shade700,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: SelectableText(
              _displayValue(value),
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPoCard(PostList itemPO) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.shade100),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.orange.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.receipt_long, color: Colors.deepOrange),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _displayValue(itemPO.poNo),
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  'Purchase Order',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey.shade700),
                ),
              ],
            ),
          ),
          TextButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.edit_outlined, size: 18),
            label: const Text('Update'),
          ),
        ],
      ),
    );
  }

  Widget _buildSoCard(PostList itemSO) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.local_shipping,
                  color: Colors.orange.shade800,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SO ${_displayValue(itemSO.so)}',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Sales Order',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.edit_outlined, size: 18),
                label: const Text('Update'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildLineItem('ETA', itemSO.eta),
          _buildLineItem('Note SO', itemSO.noteSo),
        ],
      ),
    );
  }

  Widget _buildToolItemCard(PostList itemTool, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: clrOrange.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(
                  '${index + 1}',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: clrOrange,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _displayValue(itemTool.pnGroup),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Edit data tool',
                onPressed: () {
                  postMultipleToolCont(
                    '${index + 1}',
                    itemTool.idForm,
                    itemTool.idFormDetail,
                    itemTool.formComment,
                    itemTool.pnGroup,
                    itemTool.pnDesc,
                    itemTool.qty,
                    itemTool.explan,
                    itemTool.actionNote,
                    itemTool.valType,
                    itemTool.partValue,
                    context,
                  );
                },
                icon: const Icon(Icons.edit_outlined),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildMetaChip(
                icon: Icons.category_outlined,
                label: 'Type ${_displayValue(itemTool.valType)}',
                color: Colors.deepOrange,
              ),
              _buildMetaChip(
                icon: Icons.inventory_2_outlined,
                label: 'Qty ${_displayValue(itemTool.qty)}',
                color: Colors.orange.shade700,
              ),
              _buildMetaChip(
                icon: Icons.payments_outlined,
                label: 'Value ${_displayValue(itemTool.partValue)}',
                color: Colors.orange.shade900,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildLineItem('Part Desc', itemTool.pnDesc),
          _buildLineItem('Explanation', itemTool.explan),
          _buildLineItem('Action Note', itemTool.actionNote),
          StoreConnector<AppState, List<PostList>>(
            converter: (store) {
              final allDataPO = store.state.posDetailState.posDetail;
              return allDataPO
                  .where(
                    (itemPO) => itemPO.idFormDetail == itemTool.idFormDetail,
                  )
                  .toList();
            },
            builder: (context, filteredListPO) {
              if (filteredListPO.isEmpty) {
                return const SizedBox.shrink();
              }
              return Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader('Purchase Order', icon: Icons.receipt),
                    ...filteredListPO.map(_buildPoCard),
                  ],
                ),
              );
            },
          ),
          StoreConnector<AppState, List<PostList>>(
            converter: (store) {
              final allDataSO = store.state.sosDetailState.sosDetail;
              return allDataSO
                  .where(
                    (itemSO) => itemSO.idFormDetail == itemTool.idFormDetail,
                  )
                  .toList();
            },
            builder: (context, filteredListSO) {
              if (filteredListSO.isEmpty) {
                return const SizedBox.shrink();
              }
              return Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader('Sales Order', icon: Icons.route),
                    ...filteredListSO.map(_buildSoCard),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard(PostList forms, int index) {
    final isExpandedLocal = _expandedForms.contains(forms.idForm);
    final statusColor = _statusColor(forms.formServComment);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [Colors.white, statusColor.withValues(alpha: 0.04)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Material(
          color: Colors.transparent,
          child: ExpansionTile(
            tilePadding: const EdgeInsets.fromLTRB(18, 18, 18, 8),
            childrenPadding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
            shape: const Border(),
            collapsedShape: const Border(),
            backgroundColor: Colors.transparent,
            collapsedBackgroundColor: Colors.transparent,
            initiallyExpanded: isExpandedLocal,
            onExpansionChanged: (expanded) {
              setState(() {
                if (expanded) {
                  _expandedForms.add(forms.idForm);
                } else {
                  _expandedForms.remove(forms.idForm);
                }
              });
            },
            leading: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: clrOrange.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(14),
              ),
              alignment: Alignment.center,
              child: Text(
                '${index + 1}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: clrOrange,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SelectableText(
                  _displayValue(forms.formNo),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildMetaChip(
                      icon: Icons.flag_outlined,
                      label: _displayValue(forms.formServComment),
                      color: statusColor,
                    ),
                    _buildMetaChip(
                      icon: Icons.build_circle_outlined,
                      label: _displayValue(forms.formServName),
                      color: Colors.orange.shade800,
                    ),
                  ],
                ),
              ],
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                'Tap untuk melihat detail request, item tools, PO, dan SO.',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey.shade700),
              ),
            ),
            children: [
              const SizedBox(height: 10),
              _buildSectionHeader(
                'Ringkasan Request',
                icon: Icons.description_outlined,
                trailing: IconButton(
                  tooltip: 'Edit request',
                  icon: Icon(Icons.edit_document, color: clrOrange),
                  onPressed: () {
                    postContForm(
                      forms.idForm,
                      forms.formNo,
                      forms.formServName,
                      forms.formServComment,
                      forms.formDateServName,
                      forms.formCheckBy,
                      forms.formDateCheckBy,
                      forms.formSuperiorAprd,
                      forms.formSuperiorComment,
                      forms.formSadminComment,
                      forms.formSheadAprd,
                      forms.formSheadComment,
                      forms.fromDateUpdate,
                      forms.formUserUpdate,
                      forms.formDateSuperiorAprd,
                      forms.formDateSadminComment,
                      forms.formDateSheadAprd,
                      forms.formMilestone,
                      forms.formStatusOrder,
                      context,
                    );
                  },
                ),
              ),
              GridView.count(
                crossAxisCount: MediaQuery.sizeOf(context).width < mobileWidth
                    ? 1
                    : 2,
                childAspectRatio: MediaQuery.sizeOf(context).width < mobileWidth
                    ? 3.8
                    : 3.3,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildInfoTile(
                    icon: Icons.category_outlined,
                    label: 'Category',
                    value: forms.idForm,
                  ),
                  _buildInfoTile(
                    icon: Icons.person_outline,
                    label: 'Serviceman',
                    value: forms.formServName,
                  ),
                  _buildInfoTile(
                    icon: Icons.event_outlined,
                    label: 'Create Date',
                    value: forms.formDateServName,
                  ),
                  _buildInfoTile(
                    icon: Icons.verified_user_outlined,
                    label: 'Checked By',
                    value: forms.formCheckBy,
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _buildSectionHeader('Quick Actions', icon: Icons.bolt_outlined),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _buildActionButton(
                    icon: Icons.cancel_outlined,
                    label: 'Reject',
                    backgroundColor: clrRed,
                    onPressed: () {
                      ShowDialogBox.show(
                        context: context,
                        title: 'Reject Request Approval',
                        contentTitle: ' Are you sure reject ?',
                        onPressedNo: () {
                          if (!context.mounted) return;
                          Navigator.pop(context);
                        },
                        onPressedYes: () async {
                          Navigator.pop(context);
                          if (!context.mounted) return;
                        },
                        textNo: 'Cancel',
                        textYes: 'Yes',
                        textColorNo: clrBlack,
                        textColorYes: clrOrange,
                      );
                    },
                  ),
                  _buildActionButton(
                    icon: Icons.task_alt_outlined,
                    label: 'Approve',
                    backgroundColor: clrGreen,
                    onPressed: () {
                      ShowDialogBox.show(
                        context: context,
                        title: 'Please make sure all data is correct',
                        contentTitle: ' Are you sure approve ?',
                        onPressedNo: () {
                          if (!context.mounted) return;
                          Navigator.pop(context);
                        },
                        onPressedYes: () async {
                          Navigator.pop(context);
                          if (!context.mounted) return;
                        },
                        textNo: 'Cancel',
                        textYes: 'Yes',
                        textColorNo: clrBlack,
                        textColorYes: clrOrange,
                      );
                    },
                  ),
                  _buildActionButton(
                    icon: Icons.add_circle_outline,
                    label: 'Add Tool',
                    backgroundColor: Colors.orange.shade700,
                    onPressed: () {
                      PageRoutes.routeUserFormDetail(context, 'ADD DATA');
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildSectionHeader('Daftar Tool', icon: Icons.handyman_outlined),
              StoreConnector<AppState, List<PostList>>(
                converter: (store) {
                  final allTool = store.state.formsDetailState.formsDetail;
                  return allTool
                      .where((itemTool) => itemTool.idForm == forms.idForm)
                      .toList();
                },
                builder: (context, filteredList) {
                  if (filteredList.isEmpty) {
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.inventory_2_outlined,
                            size: 34,
                            color: Colors.grey.shade500,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Belum ada detail tool untuk request ini.',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredList.length,
                    itemBuilder: (context, ii) {
                      final itemTool = filteredList[ii];
                      return _buildToolItemCard(itemTool, ii);
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: clrOrange.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: clrOrange.withValues(alpha: 0.22)),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: 'Cari data tool...',
                  hintStyle: TextStyle(color: Colors.orange.shade700),
                  prefixIcon: Icon(Icons.search, color: Colors.orange.shade700),
                  filled: true,
                  fillColor: Colors.transparent,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: Colors.orange.shade700,
                      width: 1.4,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
            decoration: BoxDecoration(
              color: clrOrange.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: clrOrange.withValues(alpha: 0.22)),
            ),
            child: DropdownButton<String>(
              value: _searchField,
              underline: const SizedBox.shrink(),
              iconEnabledColor: Colors.orange.shade800,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.orange.shade900,
                fontWeight: FontWeight.w600,
              ),
              items: _searchFieldLabels.entries
                  .map(
                    (entry) => DropdownMenuItem<String>(
                      value: entry.key,
                      child: Text(entry.value),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  _searchField = value;
                });
              },
            ),
          ),
          if (_searchQuery.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(left: 4),
              decoration: BoxDecoration(
                color: clrOrange.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: _clearSearch,
                icon: Icon(Icons.clear, color: Colors.orange.shade900),
                tooltip: 'Clear search',
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSearchNotFoundContent() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off,
              size: 52,
              color: clrOrange.withValues(alpha: 0.75),
            ),
            const SizedBox(height: 12),
            Text(
              'Data tidak ditemukan untuk filter '
              '"${_searchFieldLabels[_searchField] ?? 'Semua'}" '
              'dengan kata kunci "$_searchQuery"',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: Colors.orange.shade800),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: true,
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: clrWhite,
        drawer: DrawerMenu(title: name),
        body: RefreshIndicator(
          onRefresh: _refreshData,
          child: CustomScrollView(
            slivers: [
              SliverAppbars(
                title: titleDataTool,
                onPressTailing: () {
                  postContForm(
                    "",
                    "",
                    "",
                    "",
                    "",
                    "",
                    "",
                    "",
                    "",
                    "",
                    "",
                    "",
                    "",
                    "",
                    "",
                    "",
                    "",
                    "",
                    "",
                    context,
                  );
                },
                onPressLeading: () => _scaffoldKey.currentState?.openDrawer(),
                textColor: Colors.black,
                iconTailing: Icon(Icons.add),
                iconLeading: Icon(Icons.menu),
              ),
              StoreConnector<AppState, FormsState>(
                converter: (store) => store.state.formsState,
                builder: (context, state) {
                  final filteredForms = state.forms
                      .where(_matchesSearch)
                      .toList();
                  if (state.isLoadingTool) {
                    return SliverFillRemaiings(
                      errors: "Loading",
                      hasScrollBodys: false,
                    );
                  }
                  if (state.error != null) {
                    return SliverFillRemaiings(
                      errors: state.error ?? '${state.error}',
                      hasScrollBodys: false,
                    );
                  }
                  if (state.forms.isEmpty) {
                    return SliverFillRemaiings(
                      errors: state.error ?? "No Record Data Found",
                      hasScrollBodys: false,
                    );
                  }
                  if (filteredForms.isEmpty) {
                    return SliverMainAxisGroup(
                      slivers: [
                        SliverPersistentHeader(
                          pinned: true,
                          delegate: _PinnedSearchHeaderDelegate(
                            backgroundColor: clrWhite,
                            child: _buildSearchBar(),
                          ),
                        ),
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: _buildSearchNotFoundContent(),
                        ),
                      ],
                    );
                  }
                  return SliverMainAxisGroup(
                    slivers: [
                      SliverPersistentHeader(
                        pinned: true,
                        delegate: _PinnedSearchHeaderDelegate(
                          backgroundColor: clrWhite,
                          child: _buildSearchBar(),
                        ),
                      ),
                      SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final forms = filteredForms[index];
                          return _buildFormCard(forms, index);
                        }, childCount: filteredForms.length),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PinnedSearchHeaderDelegate extends SliverPersistentHeaderDelegate {
  _PinnedSearchHeaderDelegate({
    required this.child,
    required this.backgroundColor,
  });

  final Widget child;
  final Color backgroundColor;

  @override
  double get minExtent => 60;

  @override
  double get maxExtent => 60;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: backgroundColor,
      alignment: Alignment.centerLeft,
      child: child,
    );
  }

  @override
  bool shouldRebuild(covariant _PinnedSearchHeaderDelegate oldDelegate) {
    return oldDelegate.child != child ||
        oldDelegate.backgroundColor != backgroundColor;
  }
}
