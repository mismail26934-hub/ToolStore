import 'package:tool_store_app/controller/api_url/post_list.dart';

/// Agregat COUNT milestone dari `cont_form.php` (param DASHBOARD COUNT FORM).
class FormDashboardCounts {
  const FormDashboardCounts({
    this.draft = 0,
    this.superiorApproval = 0,
    this.serviceAdmin = 0,
    this.deptHead = 0,
    this.counterGa = 0,
    this.toolReceivedWhGa = 0,
    this.notificationTotal = 0,
  });

  final int draft;
  final int superiorApproval;
  final int serviceAdmin;
  final int deptHead;
  final int counterGa;
  final int toolReceivedWhGa;
  final int notificationTotal;

  static const empty = FormDashboardCounts();

  factory FormDashboardCounts.fromJson(Map<String, dynamic> json) {
    int readInt(dynamic v) {
      if (v == null) return 0;
      if (v is int) return v;
      if (v is num) return v.toInt();
      return int.tryParse(v.toString()) ?? 0;
    }

    return FormDashboardCounts(
      draft: readInt(json['draft']),
      superiorApproval: readInt(
        json['superior_approval'] ?? json['superiorApproval'],
      ),
      serviceAdmin: readInt(
        json['service_admin'] ?? json['serviceAdmin'],
      ),
      deptHead: readInt(json['dept_head'] ?? json['deptHead']),
      counterGa: readInt(json['counter_ga'] ?? json['counterGa']),
      toolReceivedWhGa: readInt(
        json['tool_received_wh_ga'] ?? json['toolReceivedWhGa'],
      ),
      notificationTotal: readInt(
        json['notification_total'] ?? json['notificationTotal'],
      ),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is FormDashboardCounts &&
      other.draft == draft &&
      other.superiorApproval == superiorApproval &&
      other.serviceAdmin == serviceAdmin &&
      other.deptHead == deptHead &&
      other.counterGa == counterGa &&
      other.toolReceivedWhGa == toolReceivedWhGa &&
      other.notificationTotal == notificationTotal;

  @override
  int get hashCode => Object.hash(
    draft,
    superiorApproval,
    serviceAdmin,
    deptHead,
    counterGa,
    toolReceivedWhGa,
    notificationTotal,
  );
}

// USER
class UserState {
  final List<PostList> users;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final String? error;

  /// Jumlah total user di database (filter yang sama), dari `cont_user.php` bila dikirim.
  final int? totalUsers;

  UserState({
    this.users = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.error,
    this.totalUsers,
  });

  // Factory untuk state awal
  factory UserState.initial() => UserState(users: [], isLoading: false);

  UserState copyWith({
    List<PostList>? users,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    String? error,
    int? totalUsers,
    bool clearTotalUsers = false,
  }) {
    return UserState(
      // Jika parameter baru (list) null, gunakan nilai yang sudah ada (this.users)
      users: users ?? this.users,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      error: error ?? this.error,
      totalUsers: clearTotalUsers ? null : (totalUsers ?? this.totalUsers),
    );
  }
}

class FormsState {
  final List<PostList> forms;
  final bool isLoadingTool;
  final bool isLoadingMore;
  final bool hasMore;
  final String? error;

  /// Jumlah total form di database, dari `cont_form.php` bila dikirim.
  final int? totalForms;

  /// COUNT per milestone dari `DASHBOARD COUNT FORM`.
  final FormDashboardCounts? dashboardCounts;
  final bool isLoadingDashboardCounts;
  final String? dashboardCountsError;

  FormsState({
    this.forms = const [],
    this.isLoadingTool = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.error,
    this.totalForms,
    this.dashboardCounts,
    this.isLoadingDashboardCounts = false,
    this.dashboardCountsError,
  });

  // Factory untuk state awal
  factory FormsState.initial() => FormsState(forms: [], isLoadingTool: false);

  FormDashboardCounts get dashboardCountsOrEmpty =>
      dashboardCounts ?? FormDashboardCounts.empty;

  FormsState copyWith({
    List<PostList>? forms,
    bool? isLoadingTool,
    bool? isLoadingMore,
    bool? hasMore,
    String? error,
    int? totalForms,
    bool clearTotalForms = false,
    FormDashboardCounts? dashboardCounts,
    bool clearDashboardCounts = false,
    bool? isLoadingDashboardCounts,
    String? dashboardCountsError,
    bool clearDashboardCountsError = false,
  }) {
    return FormsState(
      // Jika parameter baru (list) null, gunakan nilai yang sudah ada (this.forms)
      forms: forms ?? this.forms,
      isLoadingTool: isLoadingTool ?? this.isLoadingTool,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      error: error ?? this.error,
      totalForms: clearTotalForms ? null : (totalForms ?? this.totalForms),
      dashboardCounts: clearDashboardCounts
          ? null
          : (dashboardCounts ?? this.dashboardCounts),
      isLoadingDashboardCounts:
          isLoadingDashboardCounts ?? this.isLoadingDashboardCounts,
      dashboardCountsError: clearDashboardCountsError
          ? null
          : (dashboardCountsError ?? this.dashboardCountsError),
    );
  }
}

// FORM
class FormsDetailState {
  final List<PostList> formsDetail;
  final bool isLoadingToolDetail;
  final String? error;

  FormsDetailState({
    this.formsDetail = const [],
    this.isLoadingToolDetail = false,
    this.error,
  });

  // Factory untuk state awal
  factory FormsDetailState.initial() =>
      FormsDetailState(formsDetail: [], isLoadingToolDetail: false);

  FormsDetailState copyWith({
    List<PostList>? formsDetail,
    bool? isLoadingToolDetail,
    String? error,
  }) {
    return FormsDetailState(
      // Jika parameter baru (list) null, gunakan nilai yang sudah ada (this.formsDetail)
      formsDetail: formsDetail ?? this.formsDetail,
      isLoadingToolDetail: isLoadingToolDetail ?? this.isLoadingToolDetail,
      error: error ?? this.error,
    );
  }
}

// PO
class PosDetailState {
  final List<PostList> posDetail;
  final bool isLoadingPO;
  final String? error;

  PosDetailState({
    this.posDetail = const [],
    this.isLoadingPO = false,
    this.error,
  });

  // Factory untuk state awal
  factory PosDetailState.initial() =>
      PosDetailState(posDetail: [], isLoadingPO: false);

  PosDetailState copyWith({
    List<PostList>? posDetail,
    bool? isLoadingPO,
    String? error,
  }) {
    return PosDetailState(
      // Jika parameter baru (list) null, gunakan nilai yang sudah ada (this.poDetail)
      posDetail: posDetail ?? this.posDetail,
      isLoadingPO: isLoadingPO ?? this.isLoadingPO,
      error: error ?? this.error,
    );
  }
}

// SO
class SosDetailState {
  final List<PostList> sosDetail;
  final bool isLoadingSO;
  final String? error;

  SosDetailState({
    this.sosDetail = const [],
    this.isLoadingSO = false,
    this.error,
  });

  // Factory untuk state awal
  factory SosDetailState.initial() =>
      SosDetailState(sosDetail: [], isLoadingSO: false);

  SosDetailState copyWith({
    List<PostList>? sosDetail,
    bool? isLoadingSO,
    String? error,
  }) {
    return SosDetailState(
      // Jika parameter baru (list) null, gunakan nilai yang sudah ada (this.formsDetail)
      sosDetail: sosDetail ?? this.sosDetail,
      isLoadingSO: isLoadingSO ?? this.isLoadingSO,
      error: error ?? this.error,
    );
  }
}

// SUPERRIOR
class SuperriorState {
  final List<PostList> superriorS;
  final bool isLoadingSuperrior;
  final String? error;

  SuperriorState({
    this.superriorS = const [],
    this.isLoadingSuperrior = false,
    this.error,
  });

  // Factory untuk state awal
  factory SuperriorState.initial() =>
      SuperriorState(superriorS: [], isLoadingSuperrior: false);

  SuperriorState copyWith({
    List<PostList>? superriorS,
    bool? isLoadingSuperrior,
    String? error,
  }) {
    return SuperriorState(
      // Jika parameter baru (list) null, gunakan nilai yang sudah ada (this.formsDetail)
      superriorS: superriorS ?? this.superriorS,
      isLoadingSuperrior: isLoadingSuperrior ?? this.isLoadingSuperrior,
      error: error ?? this.error,
    );
  }
}

// RCV WH
class RcvWhState {
  final List<PostList> rcvWhs;
  final bool isLoadingrcvWh;
  final String? error;

  RcvWhState({this.rcvWhs = const [], this.isLoadingrcvWh = false, this.error});

  // Factory untuk state awal
  factory RcvWhState.initial() => RcvWhState(rcvWhs: [], isLoadingrcvWh: false);

  RcvWhState copyWith({
    List<PostList>? rcvWhs,
    bool? isLoadingrcvWh,
    String? error,
  }) {
    return RcvWhState(
      // Jika parameter baru (list) null, gunakan nilai yang sudah ada (this.formsDetail)
      rcvWhs: rcvWhs ?? this.rcvWhs,
      isLoadingrcvWh: isLoadingrcvWh ?? this.isLoadingrcvWh,
      error: error ?? this.error,
    );
  }
}

// RCV TOOL
class RcvToolState {
  final List<PostList> rcvTools;
  final bool isLoadingrcvTool;
  final String? error;

  RcvToolState({
    this.rcvTools = const [],
    this.isLoadingrcvTool = false,
    this.error,
  });

  // Factory untuk state awal
  factory RcvToolState.initial() =>
      RcvToolState(rcvTools: [], isLoadingrcvTool: false);

  RcvToolState copyWith({
    List<PostList>? rcvTools,
    bool? isLoadingrcvTool,
    String? error,
  }) {
    return RcvToolState(
      // Jika parameter baru (list) null, gunakan nilai yang sudah ada (this.formsDetail)
      rcvTools: rcvTools ?? this.rcvTools,
      isLoadingrcvTool: isLoadingrcvTool ?? this.isLoadingrcvTool,
      error: error ?? this.error,
    );
  }
}

// APP STATE
class AppState {
  final UserState userState;
  final FormsState formsState;
  final FormsDetailState formsDetailState;
  final PosDetailState posDetailState;
  final SosDetailState sosDetailState;
  final SuperriorState superriorState;
  final RcvWhState rcvWhState;
  final RcvToolState rcvToolState;

  AppState({
    required this.userState,
    required this.formsState,
    required this.formsDetailState,
    required this.posDetailState,
    required this.sosDetailState,
    required this.superriorState,
    required this.rcvWhState,
    required this.rcvToolState,
  });

  factory AppState.initial() => AppState(
    userState: UserState.initial(),
    formsState: FormsState.initial(),
    formsDetailState: FormsDetailState.initial(),
    posDetailState: PosDetailState.initial(),
    sosDetailState: SosDetailState.initial(),
    superriorState: SuperriorState.initial(),
    rcvWhState: RcvWhState.initial(),
    rcvToolState: RcvToolState.initial(),
  );
}
