#!/usr/bin/env python3
"""Gera um personagem pixel art 32x32 no estilo do Mask Dude."""

import os
from PIL import Image

# Paleta (RGBA)
T  = (0, 0, 0, 0)           # transparente
SK = (255, 204, 170, 255)   # pele
C1 = (45, 28, 80, 255)      # capuz escuro
C2 = (70, 45, 120, 255)     # capuz medio
C3 = (95, 65, 150, 255)     # capuz claro / dobra
R1 = (60, 40, 90, 255)      # roupa escura
R2 = (85, 60, 125, 255)     # roupa media
R3 = (110, 85, 155, 255)    # roupa clara / highlight
M  = (25, 25, 40, 255)      # mascara
E  = (0, 255, 255, 255)     # brilho ciano olhos
W  = (230, 245, 255, 255)   # branco olhos
B  = (200, 50, 50, 255)     # faixa vermelha
B2 = (150, 30, 30, 255)     # faixa sombra
K  = (20, 20, 20, 255)      # botas/luvas
G  = (120, 120, 130, 255)   # cinza parede


def new_frame():
    return [[T for _ in range(32)] for _ in range(32)]


def put(pixels, x, y, color):
    if 0 <= x < 32 and 0 <= y < 32:
        pixels[y][x] = color


def rect(pixels, x, y, w, h, color):
    for yy in range(y, y + h):
        for xx in range(x, x + w):
            put(pixels, xx, yy, color)


def hline(pixels, x, y, w, color):
    for xx in range(x, x + w):
        put(pixels, xx, y, color)


def vline(pixels, x, y, h, color):
    for yy in range(y, y + h):
        put(pixels, x, yy, color)


def mirror_x(pixels):
    return [row[::-1] for row in pixels]


def to_image(pixels):
    img = Image.new('RGBA', (32, 32), T)
    data = [pixels[y][x] for y in range(32) for x in range(32)]
    img.putdata(data)
    return img


def join_frames(frames):
    w = len(frames) * 32
    img = Image.new('RGBA', (w, 32), T)
    for i, fr in enumerate(frames):
        img.paste(to_image(fr), (i * 32, 0))
    return img


def build_sheet(frames, name, folder):
    img = join_frames(frames)
    img.save(os.path.join(folder, f"{name} (32x32).png"))
    left = [mirror_x(fr) for fr in frames]
    join_frames(left).save(os.path.join(folder, f"{name}-left (32x32).png"))


