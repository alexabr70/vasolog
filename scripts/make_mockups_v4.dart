#!/usr/bin/env dart

import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:image/image.dart' as img;

// Headlines and badges
const Map<String, Map<String, List<String>>> headlines = {
  'en': {
    '01_home': ['Your Raynaud\'s,\ndecoded.', 'Weather, attacks, triggers — one place'],
    '02_add_top': ['Log an attack in\n10 seconds', 'Severity, color, fingers — at a glance'],
    '03_add_hands': ['Every finger\ntells a story', 'Tap exactly where — only here'],
    '04_history': ['Patterns your\ndoctor misses', 'Weekly charts reveal YOUR triggers'],
    '05_add_bottom': ['Never forget\nan attack', 'Photos, notes, full history'],
    '06_report': ['Your doctor\nwill thank you', '6-month medical PDF — one tap'],
  },
};

const Map<String, String> uspBadges = {
  'en': 'UNIQUE',
};

// Config
const int canvasW = 1260;
const int canvasH = 2798;

const int phoneFrameW = 1100;
const int phoneFrameH = 2310;
const int phoneFrameColor = 0xFF1C1C1E; // Titanium
const int phoneInset = 12;
const int phoneScreenW = phoneFrameW - 2 * phoneInset;
const int phoneScreenH = phoneFrameH - 2 * phoneInset;
const int phoneOuterRadius = 68;
const int phoneInnerRadius = 58;

const int phoneRotation = 10;

const int headlineSize = 100;
const int subheadSize = 48;
const int headlineY = 140;
const int subheadOffset = 40;

const int uspSize = 42;
const int uspOffset = 30;

const int shadowBlur = 60;
const int shadowOffsetY = 40;
const int shadowOffsetX = 10;

const int glowDiameter = 800;
const int glowBlur = 40;

const int emojiSize = 100;
const int emojiPadding = 60;

// Colors
const int gradientTop = 0xFF0F0820;    // Deep purple/black
const int gradientMid = 0xFF5E35B1;    // Brand purple
const int gradientBot = 0xFF8B5CF6;    // Light purple
const int phoneColor = 0xFF1C1C1E;     // Titanium
const int uspColor = 0xFFFF7043;       // Orange
const int white = 0xFFFFFFFF;
const int black = 0xFF000000;

void main(List<String> args) async {
  final baseRaw = 'D:/DEV/vasolog/release/v1.1.0/store_assets/appgallery/raw';
  final baseOut = 'D:/DEV/vasolog/release/v1.1.0/store_assets/appgallery/mockups_v4';

  final screens = [
    '01_home',
    '02_add_top',
    '03_add_hands',
    '04_history',
    '05_add_bottom',
    '06_report'
  ];
  final langs = ['en'];

  print('=== VasoLog Premium Mockup Generator v4 ===\n');

  int count = 0;
  int totalSize = 0;

  for (final lang in langs) {
    print('=== $lang.toUpperCase() ===');

    for (final screen in screens) {
      final rawPath = '$baseRaw/$lang/$screen.png';
      final outDir = '$baseOut/$lang';

      try {
        final result = await makeMockup(rawPath, lang, screen, outDir);
        if (result != null) {
          count++;
          totalSize += File(result).lengthSync();
          print('✓ $screen');
        }
      } catch (e) {
        print('✗ $screen: $e');
      }
    }
  }

  print('\n=== SUMMARY ===');
  print('Generated $count mockups');
  print('Total size: ${(totalSize / 1024 / 1024).toStringAsFixed(1)}MB');
}

