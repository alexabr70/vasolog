#!/usr/bin/env node

/**
 * VasoLog Premium Mockup Generator v5
 *
 * Изменения v4 → v5:
 *  - USP badge перемещён НИЖЕ subhead (не перекрывает текст)
 *  - Phone уменьшен (1000×2000) и сдвинут вниз (не обрезается rotation'ом)
 *  - Tilt 10° → 5° (phone не выходит за canvas)
 *  - Phone frame INSET 12 → 20 (читается как устройство)
 *  - Убран случайный orange blob (фон чище, только gradient)
 *  - 18 языков из headlines_v2.json
 */

const fs = require('fs');
const path = require('path');
const { createCanvas, loadImage } = require('canvas');

// ==================== CONFIG ====================

const CANVAS_W = 1260;
const CANVAS_H = 2798;

// Phone - уменьшен, чтобы влезал с rotation
const PHONE_FRAME_W = 1000;
const PHONE_FRAME_H = 2000;
const PHONE_FRAME_COLOR = '#1C1C1E';
const PHONE_INSET = 20; // было 12 - теперь читается как frame
const PHONE_SCREEN_W = PHONE_FRAME_W - 2 * PHONE_INSET;
const PHONE_SCREEN_H = PHONE_FRAME_H - 2 * PHONE_INSET;
const PHONE_OUTER_RADIUS = 72;
const PHONE_INNER_RADIUS = 54;

// Phone center: сдвинут вниз, чтобы текст + badge не перекрывались
const PHONE_CENTER_Y = 1640;
const PHONE_ROTATION = 5; // было 10°

// Typography
const HEADLINE_SIZE = 96;
const HEADLINE_COLOR = '#FFFFFF';
const HEADLINE_Y_START = 130;
const HEADLINE_SHADOW_COLOR = 'rgba(0,0,0,0.35)';
const HEADLINE_SHADOW_OFFSET = 3;
const HEADLINE_LINE_HEIGHT = 1.08;

const SUBHEAD_SIZE = 44;
const SUBHEAD_COLOR = 'rgba(255,255,255,0.85)';
const SUBHEAD_OFFSET = 44; // gap от headline

// USP badge - ниже subhead с gap
const USP_COLOR = '#FF7043';
const USP_TEXT_SIZE = 40;
const USP_RADIUS = 36;
const USP_H_PADDING = 36;
const USP_V_PADDING = 14;
const USP_TOP_GAP = 36; // gap от subhead до badge

// Emoji (screen 06)
const EMOJI_SIZE = 100;
const EMOJI_OPACITY = 0.18;
const EMOJI_PADDING = 60;

// Shadow под phone
const SHADOW_BLUR = 70;
const SHADOW_COLOR = 'rgba(0,0,0,0.45)';
const SHADOW_OFFSET_X = 12;
const SHADOW_OFFSET_Y = 48;

// Ambient glow
const GLOW_OPACITY = 0.14;
const GLOW_DIAMETER = 900;

// Background colors
const GRADIENT_TOP = '#0F0820';
const GRADIENT_MID = '#5E35B1';
const GRADIENT_BOT = '#8B5CF6';

// Crop source screenshot (отрезать status bar + nav bar)
const STATUS_CROP = 100;
const NAV_CROP = 195;

// Языки + screens
const LANGS = ['en','ru','de','fr','es','pt','it','sv','fi','nb','da','nl','pl','cs','hu','uk','ja','ko'];
const SCREENS = ['01_home','02_add_top','03_add_hands','04_history','05_add_bottom','06_report'];

// Font stack: Windows system fonts для CJK/кириллицы
const FONT_STACK = '"Segoe UI","Yu Gothic UI","Malgun Gothic","Arial",sans-serif';

// ==================== DATA ====================

const DATA = JSON.parse(fs.readFileSync(path.join(__dirname, 'headlines_v2.json'), 'utf-8'));
const HEADLINES = DATA.headlines;
const USP_BADGES = DATA.usp_badges;

// ==================== MAIN ====================