# ============================================================================
# Desenho do personagem
# ============================================================================
def draw_character(pixels,
                   head_y=0,
                   body_y=0,
                   left_leg=(0, 0), right_leg=(0, 0),
                   left_arm=(0, 0), right_arm=(0, 0),
                   mask_offset=0,
                   lean=0,
                   eyes_closed=False,
                   show_wall=False):
    """Desenha o ninja em pixels 32x32."""
    cx = 16
    base_y = 28 + body_y

    # Pernas
    llx, lly = left_leg
    rlx, rly = right_leg
    # Coxa/calca
    rect(pixels, cx - 4 + llx, base_y - 10 + lly, 3, 6, R2)
    rect(pixels, cx + 1 + rlx, base_y - 10 + rly, 3, 6, R2)
    # Sombra nas coxas
    vline(pixels, cx - 4 + llx, base_y - 10 + lly, 6, R1)
    vline(pixels, cx + 3 + rlx, base_y - 10 + rly, 6, R1)
    # Botas
    rect(pixels, cx - 4 + llx, base_y - 5 + lly, 3, 5, K)
    rect(pixels, cx + 1 + rlx, base_y - 5 + rly, 3, 5, K)
    # Detalhe bota
    hline(pixels, cx - 4 + llx, base_y - 3 + lly, 3, G)
    hline(pixels, cx + 1 + rlx, base_y - 3 + rly, 3, G)

    # Corpo (quimono) 10x12
    body_top = base_y - 21 + body_y
    rect(pixels, cx - 5, body_top, 10, 13, R2)
    # Lateral sombra
    vline(pixels, cx - 5, body_top, 13, R1)
    vline(pixels, cx + 4, body_top, 13, R1)
    # Abertura do quimono (V)
    put(pixels, cx - 1, body_top + 2, M)
    put(pixels, cx, body_top + 2, M)
    put(pixels, cx - 1, body_top + 3, M)
    put(pixels, cx, body_top + 3, M)
    put(pixels, cx - 1, body_top + 4, M)
    put(pixels, cx, body_top + 4, M)
    # Faixa vermelha
    hline(pixels, cx - 5, body_top + 7, 10, B)
    hline(pixels, cx - 5, body_top + 8, 10, B2)
    # No na faixa
    rect(pixels, cx - 2, body_top + 7, 4, 2, B)
    put(pixels, cx - 1, body_top + 9, B)
    put(pixels, cx, body_top + 9, B)

    # Pescoco
    rect(pixels, cx - 2, body_top - 2, 4, 2, SK)
    hline(pixels, cx - 2, body_top - 2, 4, M)  # gola mascara

    # Cabeca/capuz
    hx = cx - 6 + lean
    hy = body_top - 13 + head_y
    # Forma base do capuz
    rect(pixels, hx, hy, 12, 11, C1)
    # Topo arredondado
    hline(pixels, hx + 1, hy, 10, C1)
    hline(pixels, hx + 3, hy - 1, 6, C1)
    # Orelhas/pontas do capuz
    put(pixels, hx - 1, hy + 5, C2)
    put(pixels, hx - 2, hy + 6, C2)
    put(pixels, hx - 2, hy + 7, C2)
    put(pixels, hx + 12, hy + 5, C2)
    put(pixels, hx + 13, hy + 6, C2)
    put(pixels, hx + 13, hy + 7, C2)
    # Dobra clara no capuz
    hline(pixels, hx + 1, hy + 1, 10, C2)
    vline(pixels, hx + 1, hy + 1, 9, C2)
    vline(pixels, hx + 10, hy + 1, 9, C2)

    # Rosto / mascara
    face_y = hy + 4
    rect(pixels, hx + 2, face_y, 8, 5, M)
    # Olhos
    eye_y = face_y + 2
    if not eyes_closed:
        put(pixels, hx + 3 + mask_offset, eye_y, W)
        put(pixels, hx + 7 + mask_offset, eye_y, W)
        put(pixels, hx + 3 + mask_offset, eye_y - 1, E)
        put(pixels, hx + 7 + mask_offset, eye_y - 1, E)
    else:
        hline(pixels, hx + 3 + mask_offset, eye_y, 2, W)
        hline(pixels, hx + 7 + mask_offset, eye_y, 2, W)

    # Bracos
    lax, lay = left_arm
    rax, ray = right_arm
    # Manga esquerda
    rect(pixels, cx - 8 + lax, body_top + 1 + lay, 3, 7, R2)
    vline(pixels, cx - 8 + lax, body_top + 1 + lay, 7, R1)
    # Luva esquerda
    rect(pixels, cx - 8 + lax, body_top + 7 + lay, 3, 3, K)
    # Manga direita
    rect(pixels, cx + 5 + rax, body_top + 1 + ray, 3, 7, R2)
    vline(pixels, cx + 7 + rax, body_top + 1 + ray, 7, R1)
    # Luva direita
    rect(pixels, cx + 5 + rax, body_top + 7 + ray, 3, 3, K)

    # Indicacao de parede (wall jump)
    if show_wall:
        vline(pixels, 30, 6, 20, G)
        put(pixels, 29, 8, G)
        put(pixels, 29, 20, G)


# ============================================================================
# Animacoes
# ============================================================================
def idle_frames():
    frames = []
    # 11 frames: respiracao suave e piscar ocasional
    head_cycle = [0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 0]
    arm_cycle_l = [0, 0, 0, 1, 1, 0, 0, 0, 1, 1, 0]
    arm_cycle_r = [0, 1, 1, 0, 0, 0, 1, 1, 0, 0, 0]
    for i in range(11):
        f = new_frame()
        draw_character(f,
                       head_y=head_cycle[i],
                       body_y=head_cycle[i] // 2,
                       left_arm=(0, arm_cycle_l[i]),
                       right_arm=(0, arm_cycle_r[i]),
                       eyes_closed=(i == 9))
        frames.append(f)
    return frames


