<?php
/**
 * Server-side filter for VIEW DATA TOOL / PO / SO / receive rows by parent form.
 *
 * Copy into the PHP backend (e.g. helpers/form_detail_filter.php) and call from
 * each VIEW handler when `id_form` is posted and non-empty.
 */

/**
 * @return array{0: string, 1: array<int, string>} SQL fragment + bind values
 */
function toolstore_form_detail_filter_clause(?string $idForm): array
{
    $id = trim((string) $idForm);
    if ($id === '') {
        return ['', []];
    }
    return [' AND id_form = ? ', [$id]];
}

/**
 * Filter child tables (PO, SO, receive WH/tool) that link via id_form_detail.
 *
 * @return array{0: string, 1: array<int, string>}
 */
function toolstore_form_child_filter_clause(?string $idForm): array
{
    $id = trim((string) $idForm);
    if ($id === '') {
        return ['', []];
    }
    return [
        ' AND id_form_detail IN (SELECT id_form_detail FROM data_form_detail WHERE id_form = ?) ',
        [$id],
    ];
}

/*
 * Example — VIEW DATA TOOL (form/detail endpoint):
 *
 *   $idForm = $_POST['id_form'] ?? $_POST['idForm'] ?? '';
 *   [$formSql, $formBinds] = toolstore_form_detail_filter_clause($idForm);
 *   $sql = 'SELECT * FROM data_form_detail WHERE 1=1' . $formSql;
 *
 * Example — VIEW DATA PO:
 *
 *   [$childSql, $childBinds] = toolstore_form_child_filter_clause($idForm);
 *   $sql = 'SELECT * FROM data_po WHERE 1=1' . $childSql;
 *
 * Ganti nama tabel sesuai environment.
 */