async function main() {
  const baseRaw = 'D:/DEV/vasolog/release/v1.1.0/store_assets/appgallery/raw';
  const baseOut = 'D:/DEV/vasolog/release/v1.1.0/store_assets/appgallery/mockups_final';

  // CLI: --lang=en (тест одного) | --all
  const argLang = process.argv.find(a => a.startsWith('--lang='));
  const onlyLang = argLang ? argLang.split('=')[1] : null;
  const langs = onlyLang ? [onlyLang] : LANGS;

  console.log('=== VasoLog Mockup Generator v5 ===');
  console.log(`Langs: ${langs.length}, screens: ${SCREENS.length}, total: ${langs.length * SCREENS.length}\n`);

  let count = 0;
  let totalBytes = 0;
  const failures = [];

  for (const lang of langs) {
    process.stdout.write(`[${lang}] `);
    for (const screen of SCREENS) {
      const rawPath = path.join(baseRaw, lang, `${screen}.png`);
      const outDir = path.join(baseOut, lang);

      try {
        const outPath = await makeMockup(rawPath, lang, screen, outDir);
        const size = fs.statSync(outPath).size;
        count++;
        totalBytes += size;
        process.stdout.write('✓');
      } catch (e) {
        failures.push(`${lang}/${screen}: ${e.message}`);
        process.stdout.write('✗');
      }
    }
    process.stdout.write('\n');
  }

  console.log(`\n=== DONE ===`);
  console.log(`Generated: ${count}/${langs.length * SCREENS.length}`);
  console.log(`Total size: ${(totalBytes / 1024 / 1024).toFixed(2)}MB`);
  console.log(`Avg per image: ${(totalBytes / count / 1024).toFixed(0)}KB`);
  if (failures.length) {
    console.log(`\nFailures:`);
    failures.forEach(f => console.log('  ' + f));
  }
}

// ==================== MOCKUP ====================

async function makeMockup(rawPath, lang, screenId, outDir) {
  if (!fs.existsSync(rawPath)) throw new Error(`raw not found: ${rawPath}`);
  fs.mkdirSync(outDir, { recursive: true });

  const rawImg = await loadImage(rawPath);

  const canvas = createCanvas(CANVAS_W, CANVAS_H);
  const ctx = canvas.getContext('2d');

  // Background
  fillGradientBackground(ctx);
  addRadialGlow(ctx);

  // Phone (позади текста/badge - чтобы text был на top)
  await drawRotatedPhone(rawImg, ctx);

  // Typography
  drawTypography(ctx, lang, screenId);

  // USP badge (screen 03)
  if (screenId === '03_add_hands') {
    drawUSPBadge(ctx, USP_BADGES[lang] || 'UNIQUE', lang, screenId);
  }

  // Medical emoji decoration (screen 06)
  if (screenId === '06_report') {
    drawMedicalEmoji(ctx);
  }

  const outPath = path.join(outDir, `${screenId}.png`);
  fs.writeFileSync(outPath, canvas.toBuffer('image/png'));
  return outPath;
}

// ==================== BACKGROUND ====================

function fillGradientBackground(ctx) {
  const g = ctx.createLinearGradient(0, 0, 0, CANVAS_H);
  g.addColorStop(0.0, GRADIENT_TOP);
  g.addColorStop(0.5, GRADIENT_MID);
  g.addColorStop(1.0, GRADIENT_BOT);
  ctx.fillStyle = g;
  ctx.fillRect(0, 0, CANVAS_W, CANVAS_H);
}

function addRadialGlow(ctx) {
  // soft glow сверху по центру
  const gx = CANVAS_W / 2;
  const gy = -(GLOW_DIAMETER / 4);
  const r = GLOW_DIAMETER / 2;
  const g = ctx.createRadialGradient(gx, gy, 0, gx, gy, r);
  g.addColorStop(0.0, `rgba(255,255,255,${GLOW_OPACITY})`);
  g.addColorStop(1.0, 'rgba(255,255,255,0)');
  ctx.fillStyle = g;
  ctx.fillRect(0, 0, CANVAS_W, CANVAS_H);
}

// ==================== PHONE ====================

