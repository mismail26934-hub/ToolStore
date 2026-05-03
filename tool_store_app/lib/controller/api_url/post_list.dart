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
  late String superiorId;

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
  late String formMilestone;
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
  late String noteinitial;
  late String actionNoteDesc;
  late String actionDateUpdate;
  late String actionNoteUser;

  late String idPo;
  late String poNo;
  late String dateUpdatePo;
  late String userUpdatePo;

  late String idSo;
  late String so;
  late String eta;
  late String noteSo;
  late String dateUpdateSo;
  late String idUpdateSo;

  late String namaSuperior;
  late String statusSuperior;
  late String userIdInputSuperior;
  late String dateInputSuperior;

  late String idRcvTool;
  late String rcvToolDate;
  late String rcvToolIdInput;
  late String rcvToolDateInput;

  late String idRcvWh;
  late String rcvWhDate;
  late String rcvWhIdInput;
  late String rcvWhDateInput;
  late String valueResponse;
  late String messageResponse;

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
    required this.superiorId,

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
    required this.formMilestone,
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
    required this.noteinitial,
    required this.actionNoteDesc,
    required this.actionDateUpdate,
    required this.actionNoteUser,

    required this.idPo,
    required this.poNo,
    required this.dateUpdatePo,
    required this.userUpdatePo,

    required this.idSo,
    required this.so,
    required this.eta,
    required this.noteSo,
    required this.dateUpdateSo,
    required this.idUpdateSo,

    required this.namaSuperior,
    required this.statusSuperior,
    required this.userIdInputSuperior,
    required this.dateInputSuperior,

    required this.idRcvTool,
    required this.rcvToolDate,
    required this.rcvToolIdInput,
    required this.rcvToolDateInput,

    required this.idRcvWh,
    required this.rcvWhDate,
    required this.rcvWhIdInput,
    required this.rcvWhDateInput,
    required this.valueResponse,
    required this.messageResponse,
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
      superiorId: json['superior_id'] ?? "",

      idForm: json['id_form'] ?? "",
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
      formMilestone: json['form_milestone'] ?? "",
      formStatusOrder: json['form_status_order'] ?? "",

      idFormDetail: json['id_form_detail'] ?? "",
      formComment: json['form_comment'] ?? "",
      pnGroup: json['pn_group'] ?? "",
      pnDesc: json['pn_desc'] ?? "",
      qty: json['qty'] ?? "",
      explan: json['explan'] ?? "",
      actionNote: json['action_note'] ?? "",
      formDetailDate: json['form_detail_date'] ?? "",
      formDetailUser: json['form_detail_user'] ?? "",
      valType: json['val_type'] ?? "",
      partValue: json['part_value'] ?? "",

      idActionNote: json['id_action_note'] ?? "",
      noteinitial: json['note_initial'] ?? "",
      actionNoteDesc: json['action_note_desc'] ?? "",
      actionDateUpdate: json['action_date_update'] ?? "",
      actionNoteUser: json['action_note_user'] ?? "",

      idPo: json['id_po'] ?? "",
      poNo: json['po_no'] ?? "",
      dateUpdatePo: json['date_update_po'] ?? "",
      userUpdatePo: json['user_update_po'] ?? "",

      idSo: json['id_so'] ?? "",
      so: json['so'] ?? "",
      eta: json['eta'] ?? "",
      noteSo: json['note_so'] ?? "",
      dateUpdateSo: json['date_update_so	'] ?? "",
      idUpdateSo: json['id_update_so'] ?? "",

      namaSuperior: json['nama_superior'] ?? "",
      statusSuperior: json['status_superior'] ?? "",
      userIdInputSuperior: json['user_id_input_superior'] ?? "",
      dateInputSuperior: json['date_input_superior'] ?? "",

      idRcvTool: json['id_rcv_tool'] ?? "",
      rcvToolDate: json['rcv_tool_date'] ?? "",
      rcvToolIdInput: json['rcv_tool_id_input'] ?? "",
      rcvToolDateInput: json['rcv_tool_date_input'] ?? "",

      idRcvWh: json['id_rcv_wh'] ?? "",
      rcvWhDate: json['rcv_wh_date'] ?? "",
      rcvWhIdInput: json['rcv_wh_id_input'] ?? "",
      rcvWhDateInput: json['rcv_wh_date_input'] ?? "",
      valueResponse: json['value'] ?? "",
      messageResponse: json['message'] ?? "",
    );
  }
}
