import { formatActionNote } from '@/lib/actionNotes'
import { formatDateDisplay } from '@/lib/dateFormat'
import { formatThousands, parseQtyNumber } from '@/lib/numberFormat'
import type {
  PoRow,
  RcvToolRow,
  RcvWhRow,
  SoRow,
  ToolDetailRow,
} from '@/types/models'

const DIVIDER = '────────────────'
const MAX_ITEMS = 6

export type NotifyMessageRule = {
  step: number
  title: string
  action: string
}

function nonempty(value: string | null | undefined): string {
  const v = (value ?? '').trim()
  if (!v || v === '—' || v === '-') return ''
  return v
}

function field(label: string, value: string | null | undefined): string | null {
  const v = nonempty(value)
  return v ? `${label}: ${v}` : null
}

function linesOf(...parts: Array<string | null | undefined>): string[] {
  return parts.filter((p): p is string => Boolean(p && p.trim()))
}

function joinUnique(values: string[]): string {
  const seen = new Set<string>()
  const out: string[] = []
  for (const raw of values) {
    const v = nonempty(raw)
    if (!v) continue
    const key = v.toLowerCase()
    if (seen.has(key)) continue
    seen.add(key)
    out.push(v)
  }
  return out.join(', ')
}

function sumQty(values: string[]): number {
  return values.reduce((acc, v) => acc + (parseQtyNumber(v) ?? 0), 0)
}

/** Qty Received < Qty Order → Partial Received. Received 0 → empty (omit). */
export function formatReceivedQty(
  receivedQty: number,
  orderQty: number,
  extra?: string,
): string {
  if (receivedQty <= 0) return ''
  let line = formatThousands(receivedQty)
  const extraTrim = nonempty(extra)
  if (extraTrim) line += ` · ${extraTrim}`
  if (orderQty > 0 && receivedQty < orderQty) {
    line += ' (Partial Received)'
  }
  return line
}

/** Full http(s) URL on its own line so WhatsApp opens it in the browser. */
export function formLink(formNo: string): string {
  let base = (
    process.env.APP_BASE_URL ||
    process.env.NEXT_PUBLIC_APP_URL ||
    ''
  )
    .trim()
    .replace(/\/+$/, '')
  const no = formNo.trim()
  if (!base || !no) return ''
  if (!/^https?:\/\//i.test(base)) base = `http://${base}`
  return `${base}/forms?form_no=${encodeURIComponent(no)}`
}

function itemBlock(
  index: number,
  tool: ToolDetailRow,
  related: {
    pos: PoRow[]
    sos: SoRow[]
    whs: RcvWhRow[]
    rooms: RcvToolRow[]
  },
): string {
  const orderQty = parseQtyNumber(tool.qty) ?? 0
  const whQty = sumQty(related.whs.map((r) => r.qty))
  const roomQty = sumQty(related.rooms.map((r) => r.qty))
  const whDates = joinUnique(related.whs.map((r) => formatDateDisplay(r.rcvWhDate)))
  const roomDates = joinUnique(
    related.rooms.map((r) => formatDateDisplay(r.rcvToolDate)),
  )
  const pn = nonempty(tool.pnGroup)
  const title = pn ? `*Item ${index + 1} — ${pn}*` : `*Item ${index + 1}*`

  return linesOf(
    title,
    field('Qty Order', tool.qty.trim() ? formatThousands(tool.qty) : ''),
    field('Description', tool.pnDesc),
    field('Price', formatThousands(tool.partValue)),
    field('Cat / Vendor', tool.valType),
    field('Brand', tool.brand),
    field('Spesifikasi', tool.spesifikasi),
    field('Explanation', tool.explan),
    field('Action note', formatActionNote(tool.actionNote)),
    field('PO', joinUnique(related.pos.map((r) => r.poNo))),
    field('SO/PR', joinUnique(related.sos.map((r) => r.so))),
    field('ETA', joinUnique(related.sos.map((r) => formatDateDisplay(r.eta)))),
    field('Note SO/PR', joinUnique(related.sos.map((r) => r.noteSo))),
    field('Qty WH Received', formatReceivedQty(whQty, orderQty, whDates)),
    field(
      'Qty Tool Room Received',
      formatReceivedQty(roomQty, orderQty, roomDates),
    ),
  ).join('\n')
}

export function buildNotifyMessage(input: {
  rule: NotifyMessageRule
  formNo: string
  formStatusOrder: string
  formCategory: string
  servicemanName: string
  milestone: string
  superiorComment?: string
  sadminComment?: string
  sheadComment?: string
  tools: ToolDetailRow[]
  pos: PoRow[]
  sos: SoRow[]
  whs: RcvWhRow[]
  rooms: RcvToolRow[]
}): string {
  const formNo = nonempty(input.formNo)
  const statusBits = [input.formStatusOrder.trim(), input.formCategory.trim()]
    .filter(Boolean)
    .join(' / ')
  const orderQty = sumQty(input.tools.map((t) => t.qty))
  const whQty = sumQty(input.whs.map((r) => r.qty))
  const roomQty = sumQty(input.rooms.map((r) => r.qty))

  const formLine = formNo
    ? `Form *${formNo}*${statusBits ? `  ·  ${statusBits}` : ''}`
    : statusBits
      ? statusBits
      : null

  const link = formLink(input.formNo)
  const header = [
    `🔧 Tool Store — Step ${input.rule.step}/7`,
    `*${input.rule.title}*`,
    '',
    ...linesOf(
      formLine,
      field('Serviceman', input.servicemanName),
      input.tools.length > 0 ? `Items: *${input.tools.length}*` : null,
      field('Status', input.milestone),
      field('Qty Order', orderQty > 0 ? formatThousands(orderQty) : ''),
    ),
    ...(link ? ['', 'Buka di browser:', link] : []),
    ...linesOf(
      field('Superior', input.superiorComment),
      field('Service Admin', input.sadminComment),
      field('Dept Head', input.sheadComment),
      field('Qty WH Received', formatReceivedQty(whQty, orderQty)),
      field('Qty Tool Room Received', formatReceivedQty(roomQty, orderQty)),
    ),
  ]

  const shown = input.tools.slice(0, MAX_ITEMS)
  const itemBlocks = shown
    .map((tool, i) => {
      const id = tool.idFormDetail
      return itemBlock(i, tool, {
        pos: input.pos.filter((r) => r.idFormDetail === id),
        sos: input.sos.filter((r) => r.idFormDetail === id),
        whs: input.whs.filter((r) => r.idFormDetail === id),
        rooms: input.rooms.filter((r) => r.idFormDetail === id),
      })
    })
    .filter((block) => block.trim())

  const extra =
    input.tools.length > MAX_ITEMS
      ? `+${input.tools.length - MAX_ITEMS} item lain, buka tautan di atas.`
      : ''

  const chunks = [header.join('\n')]
  if (itemBlocks.length) {
    chunks.push(DIVIDER, itemBlocks.join(`\n${DIVIDER}\n`))
  }
  if (extra) chunks.push(DIVIDER, extra)
  chunks.push(DIVIDER, input.rule.action)
  return chunks.join('\n')
}
