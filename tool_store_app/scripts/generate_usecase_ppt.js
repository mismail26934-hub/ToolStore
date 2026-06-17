/**
 * Generates Tool Store use case PowerPoint (docs/Tool_Store_Use_Case.pptx).
 * Includes flowchart slides + swimlane diagram (Tool Keeper input → Receive Tool Store).
 * Run: node scripts/generate_usecase_ppt.js
 */
const fs = require('fs');
const path = require('path');
const PptxGenJS = require('pptxgenjs');

const ORANGE = 'FF9800';
const ORANGE_LIGHT = 'FFB84C';
const DARK = '1E1E1E';
const GRAY = '666666';
const WHITE = 'FFFFFF';
const LIGHT_BG = 'F5F5F5';
const BLUE_FILL = 'E3F2FD';
const BLUE_LINE = '2196F3';
const YELLOW_FILL = 'FFF8E1';
const YELLOW_LINE = 'FFC107';
const GREEN_FILL = 'E8F5E9';
const GREEN_LINE = '4CAF50';
const RED_FILL = 'FFEBEE';
const RED_LINE = 'F44336';

const docsDir = path.join(__dirname, '..', 'docs');
const outPath = path.join(docsDir, 'Tool_Store_Use_Case.pptx');

function ensureDir(dir) {
  if (!fs.existsSync(dir)) fs.mkdirSync(dir, { recursive: true });
}

function addHeader(slide, title, pres) {
  slide.addShape(pres.ShapeType.rect, {
    x: 0,
    y: 0,
    w: 10,
    h: 0.9,
    fill: { color: ORANGE },
  });
  slide.addText(title, {
    x: 0.5,
    y: 0.15,
    w: 9,
    h: 0.6,
    fontSize: 24,
    bold: true,
    color: WHITE,
    fontFace: 'Segoe UI',
  });
}

function addFooter(slide) {
  slide.addText('Tool Monitoring App v1.0.0', {
    x: 0.5,
    y: 5.35,
    w: 9,
    h: 0.3,
    fontSize: 9,
    color: GRAY,
    fontFace: 'Segoe UI',
  });
}

function addTableSlide(pres, title, headers, rows, colW) {
  const slide = pres.addSlide();
  addHeader(slide, title, pres);
  const tableRows = [
    headers.map((h) => ({
      text: h,
      options: {
        bold: true,
        fill: { color: ORANGE_LIGHT },
        color: DARK,
        fontSize: 11,
        fontFace: 'Segoe UI',
      },
    })),
    ...rows.map((row) =>
      row.map((cell) => ({
        text: cell,
        options: { fontSize: 10, color: DARK, fontFace: 'Segoe UI' },
      })),
    ),
  ];
  slide.addTable(tableRows, {
    x: 0.4,
    y: 1.1,
    w: 9.2,
    colW: colW || headers.map(() => 9.2 / headers.length),
    border: { type: 'solid', color: 'DDDDDD', pt: 0.5 },
    autoPage: false,
  });
  addFooter(slide);
}

function addFlowText(slide, x, y, w, h, text, fontSize = 8) {
  slide.addText(text, {
    x,
    y,
    w,
    h,
    align: 'center',
    valign: 'mid',
    fontSize,
    color: DARK,
    fontFace: 'Segoe UI',
  });
}

function addFlowTerminator(slide, pres, x, y, w, h, text, fill, line) {
  slide.addShape(pres.ShapeType.flowChartTerminator, {
    x,
    y,
    w,
    h,
    fill: { color: fill || ORANGE_LIGHT },
    line: { color: line || ORANGE, width: 1.2 },
  });
  addFlowText(slide, x, y, w, h, text, 9);
}

function addFlowProcess(slide, pres, x, y, w, h, text, fill, line) {
  slide.addShape(pres.ShapeType.flowChartProcess, {
    x,
    y,
    w,
    h,
    fill: { color: fill || BLUE_FILL },
    line: { color: line || BLUE_LINE, width: 1.2 },
  });
  addFlowText(slide, x, y, w, h, text, 8);
}

function addFlowDecision(slide, pres, x, y, w, h, text) {
  slide.addShape(pres.ShapeType.flowChartDecision, {
    x,
    y,
    w,
    h,
    fill: { color: YELLOW_FILL },
    line: { color: YELLOW_LINE, width: 1.2 },
  });
  addFlowText(slide, x, y + 0.04, w, h - 0.08, text, 7);
}

function addFlowArrowDown(slide, pres, cx, y1, y2, label) {
  if (y2 <= y1) return;
  slide.addShape(pres.ShapeType.line, {
    x: cx,
    y: y1,
    w: 0,
    h: y2 - y1,
    line: { color: GRAY, width: 1.2, endArrowType: 'triangle' },
  });
  if (label) {
    slide.addText(label, {
      x: cx + 0.08,
      y: (y1 + y2) / 2 - 0.12,
      w: 1.4,
      h: 0.22,
      fontSize: 7,
      color: GRAY,
      fontFace: 'Segoe UI',
    });
  }
}

function addFlowArrowRight(slide, pres, x1, y, x2, label) {
  if (x2 <= x1) return;
  slide.addShape(pres.ShapeType.line, {
    x: x1,
    y,
    w: x2 - x1,
    h: 0,
    line: { color: GRAY, width: 1.2, endArrowType: 'triangle' },
  });
  if (label) {
    slide.addText(label, {
      x: (x1 + x2) / 2 - 0.35,
      y: y - 0.28,
      w: 1.0,
      h: 0.2,
      fontSize: 7,
      color: GRAY,
      fontFace: 'Segoe UI',
      align: 'center',
    });
  }
}

function addFlowchartSlide(pres, title, drawFn) {
  const slide = pres.addSlide();
  slide.background = { color: WHITE };
  addHeader(slide, title, pres);
  drawFn(slide, pres);
  addFooter(slide);
  return slide;
}

