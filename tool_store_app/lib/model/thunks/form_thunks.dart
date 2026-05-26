import 'package:dio/dio.dart';
import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';
import 'package:tool_store_app/controller/cont_crud/redux/action.dart';
import 'package:tool_store_app/controller/cont_crud/redux/state.dart';
import 'package:tool_store_app/debug/agent_log.dart';
import 'package:tool_store_app/model/api_client.dart';
import 'package:tool_store_app/model/repositories/form_repository.dart';
import 'package:tool_store_app/model/repositories/list_merge_utils.dart';
import 'package:tool_store_app/view/var/var.dart';

ThunkAction<AppState> getDashboardFormCounts() {
  return (Store<AppState> store) async {
    if (store.state.formsState.dashboardCounts != null) {
      store.dispatch(FetchDashboardCountsRefreshAction());
    } else {
      store.dispatch(FetchDashboardCountsAction());
    }
    try {
      final counts = await fetchDashboardFormCounts();
      store.dispatch(DashboardCountsLoadedAction(counts));
      return counts;
    } on DioException catch (e) {
      final msg = applyDioError(e);
      store.dispatch(DashboardCountsErrorAction(errors));
      throw Exception(msg);
    } catch (e) {
      store.dispatch(DashboardCountsErrorAction(e.toString()));
      throw Exception(e);
    }
  };
}

ThunkAction<AppState> getDataTool({
  required String param,
  required String idForm,
  required String formNo,
  required String formServName,
  required String formCheckBy,
  required String formDateCheckBy,
  required String formDateServName,
  required String formServComment,
  required String formSuperiorAprd,
  required String formSuperiorComment,
  required String formSadminComment,
  required String formMilestone,
  required String formStatusOrder,
  required String formSheadAprd,
  required String formSheadComment,
  required String fromDateUpdate,
  required String formUserUpdate,
  int page = 1,
  int limit = kToolFormPageSize,
  bool append = false,
  String viewKeyword = '',
  String viewSearchField = 'all',
}) {
  return (Store<AppState> store) async {
    final isView = param == paramViewDataForm;
    if (isView) {
      if (append) {
        store.dispatch(FetchDatasMoreAction());
      } else if (store.state.formsState.forms.isNotEmpty) {
        store.dispatch(FetchDatasRefreshAction());
      } else {
        store.dispatch(FetchDatasAction());
      }
    }
    final body = <String, dynamic>{
      'param': param,
      'id_form': idForm,
      'form_no': formNo,
      'form_serv_name': formServName,
      'form_check_by': formCheckBy,
      'form_date_check_by': formDateCheckBy,
      'form_date_serv_name': formDateServName,
      'form_serv_comment': formServComment,
      'form_superior_aprd': formSuperiorAprd,
      'form_superior_comment': formSuperiorComment,
      'form_sadmin_comment': formSadminComment,
      'form_milestone': formMilestone,
      'form_status_order': formStatusOrder,
      'form_shead_aprd': formSheadAprd,
      'form_shead_comment': formSheadComment,
      'from_date_update': fromDateUpdate,
      'form_user_update': formUserUpdate,
      'page': page.toString(),
      'limit': limit.toString(),
    };
    final kw = viewKeyword.trim();
    if (isView && kw.isNotEmpty) {
      body['keyword'] = kw;
      body['search_field'] = viewSearchField.trim().isEmpty
          ? 'all'
          : viewSearchField.trim();
    }
    try {
      final parsed = await fetchFormList(body);
      final listTool = parsed.items;
      final int? apiTotal = parsed.total;

      if (isView) {
        agentDebugLog(
          hypothesisId: 'C',
          location: 'form_thunks.dart:getDataTool',
          message: 'API view response',
          data: {
            'page': page,
            'limit': limit,
            'append': append,
            'itemsCount': listTool.length,
            'apiTotal': apiTotal,
            'viewKeyword': viewKeyword,
            'viewSearchField': viewSearchField,
            'sampleMilestones': listTool
                .take(5)
                .map((f) => f.formMilestone.trim())
                .toList(),
          },
        );
      }

      final bool hasMore;
      if (isView) {
        final mergedCount = append
            ? mergeFormsPreview(store.state.formsState.forms, listTool).length
            : listTool.length;
        if (apiTotal != null) {
          hasMore = mergedCount < apiTotal;
        } else {
          hasMore = listTool.length >= limit;
        }
      } else {
        hasMore = false;
      }

      if (isView) {
        if (append) {
          store.dispatch(
            DatasAppendAction(listTool, hasMore: hasMore, totalForms: apiTotal),
          );
        } else {
          store.dispatch(
            DatasLoadedAction(listTool, hasMore: hasMore, totalForms: apiTotal),
          );
        }
      }
      return listTool;
    } on DioException catch (e) {
      final msg = applyDioError(e);
      if (isView) store.dispatch(DatasErrorAction(msg));
      throw Exception(msg);
    } catch (e) {
      if (isView) store.dispatch(DatasErrorAction(e.toString()));
      throw Exception(e);
    }
  };
}
