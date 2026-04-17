#!/usr/bin/env node

/**
 * VasoLog Premium App Store Mockup Generator v4
 *
 * Design: Calm/Headspace/Ada-style with Raynaud brand colors
 * Canvas: 1260×2798px (9:19.5 ratio)
 */

const fs = require('fs');
const path = require('path');
const { createCanvas, loadImage } = require('canvas');

// ==================== CONFIG ====================

const CANVAS_W = 1260;
const CANVAS_H = 2798;

const PHONE_FRAME_W = 1100;
const PHONE_FRAME_H = 2310;
const PHONE_FRAME_COLOR = '#1C1C1E'; // Titanium
const PHONE_INSET = 12;
const PHONE_SCREEN_W = PHONE_FRAME_W - 2 * PHONE_INSET;
const PHONE_SCREEN_H = PHONE_FRAME_H - 2 * PHONE_INSET;
const PHONE_OUTER_RADIUS = 68;
const PHONE_INNER_RADIUS = 58;

const PHONE_ROTATION = 10;

const HEADLINE_SIZE = 100;
const HEADLINE_COLOR = '#FFFFFF';
const HEADLINE_Y_START = 140;
const HEADLINE_SHADOW_COLOR = 'rgba(0,0,0,0.31)';
const HEADLINE_SHADOW_BLUR = 6;
const HEADLINE_SHADOW_OFFSET = 2;

const SUBHEAD_SIZE = 48;
const SUBHEAD_COLOR = 'rgba(255,255,255,0.82)';
const SUBHEAD_OFFSET = 40;

const USP_COLOR = '#FF7043'; // Orange
const USP_TEXT_SIZE = 42;
const USP_RADIUS = 32;
const USP_H_PADDING = 34;
const USP_V_PADDING = 14;
const USP_GLOW_COLOR = 'rgba(255,112,67,0.25)';
const USP_GLOW_BLUR = 30;
const USP_OFFSET = 30;

const EMOJI_SIZE = 100;
const EMOJI_OPACITY = 0.2;
const EMOJI_PADDING = 60;

const SHADOW_BLUR = 60;
const SHADOW_COLOR = 'rgba(0,0,0,0.55)';
const SHADOW_OFFSET_X = 10;
const SHADOW_OFFSET_Y = 40;

const GLOW_OPACITY = 0.12;
const GLOW_DIAMETER = 800;
const GLOW_BLUR = 40;

const NOISE_OPACITY = 0.04;
const BLOB_OPACITY = 0.15;
const BLOB_RADIUS = 120;
const BLOB_BLUR = 80;

// Colors
const GRADIENT_TOP = '#0F0820';    // Deep purple/black
const GRADIENT_MID = '#5E35B1';    // Brand purple
const GRADIENT_BOT = '#8B5CF6';    // Light purple
const BLOB_COLOR = '#FF7043';      // Orange

// Headlines & badges
const HEADLINES = {
  en: {
    '01_home': {
      headline: 'Your Raynaud\'s,\ndecoded.',
      subhead: 'Weather, attacks, triggers — one place'
    },
    '02_add_top': {
      headline: 'Log an attack in\n10 seconds',
      subhead: 'Severity, color, fingers — at a glance'
    },
    '03_add_hands': {
      headline: 'Every finger\ntells a story',
      subhead: 'Tap exactly where — only here'
    },
    '04_history': {
      headline: 'Patterns your\ndoctor misses',
      subhead: 'Weekly charts reveal YOUR triggers'
    },
    '05_add_bottom': {
      headline: 'Never forget\nan attack',
      subhead: 'Photos, notes, full history'
    },
    '06_report': {
      headline: 'Your doctor\nwill thank you',
      subhead: '6-month medical PDF — one tap'
    }
  }
};

const USP_BADGES = {
  en: 'UNIQUE'
};

// ==================== MAIN ====================