function addFlowchartStartupLogin(pres) {
  addFlowchartSlide(pres, 'Flowchart — Startup & Login', (slide, pres) => {
    const cx = 4.0;
    const bw = 2.2;
    let y = 1.05;
    const gap = 0.28;
    const hTerm = 0.42;
    const hProc = 0.48;
    const hDec = 0.72;

    addFlowTerminator(slide, pres, cx, y, bw, hTerm, 'Mulai App');
    y += hTerm + gap;
    addFlowArrowDown(slide, pres, cx + bw / 2, y - gap, y);
    addFlowProcess(slide, pres, cx, y, bw, hProc, 'Splash Screen');
    y += hProc + gap;
    addFlowArrowDown(slide, pres, cx + bw / 2, y - gap, y);
    addFlowDecision(slide, pres, cx - 0.15, y, bw + 0.3, hDec, 'Sesi login\nmasih valid?');
    y += hDec + gap;

    const noX = 1.0;
    const yesX = 6.8;
    addFlowArrowRight(slide, pres, cx + bw / 2, y - gap - 0.15, noX + bw, 'Tidak');
    addFlowArrowRight(slide, pres, cx + bw / 2, y - gap + 0.15, yesX + bw / 2, 'Ya');

    addFlowProcess(slide, pres, noX, y, bw, hProc, 'Halaman Login');
    addFlowProcess(slide, pres, yesX, y, bw, hProc, 'Preload data\n+ sync FCM');

    const loginY = y + hProc + gap;
    addFlowArrowDown(slide, pres, noX + bw / 2, y + hProc, loginY);
    addFlowDecision(slide, pres, noX - 0.15, loginY, bw + 0.3, hDec, 'Login\nberhasil?');
    addFlowArrowRight(slide, pres, noX + bw / 2, loginY + hDec / 2, yesX + bw / 2, 'Ya');
    addFlowProcess(slide, pres, noX - 0.5, loginY + hDec + gap, 1.6, 0.38, 'Tampilkan error', RED_FILL, RED_LINE);

    const deepY = loginY + hDec + gap + 0.1;
    addFlowArrowDown(slide, pres, yesX + bw / 2, y + hProc, deepY);
    addFlowDecision(slide, pres, yesX - 0.15, deepY, bw + 0.3, hDec, 'Ada deep link\nformNo?');

    const dashY = deepY + hDec + gap;
    addFlowArrowRight(slide, pres, yesX + bw / 2, deepY + hDec / 2, cx + bw / 2, 'Tidak');
    addFlowProcess(slide, pres, cx - 0.4, dashY, 1.5, 0.42, 'Dashboard');
    addFlowProcess(slide, pres, yesX - 0.1, dashY, bw + 0.2, 0.42, 'Buka form\ntarget');
    addFlowArrowDown(slide, pres, yesX + bw / 2, deepY + hDec, dashY, 'Ya');

    addFlowTerminator(slide, pres, cx + 2.6, dashY + 0.55, 1.6, 0.38, 'Selesai', GREEN_FILL, GREEN_LINE);
    addFlowArrowRight(slide, pres, cx + 1.1, dashY + 0.21, cx + 2.6);
    addFlowArrowRight(slide, pres, yesX + bw, dashY + 0.21, cx + 2.6);
  });
}

function addFlowchartToolRequest(pres) {
  addFlowchartSlide(pres, 'Flowchart — Alur Permintaan Tool', (slide, pres) => {
    const lx = 0.35;
    const lw = 2.05;
    const rx = 7.0;
    const rw = 2.05;
    let y = 1.05;
    const g = 0.22;
    const hp = 0.4;
    const hd = 0.62;

    const steps = [
      'DRAFT\n(TOOL_KEEPER)',
      'Submit Request\n(SERVICE_ADMIN)',
      'CHECK BY\nTOOL STORE',
      'Validasi Superior\n(SUPERIOR)',
    ];
    steps.forEach((t, i) => {
      addFlowProcess(slide, pres, lx, y, lw, hp, t);
      if (i > 0) addFlowArrowDown(slide, pres, lx + lw / 2, y - g, y);
      y += hp + g;
    });

    addFlowDecision(slide, pres, lx - 0.1, y, lw + 0.2, hd, 'Approved?');
    addFlowArrowDown(slide, pres, lx + lw / 2, y - g, y);
    y += hd + g;
    addFlowProcess(slide, pres, rx, y - hd - g - hp, rw, hp, 'REJECTED\nBY SUPERIOR', RED_FILL, RED_LINE);
    addFlowArrowRight(slide, pres, lx + lw, y - hd - g - hp / 2, rx, 'Tidak');

    addFlowProcess(slide, pres, lx, y, lw, hp, 'SUPERIOR\nAPPROVED');
    addFlowArrowDown(slide, pres, lx + lw / 2, y - g, y, 'Ya');
    y += hp + g;
    addFlowProcess(slide, pres, lx, y, lw, hp, 'Review Service Admin');
    y += hp + g;
    addFlowArrowDown(slide, pres, lx + lw / 2, y - g, y);
    addFlowDecision(slide, pres, lx - 0.1, y, lw + 0.2, hd, 'Continue\n/ Hold?');
    y += hd + g;
    addFlowProcess(slide, pres, rx, y - hd - g - hp, rw, hp, 'HOLD BY\nSERVICE ADMIN', RED_FILL, RED_LINE);
    addFlowArrowRight(slide, pres, lx + lw, y - hd - g - hp / 2, rx, 'Hold');
    addFlowProcess(slide, pres, lx, y, lw, hp, 'REVIEWED BY\nSERVICE ADMIN');
    addFlowArrowDown(slide, pres, lx + lw / 2, y - g, y, 'Continue');
    y += hp + g;
    addFlowProcess(slide, pres, lx, y, lw, hp, 'Approval\nDept Head');
    y += hp + g;
    addFlowArrowDown(slide, pres, lx + lw / 2, y - g, y);
    addFlowDecision(slide, pres, lx - 0.1, y, lw + 0.2, hd, 'Approved?');
    y += hd + g;
    addFlowProcess(slide, pres, rx, y - hd - g - hp, rw, hp, 'REJECTED\nBY DEPT HEAD', RED_FILL, RED_LINE);
    addFlowArrowRight(slide, pres, lx + lw, y - hd - g - hp / 2, rx, 'Tidak');

    const mx = 3.35;
    const mw = 2.4;
    let my = 1.05;
    addFlowProcess(slide, pres, mx, my, mw, hp, 'APPROVED BY\nDEPT HEAD');
    addFlowArrowRight(slide, pres, lx + lw, y - g - hd / 2, mx, 'Ya');
    my += hp + g;
    addFlowArrowDown(slide, pres, mx + mw / 2, my - g, my);
    addFlowProcess(slide, pres, mx, my, mw, hp, 'PROCESSING ORDER');
    my += hp + g;
    addFlowArrowDown(slide, pres, mx + mw / 2, my - g, my);
    addFlowProcess(slide, pres, mx, my, mw, hp, 'Kelola PO\n(TOOL_KEEPER)');
    my += hp + g;
    addFlowArrowDown(slide, pres, mx + mw / 2, my - g, my);
    addFlowProcess(slide, pres, mx, my, mw, hp, 'Kelola SO/PR\n(COUNTER/GA)');
    my += hp + g;
    addFlowArrowDown(slide, pres, mx + mw / 2, my - g, my);
    addFlowProcess(slide, pres, mx, my, mw, hp, 'WH Received\n(WH)');
    my += hp + g;
    addFlowArrowDown(slide, pres, mx + mw / 2, my - g, my);
    addFlowProcess(slide, pres, mx, my, mw, hp, 'Tool Room Received\n(TOOL_KEEPER)');
    my += hp + g;
    addFlowArrowDown(slide, pres, mx + mw / 2, my - g, my);
    addFlowTerminator(slide, pres, mx + 0.35, my, mw - 0.7, 0.38, 'RECEIVED\nTOOL STORE', GREEN_FILL, GREEN_LINE);
  });
}

