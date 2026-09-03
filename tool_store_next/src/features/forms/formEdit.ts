import type { FormRow } from '@/types/models'
import type { SaveFormInput } from '@/features/forms/formsApi'
import { ApiParam } from '@/api/params'
import { todayYmd } from '@/auth/roles'

/** Build EDIT DATA FORM payload from current form row + patches. */
export function formEditPayload(
  form: FormRow,
  patch: Partial<SaveFormInput> & { formMilestone?: string },
  userId: string,
): SaveFormInput {
  return {
    param: ApiParam.editForm,
    idForm: form.idForm,
    formNo: form.formNo,
    formServName: form.formServName,
    formCheckBy: form.formCheckBy,
    formDateCheckBy: form.formDateCheckBy,
    formDateServName: form.formDateServName,
    formServComment: form.formServComment,
    formSuperiorAprd: form.formSuperiorAprd,
    formSuperiorComment: form.formSuperiorComment,
    formSadminComment: form.formSadminComment,
    formMilestone: form.formMilestone,
    formStatusOrder: form.formStatusOrder,
    formSheadAprd: form.formSheadAprd,
    formSheadComment: form.formSheadComment,
    fromDateUpdate: todayYmd(),
    formUserUpdate: userId,
    ...patch,
  }
}
