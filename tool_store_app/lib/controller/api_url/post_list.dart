class PostList {
  late String idUsers;
  late String username;
  late String password;
  late String namaUser;
  late String foto;
  late String idTU;
  late String noTelp;
  late String token;
  late String level;
  late String status;

  late String idFrom;
  late String formServName;
  late String formCheckBy;
  late String formDateCheckBy;
  late String formDateServName;
  late String formServComment;
  late String formSuperiorAprd;
  late String formSuperiorComment;
  late String formSadminComment;
  late String formSheadAprd;
  late String formSheadComment;
  late String fromDateUpdate;
  late String formUserUpdate;

  late String idFormDetail;
  late String formComment;
  late String pnGroup;
  late String pnDesc;
  late String qty;
  late String explan;
  late String actionNote;
  late String formDetailDate;
  late String formDetailUser;

  late String idActionNote;
  late String actionNoteDesc;
  late String actionDateUpdate;
  late String actionNoteUser;

  PostList({
    required this.idUsers,
    required this.username,
    required this.password,
    required this.namaUser,
    required this.foto,
    required this.idTU,
    required this.noTelp,
    required this.token,
    required this.level,
    required this.status,

    required this.idFrom,
    required this.formServName,
    required this.formCheckBy,
    required this.formDateCheckBy,
    required this.formDateServName,
    required this.formServComment,
    required this.formSuperiorAprd,
    required this.formSuperiorComment,
    required this.formSadminComment,
    required this.formSheadAprd,
    required this.formSheadComment,
    required this.fromDateUpdate,
    required this.formUserUpdate,

    required this.idFormDetail,
    required this.formComment,
    required this.pnGroup,
    required this.pnDesc,
    required this.qty,
    required this.explan,
    required this.actionNote,
    required this.formDetailDate,
    required this.formDetailUser,

    required this.idActionNote,
    required this.actionNoteDesc,
    required this.actionDateUpdate,
    required this.actionNoteUser,
  });

  factory PostList.fromJson(Map<String, dynamic> json) {
    return PostList(
      idUsers: json['idUsers'] ?? "",
      username: json['username'] ?? "",
      password: json['password'] ?? "",
      namaUser: json['nama_user'] ?? "",
      foto: json['foto'] ?? "",
      idTU: json['id_tu'] ?? "",
      noTelp: json['no_telp'] ?? "",
      token: json['token'] ?? "",
      level: json['level'] ?? "",
      status: json['status'] ?? "",

      idFrom: json['idFrom'] ?? "",
      formServName: json['formServName'] ?? "",
      formCheckBy: json['formCheckBy'] ?? "",
      formDateCheckBy: json['formDateCheckBy'] ?? "",
      formDateServName: json['formDateServName'] ?? "",
      formServComment: json['formServComment'] ?? "",
      formSuperiorAprd: json['formSuperiorAprd'] ?? "",
      formSuperiorComment: json['formSuperiorComment'] ?? "",
      formSadminComment: json['formSadminComment'] ?? "",
      formSheadAprd: json['formSheadAprd'] ?? "",
      formSheadComment: json['formSheadComment'] ?? "",
      fromDateUpdate: json['fromDateUpdate'] ?? "",
      formUserUpdate: json['formUserUpdate'] ?? "",

      idFormDetail: json['idFormDetail'] ?? "",
      formComment: json['formComment'] ?? "",
      pnGroup: json['pnGroup'] ?? "",
      pnDesc: json['pnDesc'] ?? "",
      qty: json['qty'] ?? "",
      explan: json['explan'] ?? "",
      actionNote: json['actionNote'] ?? "",
      formDetailDate: json['formDetailDate'] ?? "",
      formDetailUser: json['formDetailUser'] ?? "",

      idActionNote: json['idActionNote'] ?? "",
      actionNoteDesc: json['actionNoteDesc'] ?? "",
      actionDateUpdate: json['actionDateUpdate'] ?? "",
      actionNoteUser: json['actionNoteUser'] ?? "",
    );
  }
}
