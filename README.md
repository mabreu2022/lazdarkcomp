# LazDarkComp (MetaDarkStyle with Decoupled Form Designer)

**LazDarkComp** brings a modern dark theme to the Lazarus IDE on Windows 10/11, while keeping the **Form Designer (visual design surface) decoupled in classic light mode** ($F0F0F0 / clBtnFace).

This solves the classic problem where applying a dark theme turned the designed forms dark and made designing standard Windows applications difficult.

---

## Features
- **Full Dark IDE**: Source Editor, Object Inspector, Messages, Menus, Toolbars, and Docked Panels render in sleek dark mode.
- **Decoupled Form Designer**: Form design surfaces (`Form1`) and controls in design mode maintain their clean, native light background (`$F0F0F0`), grid dots, and standard contrast.
- **100% Self-Contained Package**: Requires **no modifications** to Lazarus or LCL source code.
- **Compatible with AnchorDocking / DockedFormEditor**: Transparently prevents the dark tabsheet background from bleeding into your design form.
- **No recursion / Stack Overflow**: Stable Win32 LCL message handling.

---

## Packages
- `metadarkstyle.lpk`: Base runtime package with Windows 10/11 dark mode logic.
- `metadarkstyledsgn.lpk`: Design-time package for modern Lazarus (3.0, 3.2, 3.4, trunk).
- `metadarkstyledsgn226.lpk`: Design-time package for Lazarus 2.2.6.

---

## System Requirements
- Windows 10 (version 1809+) or Windows 11
- Lazarus 2.2.6, 3.0, 3.2, 3.4, or trunk
- FPC 3.2.2 or later

---

## Installation

1. Clone or download this repository.
2. Open Lazarus IDE.
3. Go to **Package** -> **Open Package File (.lpk)**.
4. Select `metadarkstyle.lpk`, click **Compile**.
5. Select `metadarkstyledsgn.lpk` (or `metadarkstyledsgn226.lpk` if on Lazarus 2.2.6), click **Compile**, then **Use** -> **Install**.
6. Lazarus will rebuild itself and restart.
7. Go to **Tools** -> **Options** -> **Environment** -> **Dark Style** to configure your preferred scheme (e.g. Modern Dark).

---

## License
GNU Lesser General Public License (LGPL 2.1) with linking exception, matching Lazarus and Free Pascal license terms.
