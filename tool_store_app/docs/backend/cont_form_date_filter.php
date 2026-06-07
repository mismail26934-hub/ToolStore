<?php
/**
 * Helper filter rentang tanggal `from_date_update` untuk VIEW DATA FORM.
 *
 * Endpoint: api_tool/api_toolstore/v1/form
 * Param: VIEW DATA FORM
 *
 * Request body dari Flutter (getDataTool):
 *   from_date_update  YYYY-MM-DD  (wajib jika filter aktif)
 *   to_date_update    YYYY-MM-DD  (opsional; default = from_date_update)
 *
 * ADD/EDIT form: Flutter mengirim from_date_update sebagai nilai kolom,
 * bukan filter — jangan panggil helper ini kecuali param === 'VIEW DATA FORM'.
 */

declare(strict_types=1);

/**
 * @return array{0: string, 1: array<int, string>} [sqlFragment, bindValues]
 */
function toolstore_form_date_filter_clause(?string $from, ?string $to): array
{
    $from = trim((string) $from);
    if ($from === '') {
        return ['', []];
    }

    $to = trim((string) $to);
    if ($to === '') {
        $to = $from;
    }

    if (!preg_match('/^\d{4}-\d{2}-\d{2}$/', $from) ||
        !preg_match('/^\d{4}-\d{2}-\d{2}$/', $to)) {
        return ['', []];
    }

    if ($from > $to) {
        [$from, $to] = [$to, $from];
    }

    return [
        ' AND DATE(from_date_update) >= ? AND DATE(from_date_update) <= ?',
        [$from, $to],
    ];
}

/**
 * Contoh integrasi di FormController / cont_form.php
 *
 * public function viewDataForm(array $post): array
 * {
 *     $page  = max(1, (int) ($post['page'] ?? 1));
 *     $limit = max(1, min(1000, (int) ($post['limit'] ?? 20)));
 *     $offset = ($page - 1) * $limit;
 *
 *     // Keyword search existing (jangan diubah)
 *     [$keywordSql, $keywordBinds] = $this->buildKeywordClause(
 *         $post['keyword'] ?? '',
 *         $post['search_field'] ?? 'all'
 *     );
 *
 *     // Filter tanggal update (baru)
 *     [$dateSql, $dateBinds] = toolstore_form_date_filter_clause(
 *         $post['from_date_update'] ?? '',
 *         $post['to_date_update'] ?? ''
 *     );
 *
 *     $where = ' WHERE 1=1' . $keywordSql . $dateSql;
 *     $binds = array_merge($keywordBinds, $dateBinds);
 *
 *     $countSql = 'SELECT COUNT(*) AS cnt FROM data_form' . $where;
 *     $total = (int) $this->db->fetchColumn($countSql, $binds);
 *
 *     $listSql = 'SELECT * FROM data_form' . $where
 *         . ' ORDER BY from_date_update DESC, id_form DESC'
 *         . ' LIMIT ? OFFSET ?';
 *     $listBinds = array_merge($binds, [$limit, $offset]);
 *     $rows = $this->db->fetchAll($listSql, $listBinds);
 *
 *     return [
 *         'total' => $total,
 *         'data'  => $rows,
 *     ];
 * }
 */
