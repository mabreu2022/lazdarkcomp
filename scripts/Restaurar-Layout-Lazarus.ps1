<#
.SYNOPSIS
    Script de Restauração e Organização do Layout Docado da IDE do Lazarus.
.DESCRIPTION
    Localiza automaticamente a instalação e o perfil de configuração do Lazarus,
    varrendo todas as unidades e diretórios do usuário, e reorganiza o layout docado:
      - Lado Esquerdo: Inspetor de Objetos (Componentes, Propriedades e Eventos).
      - Centro Superior: Editor de Código e Designer de Formulários.
      - Centro Inferior: Mensagens, Busca, Watches, Pontos de Parada e Assembler (Abas).
      - Lado Direito Superior: Inspetor de Projeto (Arquivos).
      - Lado Direito Inferior: Explorador de Código e Lista de Componentes (Abas).
#>
param(
    [switch]$Silent = $false,
    [string]$TargetConfigDir = ""
)

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

if (-not $Silent) {
    try { $Host.UI.RawUI.WindowTitle = "Restaurador de Layout do Lazarus" } catch {}
    Write-Host "=======================================================================" -ForegroundColor Cyan
    Write-Host "           Restaurador de Layout Docado - Lazarus IDE                  " -ForegroundColor Cyan
    Write-Host "=======================================================================" -ForegroundColor Cyan
    Write-Host ""
}

# -----------------------------------------------------------------------------
# 1. Verificar se o Lazarus está em execução e obter dados do processo
# -----------------------------------------------------------------------------
$lazProc = Get-Process -Name "lazarus", "startlazarus" -ErrorAction SilentlyContinue
$runningLazExe = $null
$runningLazPcp = $null

if ($lazProc) {
    try {
        $firstProc = $lazProc | Select-Object -First 1
        $runningLazExe = $firstProc.Path
        $procId = $firstProc.Id
        $wmiProc = Get-CimInstance Win32_Process -Filter "ProcessId = $procId" -ErrorAction SilentlyContinue
        if ($wmiProc -and $wmiProc.CommandLine) {
            if ($wmiProc.CommandLine -match '(?i)--(?:primary-config-path|pcp)=["'']?([^"'']+)["'']?') {
                $runningLazPcp = $matches[1].Trim()
            }
        }
    } catch {}

    if (-not $Silent) {
        Write-Host "[!] O Lazarus está em execução no momento." -ForegroundColor Yellow
        Write-Host "    Para que as configurações não sejam sobrescritas ao sair, o Lazarus precisa ser fechado."
        $resp = Read-Host "    Deseja fechar o Lazarus agora para continuar? (S/N)"
        if ($resp -match "^[sSyY]") {
            $lazProc | Stop-Process -Force
            Start-Sleep -Seconds 1
            Write-Host "[+] Lazarus fechado com sucesso." -ForegroundColor Green
        } else {
            Write-Host "[-] Operação cancelada. Feche o Lazarus e tente novamente." -ForegroundColor Red
            return
        }
    } else {
        $lazProc | Wait-Process -Timeout 15 -ErrorAction SilentlyContinue
        Start-Sleep -Milliseconds 600
    }
}

# -----------------------------------------------------------------------------
# 2. Localizar pasta onde o componente foi instalado/extraído
# -----------------------------------------------------------------------------
$detectedComponentDir = $null
$compCandidates = @(
    $PSScriptRoot,
    (Split-Path $PSScriptRoot -Parent),
    "$env:USERPROFILE\Documents\ComponentesLazarus\lazdarkcomp",
    "$env:USERPROFILE\Documents\lazdarkcomp",
    "$env:USERPROFILE\Documents\metadark_safe"
)

$fileSystemDrives = Get-PSDrive -PSProvider FileSystem -ErrorAction SilentlyContinue

foreach ($d in $fileSystemDrives) {
    $r = $d.Root
    $compCandidates += "$r\ComponentesLazarus\lazdarkcomp"
    $compCandidates += "$r\Componentes\lazdarkcomp"
    $compCandidates += "$r\lazdarkcomp"
    $compCandidates += "$r\Users\*\Documents\ComponentesLazarus\lazdarkcomp"
}

