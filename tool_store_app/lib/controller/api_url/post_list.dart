String _jsonString(dynamic value, [String fallback = '']) {
  if (value == null) return fallback;
  return value.toString();
}

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
      idUsers: _jsonString(json['id_users']),
      username: _jsonString(json['username']),
      password: _jsonString(json['password']),
      namaUser: _jsonString(json['nama_user']),
      foto: _jsonString(json['foto']),
      idTU: _jsonString(json['id_tu']),
      noTelp: _jsonString(json['no_telp']),
      token: _jsonString(json['token']),
      level: _jsonString(json['level']),
      status: _jsonString(json['status']),
      superiorId: _jsonString(json['superior_id']),

      idForm: _jsonString(json['id_form'] ?? json['id']),
      formNo: _jsonString(json['form_no']),
      formServName: _jsonString(json['form_serv_name']),
      formServComment: _jsonString(json['form_serv_comment']),
      formCheckBy: _jsonString(json['form_check_by']),
      formDateCheckBy: _jsonString(json['form_date_check_by']),
      formDateServName: _jsonString(json['form_date_serv_name']),
      formSuperiorAprd: _jsonString(json['form_superior_aprd']),
      formSuperiorComment: _jsonString(json['form_superior_comment']),
      formSadminComment: _jsonString(json['form_sadmin_comment']),
      formSheadAprd: _jsonString(json['form_shead_aprd']),
      formSheadComment: _jsonString(json['form_shead_comment']),
      fromDateUpdate: _jsonString(json['from_date_update']),
      formUserUpdate: _jsonString(json['form_user_update']),
      formDateSuperiorAprd: _jsonString(json['form_date_superior_aprd']),
      formDateSadminComment: _jsonString(json['form_date_sadmin_comment']),
      formDateSheadAprd: _jsonString(json['form_date_shead_aprd']),
      formMilestone: _jsonString(json['form_milestone']),
      formStatusOrder: _jsonString(json['form_status_order']),

      idFormDetail: _jsonString(json['id_form_detail']),
      formComment: _jsonString(json['form_comment']),
      pnGroup: _jsonString(json['pn_group']),
      pnDesc: _jsonString(json['pn_desc']),
      qty: _jsonString(json['qty']),
      explan: _jsonString(json['explan']),
      actionNote: _jsonString(json['action_note']),
      formDetailDate: _jsonString(json['form_detail_date']),
      formDetailUser: _jsonString(json['form_detail_user']),
      valType: _jsonString(json['val_type']),
      partValue: _jsonString(json['part_value']),

      idActionNote: _jsonString(json['id_action_note']),
      noteinitial: _jsonString(json['note_initial']),
      actionNoteDesc: _jsonString(json['action_note_desc']),
      actionDateUpdate: _jsonString(json['action_date_update']),
      actionNoteUser: _jsonString(json['action_note_user']),

      idPo: _jsonString(json['id_po']),
      poNo: _jsonString(json['po_no']),
      dateUpdatePo: _jsonString(json['date_update_po']),
      userUpdatePo: _jsonString(json['user_update_po']),

      idSo: _jsonString(json['id_so']),
      so: _jsonString(json['so']),
      eta: _jsonString(json['eta']),
      noteSo: _jsonString(json['note_so']),
      dateUpdateSo: _jsonString(json['date_update_so	']),
      idUpdateSo: _jsonString(json['id_update_so']),

      namaSuperior: _jsonString(json['nama_superior']),
      statusSuperior: _jsonString(json['status_superior']),
      userIdInputSuperior: _jsonString(json['user_id_input_superior']),
      dateInputSuperior: _jsonString(json['date_input_superior']),

      idRcvTool: _jsonString(json['id_rcv_tool']),
      rcvToolDate: _jsonString(json['rcv_tool_date']),
      rcvToolIdInput: _jsonString(json['rcv_tool_id_input']),
      rcvToolDateInput: _jsonString(json['rcv_tool_date_input']),

      idRcvWh: _jsonString(json['id_rcv_wh']),
      rcvWhDate: _jsonString(json['rcv_wh_date']),
      rcvWhIdInput: _jsonString(json['rcv_wh_id_input']),
      rcvWhDateInput: _jsonString(json['rcv_wh_date_input']),
      valueResponse: _jsonString(json['value']),
      messageResponse: _jsonString(json['message']),
    );
  }
}
