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

  late String idForm;
  late String formNo;
  late String formServName;
  late String formServComment;
  late String formCheckBy;
  late String formDateCheckBy;
  late String formDateServName;
  late String formSuperiorAprd;
  late String formSuperiorComment;
  late String formSadminComment;
  late String formSheadAprd;
  late String formSheadComment;
  late String fromDateUpdate;
  late String formUserUpdate;
  late String formDateSuperiorAprd;
  late String formDateSadminComment;
  late String formDateSheadAprd;
  late String formmilestone;
  late String formStatusOrder;

  late String idFormDetail;
  late String formComment;
  late String pnGroup;
  late String pnDesc;
  late String qty;
  late String explan;
  late String actionNote;
  late String formDetailDate;
  late String formDetailUser;
  late String valType;
  late String partValue;

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

    required this.idForm,
    required this.formNo,
    required this.formServName,
    required this.formServComment,
    required this.formCheckBy,
    required this.formDateCheckBy,
    required this.formDateServName,
    required this.formSuperiorAprd,
    required this.formSuperiorComment,
    required this.formSadminComment,
    required this.formSheadAprd,
    required this.formSheadComment,
    required this.fromDateUpdate,
    required this.formUserUpdate,
    required this.formDateSuperiorAprd,
    required this.formDateSadminComment,
    required this.formDateSheadAprd,
    required this.formmilestone,
    required this.formStatusOrder,

    required this.idFormDetail,
    required this.formComment,
    required this.pnGroup,
    required this.pnDesc,
    required this.qty,
    required this.explan,
    required this.actionNote,
    required this.formDetailDate,
    required this.formDetailUser,
    required this.valType,
    required this.partValue,

    required this.idActionNote,
    required this.actionNoteDesc,
    required this.actionDateUpdate,
    required this.actionNoteUser,
  });

  factory PostList.fromJson(Map<String, dynamic> json) {
    return PostList(
      idUsers: json['id_users'] ?? "",
      username: json['username'] ?? "",
      password: json['password'] ?? "",
      namaUser: json['nama_user'] ?? "",
      foto: json['foto'] ?? "",
      idTU: json['id_tu'] ?? "",
      noTelp: json['no_telp'] ?? "",
      token: json['token'] ?? "",
      level: json['level'] ?? "",
      status: json['status'] ?? "",

      idForm: json['id_from'] ?? "",
      formNo: json['form_no'] ?? "",
      formServName: json['form_serv_name'] ?? "",
      formServComment: json['form_serv_comment'] ?? "",
      formCheckBy: json['form_check_by'] ?? "",
      formDateCheckBy: json['form_date_check_by'] ?? "",
      formDateServName: json['form_date_serv_name'] ?? "",
      formSuperiorAprd: json['form_superior_aprd'] ?? "",
      formSuperiorComment: json['form_superior_comment'] ?? "",
      formSadminComment: json['form_sadmin_comment'] ?? "",
      formSheadAprd: json['form_shead_aprd'] ?? "",
      formSheadComment: json['form_shead_comment'] ?? "",
      fromDateUpdate: json['from_date_update'] ?? "",
      formUserUpdate: json['form_user_update'] ?? "",
      formDateSuperiorAprd: json['form_date_superior_aprd'] ?? "",
      formDateSadminComment: json['form_date_sadmin_comment'] ?? "",
      formDateSheadAprd: json['form_date_shead_aprd'] ?? "",
      formmilestone: json['form_milestone'] ?? "",
      formStatusOrder: json['form_status_order'] ?? "",

      idFormDetail: json['idFormDetail'] ?? "",
      formComment: json['formComment'] ?? "",
      pnGroup: json['pnGroup'] ?? "",
      pnDesc: json['pnDesc'] ?? "",
      qty: json['qty'] ?? "",
      explan: json['explan'] ?? "",
      actionNote: json['action_note'] ?? "",
      formDetailDate: json['form_detail_date'] ?? "",
      formDetailUser: json['form_detail_user'] ?? "",
      valType: json['val_type'] ?? "",
      partValue: json['part_value'] ?? "",

      idActionNote: json['idActionNote'] ?? "",
      actionNoteDesc: json['actionNoteDesc'] ?? "",
      actionDateUpdate: json['actionDateUpdate'] ?? "",
      actionNoteUser: json['actionNoteUser'] ?? "",
    );
  }
}