function addFlowchartPoSoWh(pres) {
  addFlowchartSlide(pres, 'Flowchart — PO, SO & Penerimaan', (slide, pres) => {
    const cols = [
      { x: 0.35, title: 'Tahap PO', steps: ['Dept Head\nApproved', 'Input PO\n(TOOL_KEEPER)'] },
      { x: 2.55, title: 'Tahap SO/PR', steps: ['Belum ada\nWH Received?', 'Input SO/PR\n(COUNTER/GA)'] },
      { x: 4.75, title: 'Tahap WH', steps: ['Belum ada\nTool Room?', 'WH Received\n(WH)'] },
      { x: 6.95, title: 'Tahap Tool Room', steps: ['Tool Room\nReceived', 'Semua item\nditerima?'] },
    ];
    const bw = 1.85;
    const hp = 0.55;
    const hd = 0.65;
    const g = 0.35;

    cols.forEach((col, ci) => {
      slide.addText(col.title, {
        x: col.x,
        y: 1.05,
        w: bw,
        h: 0.3,
        fontSize: 10,
        bold: true,
        color: ORANGE,
        fontFace: 'Segoe UI',
        align: 'center',
      });
      let y = 1.45;
      col.steps.forEach((step, si) => {
        if (si === 1 && ci > 0) {
          addFlowDecision(slide, pres, col.x, y, bw, hd, step);
          y += hd + g;
        } else if (si === 1 && ci === 3) {
          addFlowDecision(slide, pres, col.x, y, bw, hd, step);
          y += hd + g;
          addFlowProcess(slide, pres, col.x - 0.1, y, bw + 0.2, 0.42, 'PARTIAL RECEIVED', YELLOW_FILL, YELLOW_LINE);
          addFlowProcess(slide, pres, col.x - 0.1, y + 0.5, bw + 0.2, 0.42, 'RECEIVED TOOL STORE', GREEN_FILL, GREEN_LINE);
          addFlowArrowRight(slide, pres, col.x + bw / 2 + 0.5, y + 0.21, col.x + bw + 0.6, 'Ya');
          addFlowArrowRight(slide, pres, col.x + bw / 2 - 0.5, y + 0.21, col.x - 0.1, 'Tidak');
        } else {
          addFlowProcess(slide, pres, col.x, y, bw, hp, step);
          y += hp + g;
        }
        if (si === 0) addFlowArrowDown(slide, pres, col.x + bw / 2, y - g, y);
      });
      if (ci < cols.length - 1) {
        addFlowArrowRight(slide, pres, col.x + bw, 2.15, cols[ci + 1].x);
      }
    });

    slide.addText('Aturan: PO → sebelum SO | SO → sebelum WH | WH → sebelum Tool Room', {
      x: 0.4,
      y: 4.85,
      w: 9.2,
      h: 0.35,
      fontSize: 9,
      italic: true,
      color: GRAY,
      fontFace: 'Segoe UI',
      align: 'center',
    });
  });
}

