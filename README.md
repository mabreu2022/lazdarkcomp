# LazDarkComp (MetaDarkStyle with Decoupled Form Designer)

**LazDarkComp** brings a modern dark theme to the Lazarus IDE on Windows 10/11, while keeping the **Form Designer (visual design surface) decoupled in classic light mode** (`$F0F0F0` / `clBtnFace`).

This solves the classic problem where applying a dark theme turned the designed forms dark and made designing standard Windows applications difficult.

---

## Features
- **Full Dark IDE**: Source Editor, Object Inspector, Messages, Menus, Toolbars, and Docked Panels render in sleek dark mode.
- **Decoupled Form Designer**: Form design surfaces (`Form1`) and controls in design mode maintain their clean, native light background (`$F0F0F0`), grid dots, and standard contrast.
- **100% Self-Contained Package**: Requires **no modifications** to Lazarus or LCL source code.
- **Auto-Deployed Editor Scheme**: Automatically deploys the curated `DarkModern.xml` syntax color scheme into Lazarus `userschemes`.
- **Compatible with AnchorDocking / DockedFormEditor**: Transparently prevents the dark tabsheet background from bleeding into your design form.
- **No recursion / Stack Overflow**: Stable Win32 LCL message handling.

---

## Packages
- `metadarkstyle.lpk`: Base runtime package with Windows 10/11 dark mode logic.
- `metadarkstyledsgn.lpk`: Design-time package for modern Lazarus (3.0, 3.2, 3.4, 4.0, 4.8, trunk).
- `metadarkstyledsgn226.lpk`: Design-time package for Lazarus 2.2.6.

---

## System Requirements & Compatibility
- Windows 10 (version 1809+) or Windows 11
- Lazarus 2.2.6, 3.0, 3.2, 3.4, 4.0, **4.8**, or trunk
- FPC 3.2.2 or later

---

## Installation

### Method 1: Using Lazarus IDE (GUI)

1. Clone or download this repository (e.g. to `C:\componentes\darkcomp\lazdarkcomp`).
2. Open Lazarus IDE.
3. Open **Package** -> **Open Package File (.lpk)...**:
   - Select `metadarkstyle.lpk` and click **Compile**.
4. Open **Package** -> **Open Package File (.lpk)...**:
   - Select `metadarkstyledsgn.lpk` (or `metadarkstyledsgn226.lpk` if using Lazarus 2.2.6).
   - Click **Compile**.
   - Click **Use** -> **Install**.
5. When Lazarus asks to rebuild the IDE, confirm with **Yes**. Lazarus will rebuild itself and restart automatically.

---

### Method 2: Using Command Line (`lazbuild`)

If you prefer building from the terminal:

```cmd
cd C:\componentes\darkcomp\lazdarkcomp

lazbuild --add-package-link metadarkstyle.lpk
lazbuild --add-package-link metadarkstyledsgn.lpk
lazbuild --add-package metadarkstyledsgn
lazbuild --build-ide
```

---

## Configuring the Themes

### 1. IDE Dark Theme (MetaDarkStyle)
1. In Lazarus, go to **Tools (Ferramentas)** -> **Options... (Opções da IDE...)**.
2. Under **Environment (Ambiente)** -> **Dark Style**:
   - Set **Application Mode** to `Force Dark` (or `Allow Dark`).
   - Select your preferred scheme (e.g., `Modern Dark`).
   - Click **OK**.

### 2. Editor Syntax Colors (DarkModern Scheme)
The package automatically deploys the `DarkModern.xml` color scheme into your Lazarus configuration:
1. In Lazarus, go to **Tools (Ferramentas)** -> **Options... (Opções da IDE...)**.
2. Navigate to **Editor** -> **Display (Exibir)** -> **Colors (Cores)**.
3. In the color scheme drop-down list (where `Default`, `Delphi`, etc. appear), select **DarkModern**.
4. Click **OK** / **Apply**.

*(Note: If you have just installed the package, restart Lazarus once so it registers newly deployed schemes).*

---

## Repository Structure
- `src/`: Core units for dark theme implementation and form designer decoupling hooks.
- `src/dsgn/`: IDE integration, options frame, and auto-deploy logic.
- `userschemes/`: Pre-configured editor color schemes (`DarkModern.xml`).
- `docs/`: Additional documentation and notes.

---

## License
GNU Lesser General Public License (LGPL 2.1) with linking exception, matching Lazarus and Free Pascal license terms.
