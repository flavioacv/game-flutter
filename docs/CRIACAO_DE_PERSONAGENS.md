# Guia de Criação e Integração de Personagens (Pixel Adventure)

Este documento descreve o processo completo para criar, desenhar e integrar novos personagens jogáveis no projeto **Pixel Adventure**.

---

## 1. Padrão Visual e Artístico

Os personagens do jogo seguem a estética oficial do pacote *Pixel Adventure*:

| Propriedade | Valor / Regra |
| :--- | :--- |
| **Tamanho do Frame** | $32 \times 32$ pixels |
| **Contorno Oficial** | Hex `#211f30` / RGBA `(33, 31, 48, 255)` |
| **Linha de Base do Chão** | Os pés tocam a linha $y = 31$ (ou $y = 30$ em repouso) |
| **Anatomia** | Formato *"bean / chibi"* — cabeça grande expressiva integrada ao tronco |
| **Iluminação** | Luz superior/frontal (tons claros no topo da cabeça e ombros, sombras no dorso/costas) |
| **Regra da Casca Externa** | Ao gerar a partir de um rig base (ex: *Virtual Guy*), deve-se extrair **apenas o contorno externo** e descartar linhas internas de visor/capacete para manter a cabeça lisa e orgânica. |

---

## 2. As 14 Folhas de Spritesheet Exigidas

Cada personagem precisa de **14 arquivos `.png`** localizados em:  
`assets/images/Main Characters/<Nome do Personagem>/`

| Arquivo | Quantidade de Frames | Largura x Altura | Descrição |
| :--- | :---: | :---: | :--- |
| `Idle (32x32).png` | 11 | $352 \times 32$ px | Respiração e postura parado olhando para a direita |
| `Idle-left (32x32).png` | 11 | $352 \times 32$ px | Respiração olhando para a esquerda |
| `Run (32x32).png` | 12 | $384 \times 32$ px | Ciclo de corrida para a direita |
| `Run-left (32x32).png` | 12 | $384 \times 32$ px | Ciclo de corrida para a esquerda |
| `Jump (32x32).png` | 1 | $32 \times 32$ px | Subida do pulo normal para a direita |
| `Jump-left (32x32).png` | 1 | $32 \times 32$ px | Subida do pulo normal para a esquerda |
| `Fall (32x32).png` | 1 | $32 \times 32$ px | Queda no ar para a direita |
| `Fall-left (32x32).png` | 1 | $32 \times 32$ px | Queda no ar para a esquerda |
| `Double Jump (32x32).png` | 6 | $192 \times 32$ px | Cambalhota / giro do segundo pulo no ar |
| `Double Jump-left (32x32).png` | 6 | $192 \times 32$ px | Giro do duplo pulo para a esquerda |
| `Hit (32x32).png` | 7 | $224 \times 32$ px | Reação ao tomar dano ou colidir com armadilha |
| `Hit-left (32x32).png` | 7 | $224 \times 32$ px | Reação de dano voltada para a esquerda |
| `Wall Jump (32x32).png` | 5 | $160 \times 32$ px | Apoio e deslizamento na parede direita |
| `Wall Jump-left (32x32).png` | 5 | $160 \times 32$ px | Apoio e deslizamento na parede esquerda |

---

## 3. Geração Automatizada de Sprites

O script utilitário [`tools/generate_character.py`](file:///Volumes/Externo%201/projetos/zurc/game-flutter/tools/generate_character.py) automatiza a extração do movimento anatômico e gera as 14 folhas de spritesheets mantendo sincronia perfeita de passos, pulos e giros.

### Exemplo de uso para criar um novo personagem:

```python
from tools.generate_character import generate_character_sheets, extract_outer_boundary, OUTLINE, TRANSP

def render_meu_personagem(src_frame, is_facing_left=False):
    w, h = src_frame.size
    dst = Image.new('RGBA', (w, h), TRANSP)
    src = src_frame.load()
    out = dst.load()

    # 1. Extrair máscara de opacidade e borda externa pura
    mask = [[1 if src[x, y][3] > 0 else 0 for x in range(w)] for y in range(h)]
    outer_border = extract_outer_boundary(mask, w, h)

    # 2. Preencher cores do personagem
    for y in range(h):
        for x in range(w):
            if not mask[y][x]:
                continue
            if (x, y) in outer_border:
                out[x, y] = OUTLINE
                continue
            
            # Aplicar sua paleta de cores (ex: tons de armadura, túnica, etc.)
            out[x, y] = (100, 150, 255, 255) # Exemplo azul

    return dst

# Gerar todas as 14 animações para "Aqua Dude"
generate_character_sheets("Aqua Dude", render_meu_personagem)
```

---

## 4. Registro do Personagem no Flutter

Após gerar os 14 arquivos na pasta `assets/images/Main Characters/<Nome>/`:

### Passo 1: Registrar no `pubspec.yaml`
Abra o [`pubspec.yaml`](file:///Volumes/Externo%201/projetos/zurc/game-flutter/pubspec.yaml) e adicione a nova pasta na seção `flutter.assets`:

```yaml
flutter:
  assets:
    # ...
    - assets/images/Main Characters/Meu Personagem/
```
Depois execute no terminal:
```bash
flutter pub get
```

### Passo 2: Registrar no Menu de Seleção
Abra [`lib/modules/menu_select/menu_select_page.dart`](file:///Volumes/Externo%201/projetos/zurc/game-flutter/lib/modules/menu_select/menu_select_page.dart) e adicione o nome do personagem à lista `characters`:

```dart
final List<String> characters = [
  'Ninja Frog',
  'Mask Dude',
  'Pink Man',
  'Virtual Guy',
  'Ninja Dude',
  'Knight Dude',
  'Skull Dude',
  'Mage Dude',
  'Mice Dude',
  'Shark Dude',
  'Death Dude',
  'Meu Personagem', // <- Adicione aqui
];
```

O componente [`Player`](file:///Volumes/Externo%201/projetos/zurc/game-flutter/lib/components/player.dart) em Flame carregará automaticamente todas as animações dinamicamente a partir do nome selecionado!
