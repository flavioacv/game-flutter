#!/usr/bin/env python3
"""
Gerador de personagens no padrão oficial Pixel Adventure (Pixel Frog) 32x32.
Gera todos os spritesheets com anatomia, paleta, contorno #211f30 e timing exatos.
"""

import os
from PIL import Image

# Cores oficiais Pixel Adventure
OUTLINE  = (33, 31, 48, 255)      # #211f30 - Contorno universal escuro
WHITE    = (255, 255, 255, 255)   # #ffffff - Brilho dos olhos e highlights
TRANSP   = (0, 0, 0, 0)

# Headband / Faixa Ninja Vermelha (mesma paleta do Ninja Frog)
RED_HI   = (228, 74, 74, 255)     # #e44a4a
RED_MID  = (204, 48, 72, 255)     # #cc3048
RED_SHD  = (156, 27, 77, 255)     # #9c1b4d

# Traje Shinobi / Ninja (grafite azulado com gradiente suave)
SUIT_HI  = (94, 90, 122, 255)     # #5e5a7a highlight sutil
SUIT_MID = (55, 51, 77, 255)      # #37334d cor base
SUIT_SHD = (37, 34, 54, 255)      # #252236 sombra
SUIT_DRK = (25, 23, 36, 255)      # #191724 sombra profunda

# Ataduras brancas/cinzas nos pulsos e canelas
WRAP_MID = (200, 210, 220, 255)

# Pele na fenda dos olhos e mãos
SKIN_HI  = (251, 223, 177, 255)   # #fbdfb1
SKIN_MID = (242, 188, 126, 255)   # #f2bc7e

# Protetor metálico da testa
MET_HI   = (235, 240, 250, 255)
MET_MID  = (170, 180, 200, 255)
MET_SHD  = (110, 120, 140, 255)

# Cores do visor VR do modelo base
VR_COLORS = {
    (228, 201, 151), (207, 158, 110), (185, 110, 84), (161, 71, 68)
}

def render_ninja_frame(src_frame):
    """Renderiza um frame individual de 32x32 com o padrão Ninja Dude."""
    w, h = src_frame.size
    dst = Image.new('RGBA', (w, h), TRANSP)
    src = src_frame.load()
    out = dst.load()

    # Detectar bounding box do visor (rosto)
    vr_pixels = []
    for y in range(h):
        for x in range(w):
            p = src[x, y]
            if p[3] > 0 and p[:3] in VR_COLORS:
                vr_pixels.append((x, y))

    if vr_pixels:
        min_x = min(x for x, y in vr_pixels)
        max_x = max(x for x, y in vr_pixels)
        min_y = min(y for x, y in vr_pixels)
        max_y = max(y for x, y in vr_pixels)
        vr_h = max_y - min_y + 1
        vr_w = max_x - min_x + 1
    else:
        min_x, max_x, min_y, max_y, vr_h, vr_w = 0, 0, 0, 0, 0, 0

    for y in range(h):
        for x in range(w):
            p = src[x, y]
            if p[3] == 0:
                continue

            # Preserva contorno escuro universal #211f30
            if p[:3] == (33, 31, 48):
                out[x, y] = OUTLINE
                continue

            # Mãos (pele)
            if p[:3] in [(242, 188, 126), (251, 223, 177)] and y >= (min_y + vr_h if vr_pixels else 20):
                out[x, y] = SKIN_MID if p[:3] == (242, 188, 126) else SKIN_HI
                continue

            # Região do Rosto (Bandana, Fenda dos Olhos, Máscara)
            if p[:3] in VR_COLORS:
                rel_y = (y - min_y) / max(1, vr_h - 1)
                rel_x = (x - min_x) / max(1, vr_w - 1)

                # 1. Bandana Ninja na testa (rel_y <= 0.28)
                if rel_y <= 0.28:
                    if 0.35 <= rel_x <= 0.65:
                        out[x, y] = MET_HI if rel_y <= 0.1 else (MET_MID if rel_y <= 0.2 else MET_SHD)
                    else:
                        out[x, y] = RED_HI if rel_y <= 0.1 else (RED_MID if rel_y <= 0.2 else RED_SHD)
                    continue

                # 2. Fenda dos olhos (rel_y entre 0.29 e 0.50)
                if 0.29 <= rel_y <= 0.50:
                    if rel_x <= 0.12 or rel_x >= 0.88:
                        out[x, y] = SUIT_SHD if rel_x <= 0.12 else SUIT_MID
                    else:
                        # Olhos expressivos ninja
                        is_eye1 = 0.24 <= rel_x <= 0.40
                        is_eye2 = 0.60 <= rel_x <= 0.76
                        if is_eye1 or is_eye2:
                            if rel_y <= 0.38 and ((is_eye1 and rel_x <= 0.32) or (is_eye2 and rel_x <= 0.68)):
                                out[x, y] = WHITE
                            else:
                                out[x, y] = OUTLINE
                        else:
                            out[x, y] = SKIN_HI if rel_y <= 0.40 else SKIN_MID
                    continue

                # 3. Máscara Ninja (rel_y >= 0.51)
                if rel_y >= 0.51:
                    if rel_x <= 0.14 or rel_x >= 0.86:
                        out[x, y] = SUIT_SHD if rel_x <= 0.14 else SUIT_MID
                    else:
                        if rel_y <= 0.58:
                            out[x, y] = SUIT_HI
                        elif 0.46 <= rel_x <= 0.54:
                            out[x, y] = SUIT_SHD  # costura central
                        else:
                            out[x, y] = SUIT_MID
                    continue

            # Faixa na cintura (obi vermelha)
            if p[:3] == (255, 255, 255) and y >= 23:
                out[x, y] = RED_HI if x % 2 == 0 else RED_MID
                continue

            # Traje Shinobi (capuz, tronco, calça, sapatos tabi)
            if p[:3] in [(172, 247, 250), (255, 255, 255)]:
                out[x, y] = SUIT_HI
            elif p[:3] == (108, 217, 241):
                out[x, y] = SUIT_MID
            elif p[:3] == (47, 172, 218):
                out[x, y] = SUIT_SHD
            else:
                out[x, y] = SUIT_DRK

    # Adicionar o nó da bandana vermelha na lateral traseira quando houver espaço (x=5..7)
    if vr_pixels and min_y >= 8:
        knot_base_y = min_y + 1
        knot_coords = [
            (min_x - 3, knot_base_y, OUTLINE), (min_x - 2, knot_base_y, RED_HI), (min_x - 1, knot_base_y, OUTLINE),
            (min_x - 4, knot_base_y + 1, OUTLINE), (min_x - 3, knot_base_y + 1, RED_MID), (min_x - 2, knot_base_y + 1, RED_MID),
            (min_x - 4, knot_base_y + 2, OUTLINE), (min_x - 3, knot_base_y + 2, RED_SHD), (min_x - 2, knot_base_y + 2, OUTLINE),
            (min_x - 3, knot_base_y + 3, OUTLINE)
        ]
        for kx, ky, col in knot_coords:
            if 0 <= kx < w and 0 <= ky < h and out[kx, ky][3] == 0:
                out[kx, ky] = col

    return dst

