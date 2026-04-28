import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:tool_store_app/controller/cont_crud/redux/state.dart';
import 'package:tool_store_app/controller/cont_crud/redux/store.dart';
import 'package:tool_store_app/controller/function/funct.dart';
import 'package:tool_store_app/model/post_get_data.dart';
import 'package:tool_store_app/view/custom/mixin/mixin_pref.dart';
import 'package:tool_store_app/view/custom/navbar/sliver_appbars.dart';
import 'package:tool_store_app/view/custom/navbar/sliver_fill_remaining.dart';
import 'package:tool_store_app/view/menu/drawer/drawer.dart';
import 'package:tool_store_app/view/var/var.dart';

class UserData extends StatefulWidget {
  const UserData({super.key});
  @override
  State<UserData> createState() => _UserDataState();
}

class _UserDataState extends State<UserData> with MixinPref {
  // 1. Buat variabel key di sini
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String _displayValue(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '-';
    }
    return value.trim();
  }

  Color _statusColor(String value) {
    final status = value.toLowerCase();
    if (status.contains('active') || status.contains('aktif')) {
      return Colors.green;
    }
    if (status.contains('inactive') ||
        status.contains('nonaktif') ||
        status.contains('disable')) {
      return Colors.red;
    }
    return Colors.orange;
  }

  Widget _buildMetaChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
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

  Widget _buildLineItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
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

  Widget _buildUserCard(dynamic users, int index) {
    final statusColor = _statusColor(users.status);
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [Colors.white, statusColor.withOpacity(0.04)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: clrOrange.withOpacity(0.12),
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
                child: SelectableText(
                  _displayValue(users.username),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Edit user',
                onPressed: () {
                  postContUser(
                    users.idUsers,
                    users.username,
                    users.password,
                    users.namaUser,
                    users.noTelp,
                    users.idTU,
                    users.level,
                    context,
                  );
                },
                icon: const Icon(Icons.edit_document),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildMetaChip(
                icon: Icons.verified_user_outlined,
                label: 'Level ${_displayValue(users.level)}',
                color: Colors.orange.shade800,
              ),
              _buildMetaChip(
                icon: Icons.flag_outlined,
                label: _displayValue(users.status),
                color: statusColor,
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildLineItem('Name', users.namaUser),
          _buildLineItem('No.Telp', users.noTelp),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    refreshPref();
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
          onRefresh: () async {
            await store.dispatch(
              getDataUser(
                param: paramViewDataUser,
                idUsers: '',
                username: '',
                password: '',
                namaUser: '',
                foto: '',
                idTU: '',
                noTelp: '',
                token: '',
                level: '',
                status: '',
              ),
            );
          },
          child: CustomScrollView(
            slivers: [
              SliverAppbars(
                title: titleDataUser,
                onPressTailing: () {
                  postContUser("", "", "", "", "", "", "", context);
                },
                onPressLeading: () => _scaffoldKey.currentState?.openDrawer(),
                textColor: Colors.black,
                iconTailing: Icon(Icons.add),
                iconLeading: Icon(Icons.menu),
              ),
              StoreConnector<AppState, UserState>(
                converter: (store) => store.state.userState,
                builder: (context, state) {
                  // 1. Tampilan saat Loading
                  if (state.isLoading) {
                    return SliverFillRemaiings(
                      errors: "Loading",
                      hasScrollBodys: false,
                    );
                  }
                  // 2. Tampilan saat Error
                  if (state.error != null) {
                    return SliverFillRemaiings(
                      errors: state.error ?? '${state.error}',
                      hasScrollBodys: false,
                    );
                  }
                  // 3. Tampilan saat Data Kosong
                  if (state.users.isEmpty) {
                    return SliverFillRemaiings(
                      errors: state.error ?? "No Record Data Found",
                      hasScrollBodys: false,
                    );
                  }
                  return SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final users = state.users[index];
                      return _buildUserCard(users, index);
                    }, childCount: state.users.length),
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