function addFlowchartUserAccess(pres) {
  addFlowchartSlide(pres, 'Flowchart — Akses Menu User', (slide, pres) => {
    const cx = 3.9;
    const bw = 2.2;
    let y = 1.2;
    const g = 0.3;
    const hp = 0.48;
    const hd = 0.72;

    addFlowTerminator(slide, pres, cx, y, bw, 0.4, 'User buka Drawer');
    y += 0.4 + g;
    addFlowArrowDown(slide, pres, cx + bw / 2, y - g, y);
    addFlowDecision(slide, pres, cx - 0.15, y, bw + 0.3, hd, 'Level =\nSUPERADMIN?');
    y += hd + g;
    addFlowArrowRight(slide, pres, cx + bw / 2, y - g - 0.1, 7.2 + bw / 2, 'Ya');
    addFlowArrowRight(slide, pres, cx + bw / 2, y - g + 0.1, 1.0 + bw / 2, 'Tidak');
    addFlowProcess(slide, pres, 1.0, y, bw, hp, 'Akses ditolak\n(SnackBar)', RED_FILL, RED_LINE);
    addFlowProcess(slide, pres, 7.2, y, bw, hp, 'Tampilkan\nmenu User');
    y += hp + g;
    addFlowArrowDown(slide, pres, 7.2 + bw / 2, y - g, y);
    addFlowProcess(slide, pres, 7.2, y, bw, hp, 'CRUD User');
    y += hp + g;
    addFlowArrowDown(slide, pres, 7.2 + bw / 2, y - g, y);
    addFlowTerminator(slide, pres, 7.35, y, bw - 0.3, 0.4, 'Tambah / Edit\n/ Hapus / Cari', GREEN_FILL, GREEN_LINE);
  });
}

function addFlowchartNotification(pres) {
  addFlowchartSlide(pres, 'Flowchart — Notifikasi & Deep Link', (slide, pres) => {
    const cx = 3.9;
    const bw = 2.3;
    let y = 1.15;
    const g = 0.28;
    const hp = 0.48;
    const hd = 0.68;

    addFlowTerminator(slide, pres, cx, y, bw, 0.42, 'Push Notif / URL');
    y += 0.42 + g;
    addFlowArrowDown(slide, pres, cx + bw / 2, y - g, y);
    addFlowDecision(slide, pres, cx - 0.15, y, bw + 0.3, hd, 'User sudah\nlogin?');
    y += hd + g;

    addFlowProcess(slide, pres, 0.8, y, 2.0, hp, 'Simpan formNo\npending');
    addFlowProcess(slide, pres, 6.9, y, 2.0, hp, 'Langsung buka\nform target');
    addFlowArrowRight(slide, pres, cx + bw / 2, y - g - 0.12, 0.8 + 2.0, 'Tidak');
    addFlowArrowRight(slide, pres, cx + bw / 2, y - g + 0.12, 6.9 + 1.0, 'Ya');

    const loginY = y + hp + g;
    addFlowArrowDown(slide, pres, 0.8 + 1.0, y + hp, loginY);
    addFlowProcess(slide, pres, 0.8, loginY, 2.0, hp, 'Login');

    const openY = loginY + hp + g + 0.15;
    addFlowArrowDown(slide, pres, 0.8 + 1.0, loginY + hp, openY);
    addFlowArrowDown(slide, pres, 6.9 + 1.0, y + hp, openY + hp / 2);
    addFlowProcess(slide, pres, cx - 0.1, openY, bw + 0.2, hp, 'Buka form target');
    const openY2 = openY + hp + g;
    addFlowArrowDown(slide, pres, cx + bw / 2, openY + hp, openY2);
    addFlowTerminator(slide, pres, cx + 0.1, openY2, bw - 0.2, 0.42, 'Expand & tampilkan\ndetail form', GREEN_FILL, GREEN_LINE);
  });
}

function addFlowInput(slide, pres, x, y, w, h, text) {
  slide.addShape(pres.ShapeType.flowChartInputOutput, {
    x,
    y,
    w,
    h,
    fill: { color: 'E8EAF6' },
    line: { color: '5C6BC0', width: 1.2 },
  });
  addFlowText(slide, x, y, w, h, text, 7);
}

function addSwimlaneColumn(slide, pres, x, w, topY, laneH, title, bg) {
  slide.addShape(pres.ShapeType.rect, {
    x,
    y: topY,
    w,
    h: laneH,
    fill: { color: bg },
    line: { color: 'BBBBBB', width: 0.75 },
  });
  slide.addShape(pres.ShapeType.rect, {
    x,
    y: topY,
    w,
    h: 0.42,
    fill: { color: ORANGE },
    line: { color: ORANGE, width: 0.5 },
  });
  slide.addText(title, {
    x,
    y: topY + 0.04,
    w,
    h: 0.36,
    fontSize: 7,
    bold: true,
    align: 'center',
    color: WHITE,
    fontFace: 'Segoe UI',
  });
}

function laneBoxX(laneX, laneW, boxW) {
  return laneX + (laneW - boxW) / 2;
}

function connectLaneRight(slide, pres, fromX, fromY, fromW, fromH, toX, toY, toH) {
  slide.addShape(pres.ShapeType.line, {
    x: fromX + fromW,
    y: fromY + fromH / 2,
    w: toX - (fromX + fromW),
    h: (toY + toH / 2) - (fromY + fromH / 2),
    line: { color: GRAY, width: 1.2, endArrowType: 'triangle' },
  });
}

function connectLaneDown(slide, pres, cx, y1, boxH1, y2) {
  addFlowArrowDown(slide, pres, cx, y1 + boxH1, y2);
}

/**
 * Swimlane process: Tool Keeper input data tool → approval chain → PO/SO/WH → Receive Tool Store.
 * Style inspired by multi-column swimlane diagrams (Flow Maker / draw.io).
 */