def generate_all():
    base_src_dir = "assets/images/Main Characters/Virtual Guy"
    target_dir = "assets/images/Main Characters/Ninja Dude"
    os.makedirs(target_dir, exist_ok=True)

    animations = [
        "Idle (32x32).png",
        "Run (32x32).png",
        "Jump (32x32).png",
        "Fall (32x32).png",
        "Hit (32x32).png",
        "Double Jump (32x32).png",
        "Wall Jump (32x32).png",
    ]

    for anim_name in animations:
        src_path = os.path.join(base_src_dir, anim_name)
        if not os.path.exists(src_path):
            print(f"Aviso: {src_path} não encontrado, pulando...")
            continue

        src_sheet = Image.open(src_path)
        sheet_w, sheet_h = src_sheet.size
        frame_count = sheet_w // 32

        # Gerar sheet voltado para direita
        dst_sheet = Image.new('RGBA', (sheet_w, sheet_h), TRANSP)
        # Gerar sheet voltado para esquerda
        dst_sheet_left = Image.new('RGBA', (sheet_w, sheet_h), TRANSP)

        for i in range(frame_count):
            frame = src_sheet.crop((i * 32, 0, (i + 1) * 32, sheet_h))
            rendered_frame = render_ninja_frame(frame)
            dst_sheet.paste(rendered_frame, (i * 32, 0))

            # Versão invertida horizontalmente (left)
            left_frame = rendered_frame.transpose(Image.FLIP_LEFT_RIGHT)
            dst_sheet_left.paste(left_frame, (i * 32, 0))

        # Salvar padrão normal
        dst_path = os.path.join(target_dir, anim_name)
        dst_sheet.save(dst_path)

        # Salvar versão left
        base_name, ext = os.path.splitext(anim_name)
        left_name = f"{base_name.replace(' (32x32)', '')}-left (32x32){ext}"
        dst_left_path = os.path.join(target_dir, left_name)
        dst_sheet_left.save(dst_left_path)

        print(f"✓ {anim_name} ({frame_count} frames) & {left_name} gerados.")

    print(f"\nTodos os spritesheets foram gerados com sucesso em: {target_dir}")

if __name__ == "__main__":
    generate_all()