async function main() {
  const baseRaw = 'D:/DEV/vasolog/release/v1.1.0/store_assets/appgallery/raw';
  const baseOut = 'D:/DEV/vasolog/release/v1.1.0/store_assets/appgallery/mockups_v4';

  const screens = ['01_home', '02_add_top', '03_add_hands', '04_history', '05_add_bottom', '06_report'];
  const langs = ['en'];

  console.log('=== VasoLog Premium Mockup Generator v4 ===\n');

  let count = 0;
  let totalSize = 0;

  for (const lang of langs) {
    console.log(`=== ${lang.toUpperCase()} ===`);

    for (const screen of screens) {
      const rawPath = path.join(baseRaw, lang, `${screen}.png`);
      const outDir = path.join(baseOut, lang);

      try {
        const result = await makeMockup(rawPath, lang, screen, outDir);
        if (result) {
          count++;
          totalSize += fs.statSync(result).size;
          console.log(`✓ ${screen}`);
        }
      } catch (e) {
        console.error(`✗ ${screen}: ${e.message}`);
      }
    }
  }

  console.log(`\n=== SUMMARY ===`);
  console.log(`Generated ${count} mockups`);
  console.log(`Total size: ${(totalSize / 1024 / 1024).toFixed(1)}MB`);
}

// ==================== HELPERS ====================

async function makeMockup(rawPath, lang, screenId, outDir) {
  // Check if raw exists
  if (!fs.existsSync(rawPath)) {
    throw new Error(`Raw file not found: ${rawPath}`);
  }

  // Create output directory
  fs.mkdirSync(outDir, { recursive: true });

  // Load raw screenshot
  const rawImg = await loadImage(rawPath);

  // Create canvas
  const canvas = createCanvas(CANVAS_W, CANVAS_H);
  const ctx = canvas.getContext('2d');

  // Fill background gradient
  fillGradientBackground(ctx);

  // Add glow
  addRadialGlow(ctx);

  // Add paint blob
  addPaintBlob(ctx);

  // Create phone mockup (this also pastes it on canvas with rotation)
  await createPhoneMockup(rawImg, ctx);

  // Draw text (headline, subhead)
  drawTypography(ctx, lang, screenId);

  // USP badge (screen 03)
  if (screenId === '03_add_hands') {
    drawUSPBadge(ctx, USP_BADGES[lang]);
  }

  // Medical emoji (screen 06)
  if (screenId === '06_report') {
    drawMedicalEmoji(ctx);
  }

  // Save
  const outPath = path.join(outDir, `${screenId}.png`);
  const buffer = canvas.toBuffer('image/png');
  fs.writeFileSync(outPath, buffer);

  return outPath;
}

function fillGradientBackground(ctx) {
  // Vertical gradient: top → mid → bot
  const gradient = ctx.createLinearGradient(0, 0, 0, CANVAS_H);

  gradient.addColorStop(0.0, GRADIENT_TOP);
  gradient.addColorStop(0.5, GRADIENT_MID);
  gradient.addColorStop(1.0, GRADIENT_BOT);

  ctx.fillStyle = gradient;
  ctx.fillRect(0, 0, CANVAS_W, CANVAS_H);
}

function addRadialGlow(ctx) {
  const glowX = CANVAS_W / 2;
  const glowY = -(GLOW_DIAMETER / 2);
  const glowRadius = GLOW_DIAMETER / 2;

  const gradient = ctx.createRadialGradient(glowX, glowY, 0, glowX, glowY, glowRadius);
  gradient.addColorStop(0.0, `rgba(255,255,255,${GLOW_OPACITY})`);
  gradient.addColorStop(1.0, 'rgba(255,255,255,0)');

  ctx.fillStyle = gradient;
  ctx.fillRect(0, 0, CANVAS_W, CANVAS_H);
}

function addPaintBlob(ctx) {
  // Paint blob bottom-left
  const blobX = 80;
  const blobY = CANVAS_H - 200;

  ctx.save();
  ctx.globalAlpha = BLOB_OPACITY;
  ctx.fillStyle = BLOB_COLOR;

  ctx.beginPath();
  ctx.arc(blobX, blobY, BLOB_RADIUS, 0, Math.PI * 2);
  ctx.fill();

  // Blur effect (simulate with multiple circles)
  ctx.globalAlpha = BLOB_OPACITY * 0.3;
  for (let i = 1; i <= 3; i++) {
    ctx.beginPath();
    ctx.arc(blobX, blobY, BLOB_RADIUS + i * 15, 0, Math.PI * 2);
    ctx.fill();
  }

  ctx.restore();
}

