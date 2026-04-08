"""
Генератор профессиональной иконки VasoLog.
Концепция: снежинка + пульс на индиго градиенте.
Выходные файлы: icon.png (1024x1024), icon_foreground.png, splash_icon.png
"""
from PIL import Image, ImageDraw
import math

SIZE = 1024
CENTER = SIZE // 2

def make_gradient(size: int) -> Image.Image:
    """Радиальный градиент индиго → фиолетовый"""
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    # Цвета: центр светлее, края темнее
    c1 = (120, 110, 220)  # Светлый индиго
    c2 = (75, 55, 160)    # Тёмный фиолет
    for y in range(size):
        for x in range(size):
            # Расстояние от центра нормализованное
            dx = (x - size / 2) / (size / 2)
            dy = (y - size / 2) / (size / 2)
            dist = min(1.0, math.sqrt(dx * dx + dy * dy))
            # Градиент от центра к краям
            t = dist * 0.7 + (y / size) * 0.3  # Смешиваем радиальный + вертикальный
            t = min(1.0, t)
            r = int(c1[0] + (c2[0] - c1[0]) * t)
            g = int(c1[1] + (c2[1] - c1[1]) * t)
            b = int(c1[2] + (c2[2] - c1[2]) * t)
            draw.point((x, y), fill=(r, g, b, 255))
    return img

def make_gradient_fast(size: int) -> Image.Image:
    """Быстрый градиент через resize"""
    # Делаем маленький градиент и увеличиваем
    small = 64
    img = Image.new('RGB', (small, small))
    draw = ImageDraw.Draw(img)
    c_top = (110, 95, 210)     # Светлый индиго сверху
    c_bottom = (60, 40, 155)   # Тёмный фиолет снизу
    for y in range(small):
        t = y / small
        r = int(c_top[0] + (c_bottom[0] - c_top[0]) * t)
        g = int(c_top[1] + (c_bottom[1] - c_top[1]) * t)
        b = int(c_top[2] + (c_bottom[2] - c_top[2]) * t)
        draw.line([(0, y), (small - 1, y)], fill=(r, g, b))
    img = img.resize((size, size), Image.LANCZOS)
    return img.convert('RGBA')

def draw_circle_mask(size: int) -> Image.Image:
    """Круглая маска"""
    mask = Image.new('L', (size, size), 0)
    draw = ImageDraw.Draw(mask)
    margin = 4
    draw.ellipse([margin, margin, size - margin, size - margin], fill=255)
    return mask

def draw_snowflake(draw: ImageDraw.Draw, cx: int, cy: int, radius: int, color, width: int):
    """Красивая снежинка с 6 лучами и ветвями"""
    # 6 основных лучей
    for i in range(6):
        angle = math.radians(i * 60 - 90)  # Начинаем сверху
        x_end = cx + radius * math.cos(angle)
        y_end = cy + radius * math.sin(angle)
        draw.line([(cx, cy), (x_end, y_end)], fill=color, width=width)

        # Ветви на каждом луче (2 штуки на разных расстояниях)
        for branch_dist in [0.45, 0.72]:
            bx = cx + radius * branch_dist * math.cos(angle)
            by = cy + radius * branch_dist * math.sin(angle)
            branch_len = radius * 0.28 * (1.1 - branch_dist * 0.5)
            for side in [-1, 1]:
                branch_angle = angle + side * math.radians(45)
                bx_end = bx + branch_len * math.cos(branch_angle)
                by_end = by + branch_len * math.sin(branch_angle)
                draw.line([(bx, by), (bx_end, by_end)], fill=color, width=max(2, width - 2))

def draw_heartbeat(draw: ImageDraw.Draw, cx: int, cy: int, width_span: int, color, line_width: int):
    """Линия пульса (ЭКГ-стиль)"""
    # Точки пульса: плоская → резкий пик вверх → глубокий провал → возврат → плоская
    hw = width_span // 2
    points = [
        (cx - hw, cy),
        (cx - hw * 0.30, cy),
        (cx - hw * 0.15, cy - hw * 0.55),   # Пик вверх (выше)
        (cx + hw * 0.02, cy + hw * 0.20),    # Провал вниз
        (cx + hw * 0.15, cy - hw * 0.28),    # Маленький пик
        (cx + hw * 0.30, cy),
        (cx + hw, cy),
    ]
    # Рисуем сегменты линии
    for i in range(len(points) - 1):
        draw.line([points[i], points[i + 1]], fill=color, width=line_width)

    # Круглые окончания на стыках
    r = line_width // 2
    for p in points:
        draw.ellipse([p[0] - r, p[1] - r, p[0] + r, p[1] + r], fill=color)