async function drawRotatedPhone(rawImg, mainCtx) {
  // Рисуем phone в offscreen canvas + rotation + paste
  const pad = 120;
  const offW = PHONE_FRAME_W + 2 * pad;
  const offH = PHONE_FRAME_H + 2 * pad;
  const off = createCanvas(offW, offH);
  const c = off.getContext('2d');

  const fx = pad;
  const fy = pad;

  // Shadow + frame
  c.save();
  c.shadowColor = SHADOW_COLOR;
  c.shadowBlur = SHADOW_BLUR;
  c.shadowOffsetX = SHADOW_OFFSET_X;
  c.shadowOffsetY = SHADOW_OFFSET_Y;
  c.fillStyle = PHONE_FRAME_COLOR;
  c.beginPath();
  roundRect(c, fx, fy, PHONE_FRAME_W, PHONE_FRAME_H, PHONE_OUTER_RADIUS);
  c.fill();
  c.restore();

  // Frame highlight - тонкая светлая полоска сверху для 3D feel
  c.save();
  const hlGrad = c.createLinearGradient(fx, fy, fx, fy + PHONE_FRAME_H);
  hlGrad.addColorStop(0.0, 'rgba(255,255,255,0.18)');
  hlGrad.addColorStop(0.15, 'rgba(255,255,255,0)');
  c.fillStyle = hlGrad;
  c.beginPath();
  roundRect(c, fx, fy, PHONE_FRAME_W, PHONE_FRAME_H, PHONE_OUTER_RADIUS);
  c.fill();
  c.restore();

  // Screen (clipped)
  c.save();
  c.beginPath();
  roundRect(c, fx + PHONE_INSET, fy + PHONE_INSET, PHONE_SCREEN_W, PHONE_SCREEN_H, PHONE_INNER_RADIUS);
  c.clip();

  // Crop status/nav и scale screenshot
  const sh = rawImg.height - STATUS_CROP - NAV_CROP;
  const scale = Math.min(PHONE_SCREEN_W / rawImg.width, PHONE_SCREEN_H / sh);
  const sw = rawImg.width * scale;
  const shh = sh * scale;
  const ox = (PHONE_SCREEN_W - sw) / 2;
  const oy = (PHONE_SCREEN_H - shh) / 2;

  c.drawImage(rawImg,
    0, STATUS_CROP, rawImg.width, sh,
    fx + PHONE_INSET + ox, fy + PHONE_INSET + oy, sw, shh);

  // Glass reflection (diagonal)
  const gg = c.createLinearGradient(fx + PHONE_INSET, fy + PHONE_INSET,
    fx + PHONE_INSET + PHONE_SCREEN_W, fy + PHONE_INSET + PHONE_SCREEN_H);
  gg.addColorStop(0.0, 'rgba(255,255,255,0.08)');
  gg.addColorStop(0.3, 'rgba(255,255,255,0)');
  c.fillStyle = gg;
  c.fillRect(fx + PHONE_INSET, fy + PHONE_INSET, PHONE_SCREEN_W, PHONE_SCREEN_H);
  c.restore();

  // Paste rotated onto main
  mainCtx.save();
  mainCtx.translate(CANVAS_W / 2, PHONE_CENTER_Y);
  mainCtx.rotate((PHONE_ROTATION * Math.PI) / 180);
  mainCtx.drawImage(off, -offW / 2, -offH / 2);
  mainCtx.restore();
}

// ==================== TYPOGRAPHY ====================