Future<String?> makeMockup(String rawPath, String lang, String screenId, String outDir) async {
  // Check if raw file exists
  final rawFile = File(rawPath);
  if (!await rawFile.exists()) {
    throw 'Raw file not found: $rawPath';
  }

  // Create output directory
  final outDirFile = Directory(outDir);
  await outDirFile.create(recursive: true);

  // Load raw screenshot
  final rawData = await rawFile.readAsBytes();
  var rawImg = img.decodeImage(rawData);
  if (rawImg == null) throw 'Failed to decode image';

  // Crop status bar (100px) + nav bar (195px)
  final cropped = img.copyCrop(rawImg,
      x: 0,
      y: 100,
      width: rawImg.width,
      height: rawImg.height - 295);

  // Scale to fit phone screen (preserving aspect)
  final scaled = img.copyResize(cropped,
      width: phoneScreenW,
      height: phoneScreenH,
      maintainAspect: true,
      backgroundColor: img.ColorRgba8(0, 0, 0, 0));

  // Create canvas
  var canvas = img.Image(width: canvasW, height: canvasH);

  // Fill with gradient background
  _fillGradientBg(canvas);

  // Add glow
  _addGlow(canvas);

  // Add paint blob
  _addBlob(canvas);

  // Create phone
  final phone = _createPhoneFrame();
  _pasteScreenOnPhone(phone, scaled);
  _addGlassReflection(phone);

  // Add shadow and rotate
  final phoneWithShadow = _addShadow(phone);
  final phoneRotated = _rotateImage(phoneWithShadow, phoneRotation);

  // Center phone on canvas
  final phoneX = (canvasW - phoneRotated.width) ~/ 2;
  final phoneY = (canvasH - phoneRotated.height) ~/ 2;

  img.compositeImage(canvas, phoneRotated, dstX: phoneX, dstY: phoneY);

  // Draw text
  _drawHeadline(canvas, headlines[lang]![screenId]![0], lang);
  _drawSubhead(canvas, headlines[lang]![screenId]![1], lang);

  // USP badge (screen 03)
  if (screenId == '03_add_hands') {
    _drawUSPBadge(canvas, uspBadges[lang]!, lang);
  }

  // Medical emoji (screen 06)
  if (screenId == '06_report') {
    _drawEmoji(canvas);
  }

  // Save
  final outPath = '$outDir/${screenId}.png';
  final outFile = File(outPath);
  await outFile.writeAsBytes(img.encodePng(canvas));

  return outPath;
}

// ==================== HELPERS ====================

void _fillGradientBg(img.Image canvas) {
  for (int y = 0; y < canvasH; y++) {
    final t = y / canvasH;
    final r, g, b;

    if (t < 0.5) {
      // Top to mid
      final t2 = t * 2;
      r = (((gradientTop >> 16) & 0xFF) * (1 - t2) +
              ((gradientMid >> 16) & 0xFF) * t2)
          .toInt();
      g = (((gradientTop >> 8) & 0xFF) * (1 - t2) +
              ((gradientMid >> 8) & 0xFF) * t2)
          .toInt();
      b = (((gradientTop) & 0xFF) * (1 - t2) + ((gradientMid) & 0xFF) * t2)
          .toInt();
    } else {
      // Mid to bot
      final t2 = (t - 0.5) * 2;
      r = (((gradientMid >> 16) & 0xFF) * (1 - t2) +
              ((gradientBot >> 16) & 0xFF) * t2)
          .toInt();
      g = (((gradientMid >> 8) & 0xFF) * (1 - t2) +
              ((gradientBot >> 8) & 0xFF) * t2)
          .toInt();
      b = (((gradientMid) & 0xFF) * (1 - t2) + ((gradientBot) & 0xFF) * t2)
          .toInt();
    }

    for (int x = 0; x < canvasW; x++) {
      canvas.setPixelRgba(x, y, r, g, b, 255);
    }
  }
}

void _addGlow(img.Image canvas) {
  final glowX = canvasW ~/ 2;
  final glowY = -(glowDiameter ~/ 2);
  final glowRadius = glowDiameter / 2;

  for (int y = 0; y < canvasH; y++) {
    for (int x = 0; x < canvasW; x++) {
      final dx = x - glowX;
      final dy = y - glowY;
      final dist = sqrt(dx * dx + dy * dy);

      if (dist < glowRadius) {
        final falloff = 1.0 - (dist / glowRadius);
        final alpha = (255 * 0.12 * falloff * falloff).toInt();

        final pixel = canvas.getPixelRgba(x, y);
        final r = ((pixel.r + (255 - pixel.r) * alpha / 255) ~/ 1).toInt();
        final g = ((pixel.g + (255 - pixel.g) * alpha / 255) ~/ 1).toInt();
        final b = ((pixel.b + (255 - pixel.b) * alpha / 255) ~/ 1).toInt();

        canvas.setPixelRgba(x, y, r, g, b, 255);
      }
    }
  }
}

void _addBlob(img.Image canvas) {
  final blobX = 80;
  final blobY = canvasH - 200;
  final blobRadius = 120;

  for (int y = max(0, blobY - blobRadius);
      y < min(canvasH, blobY + blobRadius);
      y++) {
    for (int x = max(0, blobX - blobRadius);
        x < min(canvasW, blobX + blobRadius);
        x++) {
      final dx = x - blobX;
      final dy = y - blobY;
      final dist = sqrt(dx * dx + dy * dy);

      if (dist < blobRadius) {
        final falloff = 1.0 - (dist / blobRadius);
        final alpha = (255 * 0.15 * falloff * falloff * falloff).toInt();

        final r = 255;
        final g = 112;
        final b = 67;

        final pixel = canvas.getPixelRgba(x, y);
        final blendedR = ((pixel.r * (255 - alpha) + r * alpha) ~/ 255).toInt();
        final blendedG = ((pixel.g * (255 - alpha) + g * alpha) ~/ 255).toInt();
        final blendedB = ((pixel.b * (255 - alpha) + b * alpha) ~/ 255).toInt();

        canvas.setPixelRgba(x, y, blendedR, blendedG, blendedB, 255);
      }
    }
  }
}