foreach ($cand in $compCandidates) {
    if ($cand -and (Test-Path $cand)) {
        try {
            $resolved = (Resolve-Path $cand -ErrorAction SilentlyContinue | Select-Object -First 1).Path
            $hasLpk1 = Test-Path (Join-Path $resolved "metadarkstyledsgn.lpk")
            $hasLpk2 = Test-Path (Join-Path $resolved "metadarkstyle.lpk")
            $hasScript = Test-Path (Join-Path $resolved "scripts\Restaurar-Layout-Lazarus.ps1")
            if ($hasLpk1 -or $hasLpk2 -or $hasScript) {
                $detectedComponentDir = $resolved
                break
            }
        } catch {}
    }
}

if ($detectedComponentDir -and (-not $Silent)) {
    Write-Host "[*] Pasta do componente identificada em:" -ForegroundColor Gray
    Write-Host "    $detectedComponentDir" -ForegroundColor DarkCyan
    Write-Host ""
}

# -----------------------------------------------------------------------------
# 3. Localizar instalações e perfis de configuração do Lazarus (Varredura Ampla)
# -----------------------------------------------------------------------------
$candidateConfigs = [System.Collections.Generic.List[PSObject]]::new()

function Add-ConfigCandidate([string]$path, [int]$baseScore, [string]$source) {
    if (-not $path) { return }
    $p = $path.Trim(' "''')
    if (-not (Test-Path $p)) { return }
    try {
        $fullPath = (Resolve-Path $p -ErrorAction SilentlyContinue).Path
    } catch {
        $fullPath = $p
    }
    if (-not $fullPath) { return }

    $existing = $candidateConfigs | Where-Object { $_.Path.TrimEnd('\') -ieq $fullPath.TrimEnd('\') }
    if ($existing) {
        $existing.Score += $baseScore
        $existing.Reasons += ", $source"
        return
    }

    $hasEnvOpts = Test-Path (Join-Path $fullPath "environmentoptions.xml")
    $hasPkgFiles = Test-Path (Join-Path $fullPath "packagefiles.xml")
    $hasAnchorDock = Test-Path (Join-Path $fullPath "anchordocklayout.xml")

    $score = $baseScore
    if ($hasEnvOpts) { $score += 500 }
    if ($hasAnchorDock) { $score += 150 }
    if ($hasPkgFiles) {
        $score += 200
        try {
            $pkgContent = Get-Content (Join-Path $fullPath "packagefiles.xml") -Raw -ErrorAction SilentlyContinue
            if ($pkgContent -match '(?i)lazdarkcomp|metadarkstyle|metadarkstyledsgn') {
                $score += 1500 # Match perfeito com registro do componente
            }
            if ($detectedComponentDir -and ($pkgContent -like "*$detectedComponentDir*")) {
                $score += 2000 # Match absoluto: caminho exato do componente instalado
            }
        } catch {}
    }

    $candidateConfigs.Add([PSCustomObject]@{
        Path = $fullPath
        Score = $score
        Reasons = $source
        HasEnvOpts = $hasEnvOpts
        HasPkgFiles = $hasPkgFiles
        HasAnchorDock = $hasAnchorDock
    })
}

# A. Parâmetro explícito TargetConfigDir
if ($TargetConfigDir -and (Test-Path $TargetConfigDir)) {
    Add-ConfigCandidate $TargetConfigDir 10000 "Parâmetro explícito TargetConfigDir"
}

# B. Processo Lazarus que estava em execução
if ($runningLazPcp) {
    Add-ConfigCandidate $runningLazPcp 3000 "Argumento --pcp do processo Lazarus"
}
if ($runningLazExe) {
    $procDir = Split-Path $runningLazExe -Parent
    Add-ConfigCandidate "$procDir\config" 2000 "Subpasta config do executável em execução"
    Add-ConfigCandidate $procDir 1500 "Pasta raiz do executável em execução"
    $cfgFile = Join-Path $procDir "lazarus.cfg"
    if (Test-Path $cfgFile) {
        try {
            Get-Content $cfgFile -ErrorAction SilentlyContinue | ForEach-Object {
                if ($_ -match '(?i)--(?:primary-config-path|pcp)=["'']?([^"'']+)["'']?') {
                    $rawPcp = $matches[1].Trim()
                    if (-not [System.IO.Path]::IsPathRooted($rawPcp)) { $rawPcp = Join-Path $procDir $rawPcp }
                    Add-ConfigCandidate $rawPcp 2800 "Arquivo lazarus.cfg do executável em execução"
                }
            }
        } catch {}
    }
}

# C. Registro do Windows
$regKeys = @(
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
    "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*",
    "HKCU:\Software\Lazarus"
)
foreach ($rk in $regKeys) {
    try {
        Get-ItemProperty $rk -ErrorAction SilentlyContinue | Where-Object { 
            ($_.DisplayName -like "*Lazarus*") -or ($_.PSChildName -like "*Lazarus*") 
        } | ForEach-Object {
            $instDir = $_.InstallLocation
            if (-not $instDir -and $_.UninstallString) {
                $instDir = Split-Path ($_.UninstallString.Trim('"')) -Parent
            }
            if ($instDir -and (Test-Path $instDir)) {
                Add-ConfigCandidate "$instDir\config" 1200 "Registro do Windows (config)"
                Add-ConfigCandidate $instDir 1000 "Registro do Windows (raiz)"
                $cfg = Join-Path $instDir "lazarus.cfg"
                if (Test-Path $cfg) {
                    Get-Content $cfg -ErrorAction SilentlyContinue | ForEach-Object {
                        if ($_ -match '(?i)--(?:primary-config-path|pcp)=["'']?([^"'']+)["'']?') {
                            $r = $matches[1].Trim()
                            if (-not [System.IO.Path]::IsPathRooted($r)) { $r = Join-Path $instDir $r }
                            Add-ConfigCandidate $r 2600 "Arquivo lazarus.cfg do Registro"
                        }
                    }
                }
            }
        }
    } catch {}
}

# D. Perfis padrão do usuário atual
Add-ConfigCandidate "$env:LOCALAPPDATA\lazarus" 600 "LocalAppData padrão (%LOCALAPPDATA%\lazarus)"
Add-ConfigCandidate "$env:APPDATA\lazarus" 400 "Roaming padrão (%APPDATA%\lazarus)"
Add-ConfigCandidate "$env:USERPROFILE\.lazarus" 300 "Perfil Unix/WSL padrão (~/.lazarus)"

# E. Varrer Unidades do Sistema (C:, D:, E:, etc.)
foreach ($d in $fileSystemDrives) {
    $root = $d.Root
    $standardLaz = @(
        "$root\lazarus",
        "$root\lazarus32",
        "$root\lazarus64",
        "$root\Program Files\lazarus",
        "$root\Program Files (x86)\lazarus"
    )
    foreach ($lp in $standardLaz) {
        if (Test-Path $lp) {
            $cfg = Join-Path $lp "lazarus.cfg"
            if (Test-Path $cfg) {
                try {
                    Get-Content $cfg -ErrorAction SilentlyContinue | ForEach-Object {
                        if ($_ -match '(?i)--(?:primary-config-path|pcp)=["'']?([^"'']+)["'']?') {
                            $r = $matches[1].Trim()
                            if (-not [System.IO.Path]::IsPathRooted($r)) { $r = Join-Path $lp $r }
                            Add-ConfigCandidate $r 2500 "Configuração em $cfg"
                        }
                    }
                } catch {}
            }
            Add-ConfigCandidate "$lp\config" 1100 "Subpasta config em $lp"
            Add-ConfigCandidate $lp 800 "Pasta de instalação em $lp"
        }
    }

    # Verificar pastas de outros usuários na unidade
    $usersDir = Join-Path $root "Users"
    if (Test-Path $usersDir) {
        Get-ChildItem -Path $usersDir -Directory -ErrorAction SilentlyContinue | ForEach-Object {
            $uDir = $_.FullName
            Add-ConfigCandidate "$uDir\AppData\Local\lazarus" 500 "Perfil de usuário em $uDir"
            Add-ConfigCandidate "$uDir\AppData\Roaming\lazarus" 400 "Perfil roaming em $uDir"
            Add-ConfigCandidate "$uDir\.lazarus" 300 "Pasta .lazarus em $uDir"
        }
    }
}

# F. Varredura recursiva rápida se nenhum candidato com environmentoptions.xml foi achado
$confirmed = $candidateConfigs | Where-Object { $_.HasEnvOpts -or $_.HasAnchorDock }
if ($confirmed.Count -eq 0) {
    if (-not $Silent) {
        Write-Host "[*] Realizando busca detalhada nas unidades por configurações do Lazarus..." -ForegroundColor DarkYellow
    }
    foreach ($d in $fileSystemDrives) {
        try {
            Get-ChildItem -Path $d.Root -Filter "environmentoptions.xml" -Recurse -Depth 3 -ErrorAction SilentlyContinue | ForEach-Object {
                $pDir = Split-Path $_.FullName -Parent
                if ($pDir -notmatch '(?i)tools\\install') {
                    Add-ConfigCandidate $pDir 750 "Busca automática na unidade $($d.Root)"
                }
            }
        } catch {}
    }
}

# -----------------------------------------------------------------------------
# 4. Selecionar o melhor diretório de configurações
# -----------------------------------------------------------------------------
$sortedCandidates = $candidateConfigs | Where-Object { Test-Path $_.Path } | Sort-Object Score -Descending

$configDir = $null
if ($sortedCandidates.Count -gt 0) {
    $configDir = $sortedCandidates[0].Path
}

if (-not $configDir) {
    if (-not $Silent) {
        Write-Host "[-] Não foi possível localizar automaticamente o diretório de configurações do Lazarus." -ForegroundColor Red
        Write-Host ""
        $userPath = Read-Host "Por favor, digite o caminho da pasta do Lazarus (ex: C:\lazarus) ou de suas configurações"
        if ($userPath -and (Test-Path $userPath)) {
            if (Test-Path (Join-Path $userPath "config")) {
                $configDir = (Resolve-Path (Join-Path $userPath "config")).Path
            } else {
                $configDir = (Resolve-Path $userPath).Path
            }
        } else {
            Write-Host "[-] Caminho informado não é válido. Operação encerrada." -ForegroundColor Red
            return
        }
    } else {
        return
    }
}

if (-not $Silent) {
    Write-Host "[*] Diretório de configurações do Lazarus selecionado:" -ForegroundColor Gray
    Write-Host "    $configDir" -ForegroundColor White
    if ($sortedCandidates.Count -gt 0) {
        Write-Host "    (Motivo: $($sortedCandidates[0].Reasons))" -ForegroundColor DarkGray
    }
    Write-Host ""
}

# -----------------------------------------------------------------------------
# 5. Criar backup preventivo antes de qualquer alteração
# -----------------------------------------------------------------------------
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$backupDir = Join-Path $configDir "backup_layout_$timestamp"
New-Item -ItemType Directory -Path $backupDir -Force | Out-Null
Copy-Item "$configDir\*.xml" -Destination $backupDir -ErrorAction SilentlyContinue
if (-not $Silent) {
    Write-Host "[+] Backup preventivo criado em:" -ForegroundColor Green
    Write-Host "    $backupDir" -ForegroundColor Gray
    Write-Host ""
}

# -----------------------------------------------------------------------------
# 6. XML da estrutura docada padrão perfeita (Layout estável e aninhado)
# -----------------------------------------------------------------------------
$dockInnerXml = @"
  <Version Value="1" />
  <MainConfig>
    <Nodes ChildCount="1">
      <Item1 Name="MainIDE" Type="CustomSite" WindowState="Maximized" Monitor="0" ChildCount="1" PixelsPerInch="120">
        <Bounds Left="-9" Top="-9" Width="1920" Height="966">
          <WorkArea>
            <Rect Right="1920" Bottom="1020" />
          </WorkArea>
        </Bounds>
        <Item1 Name="AnchorDockSite10" Type="Layout" WindowState="Maximized" Monitor="0" ChildCount="5" PixelsPerInch="120">
          <Bounds Top="100" Width="1920" Height="866" SplitterPos="98" />
          <Anchors Align="Bottom" />
          <Item1 Name="AnchorDockSite12" Type="Layout" WindowState="Maximized" Monitor="0" ChildCount="3" PixelsPerInch="120">
            <Bounds Left="329" Width="1223" Height="866" />
            <Anchors Left="AnchorDockSplitter4" Right="AnchorDockSplitter3" />
            <Item1 Name="SourceNotebook" Type="Control" WindowState="Maximized" Monitor="0" PixelsPerInch="120">
              <Bounds Width="1223" Height="620" />
              <Anchors Bottom="AnchorDockSplitter2" />
            </Item1>
            <Item2 Name="AnchorDockSplitter2" Type="SplitterHorizontal" WindowState="Maximized" Monitor="0" PixelsPerInch="120">
              <Bounds Top="620" Width="1223" Height="5" />
            </Item2>
            <Item3 Name="AnchorDockSite11" Type="Pages" WindowState="Maximized" Monitor="0" ChildCount="5" PixelsPerInch="120">
              <Bounds Top="625" Width="1223" Height="241" />
              <Anchors Top="AnchorDockSplitter2" />
              <Header PageIndex="0" />
              <Item1 Name="MessagesView" Type="Control" WindowState="Maximized" Monitor="0" PixelsPerInch="120">
                <Bounds Width="1193" Height="215" />
                <Anchors Align="Client" />
              </Item1>
              <Item2 Name="SearchResults" Type="Control" WindowState="Maximized" Monitor="0" PixelsPerInch="120">
                <Bounds Width="1193" Height="215" />
                <Anchors Align="Client" />
              </Item2>
              <Item3 Name="Watches" Type="Control" WindowState="Maximized" Monitor="0" PixelsPerInch="120">
                <Bounds Width="1193" Height="215" />
                <Anchors Align="Client" />
              </Item3>
              <Item4 Name="BreakPoints" Type="Control" WindowState="Maximized" Monitor="0" PixelsPerInch="120">
                <Bounds Width="1193" Height="215" />
                <Anchors Align="Client" />
              </Item4>
              <Item5 Name="Assembler" Type="Control" WindowState="Maximized" Monitor="0" PixelsPerInch="120">
                <Bounds Width="1193" Height="215" />
                <Anchors Align="Client" />
              </Item5>
            </Item3>
          </Item1>
          <Item2 Name="AnchorDockSplitter3" Type="SplitterVertical" WindowState="Maximized" Monitor="0" PixelsPerInch="120">
            <Bounds Left="1552" Width="11" Height="866" />
          </Item2>
          <Item3 Name="AnchorDockSite14" Type="Layout" WindowState="Maximized" Monitor="0" ChildCount="3" PixelsPerInch="120">
            <Bounds Left="1563" Width="357" Height="866" />
            <Anchors Left="AnchorDockSplitter3" />
            <Item1 Name="ProjectInspector" Type="Control" WindowState="Maximized" Monitor="0" PixelsPerInch="120">
              <Bounds Width="357" Height="450" />
              <Anchors Bottom="AnchorDockSplitter5" />
            </Item1>
            <Item2 Name="AnchorDockSplitter5" Type="SplitterHorizontal" WindowState="Maximized" Monitor="0" PixelsPerInch="120">
              <Bounds Top="450" Width="357" Height="5" />
            </Item2>
            <Item3 Name="AnchorDockSite15" Type="Pages" WindowState="Maximized" Monitor="0" ChildCount="2" PixelsPerInch="120">
              <Bounds Top="455" Width="357" Height="411" />
              <Anchors Top="AnchorDockSplitter5" />
              <Header PageIndex="0" />
              <Item1 Name="CodeExplorerView" Type="Control" WindowState="Maximized" Monitor="0" PixelsPerInch="120">
                <Bounds Width="327" Height="375" />
                <Anchors Align="Client" />
              </Item1>
              <Item2 Name="ComponentList" Type="Control" WindowState="Maximized" Monitor="0" PixelsPerInch="120">
                <Bounds Width="327" Height="375" />
                <Anchors Align="Client" />
              </Item2>
            </Item3>
          </Item3>
          <Item4 Name="ObjectInspectorDlg" Type="Control" WindowState="Maximized" Monitor="0" PixelsPerInch="120">
            <Bounds Width="324" Height="866" />
            <Anchors Right="AnchorDockSplitter4" />
          </Item4>
          <Item5 Name="AnchorDockSplitter4" Type="SplitterVertical" WindowState="Maximized" Monitor="0" PixelsPerInch="120">
            <Bounds Left="324" Width="5" Height="866" />
          </Item5>
        </Item1>
      </Item1>
    </Nodes>
  </MainConfig>
  <Settings FloatingWindowsOnTop="True" HeaderStyle="Line" />
"@

$anchorDockLayoutFileContent = @"
<?xml version="1.0" encoding="UTF-8"?>
<CONFIG>
$dockInnerXml
</CONFIG>
"@

$anchorDockingElementXml = @"
<AnchorDocking>
$dockInnerXml
</AnchorDocking>
"@

# -----------------------------------------------------------------------------
# 7. Garantir opções de ativação do AnchorDocking e DockedFormEditor
# -----------------------------------------------------------------------------
$anchorOptPath = Join-Path $configDir "anchordockingoptions.xml"
if (Test-Path $anchorOptPath) {
    Set-ItemProperty -Path $anchorOptPath -Name IsReadOnly -Value $false -ErrorAction SilentlyContinue
}
$anchorOptXml = @"
<?xml version="1.0" encoding="UTF-8"?>
<CONFIG>
  <EnableAnchorDock Value="True"/>
  <DoneAskUserEnableAnchorDock Value="True"/>
</CONFIG>
"@
[System.IO.File]::WriteAllText($anchorOptPath, $anchorOptXml, [System.Text.Encoding]::UTF8)

$dockedFormOptPath = Join-Path $configDir "dockedformeditoroptions.xml"
if (Test-Path $dockedFormOptPath) {
    Set-ItemProperty -Path $dockedFormOptPath -Name IsReadOnly -Value $false -ErrorAction SilentlyContinue
}
$dockedFormOptXml = @"
<?xml version="1.0" encoding="UTF-8"?>
<CONFIG>
  <EnableDockedDesigner Value="True"/>
  <DoneAskUserEnableDockedDesigner Value="True"/>
</CONFIG>
"@
[System.IO.File]::WriteAllText($dockedFormOptPath, $dockedFormOptXml, [System.Text.Encoding]::UTF8)

# -----------------------------------------------------------------------------
# 8. Atualizar anchordocklayout.xml garantindo permissão normal de gravação
# -----------------------------------------------------------------------------
$layoutFilePath = Join-Path $configDir "anchordocklayout.xml"
if (Test-Path $layoutFilePath) {
    Set-ItemProperty -Path $layoutFilePath -Name IsReadOnly -Value $false -ErrorAction SilentlyContinue
}
[System.IO.File]::WriteAllText($layoutFilePath, $anchorDockLayoutFileContent, [System.Text.Encoding]::UTF8)
Set-ItemProperty -Path $layoutFilePath -Name IsReadOnly -Value $false -ErrorAction SilentlyContinue
if (-not $Silent) {
    Write-Host "[+] Arquivo 'anchordocklayout.xml' gerado com layout limpo e padronizado." -ForegroundColor Green
}

# -----------------------------------------------------------------------------
# 9. Atualizar environmentoptions.xml corrigindo Desktop e CustomPosition
# -----------------------------------------------------------------------------
$envOptPath = Join-Path $configDir "environmentoptions.xml"
if (Test-Path $envOptPath) {
    try {
        Set-ItemProperty -Path $envOptPath -Name IsReadOnly -Value $false -ErrorAction SilentlyContinue
        $envDoc = New-Object System.Xml.XmlDocument
        $envDoc.Load($envOptPath)

        $tempDoc = New-Object System.Xml.XmlDocument
        $tempDoc.LoadXml($anchorDockingElementXml)

        $desktops = $envDoc.SelectSingleNode("//Desktops")
        if ($desktops) {
            $desktops.SetAttribute("ActiveDesktop", "default docked")

            foreach ($desktopNode in $desktops.ChildNodes) {
                if ($desktopNode.NodeType -ne [System.Xml.XmlNodeType]::Element) { continue }
                
                $name = $desktopNode.GetAttribute("Name")
                $dockMaster = $desktopNode.GetAttribute("DockMaster")

                if ($dockMaster -eq "TIDEAnchorDockMaster" -or $name -match "dock|mauricio") {
                    $desktopNode.SetAttribute("DockMaster", "TIDEAnchorDockMaster")

                    # Atualizar MainIDE
                    $mainIDE = $desktopNode.SelectSingleNode("MainIDE")
                    if ($mainIDE) {
                        $custPos = $mainIDE.SelectSingleNode("CustomPosition")
                        if ($custPos) {
                            $custPos.SetAttribute("Left", "-9")
                            $custPos.SetAttribute("Top", "-9")
                            $custPos.SetAttribute("Width", "1920")
                            $custPos.SetAttribute("Height", "966")
                        }
                        $winState = $mainIDE.SelectSingleNode("WindowState")
                        if ($winState) { $winState.SetAttribute("Value", "Maximized") }
                        $vis = $mainIDE.SelectSingleNode("Visible")
                        if (-not $vis) {
                            $vis = $envDoc.CreateElement("Visible")
                            [void]$mainIDE.AppendChild($vis)
                        }
                        $vis.SetAttribute("Value", "True")
                    }

                    # Ajustar posições individuais para não conflitar com AnchorDocking
                    $posMap = @{
                        "SourceNotebook"      = @{ Left = "329";  Top = "100"; Width = "1223"; Height = "620" }
                        "MessagesView"        = @{ Left = "329";  Top = "725"; Width = "1223"; Height = "241" }
                        "ObjectInspectorDlg"  = @{ Left = "5";    Top = "100"; Width = "324";  Height = "866" }
                        "ProjectInspector"    = @{ Left = "1563"; Top = "100"; Width = "357";  Height = "340" }
                        "TLazDroidTargetDockForm" = @{ Left = "1563"; Top = "445"; Width = "357"; Height = "170" }
                        "CodeExplorerView"    = @{ Left = "1563"; Top = "620"; Width = "357";  Height = "346" }
                        "ComponentList"       = @{ Left = "1563"; Top = "620"; Width = "357";  Height = "346" }
                        "SearchResults"       = @{ Left = "329";  Top = "725"; Width = "1223"; Height = "241" }
                        "Watches"             = @{ Left = "329";  Top = "725"; Width = "1223"; Height = "241" }
                        "BreakPoints"         = @{ Left = "329";  Top = "725"; Width = "1223"; Height = "241" }
                        "Assembler"           = @{ Left = "329";  Top = "725"; Width = "1223"; Height = "241" }
                    }

                    foreach ($formName in $posMap.Keys) {
                        $formElem = $desktopNode.SelectSingleNode($formName)
                        if (-not $formElem) {
                            $formElem = $envDoc.CreateElement($formName)
                            [void]$desktopNode.AppendChild($formElem)
                        }
                        $cPos = $formElem.SelectSingleNode("CustomPosition")
                        if (-not $cPos) {
                            $cPos = $envDoc.CreateElement("CustomPosition")
                            [void]$formElem.AppendChild($cPos)
                        }
                        $p = $posMap[$formName]
                        $cPos.SetAttribute("Left", $p.Left)
                        $cPos.SetAttribute("Top", $p.Top)
                        $cPos.SetAttribute("Width", $p.Width)
                        $cPos.SetAttribute("Height", $p.Height)

                        $vis = $formElem.SelectSingleNode("Visible")
                        if (-not $vis) {
                            $vis = $envDoc.CreateElement("Visible")
                            [void]$formElem.AppendChild($vis)
                        }
                        $vis.SetAttribute("Value", "True")
                    }

                    # Substituir o AnchorDocking pelo layout corrigido
                    $oldAnchor = $desktopNode.SelectSingleNode("AnchorDocking")
                    if ($oldAnchor) {
                        [void]$desktopNode.RemoveChild($oldAnchor)
                    }

                    $importedNode = $envDoc.ImportNode($tempDoc.DocumentElement, $true)
                    [void]$desktopNode.AppendChild($importedNode)
                }
            }
        }

        # Salvar com UTF-8 limpo
        $settings = New-Object System.Xml.XmlWriterSettings
        $settings.Indent = $true
        $settings.IndentChars = "  "
        $settings.Encoding = [System.Text.Encoding]::UTF8
        $writer = [System.Xml.XmlWriter]::Create($envOptPath, $settings)
        $envDoc.Save($writer)
        $writer.Dispose()

        if (-not $Silent) {
            Write-Host "[+] Configurações em 'environmentoptions.xml' atualizadas com sucesso." -ForegroundColor Green
        }
    }
    catch {
        if (-not $Silent) {
            Write-Host "[-] Aviso ao processar environmentoptions.xml: $_" -ForegroundColor Yellow
        }
    }
}

# -----------------------------------------------------------------------------
# 10. Replicar scripts na pasta de configuração para fácil acesso futuro
# -----------------------------------------------------------------------------
try {
    $cfgScripts = Join-Path $configDir "scripts"
    New-Item -ItemType Directory -Path $cfgScripts -Force -ErrorAction SilentlyContinue | Out-Null
    if (Test-Path "$PSScriptRoot\Restaurar-Layout-Lazarus.cmd") {
        Copy-Item "$PSScriptRoot\Restaurar-Layout-Lazarus.cmd" -Destination $configDir -Force -ErrorAction SilentlyContinue
        Copy-Item "$PSScriptRoot\Restaurar-Layout-Lazarus.cmd" -Destination $cfgScripts -Force -ErrorAction SilentlyContinue
    }
    if (Test-Path "$PSCommandPath") {
        Copy-Item "$PSCommandPath" -Destination $configDir -Force -ErrorAction SilentlyContinue
        Copy-Item "$PSCommandPath" -Destination $cfgScripts -Force -ErrorAction SilentlyContinue
    }
} catch {}

# -----------------------------------------------------------------------------
# 11. Conclusão e opção para abrir o Lazarus
# -----------------------------------------------------------------------------
if (-not $Silent) {
    Write-Host ""
    Write-Host "=======================================================================" -ForegroundColor Green
    Write-Host "         Layout Docado Restaurado e Organizado com Sucesso!           " -ForegroundColor Green
    Write-Host "=======================================================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Resumo do layout aplicado:"
    Write-Host "  * Esquerda:   Inspetor de Objetos (Object Inspector)" -ForegroundColor Cyan
    Write-Host "  * Centro Sup: Editor de Código + Designer (SourceNotebook + Form Designer)" -ForegroundColor Cyan
    Write-Host "  * Centro Inf: Mensagens, Busca, Watches, BreakPoints e Assembler" -ForegroundColor Cyan
    Write-Host "  * Direita:    Inspetor de Projeto (Topo) e Explorador de Código (Base)" -ForegroundColor Cyan
    Write-Host ""

    $lazarusExe = ""
    if ($runningLazExe -and (Test-Path $runningLazExe)) {
        $lazarusExe = $runningLazExe
    } else {
        $searchExe = @(
            "C:\lazarus\lazarus.exe",
            "D:\lazarus\lazarus.exe"
        )
        foreach ($d in $fileSystemDrives) {
            $searchExe += "$($d.Root)lazarus\lazarus.exe"
            $searchExe += "$($d.Root)Program Files\lazarus\lazarus.exe"
        }
        foreach ($se in $searchExe) {
            if (Test-Path $se) {
                $lazarusExe = $se
                break
            }
        }
        if (-not $lazarusExe) {
            $cmd = Get-Command "lazarus.exe" -ErrorAction SilentlyContinue
            if ($cmd) { $lazarusExe = $cmd.Source }
        }
    }

    if (Test-Path $lazarusExe) {
        $abrir = Read-Host "Deseja abrir o Lazarus agora? (S/N)"
        if ($abrir -match "^[sSyY]") {
            Write-Host "[*] Iniciando o Lazarus em $lazarusExe..." -ForegroundColor Green
            # Se a configuração usada for diferente do padrão AppData, passa o parâmetro --pcp
            $defaultPcp = "$env:LOCALAPPDATA\lazarus"
            if ($configDir.TrimEnd('\') -ine $defaultPcp.TrimEnd('\')) {
                Start-Process $lazarusExe -ArgumentList "--pcp=`"$configDir`""
            } else {
                Start-Process $lazarusExe
            }
        }
    }
}