function drawTypography(ctx, lang, screenId) {
  const d = HEADLINES[lang][screenId];

  const lines = d.headline.split('\n');

  // Headline (с тенью)
  ctx.font = `bold ${HEADLINE_SIZE}px ${FONT_STACK}`;
  ctx.textAlign = 'center';
  ctx.textBaseline = 'alphabetic';

  let y = HEADLINE_Y_START + HEADLINE_SIZE;
  // Shadow pass
  ctx.fillStyle = HEADLINE_SHADOW_COLOR;
  for (const line of lines) {
    ctx.fillText(line, CANVAS_W / 2 + HEADLINE_SHADOW_OFFSET, y + HEADLINE_SHADOW_OFFSET);
    y += HEADLINE_SIZE * HEADLINE_LINE_HEIGHT;
  }
  // Main pass
  y = HEADLINE_Y_START + HEADLINE_SIZE;
  ctx.fillStyle = HEADLINE_COLOR;
  for (const line of lines) {
    ctx.fillText(line, CANVAS_W / 2, y);
    y += HEADLINE_SIZE * HEADLINE_LINE_HEIGHT;
  }

  // Subhead
  ctx.font = `${SUBHEAD_SIZE}px ${FONT_STACK}`;
  ctx.fillStyle = SUBHEAD_COLOR;
  const subY = y - HEADLINE_SIZE * (HEADLINE_LINE_HEIGHT - 1) + SUBHEAD_OFFSET;
  ctx.fillText(d.subhead, CANVAS_W / 2, subY);

  // store для USP badge
  ctx._subheadBottom = subY + SUBHEAD_SIZE * 0.3;
}

// ==================== USP BADGE ====================

function drawUSPBadge(ctx, text, lang, screenId) {
  const badgeText = `✨ ${text}`;

  ctx.font = `bold ${USP_TEXT_SIZE}px ${FONT_STACK}`;
  ctx.textAlign = 'left';
  ctx.textBaseline = 'alphabetic';
  const m = ctx.measureText(badgeText);
  const textW = m.width;
  const badgeW = textW + 2 * USP_H_PADDING;
  const badgeH = USP_TEXT_SIZE + 2 * USP_V_PADDING;

  const bx = (CANVAS_W - badgeW) / 2;
  // ниже subhead с gap
  const by = (ctx._subheadBottom || 480) + USP_TOP_GAP;

  // Soft glow
  ctx.save();
  const glowR = Math.max(badgeW, badgeH) * 0.9;
  const gg = ctx.createRadialGradient(bx + badgeW/2, by + badgeH/2, 0, bx + badgeW/2, by + badgeH/2, glowR);
  gg.addColorStop(0.0, 'rgba(255,112,67,0.45)');
  gg.addColorStop(1.0, 'rgba(255,112,67,0)');
  ctx.fillStyle = gg;
  ctx.fillRect(bx - glowR, by - glowR, badgeW + glowR * 2, badgeH + glowR * 2);
  ctx.restore();

  // Badge background
  ctx.fillStyle = USP_COLOR;
  ctx.beginPath();
  roundRect(ctx, bx, by, badgeW, badgeH, USP_RADIUS);
  ctx.fill();

  // Badge text
  ctx.fillStyle = '#FFFFFF';
  ctx.font = `bold ${USP_TEXT_SIZE}px ${FONT_STACK}`;
  ctx.fillText(badgeText, bx + USP_H_PADDING, by + USP_V_PADDING + USP_TEXT_SIZE * 0.8);
}

// ==================== EMOJI (screen 06) ====================

function drawMedicalEmoji(ctx) {
  ctx.save();
  ctx.globalAlpha = EMOJI_OPACITY;
  ctx.font = `${EMOJI_SIZE}px "Segoe UI Emoji","Apple Color Emoji",Arial`;
  ctx.textAlign = 'right';
  ctx.fillText('🩺', CANVAS_W - EMOJI_PADDING, EMOJI_PADDING + EMOJI_SIZE * 0.75);
  ctx.restore();
}

// ==================== HELPERS ====================

function roundRect(ctx, x, y, w, h, r) {
  const rr = Math.min(r, w / 2, h / 2);
  ctx.moveTo(x + rr, y);
  ctx.lineTo(x + w - rr, y);
  ctx.arcTo(x + w, y, x + w, y + rr, rr);
  ctx.lineTo(x + w, y + h - rr);
  ctx.arcTo(x + w, y + h, x + w - rr, y + h, rr);
  ctx.lineTo(x + rr, y + h);
  ctx.arcTo(x, y + h, x, y + h - rr, rr);
  ctx.lineTo(x, y + rr);
  ctx.arcTo(x, y, x + rr, y, rr);
}

// ==================== RUN ====================

main().catch(err => {
  console.error(err);
  process.exit(1);
});