function addFlowchartToolKeeperProcessSwimlane(pres) {
  addFlowchartSlide(
    pres,
    'Diagram Proses — Input Tool Keeper s/d Receive Tool Store',
    (slide, pres) => {
      const topY = 1.05;
      const laneH = 4.2;
      const startX = 0.12;
      const totalW = 9.76;
      const laneCount = 6;
      const laneW = totalW / laneCount;
      const bw = laneW - 0.14;
      const hp = 0.38;
      const hi = 0.42;
      const hd = 0.58;
      const ht = 0.34;
      const vg = 0.14;

      const lanes = [
        { title: 'Tool Keeper\n(Input Data)', bg: 'FFF3E0' },
        { title: 'Service Admin', bg: 'E3F2FD' },
        { title: 'Superior /\nHead Service', bg: 'F3E5F5' },
        { title: 'Tool Keeper\n(PO)', bg: 'FFF3E0' },
        { title: 'Counter/GA\n& WH', bg: 'E0F7FA' },
        { title: 'Tool Keeper\n(Receive)', bg: 'FFE0B2' },
      ];

      lanes.forEach((lane, i) => {
        addSwimlaneColumn(slide, pres, startX + i * laneW, laneW, topY, laneH, lane.title, lane.bg);
      });

      const y0 = topY + 0.55;
      const lx = (i) => startX + i * laneW;
      const bx = (i) => laneBoxX(lx(i), laneW, bw);
      const cx = (i) => bx(i) + bw / 2;

      // Lane 0 — Tool Keeper Input
      let y = y0;
      addFlowTerminator(slide, pres, bx(0), y, bw, ht, 'Mulai');
      y += ht + vg;
      connectLaneDown(slide, pres, cx(0), y - vg - ht, y - vg);
      addFlowProcess(slide, pres, bx(0), y, bw, hp, 'Login');
      y += hp + vg;
      connectLaneDown(slide, pres, cx(0), y - vg - hp, y - vg);
      addFlowInput(slide, pres, bx(0), y, bw, hi, 'Input Form\nTool');
      y += hi + vg;
      connectLaneDown(slide, pres, cx(0), y - vg - hi, y - vg);
      addFlowInput(slide, pres, bx(0), y, bw, hi, 'Tambah Item\nTool');
      y += hi + vg;
      connectLaneDown(slide, pres, cx(0), y - vg - hi, y - vg);
      addFlowProcess(slide, pres, bx(0), y, bw, hp, 'Simpan\n(DRAFT)');
      const tkDraftY = y;

      // Lane 1 — Service Admin
      y = y0 + 0.55;
      addFlowProcess(slide, pres, bx(1), y, bw, hp, 'Submit Request\nOrder');
      y += hp + vg;
      connectLaneDown(slide, pres, cx(1), y - vg - hp, y - vg);
      addFlowProcess(slide, pres, bx(1), y, bw, hp, 'CHECK BY\nTOOL STORE');
      y += hp + vg;
      connectLaneDown(slide, pres, cx(1), y - vg - hp, y - vg);
      addFlowDecision(slide, pres, bx(1), y, bw, hd, 'Review\nContinue?');
      const saReviewY = y;

      // Lane 2 — Superior / Head Service
      y = y0 + 0.35;
      addFlowDecision(slide, pres, bx(2), y, bw, hd, 'Validasi\nSuperior?');
      y += hd + vg;
      connectLaneDown(slide, pres, cx(2), y - vg - hd, y - vg);
      addFlowProcess(slide, pres, bx(2), y, bw, hp, 'SUPERIOR\nAPPROVED');
      y += hp + vg;
      connectLaneDown(slide, pres, cx(2), y - vg - hp, y - vg);
      addFlowDecision(slide, pres, bx(2), y, bw, hd, 'Approval\nDept Head?');
      y += hd + vg;
      connectLaneDown(slide, pres, cx(2), y - vg - hd, y - vg);
      addFlowProcess(slide, pres, bx(2), y, bw, hp, 'APPROVED BY\nDEPT HEAD');
      const headDoneY = y;

      // Lane 3 — Tool Keeper PO
      y = y0 + 1.0;
      addFlowInput(slide, pres, bx(3), y, bw, hi, 'Input PO\n(Purchase Order)');
      y += hi + vg;
      connectLaneDown(slide, pres, cx(3), y - vg - hi, y - vg);
      addFlowProcess(slide, pres, bx(3), y, bw, hp, 'Simpan PO');
      const poY = y;

      // Lane 4 — Counter/GA & WH
      y = y0 + 0.55;
      addFlowInput(slide, pres, bx(4), y, bw, hi, 'Input SO/PR\n(Counter/GA)');
      y += hi + vg;
      connectLaneDown(slide, pres, cx(4), y - vg - hi, y - vg);
      addFlowProcess(slide, pres, bx(4), y, bw, hp, 'Simpan SO');
      y += hp + vg + 0.12;
      connectLaneDown(slide, pres, cx(4), y - vg - 0.12 - hp, y - vg);
      addFlowInput(slide, pres, bx(4), y, bw, hi, 'WH Received\n(WH)');
      y += hi + vg;
      connectLaneDown(slide, pres, cx(4), y - vg - hi, y - vg);
      addFlowProcess(slide, pres, bx(4), y, bw, hp, 'Simpan WH');
      const whY = y;

      // Lane 5 — Tool Keeper Receive
      y = y0 + 0.55;
      addFlowInput(slide, pres, bx(5), y, bw, hi, 'Tool Room\nReceived');
      y += hi + vg;
      connectLaneDown(slide, pres, cx(5), y - vg - hi, y - vg);
      addFlowProcess(slide, pres, bx(5), y, bw, hp, 'Simpan\nPenerimaan');
      y += hp + vg;
      connectLaneDown(slide, pres, cx(5), y - vg - hp, y - vg);
      addFlowTerminator(
        slide,
        pres,
        bx(5),
        y,
        bw,
        ht,
        'RECEIVED\nTOOL STORE',
        GREEN_FILL,
        GREEN_LINE,
      );
      y += ht + vg;
      connectLaneDown(slide, pres, cx(5), y - vg - ht, y - vg);
      addFlowTerminator(slide, pres, bx(5), y, bw, ht, 'Selesai', GREEN_FILL, GREEN_LINE);

      // Cross-lane connectors (left → right)
      connectLaneRight(slide, pres, bx(0), tkDraftY, bw, hp, bx(1), y0 + 0.55 + hp / 2, hp);
      connectLaneRight(
        slide,
        pres,
        bx(1),
        y0 + 0.55 + hp + vg,
        bw,
        hp,
        bx(2),
        y0 + 0.35 + hd / 2,
        hd,
      );
      connectLaneRight(slide, pres, bx(2), headDoneY, bw, hp, bx(3), y0 + 1.0 + hi / 2, hi);
      connectLaneRight(slide, pres, bx(3), poY, bw, hp, bx(4), y0 + 0.55 + hi / 2, hi);
      connectLaneRight(slide, pres, bx(4), whY, bw, hp, bx(5), y0 + 0.55 + hi / 2, hi);

      // SA review connector (vertical within approval chain)
      connectLaneRight(
        slide,
        pres,
        bx(2),
        y0 + 0.35 + hd + vg + hp / 2,
        bw,
        hp,
        bx(1),
        saReviewY + hd / 2,
        hd,
      );

      slide.addText(
        'Alur end-to-end: Tool Keeper input data → persetujuan berjenjang → PO → SO/PR → WH → Tool Keeper terima di Tool Store',
        {
          x: 0.2,
          y: 5.05,
          w: 9.6,
          h: 0.28,
          fontSize: 8,
          italic: true,
          color: GRAY,
          fontFace: 'Segoe UI',
          align: 'center',
        },
      );
    },
  );
}