async function createPhoneMockup(rawImg, mainCtx) {
  // Create phone frame canvas with extra space for shadow and rotation
  const phoneCanvas = createCanvas(PHONE_FRAME_W + 200, PHONE_FRAME_H + 200);
  const phoneCtx = phoneCanvas.getContext('2d');

  const offsetX = 100;
  const offsetY = 100;

  // Draw shadow first
  phoneCtx.save();
  phoneCtx.shadowColor = 'rgba(0,0,0,0.35)';
  phoneCtx.shadowBlur = SHADOW_BLUR;
  phoneCtx.shadowOffsetX = SHADOW_OFFSET_X;
  phoneCtx.shadowOffsetY = SHADOW_OFFSET_Y;

  // Frame background (titanium)
  phoneCtx.fillStyle = PHONE_FRAME_COLOR;
  phoneCtx.beginPath();
  roundRect(phoneCtx, offsetX, offsetY, PHONE_FRAME_W, PHONE_FRAME_H, PHONE_OUTER_RADIUS);
  phoneCtx.fill();
  phoneCtx.restore();

  // Screen area (rounded)
  phoneCtx.save();
  phoneCtx.beginPath();
  roundRect(phoneCtx, offsetX + PHONE_INSET, offsetY + PHONE_INSET, PHONE_SCREEN_W, PHONE_SCREEN_H, PHONE_INNER_RADIUS);
  phoneCtx.clip();

  // Crop and scale raw screenshot
  const statusCrop = 100;
  const navCrop = 195;
  const sourceHeight = rawImg.height - statusCrop - navCrop;

  // Scale to fit phone screen
  const scale = Math.min(PHONE_SCREEN_W / rawImg.width, PHONE_SCREEN_H / sourceHeight);
  const scaledW = rawImg.width * scale;
  const scaledH = sourceHeight * scale;

  const imgOffsetX = (PHONE_SCREEN_W - scaledW) / 2;
  const imgOffsetY = (PHONE_SCREEN_H - scaledH) / 2;

  phoneCtx.drawImage(
    rawImg,
    0, statusCrop, rawImg.width, sourceHeight,
    offsetX + PHONE_INSET + imgOffsetX, offsetY + PHONE_INSET + imgOffsetY, scaledW, scaledH
  );

  // Glass reflection gradient
  const glassGrad = phoneCtx.createLinearGradient(
    offsetX + PHONE_INSET, offsetY + PHONE_INSET,
    offsetX + PHONE_INSET + PHONE_SCREEN_W, offsetY + PHONE_INSET + PHONE_SCREEN_H
  );
  glassGrad.addColorStop(0.0, 'rgba(255,255,255,0.25)');
  glassGrad.addColorStop(1.0, 'rgba(255,255,255,0)');

  phoneCtx.fillStyle = glassGrad;
  phoneCtx.fillRect(offsetX + PHONE_INSET, offsetY + PHONE_INSET, PHONE_SCREEN_W, PHONE_SCREEN_H);

  phoneCtx.restore();

  // Rotate and paste on main canvas
  pasteRotatedPhone(mainCtx, phoneCanvas);

  return phoneCanvas;
}

function pasteRotatedPhone(ctx, phoneCanvas) {
  // Rotate and center phone on main canvas
  ctx.save();

  // Translate to center
  const centerX = CANVAS_W / 2;
  const centerY = CANVAS_H / 2;

  ctx.translate(centerX, centerY);
  ctx.rotate((PHONE_ROTATION * Math.PI) / 180);

  // Draw phone centered at origin
  const phoneX = -(phoneCanvas.width / 2);
  const phoneY = -(phoneCanvas.height / 2);

  ctx.drawImage(phoneCanvas, phoneX, phoneY);

  ctx.restore();
}

