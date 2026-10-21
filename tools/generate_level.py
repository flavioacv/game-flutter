#!/usr/bin/env python3
"""
Gera o Level-06.tmx com formatação CSV rigorosa compatível com o parser tiled/flame_tiled.
"""

WIDTH = 80
HEIGHT = 23
TILE_SIZE = 16

tiles = [[0 for _ in range(WIDTH)] for _ in range(HEIGHT)]

# Borda externa
# Teto (y=0)
tiles[0][0] = 92
for x in range(1, WIDTH - 1):
    tiles[0][x] = 134
tiles[0][WIDTH - 1] = 93

# Paredes laterais (y=1..HEIGHT-2)
for y in range(1, HEIGHT - 1):
    tiles[y][0] = 113
    tiles[y][WIDTH - 1] = 111

# Chão inferior contínuo (y=22)
tiles[HEIGHT - 1][0] = 114
for x in range(1, WIDTH - 1):
    tiles[HEIGHT - 1][x] = 90
tiles[HEIGHT - 1][WIDTH - 1] = 115

def draw_ground(x_start, y_top, width, height=3):
    for w in range(width):
        col = x_start + w
        if 0 <= col < WIDTH:
            if w == 0:
                t = 7
            elif w == width - 1:
                t = 9
            else:
                t = 8
            if 0 <= y_top < HEIGHT:
                tiles[y_top][col] = t
            for d in range(1, height):
                yy = y_top + d
                if 0 <= yy < HEIGHT - 1:
                    tiles[yy][col] = 30

def draw_brick_pillar(col, y_top, height):
    for h in range(height):
        yy = y_top + h
        if 0 <= yy < HEIGHT - 1:
            if h == 0:
                tiles[yy][col] = 16
            elif h == height - 1:
                tiles[yy][col] = 60
            else:
                tiles[yy][col] = 38

def draw_brick_block(x_start, y, width):
    for w in range(width):
        col = x_start + w
        if 0 <= col < WIDTH and 0 <= y < HEIGHT:
            tiles[y][col] = 16

# 1. Seção Inicial
draw_ground(2, 18, 12, 4)

# 2. Degraus de Quina / Kina Boost
draw_brick_block(28, 19, 3)
draw_brick_block(33, 17, 3)
draw_brick_block(38, 15, 3)
draw_ground(42, 14, 6, 8)

# 3. Parede Vertical para Escalada
draw_brick_pillar(50, 6, 16)
draw_brick_block(51, 6, 7)

# 4. Plataforma intermediária e serra
draw_ground(62, 16, 7, 6)

# 5. Reta Final com Checkpoint
draw_ground(70, 18, 9, 4)

# Gerar CSV com a vírgula obrigatória no final de cada linha (exceto a última)
csv_lines = []
for idx, row in enumerate(tiles):
    line_str = ",".join(str(val) for val in row)
    if idx < len(tiles) - 1:
        line_str += ","
    csv_lines.append(line_str)
csv_data = "\n".join(csv_lines)

collisions = [
    # Bordas externas
    {"x": 0, "y": 0, "w": 16, "h": 368},
    {"x": 0, "y": 0, "w": 1280, "h": 16},
    {"x": 1264, "y": 0, "w": 16, "h": 368},
    {"x": 0, "y": 352, "w": 1280, "h": 16},

    # 1. Spawn ground
    {"x": 32, "y": 288, "w": 192, "h": 64},

    # 2. Degraus Kina
    {"x": 448, "y": 304, "w": 48, "h": 16},
    {"x": 528, "y": 272, "w": 48, "h": 16},
    {"x": 608, "y": 240, "w": 48, "h": 16},
    {"x": 672, "y": 224, "w": 96, "h": 128},

    # 3. Parede de escalada
    {"x": 800, "y": 96, "w": 16, "h": 256},
    {"x": 816, "y": 96, "w": 112, "h": 16},

    # 4. Plataforma semi-sólida
    {"x": 928, "y": 192, "w": 64, "h": 16, "type": "Platform", "class": "Platform"},
    {"x": 992, "y": 256, "w": 112, "h": 96},

    # 5. Acelerador
    {"x": 1072, "y": 336, "w": 48, "h": 16, "type": "boost_right", "class": "boost_right"},

    # 6. Plataforma final
    {"x": 1120, "y": 288, "w": 144, "h": 64},
]