def run_frames():
    frames = []
    # 12 frames de ciclo de corrida
    cycle = [
        # body_y, head_y, llx, lly, rlx, rly, lax, lay, rax, ray, lean
        (0, 0,  0, 0,  0, 0,  0, 0,  0, 0,  0),
        (0, -1, 1, -1, -1, 0, 0, 1, 0, -1, 1),
        (-1, -2, 2, -2, -2, 1, 0, 2, 0, -2, 1),
        (0, -1, 1, -1, -1, 0, 0, 1, 0, -1, 0),
        (0, 0,  0, 0,  0, 0,  0, 0,  0, 0,  0),
        (0, -1, -1, 0, 1, -1, 0, -1, 0, 1, 1),
        (-1, -2, -2, 1, 2, -2, 0, -2, 0, 2, 1),
        (0, -1, -1, 0, 1, -1, 0, -1, 0, 1, 0),
        (0, 0,  0, 0,  0, 0,  0, 0,  0, 0,  0),
        (0, -1, 1, -2, -1, 1, 0, 1, 0, -1, 1),
        (-1, -2, 2, -3, -2, 2, 0, 2, 0, -2, 1),
        (0, -1, 1, -1, -1, 0, 0, 1, 0, -1, 0),
    ]
    for vals in cycle:
        f = new_frame()
        draw_character(f,
                       body_y=vals[0],
                       head_y=vals[1],
                       left_leg=(vals[2], vals[3]),
                       right_leg=(vals[4], vals[5]),
                       left_arm=(vals[6], vals[7]),
                       right_arm=(vals[8], vals[9]),
                       lean=vals[10])
        frames.append(f)
    return frames


def jump_frame():
    f = new_frame()
    draw_character(f,
                   head_y=-2,
                   body_y=-2,
                   left_leg=(-1, -3),
                   right_leg=(2, -1),
                   left_arm=(0, -4),
                   right_arm=(0, -4))
    return [f]


def fall_frame():
    f = new_frame()
    draw_character(f,
                   head_y=-1,
                   body_y=-1,
                   left_leg=(-2, 1),
                   right_leg=(2, 1),
                   left_arm=(0, 1),
                   right_arm=(0, 1))
    return [f]


def hit_frames():
    frames = []
    for i in range(7):
        f = new_frame()
        # Recuo para tras
        recoil = -1 if i < 3 else 0
        if i % 2 == 0:
            draw_character(f,
                           head_y=0,
                           body_y=0,
                           left_leg=(1 + recoil, 0),
                           right_leg=(-1 + recoil, 0),
                           left_arm=(1 + recoil, 0),
                           right_arm=(-1 + recoil, 0),
                           lean=-1,
                           eyes_closed=(i > 2))
        else:
            # Frame de flash branco
            temp = new_frame()
            draw_character(temp,
                           head_y=0,
                           body_y=0,
                           left_leg=(1 + recoil, 0),
                           right_leg=(-1 + recoil, 0),
                           left_arm=(1 + recoil, 0),
                           right_arm=(-1 + recoil, 0),
                           lean=-1,
                           eyes_closed=(i > 2))
            for y in range(32):
                for x in range(32):
                    if temp[y][x][3] > 0:
                        f[y][x] = (255, 255, 255, 200)
        frames.append(f)
    return frames


def double_jump_frames():
    frames = []
    for i in range(6):
        f = new_frame()
        t = i / 5.0
        lean = int((t - 0.5) * 4)
        draw_character(f,
                       head_y=-3,
                       body_y=-3,
                       left_leg=(-2 + int(t * 4), -2),
                       right_leg=(2 - int(t * 4), -1),
                       left_arm=(-1 - int(t * 2), -3),
                       right_arm=(1 + int(t * 2), -3),
                       lean=lean)
        frames.append(f)
    return frames


def wall_jump_frames():
    frames = []
    for i in range(5):
        f = new_frame()
        lean = 3 if i < 3 else -1
        body_off = -1 if i < 3 else -3
        draw_character(f,
                       head_y=-1,
                       body_y=body_off,
                       left_leg=(0, 0),
                       right_leg=(3, 0),
                       left_arm=(0, -3),
                       right_arm=(3, -3),
                       lean=lean,
                       show_wall=True)
        frames.append(f)
    return frames


# ============================================================================
# Geracao
# ============================================================================
def main():
    folder = "assets/images/Main Characters/Ninja Dude"
    os.makedirs(folder, exist_ok=True)

    build_sheet(idle_frames(), "Idle", folder)
    build_sheet(run_frames(), "Run", folder)
    build_sheet(jump_frame(), "Jump", folder)
    build_sheet(fall_frame(), "Fall", folder)
    build_sheet(hit_frames(), "Hit", folder)
    build_sheet(double_jump_frames(), "Double Jump", folder)
    build_sheet(wall_jump_frames(), "Wall Jump", folder)

    print(f"Personagem gerado em: {folder}")


if __name__ == "__main__":
    main()
