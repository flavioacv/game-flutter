#!/usr/bin/env python3
"""
tools/generate_character.py
Script modular para geração de novos personagens no estilo Pixel Adventure (32x32).
Gera automaticamente as 14 folhas de spritesheet necessárias para o Flame Player:
- Idle, Idle-left (11 frames)
- Run, Run-left (12 frames)
- Jump, Jump-left (1 frame)
- Fall, Fall-left (1 frame)
- Double Jump, Double Jump-left (6 frames)
- Hit, Hit-left (7 frames)
- Wall Jump, Wall Jump-left (5 frames)
"""

import os
from PIL import Image

OUTLINE = (33, 31, 48, 255)  # Contorno oficial #211f30
WHITE   = (255, 255, 255, 255)
TRANSP  = (0, 0, 0, 0)

def extract_outer_boundary(mask, w, h):
    """Retorna o conjunto de coordenadas (x, y) que formam a borda externa da silhueta."""
    border = set()
    for y in range(h):
        for x in range(w):
            if mask[y][x]:
                is_edge = False
                for dx, dy in [(-1, 0), (1, 0), (0, -1), (0, 1)]:
                    nx, ny = x + dx, y + dy
                    if nx < 0 or nx >= w or ny < 0 or ny >= h or not mask[ny][nx]:
                        is_edge = True
                        break
                if is_edge:
                    border.add((x, y))
    return border

def generate_character_sheets(char_name, render_frame_func, base_char='Virtual Guy'):
    """
    Lê os spritesheets do personagem base, processa cada frame com render_frame_func
    e salva os 14 spritesheets no diretório assets/images/Main Characters/{char_name}/.
    """
    base_dir = f'assets/images/Main Characters/{base_char}'
    out_dir = f'assets/images/Main Characters/{char_name}'
    os.makedirs(out_dir, exist_ok=True)

    anim_files = [
        'Idle (32x32).png',
        'Idle-left (32x32).png',
        'Run (32x32).png',
        'Run-left (32x32).png',
        'Jump (32x32).png',
        'Jump-left (32x32).png',
        'Fall (32x32).png',
        'Fall-left (32x32).png',
        'Double Jump (32x32).png',
        'Hit (32x32).png',
        'Hit-left (32x32).png',
        'Wall Jump (32x32).png'
    ]

    for fname in anim_files:
        in_path = os.path.join(base_dir, fname)
        if not os.path.exists(in_path):
            continue

        src_sheet = Image.open(in_path).convert('RGBA')
        sheet_w, sheet_h = src_sheet.size
        num_frames = sheet_w // 32
        is_left = '-left' in fname

        dst_sheet = Image.new('RGBA', (sheet_w, sheet_h), TRANSP)

        for i in range(num_frames):
            src_frame = src_sheet.crop((i * 32, 0, (i + 1) * 32, 32))
            frame_rendered = render_frame_func(src_frame, is_facing_left=is_left)
            dst_sheet.paste(frame_rendered, (i * 32, 0))

        out_path = os.path.join(out_dir, fname)
        dst_sheet.save(out_path)
        print(f"[{char_name}] Salvo {fname} ({num_frames} frames)")

    # Gerar versões espelhadas ausentes: Double Jump-left e Wall Jump-left
    def make_left(right_name, left_name):
        r_path = os.path.join(out_dir, right_name)
        l_path = os.path.join(out_dir, left_name)
        if os.path.exists(r_path):
            src = Image.open(r_path).convert('RGBA')
            w, h = src.size
            num_f = w // 32
            dst = Image.new('RGBA', (w, h), TRANSP)
            for i in range(num_f):
                f = src.crop((i * 32, 0, (i + 1) * 32, 32)).transpose(Image.FLIP_LEFT_RIGHT)
                dst.paste(f, (i * 32, 0))
            dst.save(l_path)
            print(f"[{char_name}] Gerado {left_name}")

    make_left('Double Jump (32x32).png', 'Double Jump-left (32x32).png')
    make_left('Wall Jump (32x32).png', 'Wall Jump-left (32x32).png')
    print(f"==> Personagem '{char_name}' finalizado com 14 folhas de spritesheet!")

if __name__ == '__main__':
    print("Módulo de geração de personagens carregado.")
    print("Importe este módulo ou consulte docs/CRIACAO_DE_PERSONAGENS.md para criar novos heróis.")