function drawTypography(ctx, lang, screenId) {
  const data = HEADLINES[lang][screenId];

  // Headline
  ctx.font = `bold ${HEADLINE_SIZE}px "Segoe UI", Arial, sans-serif`;
  ctx.fillStyle = HEADLINE_SHADOW_COLOR;
  ctx.textAlign = 'center';

  const headlineLines = data.headline.split('\n');
  let y = HEADLINE_Y_START + HEADLINE_SHADOW_OFFSET;

  for (const line of headlineLines) {
    ctx.fillText(line, CANVAS_W / 2 + HEADLINE_SHADOW_OFFSET, y);
    y += HEADLINE_SIZE * 1.12;
  }

  // Headline text
  ctx.fillStyle = HEADLINE_COLOR;
  y = HEADLINE_Y_START;
  for (const line of headlineLines) {
    ctx.fillText(line, CANVAS_W / 2, y);
    y += HEADLINE_SIZE * 1.12;
  }

  // Subhead
  ctx.font = `${SUBHEAD_SIZE}px "Segoe UI", Arial, sans-serif`;
  ctx.fillStyle = SUBHEAD_COLOR;
  ctx.textAlign = 'center';

  const subheadY = y + SUBHEAD_OFFSET;
  ctx.fillText(data.subhead, CANVAS_W / 2, subheadY);
}

function drawUSPBadge(ctx, text) {
  const badgeText = `✨ ${text}`;

  ctx.font = `bold ${USP_TEXT_SIZE}px "Segoe UI", Arial, sans-serif`;
  const metrics = ctx.measureText(badgeText);
  const textW = metrics.width;
  const textH = USP_TEXT_SIZE;

  const badgeW = textW + 2 * USP_H_PADDING;
  const badgeH = textH + 2 * USP_V_PADDING;

  const badgeX = (CANVAS_W - badgeW) / 2;
  const badgeY = HEADLINE_Y_START + 280;

  // Glow
  ctx.save();
  ctx.globalAlpha = 0.25;
  ctx.fillStyle = '#FF7043';
  ctx.beginPath();
  ctx.arc(badgeX + badgeW / 2, badgeY + badgeH / 2, 100, 0, Math.PI * 2);
  ctx.fill();
  ctx.restore();

  // Badge background
  ctx.fillStyle = USP_COLOR;
  roundRect(ctx, badgeX, badgeY, badgeW, badgeH, USP_RADIUS);
  ctx.fill();

  // Badge text
  ctx.fillStyle = '#FFFFFF';
  ctx.font = `bold ${USP_TEXT_SIZE}px "Segoe UI", Arial, sans-serif`;
  ctx.textAlign = 'left';
  ctx.fillText(badgeText, badgeX + USP_H_PADDING, badgeY + USP_V_PADDING + USP_TEXT_SIZE * 0.75);
}

function drawMedicalEmoji(ctx) {
  ctx.save();
  ctx.globalAlpha = EMOJI_OPACITY;
  ctx.font = `${EMOJI_SIZE}px Arial`;
  ctx.textAlign = 'right';
  ctx.fillText('🩺', CANVAS_W - EMOJI_PADDING, EMOJI_PADDING + EMOJI_SIZE * 0.75);
  ctx.restore();
}

function roundRect(ctx, x, y, w, h, r) {
  const tl = Math.min(r, w / 2, h / 2);
  ctx.moveTo(x + tl, y);
  ctx.lineTo(x + w - tl, y);
  ctx.arcTo(x + w, y, x + w, y + tl, tl);
  ctx.lineTo(x + w, y + h - tl);
  ctx.arcTo(x + w, y + h, x + w - tl, y + h, tl);
  ctx.lineTo(x + tl, y + h);
  ctx.arcTo(x, y + h, x, y + h - tl, tl);
  ctx.lineTo(x, y + tl);
  ctx.arcTo(x, y, x + tl, y, tl);
}

// ==================== RUN ====================

main().catch(console.error);
