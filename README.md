# Pixel Adventure

A 2D Pixel Art Platformer coded in Flutter and Flame.

---

## 📚 Documentação Técnica do Projeto

- **[Criação e Integração de Personagens](docs/CRIACAO_DE_PERSONAGENS.md)**: Guia completo para criação de novos personagens, anatomia chibi 32x32, padrão oficial de contorno `#211f30`, as 14 folhas de spritesheet e registro no menu de seleção.
- **[Criação e Configuração de Mapas](docs/CRIACAO_DE_MAPAS.md)**: Guia de arquitetura dos mapas Tiled (`.tmx`), camadas de terreno, objetos de spawn (`Player`, `Checkpoint`, `Saw`, `Chicken`, `Fruit`, `boost_right`), regra estrita do CSV e testes automatizados.

---

## 🛠️ Ferramentas Utilitárias (`tools/`)

- [`tools/generate_character.py`](tools/generate_character.py): Script modular para geração automatizada dos 14 spritesheets de novos personagens.
- [`tools/generate_level.py`](tools/generate_level.py): Script gerador de mapas Tiled com validação rigorosa de sintaxe CSV e posicionamento de armadilhas.

---

## 🧪 Testes Automatizados

Para certificar que todos os mapas e recursos do jogo continuam funcionando:

```bash
flutter test test/level_test.dart
```

---

## 🖼️ Créditos dos Recursos Visuais
- Asset pack original: <https://pixelfrog-assets.itch.io/pixel-adventure-1>
- Tutorial de referência: <https://www.youtube.com/playlist?list=PLRRATgFqhVCh8qD7xmaSbwG1vfaCddvCM>