function addAllFlowchartSlides(pres) {
  addFlowchartStartupLogin(pres);
  addFlowchartToolRequest(pres);
  addFlowchartPoSoWh(pres);
  addFlowchartUserAccess(pres);
  addFlowchartNotification(pres);
  addFlowchartToolKeeperProcessSwimlane(pres);
}

function addBulletSlide(pres, title, bullets, subBullets) {
  const slide = pres.addSlide();
  addHeader(slide, title, pres);
  const items = bullets.map((b) => ({
    text: b,
    options: { bullet: true, fontSize: 16, color: DARK, fontFace: 'Segoe UI', breakLine: true },
  }));
  slide.addText(items, { x: 0.6, y: 1.2, w: 8.8, h: 4, valign: 'top' });
  if (subBullets && subBullets.length) {
    slide.addText(
      subBullets.map((b) => ({
        text: b,
        options: { bullet: { indent: 20 }, fontSize: 13, color: GRAY, fontFace: 'Segoe UI', breakLine: true },
      })),
      { x: 0.9, y: 3.2, w: 8.5, h: 2, valign: 'top' },
    );
  }
  addFooter(slide);
}

async function main() {
  ensureDir(docsDir);
  const pres = new PptxGenJS();
  pres.layout = 'LAYOUT_16x9';
  pres.author = 'Tool Store App';
  pres.title = 'Use Case Aplikasi Tool Store / Tool Monitoring';
  pres.subject = 'Dokumentasi Kebutuhan Fungsional';

  // Slide 1 — Cover
  {
    const slide = pres.addSlide();
    slide.background = { color: ORANGE };
    slide.addShape(pres.ShapeType.rect, {
      x: 0,
      y: 4.2,
      w: 10,
      h: 1.425,
      fill: { color: DARK, transparency: 15 },
    });
    slide.addText('Use Case Aplikasi', {
      x: 0.5,
      y: 1.4,
      w: 9,
      h: 0.8,
      fontSize: 36,
      bold: true,
      color: WHITE,
      fontFace: 'Segoe UI',
    });
    slide.addText('Tool Store / Tool Monitoring', {
      x: 0.5,
      y: 2.2,
      w: 9,
      h: 0.7,
      fontSize: 28,
      color: WHITE,
      fontFace: 'Segoe UI',
    });
    slide.addText('Dokumentasi Kebutuhan Fungsional', {
      x: 0.5,
      y: 3.0,
      w: 9,
      h: 0.5,
      fontSize: 18,
      color: WHITE,
      fontFace: 'Segoe UI',
    });
    slide.addText('Versi 1.0.0  |  Juni 2026', {
      x: 0.5,
      y: 4.6,
      w: 9,
      h: 0.4,
      fontSize: 14,
      color: WHITE,
      fontFace: 'Segoe UI',
    });
  }

  addBulletSlide(pres, 'Latar Belakang', [
    'Aplikasi mobile/web (Flutter) untuk monitoring permintaan tool',
    'Mengelola alur dari draft hingga diterima di Tool Store',
    'Terintegrasi dengan backend REST API (api_toolstore/v1)',
    'Multi-role dengan hak akses berbeda per level user',
    'Fitur: push notification (FCM), deep link, export Excel',
  ]);

  addTableSlide(
    pres,
    'Ruang Lingkup Sistem',
    ['In Scope', 'Out of Scope'],
    [
      ['Login, dashboard, data tool', 'Backend admin panel terpisah'],
      ['Workflow approval berjenjang', 'Integrasi ERP eksternal'],
      ['PO, SO, penerimaan WH & Tool Room', ''],
      ['Manajemen user (Superadmin)', ''],
      ['Export Excel, notifikasi, deep link', ''],
    ],
    [4.6, 4.6],
  );

  addTableSlide(
    pres,
    'Aktor (Pengguna)',
    ['Aktor', 'Peran Singkat'],
    [
      ['Guest', 'Belum login; hanya bisa login'],
      ['User', 'Akses umum setelah login'],
      ['MECHANIC', 'Serviceman yang terkait pada form permintaan'],
      ['TOOL_KEEPER', 'PO, item tool, penerimaan Tool Room'],
      ['SUPERIOR', 'Menyetujui/menolak permintaan bawahan'],
      ['SERVICE_ADMIN', 'Review Service Support (Continue/Hold)'],
      ['HEAD_SERVICE', 'Persetujuan Kepala Departemen'],
      ['COUNTER / GA', 'Mengelola Sales Order / PR'],
      ['WH', 'Mencatat penerimaan Warehouse'],
      ['SUPERADMIN', 'Akses penuh + manajemen user'],
    ],
    [2.2, 7.0],
  );

  addBulletSlide(
    pres,
    'Paket Use Case (Tingkat Tinggi)',
    [
      '1. Autentikasi & Profil — Login, logout, edit profil, cek sesi',
      '2. Monitoring — Dashboard, cari form, daftar & timeline',
      '3. Workflow Permintaan Tool — Form, approval, PO/SO, penerimaan',
      '4. Administrasi — Manajemen user, export Excel',
      '5. Integrasi Sistem — Push notification, deep link, tema/bahasa',
    ],
  );

  addBulletSlide(
    pres,
    'Alur Proses (Milestone)',
    [
      'DRAFT',
      'CHECK BY TOOL STORE',
      'SUPERIOR APPROVED  /  REJECTED BY SUPERIOR',
      'REVIEWED BY SERVICE ADMIN  /  HOLD BY SERVICE ADMIN',
      'APPROVED BY SERVICE DEPT. HEAD  /  REJECTED BY SERVICE DEPT. HEAD',
      'PROCESSING ORDER  /  ORDER PROCESSED',
      'RECEIVED BY WH/GA (Full / Partial)',
      'RECEIVED TOOL STORE (Full / Partial)',
    ],
    ['Status khusus: DRAFT, HOLD, REJECTED, PARTIAL RECEIVED'],
  );

  addAllFlowchartSlides(pres);

  addTableSlide(
    pres,
    'Use Case — Autentikasi & Sesi',
    ['ID', 'Use Case', 'Aktor'],
    [
      ['UC-01', 'Login', 'Guest, Semua user'],
      ['UC-02', 'Logout', 'Semua user'],
      ['UC-03', 'Cek sesi otomatis (Splash)', 'Sistem'],
      ['UC-04', 'Edit profil sendiri', 'User login'],
    ],
    [1.0, 4.5, 3.7],
  );

  addTableSlide(
    pres,
    'Use Case — Dashboard & Navigasi',
    ['ID', 'Use Case', 'Aktor'],
    [
      ['UC-05', 'Lihat dashboard (jumlah per tahap)', 'User login'],
      ['UC-06', 'Filter form dari kartu dashboard', 'User login'],
      ['UC-07', 'Cari form tool', 'User login'],
      ['UC-08', 'Navigasi menu drawer', 'User login'],
      ['UC-09', 'Ubah tema dark/light', 'User login'],
      ['UC-10', 'Ubah bahasa ID/EN', 'User login'],
    ],
    [1.0, 5.5, 2.7],
  );

  addTableSlide(
    pres,
    'Use Case — Data Tool (Monitoring)',
    ['ID', 'Use Case', 'Aktor'],
    [
      ['UC-11', 'Lihat daftar form tool', 'User login'],
      ['UC-12', 'Filter & pencarian multi-field', 'User login'],
      ['UC-13', 'Lihat detail form (expand card)', 'User login'],
      ['UC-14', 'Lihat timeline order (7 langkah)', 'User login'],
      ['UC-15', 'Export data ke Excel (.xlsx)', 'User login'],
    ],
    [1.0, 5.5, 2.7],
  );

  addTableSlide(
    pres,
    'Use Case — Form Permintaan Tool',
    ['ID', 'Use Case', 'Aktor', 'Keterangan'],
    [
      ['UC-16', 'Buat form baru', 'TOOL_KEEPER, SUPERADMIN', 'Milestone DRAFT'],
      ['UC-17', 'Edit form', 'TOOL_KEEPER, SUPERADMIN', ''],
      ['UC-18', 'Hapus form', 'TOOL_KEEPER, SUPERADMIN', ''],
      ['UC-19', 'Tambah item tool', 'TOOL_KEEPER, SUPERADMIN', ''],
      ['UC-20', 'Edit/hapus item tool', 'TOOL_KEEPER, SUPERADMIN', ''],
    ],
    [0.9, 2.8, 2.8, 2.7],
  );

  addTableSlide(
    pres,
    'Use Case — Workflow Persetujuan',
    ['ID', 'Use Case', 'Aktor', 'Milestone'],
    [
      ['UC-21', 'Submit request order', 'SERVICE_ADMIN, SUPERADMIN', 'DRAFT → CHECK BY TOOL STORE'],
      ['UC-22', 'Validasi superior', 'SUPERIOR*, SUPERADMIN', 'CHECK BY TOOL STORE'],
      ['UC-23', 'Review service admin', 'SERVICE_ADMIN, SUPERADMIN', 'SUPERIOR APPROVED / HOLD'],
      ['UC-24', 'Approval dept head', 'HEAD_SERVICE, SUPERADMIN', 'REVIEWED BY SERVICE ADMIN'],
    ],
    [0.9, 2.5, 2.5, 3.3],
  );

  addTableSlide(
    pres,
    'Use Case — Pemrosesan Order',
    ['ID', 'Use Case', 'Aktor', 'Keterangan'],
    [
      ['UC-25', 'Kelola Purchase Order (PO)', 'TOOL_KEEPER, SUPERADMIN', 'Sebelum ada SO'],
      ['UC-26', 'Kelola Sales Order / PR (SO)', 'COUNTER, GA, SUPERADMIN', 'Sebelum WH received'],
      ['UC-27', 'Catat penerimaan WH', 'WH, SUPERADMIN', 'Sebelum Tool Room'],
      ['UC-28', 'Catat penerimaan Tool Room', 'TOOL_KEEPER, SUPERADMIN', '→ RECEIVED TOOL STORE'],
    ],
    [0.9, 2.8, 2.8, 2.7],
  );

  addTableSlide(
    pres,
    'Use Case — Manajemen User',
    ['ID', 'Use Case', 'Aktor'],
    [
      ['UC-29', 'Lihat daftar user', 'SUPERADMIN'],
      ['UC-30', 'Tambah user', 'SUPERADMIN'],
      ['UC-31', 'Edit user', 'SUPERADMIN'],
      ['UC-32', 'Hapus user', 'SUPERADMIN'],
      ['UC-33', 'Cari user', 'SUPERADMIN'],
    ],
    [1.0, 5.5, 2.7],
  );

  addTableSlide(
    pres,
    'Use Case — Integrasi Sistem',
    ['ID', 'Use Case', 'Aktor'],
    [
      ['UC-34', 'Terima notifikasi push (FCM)', 'User login'],
      ['UC-35', 'Buka form via deep link', 'User / Guest'],
      ['UC-36', 'Bagikan link form', 'User login'],
    ],
    [1.0, 5.5, 2.7],
  );

  addTableSlide(
    pres,
    'Matriks Hak Akses (Ringkas)',
    ['Use Case', 'TK', 'SA', 'SUP', 'HS', 'C/GA', 'WH', 'SADM'],
    [
      ['Buat/Edit Form', '✓', '', '', '', '', '', '✓'],
      ['Submit Request', '', '✓', '', '', '', '', '✓'],
      ['Validasi Superior', '', '', '✓*', '', '', '', '✓'],
      ['Review Service Admin', '', '✓', '', '', '', '', '✓'],
      ['Approval Dept Head', '', '', '', '✓', '', '', '✓'],
      ['Kelola PO', '✓', '', '', '', '', '', '✓'],
      ['Kelola SO', '', '', '', '', '✓', '', '✓'],
      ['WH Received', '', '', '', '', '', '✓', '✓'],
      ['Tool Room Received', '✓', '', '', '', '', '', '✓'],
      ['Manajemen User', '', '', '', '', '', '', '✓'],
    ],
    [2.4, 0.8, 0.8, 0.8, 0.8, 0.9, 0.8, 0.9],
  );

  {
    const slide = pres.addSlide();
    addHeader(slide, 'Contoh: UC-22 Validasi Superior', pres);
    const blocks = [
      { text: 'Aktor utama: SUPERIOR  |  Aktor pendukung: Sistem API\n', options: { bold: true, fontSize: 13, color: DARK, fontFace: 'Segoe UI', breakLine: true } },
      { text: 'Precondition:\n', options: { bold: true, fontSize: 12, color: ORANGE, fontFace: 'Segoe UI', breakLine: true } },
      { text: '• User sudah login\n• Form di milestone CHECK BY TOOL STORE\n• superiorId user = superiorId pada form\n\n', options: { fontSize: 11, color: DARK, fontFace: 'Segoe UI', breakLine: true } },
      { text: 'Alur utama:\n', options: { bold: true, fontSize: 12, color: ORANGE, fontFace: 'Segoe UI', breakLine: true } },
      { text: '1. Buka daftar form\n2. Expand form yang perlu divalidasi\n3. Tap Superior Validation\n4. Pilih Approved/Rejected + isi komentar\n5. Konfirmasi submit\n6. Sistem update milestone\n7. Tampilkan notifikasi sukses/gagal\n\n', options: { fontSize: 11, color: DARK, fontFace: 'Segoe UI', breakLine: true } },
      { text: 'Postcondition: ', options: { bold: true, fontSize: 12, color: ORANGE, fontFace: 'Segoe UI' } },
      { text: 'Milestone → SUPERIOR APPROVED atau REJECTED BY SUPERIOR', options: { fontSize: 11, color: DARK, fontFace: 'Segoe UI' } },
    ];
    slide.addText(blocks, { x: 0.5, y: 1.1, w: 9, h: 4.2, valign: 'top' });
    addFooter(slide);
  }

  addTableSlide(
    pres,
    'Integrasi Backend API',
    ['Fitur', 'Endpoint'],
    [
      ['Login', 'auth/login'],
      ['User CRUD', 'user'],
      ['Form tool', 'form'],
      ['Detail form', 'form/detail'],
      ['Export Excel', 'form/detail/export'],
      ['Purchase Order', 'po'],
      ['Sales Order', 'so'],
      ['Receive WH', 'receive/wh'],
      ['Receive Tool', 'receive/tool'],
      ['Superior', 'superior'],
      ['FCM token', 'device/fcm'],
    ],
    [3.5, 5.7],
  );

  {
    const slide = pres.addSlide();
    slide.background = { color: LIGHT_BG };
    addHeader(slide, 'Kesimpulan', pres);
    slide.addText(
      [
        { text: 'Aplikasi Tool Store mendukung 36 use case utama\n', options: { bullet: true, fontSize: 18, color: DARK, fontFace: 'Segoe UI', breakLine: true } },
        { text: '10 level user dengan hak akses berbeda\n', options: { bullet: true, fontSize: 18, color: DARK, fontFace: 'Segoe UI', breakLine: true } },
        { text: 'Workflow 7 tahap + status reject, hold, dan partial receive\n', options: { bullet: true, fontSize: 18, color: DARK, fontFace: 'Segoe UI', breakLine: true } },
        { text: 'Siap untuk pengembangan, testing UAT, dan dokumentasi proyek\n', options: { bullet: true, fontSize: 18, color: DARK, fontFace: 'Segoe UI', breakLine: true } },
      ],
      { x: 0.6, y: 1.3, w: 8.8, h: 3.5, valign: 'top' },
    );
    slide.addText('Pertanyaan?', {
      x: 0.6,
      y: 4.5,
      w: 8.8,
      h: 0.6,
      fontSize: 22,
      bold: true,
      color: ORANGE,
      fontFace: 'Segoe UI',
      align: 'center',
    });
    addFooter(slide);
  }

  await pres.writeFile({ fileName: outPath });
  console.log('Created:', outPath);
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