img.Image _createPhoneFrame() {
  final frame = img.Image(width: phoneFrameW, height: phoneFrameH);

  // Fill with frame color
  for (int y = 0; y < phoneFrameH; y++) {
    for (int x = 0; x < phoneFrameW; x++) {
      // Create rounded rectangle
      final isInside = _isInsideRoundedRect(x, y, phoneFrameW, phoneFrameH, phoneOuterRadius);
      if (isInside) {
        frame.setPixelRgba(x, y, 28, 28, 30, 255);
      }
    }
  }

  return frame;
}

void _pasteScreenOnPhone(img.Image phone, img.Image screen) {
  // Center screen on phone
  final offsetX = phoneInset;
  final offsetY = phoneInset;

  img.compositeImage(phone, screen, dstX: offsetX, dstY: offsetY);
}

void _addGlassReflection(img.Image phone) {
  final w = phoneScreenW;
  final h = phoneScreenH;

  // Linear diagonal gradient overlay
  for (int y = phoneInset; y < phoneInset + h; y++) {
    for (int x = phoneInset; x < phoneInset + w; x++) {
      final diag = (x + y) / (w + h);
      final alpha = (255 * 0.25 * (1.0 - diag)).toInt();

      final pixel = phone.getPixelRgba(x, y);
      final r = ((pixel.r * (255 - alpha) + 255 * alpha) ~/ 255).toInt();
      final g = ((pixel.g * (255 - alpha) + 255 * alpha) ~/ 255).toInt();
      final b = ((pixel.b * (255 - alpha) + 255 * alpha) ~/ 255).toInt();

      phone.setPixelRgba(x, y, r, g, b, 255);
    }
  }
}

img.Image _addShadow(img.Image phone) {
  final shadowW = phone.width + 100;
  final shadowH = phone.height + 100;
  final result = img.Image(width: shadowW, height: shadowH);

  // Fill with transparent
  for (int y = 0; y < shadowH; y++) {
    for (int x = 0; x < shadowW; x++) {
      result.setPixelRgba(x, y, 0, 0, 0, 0);
    }
  }

  // Draw shadow shape with blur
  final shadowX = 50;
  final shadowY = 50;

  for (int y = 0; y < shadowH; y++) {
    for (int x = 0; x < shadowW; x++) {
      final distX = ((x - (shadowX + shadowOffsetX)) / shadowBlur).abs();
      final distY = ((y - (shadowY + shadowOffsetY)) / shadowBlur).abs();
      final dist = sqrt(distX * distX + distY * distY);

      if (dist < 2.0) {
        final alpha = (140 * (1.0 - min(dist / 2.0, 1.0))).toInt();
        final pixel = result.getPixelRgba(x, y);
        result.setPixelRgba(x, y, 0, 0, 0, max(pixel.a, alpha));
      }
    }
  }

  // Paste phone on top
  img.compositeImage(result, phone, dstX: 50, dstY: 50);

  return result;
}

img.Image _rotateImage(img.Image image, int angle) {
  return img.copyRotate(image, angle: angle);
}

void _drawHeadline(img.Image canvas, String text, String lang) {
  // Simple text rendering - using drawString if available
  // For now, just mark that text should be drawn
  // In a real implementation, would use image library's text rendering
}

void _drawSubhead(img.Image canvas, String text, String lang) {
  // Simple text rendering
}

void _drawUSPBadge(img.Image canvas, String text, String lang) {
  // Draw USP badge
}

void _drawEmoji(img.Image canvas) {
  // Draw stethoscope emoji
}

bool _isInsideRoundedRect(
    int x, int y, int w, int h, int radius) {
  // Check if point is inside rounded rectangle
  if (x < radius && y < radius) {
    return sqrt((x - radius) * (x - radius) + (y - radius) * (y - radius)) <
        radius;
  }
  if (x > w - radius && y < radius) {
    return sqrt((x - (w - radius)) * (x - (w - radius)) +
            (y - radius) * (y - radius)) <
        radius;
  }
  if (x < radius && y > h - radius) {
    return sqrt((x - radius) * (x - radius) +
            (y - (h - radius)) * (y - (h - radius))) <
        radius;
  }
  if (x > w - radius && y > h - radius) {
    return sqrt((x - (w - radius)) * (x - (w - radius)) +
            (y - (h - radius)) * (y - (h - radius))) <
        radius;
  }
  return true;
}