spawnpoints = [
    {"type": "Player", "class": "Player", "name": "Player", "x": 64, "y": 240, "w": 32, "h": 32},
    {"type": "Fruit", "class": "Fruit", "name": "Apple", "x": 128, "y": 240, "w": 32, "h": 32},
    {"type": "Fruit", "class": "Fruit", "name": "Bananas", "x": 176, "y": 240, "w": 32, "h": 32},
    {
        "type": "Chicken", "class": "Chicken", "name": "Chicken", "x": 288, "y": 320, "w": 32, "h": 32,
        "props": [("offNeg", "float", "4"), ("offPos", "float", "4")]
    },
    {"type": "Fruit", "class": "Fruit", "name": "Cherries", "x": 536, "y": 224, "w": 32, "h": 32},
    {"type": "Fruit", "class": "Fruit", "name": "Cherries", "x": 616, "y": 192, "w": 32, "h": 32},
    {"type": "Fruit", "class": "Fruit", "name": "Kiwi", "x": 848, "y": 64, "w": 32, "h": 32},
    {"type": "Fruit", "class": "Fruit", "name": "Orange", "x": 896, "y": 64, "w": 32, "h": 32},
    {
        "type": "Saw", "class": "Saw", "name": "Saw", "x": 1032, "y": 192, "w": 32, "h": 32,
        "props": [("isVertical", "bool", "true"), ("offNeg", "float", "3"), ("offPos", "float", "3")]
    },
    {"type": "Checkpoint", "class": "Checkpoint", "name": "Checkpoint", "x": 1184, "y": 224, "w": 64, "h": 64},
]

tmx_content = f"""<?xml version="1.0" encoding="UTF-8"?>
<map version="1.10" tiledversion="1.11.2" orientation="orthogonal" renderorder="right-down" width="{WIDTH}" height="{HEIGHT}" tilewidth="{TILE_SIZE}" tileheight="{TILE_SIZE}" infinite="0" nextlayerid="5" nextobjectid="100">
 <tileset firstgid="1" source="Pixel Adventure.tsx"/>
 <layer id="1" name="Background" width="{WIDTH}" height="{HEIGHT}">
  <data encoding="csv">
{csv_data}
</data>
 </layer>
 <objectgroup id="2" name="Spawnpoints">
"""

obj_id = 1
for sp in spawnpoints:
    type_attr = f'type="{sp["type"]}" class="{sp.get("class", sp["type"])}"'
    name_attr = f'name="{sp["name"]}"'
    x = sp["x"]
    y = sp["y"]
    w = sp["w"]
    h = sp["h"]
    if "props" in sp:
        tmx_content += f'  <object id="{obj_id}" {name_attr} {type_attr} x="{x}" y="{y}" width="{w}" height="{h}">\n'
        tmx_content += '   <properties>\n'
        for pname, ptype, pval in sp["props"]:
            tmx_content += f'    <property name="{pname}" type="{ptype}" value="{pval}"/>\n'
        tmx_content += '   </properties>\n  </object>\n'
    else:
        tmx_content += f'  <object id="{obj_id}" {name_attr} {type_attr} x="{x}" y="{y}" width="{w}" height="{h}"/>\n'
    obj_id += 1

tmx_content += ' </objectgroup>\n <objectgroup id="3" name="Collisions">\n'

for col in collisions:
    type_attr = f'type="{col["type"]}" class="{col.get("class", col["type"])}"' if "type" in col else ''
    tmx_content += f'  <object id="{obj_id}" {type_attr} x="{col["x"]}" y="{col["y"]}" width="{col["w"]}" height="{col["h"]}"/>\n'
    obj_id += 1

tmx_content += ' </objectgroup>\n</map>\n'

target_path = "assets/tiles/Level-06.tmx"
with open(target_path, "w", encoding="utf-8") as f:
    f.write(tmx_content)

print(f"Sucesso! {target_path} gerado e corrigido.")
