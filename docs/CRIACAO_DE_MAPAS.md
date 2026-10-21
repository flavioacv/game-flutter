# Guia de Criação e Configuração de Mapas (Tiled / Flame)

Este documento descreve como criar, estruturar e validar mapas (fases) para o jogo **Pixel Adventure** utilizando o editor **Tiled** ou scripts geradores em Python.

---

## 1. Arquitetura do Mapa (`.tmx`)

Os mapas ficam localizados em:  
`assets/tiles/Level-XX.tmx`

- **Tamanho do Tile:** $16 \times 16$ pixels.
- **Dimensões Típicas:** 40 a 100 tiles de largura por 23 tiles de altura (resolução nativa de altura: $23 \times 16 = 368\text{ px}$).
- **Orientação:** Ortogonal (formato CSV).

> [!CAUTION]
> ### Regra Crítica de Formatação CSV no Tiled (Flame / Dart)
> O parser da biblioteca `tiled` em Dart exige estritamente que **cada linha da matriz CSV termine com vírgula** antes da quebra de linha:
> ```csv
> 0,0,113,0,0,0,93,
> 114,90,90,90,90,90,115
> ```
> Se a linha terminar sem vírgula, o parser concatena o último número da linha com o primeiro da linha seguinte (ex: `93` e `114` viram `93114`), provocando o erro fatal `FormatException: Invalid radix-10 number`.

---

## 2. Camadas Obrigatórias (Layers)

Cada arquivo `.tmx` deve conter as seguintes camadas configuradas:

### 1. `Background` (Image Layer)
Define o papel de parede temático que preenche o fundo:
- `Brown.png`
- `Blue.png`
- `Gray.png`
- `Green.png`
- `Pink.png`
- `Purple.png`
- `Yellow.png`

### 2. `Terrain` (Tile Layer)
Define os blocos com física de colisão sólida e degraus de escalada.
- **Tilesets utilizados:** `Terrain (16x16).png`.
- **IDs Principais:**
  - `92, 134, 93`: Borda superior do teto.
  - `113, 111`: Paredes sólidas laterais (esquerda e direita).
  - `114, 90, 115`: Chão inferior sólido.
  - `7, 8, 9`: Plataformas elevadas de terra com grama (início, meio e fim).
  - `30`: Preenchimento subterrâneo sólido de terra.
  - `174, 175`: Degraus de madeira / plataformas semi-sólidas (*pass-through*).

### 3. `Traps` (Tile Layer / Object Layer)
Contém espinhos fixos e elementos perigosos no cenário que causam colisão de dano imediata no jogador.

### 4. `Spawnpoints` (Object Group Layer)
Contém os objetos de gameplay posicionados no mundo:

| Objeto | Tipo / Classe | Propriedades Necessárias | Descrição |
| :--- | :---: | :--- | :--- |
| `Player` | Ponto de início | `x`, `y` | Posição onde o personagem surge ao carregar a fase. |
| `Checkpoint` | Ponto de salvamento | `x`, `y` | Mastro que se desdobra ao ser tocado pelo jogador. |
| `Saw` | Armadilha móvel | `isVertical` (bool), `offNeg` (int), `offPos` (int) | Serra circular que patrulha um percurso em linha reta. |
| `Chicken` | Inimigo terrestre | `x`, `y`, `offNeg`, `offPos` | Galinha que patrulha a plataforma e pode ser pisada para rebote. |
| `Fruit` | Coletável | `x`, `y` | Frutas (maçã, banana, morango) que dão pontos. |
| `boost_right` | Impulsionador Kina | `x`, `y` | Acelerador cinético de parede para manobras de Kina Boost. |

---

## 3. Geração Automatizada de Mapas

Você pode criar mapas diretamente via código usando o utilitário [`tools/generate_level.py`](file:///Volumes/Externo%201/projetos/zurc/game-flutter/tools/generate_level.py):

```bash
python3 tools/generate_level.py
```

O script monta a matriz de terreno com cálculo de bordas automáticas, posiciona o teto, chão, paredes de escalada, poços de serras, plataformas e exporta o XML com a formatação CSV 100% compatível com o Flame.

---

## 4. Testes e Validação Automatizada

Para garantir que todos os mapas (`Level-01.tmx` até o mapa mais recente) continuam sendo carregados perfeitamente pelo motor sem falhas de tileset ou colisão, execute o teste automatizado:

```bash
flutter test test/level_test.dart
```

Se todos os níveis exibirem `+X: All tests passed!`, o mapa está pronto e certificado para rodar tanto no emulador quanto em dispositivos reais Android e iOS!
