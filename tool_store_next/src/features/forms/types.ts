export type FormListFilters = {
  page?: number
  limit?: number
  keyword?: string
  searchField?: string
  fromDateUpdate?: string
  toDateUpdate?: string
  formMilestone?: string
  clientFilter?: boolean
  inbox?: string
  milestones?: string
  milestone?: string
}

export type SaveFormInput = {
  param: string
  idForm?: string
  formNo?: string
  formServName?: string
  formCheckBy?: string
  formDateCheckBy?: string
  formDateServName?: string
  formServComment?: string
  formSuperiorAprd?: string
  formSuperiorComment?: string
  formSadminComment?: string
  formMilestone?: string
  formStatusOrder?: string
  formSheadAprd?: string
  formSheadComment?: string
  fromDateUpdate?: string
  formUserUpdate?: string
}