def generate_icon():
    # Фон с градиентом
    bg = make_gradient_fast(SIZE)

    # Круглая маска
    mask = draw_circle_mask(SIZE)
    result = Image.new('RGBA', (SIZE, SIZE), (0, 0, 0, 0))
    result.paste(bg, (0, 0), mask)

    # Лёгкое свечение по краю круга
    glow = Image.new('RGBA', (SIZE, SIZE), (0, 0, 0, 0))
    glow_draw = ImageDraw.Draw(glow)
    for i in range(8):
        alpha = 30 - i * 3
        m = 4 + i * 2
        glow_draw.ellipse([m, m, SIZE - m, SIZE - m],
                         outline=(255, 255, 255, max(0, alpha)), width=2)
    result = Image.alpha_composite(result, glow)

    # Рисуем элементы на отдельном слое для сглаживания
    elements = Image.new('RGBA', (SIZE * 2, SIZE * 2), (0, 0, 0, 0))
    el_draw = ImageDraw.Draw(elements)
    c2 = CENTER * 2

    # Снежинка - белая, верхняя половина
    snow_cy = c2 - int(SIZE * 0.20)
    draw_snowflake(el_draw, c2, snow_cy, int(SIZE * 0.34), (255, 255, 255, 245), 16)

    # Центральная точка снежинки
    dot_r = 18
    el_draw.ellipse([c2 - dot_r, snow_cy - dot_r, c2 + dot_r, snow_cy + dot_r],
                    fill=(255, 255, 255, 245))

    # Пульс - яркий оранжевый, нижняя половина, крупный
    pulse_cy = c2 + int(SIZE * 0.28)
    pulse_color = (255, 120, 70, 255)  # Яркий оранжевый
    draw_heartbeat(el_draw, c2, pulse_cy, int(SIZE * 0.85), pulse_color, 26)

    # Уменьшаем 2x → 1x для антиалиасинга
    elements = elements.resize((SIZE, SIZE), Image.LANCZOS)

    # Композитим
    result = Image.alpha_composite(result, elements)

    # Сохраняем icon.png
    result.save('D:/dev/vasolog/assets/icon/icon.png', 'PNG')
    print('icon.png saved')

    # Foreground для adaptive icon (без фона, только элементы)
    fg = Image.new('RGBA', (SIZE, SIZE), (0, 0, 0, 0))
    # Перерисуем элементы с padding для adaptive icon (safe zone = 66%)
    fg_elements = Image.new('RGBA', (SIZE * 2, SIZE * 2), (0, 0, 0, 0))
    fg_draw = ImageDraw.Draw(fg_elements)

    # Уменьшенные элементы для safe zone
    scale = 0.62
    fg_snow_cy = c2 - int(SIZE * 0.10)
    draw_snowflake(fg_draw, c2, fg_snow_cy, int(SIZE * 0.30), (255, 255, 255, 240), 12)
    fg_draw.ellipse([c2 - 12, fg_snow_cy - 12, c2 + 12, fg_snow_cy + 12],
                    fill=(255, 255, 255, 240))
    fg_pulse_cy = c2 + int(SIZE * 0.22)
    draw_heartbeat(fg_draw, c2, fg_pulse_cy, int(SIZE * 0.55), pulse_color, 12)

    fg_elements = fg_elements.resize((SIZE, SIZE), Image.LANCZOS)
    fg = Image.alpha_composite(fg, fg_elements)
    fg.save('D:/dev/vasolog/assets/icon/icon_foreground.png', 'PNG')
    print('icon_foreground.png saved')

    # Splash icon - белые элементы на прозрачном фоне
    splash = Image.new('RGBA', (SIZE, SIZE), (0, 0, 0, 0))
    splash_el = Image.new('RGBA', (SIZE * 2, SIZE * 2), (0, 0, 0, 0))
    sp_draw = ImageDraw.Draw(splash_el)
    sp_snow_cy = c2 - int(SIZE * 0.10)
    draw_snowflake(sp_draw, c2, sp_snow_cy, int(SIZE * 0.30), (255, 255, 255, 255), 12)
    sp_draw.ellipse([c2 - 12, sp_snow_cy - 12, c2 + 12, sp_snow_cy + 12],
                    fill=(255, 255, 255, 255))
    sp_pulse_cy = c2 + int(SIZE * 0.22)
    draw_heartbeat(sp_draw, c2, sp_pulse_cy, int(SIZE * 0.55), (255, 255, 255, 255), 12)
    splash_el = splash_el.resize((SIZE, SIZE), Image.LANCZOS)
    splash = Image.alpha_composite(splash, splash_el)
    splash.save('D:/dev/vasolog/assets/icon/splash_icon.png', 'PNG')
    print('splash_icon.png saved')

if __name__ == '__main__':
    generate_icon()
