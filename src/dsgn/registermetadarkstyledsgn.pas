unit registerMetaDarkStyleDSGN;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Controls, Dialogs, Forms, Process,
  IDEOptionsIntf, IDEOptEditorIntf, LazIDEIntf,
  IDECommands, MenuIntf, ToolBarIntf,
  LazConfigStorage, BaseIDEIntf, Laz2_XMLCfg, PackageIntf,
  uDarkStyleParams, uDarkStyleSchemes, uMetaDarkStyle,
  MetaDarkStyleDSGNOptionsFrame, MetaDarkStyleDSGNOptions;

var
  MetaDarkStyleOptionsID: integer = 1000;
  ToggleThemeCommand: TIDECommand = nil;
  ToggleThemeButtonCmd: TIDEButtonCommand = nil;
  ToggleThemeMenuCmd: TIDEMenuCommand = nil;

procedure ApplyEditorColorScheme(const AScheme: string);
procedure ApplyCleanDockedLayout(AConfigDir: string = '');
procedure RunRestorationScript;
procedure Register;

implementation

const
  DarkModernXMLContent: string =
    '<?xml version="1.0"?>'#10 +
    '<CONFIG>'#10 +
    '  <Lazarus>'#10 +
    '    <ColorSchemes Version="6">'#10 +
    '      <Names Count="1">'#10 +
    '        <Item1 Value="DarkModern"/>'#10 +
    '      </Names>'#10 +
    '      <Globals Version="6">'#10 +
    '        <SchemeDarkModern>'#10 +
    '          <ahaDefault Background="1973790" Foreground="13948116"/>'#10 +
    '          <ahaGutter Background="2434341" Foreground="8750469"/>'#10 +
    '          <ahaGutterSeparator Background="2434341" Foreground="4210752"/>'#10 +
    '          <ahaLineHighlight Background="2763310" ForePriority="500" BackPriority="500" FramePriority="500"/>'#10 +
    '          <ahaTextBlock Background="7884582" Foreground="16777215" ForePriority="7000" BackPriority="7000" FramePriority="7000"/>'#10 +
    '          <ahaBracketMatch Background="3158064" FrameColor="14064726" ForePriority="3000" BackPriority="3000" FramePriority="3000"/>'#10 +
    '          <ahaHighlightWord Background="3158064" FrameColor="10066329" ForePriority="3000" BackPriority="3000" FramePriority="3000"/>'#10 +
    '          <ahaIncrementalSearch Background="6842472" Foreground="16777215" ForePriority="4000" BackPriority="4000" FramePriority="4000"/>'#10 +
    '          <ahaExecutionPoint Background="16744448" Foreground="16777215" ForePriority="500" BackPriority="500" FramePriority="500"/>'#10 +
    '          <ahaEnabledBreakpoint Background="255" Foreground="16777215" ForePriority="500" BackPriority="500" FramePriority="500"/>'#10 +
    '          <ahaErrorLine Background="3618815" Foreground="16777215" ForePriority="500" BackPriority="500" FramePriority="500"/>'#10 +
    '          <ahaModifiedLine Foreground="59900" FrameColor="59900"/>'#10 +
    '          <ahaCodeFoldingTree Foreground="8750469"/>'#10 +
    '          <ahaRightMargin Foreground="4210752"/>'#10 +
    '          <ahaMouseLink Foreground="14064726" ForePriority="1500" BackPriority="2500" FramePriority="7500"/>'#10 +
    '          <ahaFoldedCode Foreground="8750469" FrameColor="8750469"/>'#10 +
    '        </SchemeDarkModern>'#10 +
    '      </Globals>'#10 +
    '      <LangObjectPascal Version="6">'#10 +
    '        <SchemeDarkModern>'#10 +
    '          <Assembler Foreground="9154448"/>'#10 +
    '          <Comment Foreground="5609834" Style="fsItalic"/>'#10 +
    '          <Directive Foreground="12617413" Style="fsBold"/>'#10 +
    '          <Number Foreground="11062965"/>'#10 +
    '          <Modifier Foreground="14064726" Style="fsBold"/>'#10 +
    '          <Reserved_word Foreground="14064726" Style="fsBold"/>'#10 +
    '          <String Foreground="7901646"/>'#10 +
    '          <Symbol Foreground="13948116"/>'#10 +
    '          <NestedRoundBracket_1 Foreground="12617413"/>'#10 +
    '          <NestedRoundBracket_2 Foreground="14064726"/>'#10 +
    '          <NestedRoundBracket_3 Foreground="11062965"/>'#10 +
    '        </SchemeDarkModern>'#10 +
    '      </LangObjectPascal>'#10 +
    '      <LangLazarus_Form_definition Version="6">'#10 +
    '        <SchemeDarkModern>'#10 +
    '          <Comment Foreground="5609834" Style="fsItalic"/>'#10 +
    '          <Key Foreground="14064726" Style="fsBold"/>'#10 +
    '          <Number Foreground="11062965"/>'#10 +
    '          <String Foreground="7901646"/>'#10 +
    '          <Symbol Foreground="13948116"/>'#10 +
    '        </SchemeDarkModern>'#10 +
    '      </LangLazarus_Form_definition>'#10 +
    '      <LangXML_document Version="6">'#10 +
    '        <SchemeDarkModern>'#10 +
    '          <Attribute_Name Foreground="10079487"/>'#10 +
    '          <Attribute_Value Foreground="7901646"/>'#10 +
    '          <Comment Foreground="5609834" Style="fsItalic"/>'#10 +
    '          <Element_Name Foreground="14064726" Style="fsBold"/>'#10 +
    '          <Symbol Foreground="13948116"/>'#10 +
    '          <Text Foreground="13948116"/>'#10 +
    '        </SchemeDarkModern>'#10 +
    '      </LangXML_document>'#10 +
    '    </ColorSchemes>'#10 +
    '  </Lazarus>'#10 +
    '</CONFIG>'#10;

  CleanAnchorDockLayoutXML: string =
    '<?xml version="1.0" encoding="UTF-8"?>'#10 +
    '<CONFIG>'#10 +
    '  <Version Value="1" />'#10 +
    '  <MainConfig>'#10 +
    '    <Nodes ChildCount="1">'#10 +
    '      <Item1 Name="MainIDE" Type="CustomSite" WindowState="Maximized" Monitor="0" ChildCount="1" PixelsPerInch="120">'#10 +
    '        <Bounds Left="-9" Top="-9" Width="1920" Height="966">'#10 +
    '          <WorkArea>'#10 +
    '            <Rect Right="1920" Bottom="1020" />'#10 +
    '          </WorkArea>'#10 +
    '        </Bounds>'#10 +
    '        <Item1 Name="AnchorDockSite10" Type="Layout" WindowState="Maximized" Monitor="0" ChildCount="5" PixelsPerInch="120">'#10 +
    '          <Bounds Top="100" Width="1920" Height="866" SplitterPos="98" />'#10 +
    '          <Anchors Align="Bottom" />'#10 +
    '          <Item1 Name="AnchorDockSite12" Type="Layout" WindowState="Maximized" Monitor="0" ChildCount="3" PixelsPerInch="120">'#10 +
    '            <Bounds Left="329" Width="1223" Height="866" />'#10 +
    '            <Anchors Left="AnchorDockSplitter4" Right="AnchorDockSplitter3" />'#10 +
    '            <Item1 Name="SourceNotebook" Type="Control" WindowState="Maximized" Monitor="0" PixelsPerInch="120">'#10 +
    '              <Bounds Width="1223" Height="620" />'#10 +
    '              <Anchors Bottom="AnchorDockSplitter2" />'#10 +
    '            </Item1>'#10 +
    '            <Item2 Name="AnchorDockSplitter2" Type="SplitterHorizontal" WindowState="Maximized" Monitor="0" PixelsPerInch="120">'#10 +
    '              <Bounds Top="620" Width="1223" Height="5" />'#10 +
    '            </Item2>'#10 +
    '            <Item3 Name="AnchorDockSite11" Type="Pages" WindowState="Maximized" Monitor="0" ChildCount="5" PixelsPerInch="120">'#10 +
    '              <Bounds Top="625" Width="1223" Height="241" />'#10 +
    '              <Anchors Top="AnchorDockSplitter2" />'#10 +
    '              <Header PageIndex="0" />'#10 +
    '              <Item1 Name="MessagesView" Type="Control" WindowState="Maximized" Monitor="0" PixelsPerInch="120">'#10 +
    '                <Bounds Width="1193" Height="215" />'#10 +
    '                <Anchors Align="Client" />'#10 +
    '              </Item1>'#10 +
    '              <Item2 Name="SearchResults" Type="Control" WindowState="Maximized" Monitor="0" PixelsPerInch="120">'#10 +
    '                <Bounds Width="1193" Height="215" />'#10 +
    '                <Anchors Align="Client" />'#10 +
    '              </Item2>'#10 +
    '              <Item3 Name="Watches" Type="Control" WindowState="Maximized" Monitor="0" PixelsPerInch="120">'#10 +
    '                <Bounds Width="1193" Height="215" />'#10 +
    '                <Anchors Align="Client" />'#10 +
    '              </Item3>'#10 +
    '              <Item4 Name="BreakPoints" Type="Control" WindowState="Maximized" Monitor="0" PixelsPerInch="120">'#10 +
    '                <Bounds Width="1193" Height="215" />'#10 +
    '                <Anchors Align="Client" />'#10 +
    '              </Item4>'#10 +
    '              <Item5 Name="Assembler" Type="Control" WindowState="Maximized" Monitor="0" PixelsPerInch="120">'#10 +
    '                <Bounds Width="1193" Height="215" />'#10 +
    '                <Anchors Align="Client" />'#10 +
    '              </Item5>'#10 +
    '            </Item3>'#10 +
    '          </Item1>'#10 +
    '          <Item2 Name="AnchorDockSplitter3" Type="SplitterVertical" WindowState="Maximized" Monitor="0" PixelsPerInch="120">'#10 +
    '            <Bounds Left="1552" Width="11" Height="866" />'#10 +
    '          </Item2>'#10 +
    '          <Item3 Name="AnchorDockSite14" Type="Layout" WindowState="Maximized" Monitor="0" ChildCount="3" PixelsPerInch="120">'#10 +
    '            <Bounds Left="1563" Width="357" Height="866" />'#10 +
    '            <Anchors Left="AnchorDockSplitter3" />'#10 +
    '            <Item1 Name="ProjectInspector" Type="Control" WindowState="Maximized" Monitor="0" PixelsPerInch="120">'#10 +
    '              <Bounds Width="357" Height="450" />'#10 +
    '              <Anchors Bottom="AnchorDockSplitter5" />'#10 +
    '            </Item1>'#10 +
    '            <Item2 Name="AnchorDockSplitter5" Type="SplitterHorizontal" WindowState="Maximized" Monitor="0" PixelsPerInch="120">'#10 +
    '              <Bounds Top="450" Width="357" Height="5" />'#10 +
    '            </Item2>'#10 +
    '            <Item3 Name="AnchorDockSite15" Type="Pages" WindowState="Maximized" Monitor="0" ChildCount="2" PixelsPerInch="120">'#10 +
    '              <Bounds Top="455" Width="357" Height="411" />'#10 +
    '              <Anchors Top="AnchorDockSplitter5" />'#10 +
    '              <Header PageIndex="0" />'#10 +
    '              <Item1 Name="CodeExplorerView" Type="Control" WindowState="Maximized" Monitor="0" PixelsPerInch="120">'#10 +
    '                <Bounds Width="327" Height="375" />'#10 +
    '                <Anchors Align="Client" />'#10 +
    '              </Item1>'#10 +
    '              <Item2 Name="ComponentList" Type="Control" WindowState="Maximized" Monitor="0" PixelsPerInch="120">'#10 +
    '                <Bounds Width="327" Height="375" />'#10 +
    '                <Anchors Align="Client" />'#10 +
    '              </Item2>'#10 +
    '            </Item3>'#10 +
    '          </Item3>'#10 +
    '          <Item4 Name="ObjectInspectorDlg" Type="Control" WindowState="Maximized" Monitor="0" PixelsPerInch="120">'#10 +
    '            <Bounds Width="324" Height="866" />'#10 +
    '            <Anchors Right="AnchorDockSplitter4" />'#10 +
    '          </Item4>'#10 +
    '          <Item5 Name="AnchorDockSplitter4" Type="SplitterVertical" WindowState="Maximized" Monitor="0" PixelsPerInch="120">'#10 +
    '            <Bounds Left="324" Width="5" Height="866" />'#10 +
    '          </Item5>'#10 +
    '        </Item1>'#10 +
    '      </Item1>'#10 +
    '    </Nodes>'#10 +
    '  </MainConfig>'#10 +
    '  <Settings FloatingWindowsOnTop="True" HeaderStyle="Line" />'#10 +
    '</CONFIG>'#10;

procedure DeployDarkModernColorScheme;
var
  SchemeDir, SchemeFile: string;
  SL: TStringList;
begin
  try
    SchemeDir := IncludeTrailingPathDelimiter(LazarusIDE.GetPrimaryConfigPath) + 'userschemes';
    if not DirectoryExists(SchemeDir) then
      ForceDirectories(SchemeDir);
    SchemeFile := IncludeTrailingPathDelimiter(SchemeDir) + 'DarkModern.xml';
    if not FileExists(SchemeFile) then
    begin
      SL := TStringList.Create;
      try
        SL.Text := DarkModernXMLContent;
        SL.SaveToFile(SchemeFile);
      finally
        SL.Free;
      end;
    end;
  except
    // ignore file errors silently
  end;
end;

function AppModeOpt2PreferredAppMode(am:TAppModeOpt):TPreferredAppMode;
begin
  case am of
    amOptAllowDark:result:=pamAllowDark;
    amOptForceDark:result:=pamForceDark;
    amOptForceLight:result:=pamForceLight;
  end;
end;

procedure ApplyEditorColorScheme(const AScheme: string);
const
  KnownLangs: array[0..8] of string = (
    'ObjectPascal',
    'Lazarus_Form_definition',
    'XML_document',
    'HTML_document',
    'Diff',
    'Batch',
    'CPP',
    'SQL',
    'JScript'
  );
var
  Cfg: TConfigStorage;
  XMLCfg: TXMLConfig;
  CfgFile: string;
  i: Integer;
begin
  try
    // 1. Atualizar via GetIDEConfigStorage se disponível
    if Assigned(GetIDEConfigStorage) then
    begin
      try
        Cfg := GetIDEConfigStorage('editoroptions.xml', False);
        if Cfg <> nil then
        begin
          try
            for i := Low(KnownLangs) to High(KnownLangs) do
              Cfg.SetValue('EditorOptions/Color/Lang' + KnownLangs[i] + '/ColorScheme/Value', AScheme);
          finally
            Cfg.Free;
          end;
        end;
      except
        // ignora se storage em memória falhar
      end;
    end;

    // 2. Garantir escrita direta e flush no editoroptions.xml em disco
    if (LazarusIDE <> nil) and (LazarusIDE.GetPrimaryConfigPath <> '') then
    begin
      CfgFile := IncludeTrailingPathDelimiter(LazarusIDE.GetPrimaryConfigPath) + 'editoroptions.xml';
      if FileExists(CfgFile) then
      begin
        try
          XMLCfg := TXMLConfig.Create(CfgFile);
          try
            for i := Low(KnownLangs) to High(KnownLangs) do
              XMLCfg.SetValue('EditorOptions/Color/Lang' + KnownLangs[i] + '/ColorScheme/Value', AScheme);
            XMLCfg.Flush;
          finally
            XMLCfg.Free;
          end;
        except
          // ignora se escrita direta falhar
        end;
      end;
    end;
  except
    // proteção contra exceções
  end;
end;

function FindRestorationScript: string;
var
  Pkg: TIDEPackage;
  PkgDir, BaseDir, PrimaryCfg: string;
  Candidates: array[0..7] of string;
  i: Integer;
begin
  Result := '';
  BaseDir := ExtractFilePath(ParamStr(0));
  if LazarusIDE <> nil then
    PrimaryCfg := LazarusIDE.GetPrimaryConfigPath
  else
    PrimaryCfg := '';

  PkgDir := '';
  if Assigned(PackageEditingInterface) then
  begin
    Pkg := PackageEditingInterface.FindPackageWithName('metadarkstyledsgn');
    if Pkg = nil then
      Pkg := PackageEditingInterface.FindPackageWithName('metadarkstyle');
    if Pkg = nil then
      Pkg := PackageEditingInterface.FindPackageWithName('lazdarkcomp');
    if Pkg <> nil then
      PkgDir := Pkg.DirectoryExpanded;
  end;

  if PkgDir <> '' then
  begin
    Candidates[0] := IncludeTrailingPathDelimiter(PkgDir) + 'scripts' + PathDelim + 'Restaurar-Layout-Lazarus.cmd';
    Candidates[1] := IncludeTrailingPathDelimiter(PkgDir) + 'scripts' + PathDelim + 'Restaurar-Layout-Lazarus.ps1';
    Candidates[2] := IncludeTrailingPathDelimiter(PkgDir) + 'Restaurar-Layout-Lazarus.cmd';
    Candidates[3] := IncludeTrailingPathDelimiter(PkgDir) + 'Restaurar-Layout-Lazarus.ps1';
  end
  else
  begin
    Candidates[0] := '';
    Candidates[1] := '';
    Candidates[2] := '';
    Candidates[3] := '';
  end;

  if PrimaryCfg <> '' then
  begin
    Candidates[4] := IncludeTrailingPathDelimiter(PrimaryCfg) + 'scripts' + PathDelim + 'Restaurar-Layout-Lazarus.cmd';
    Candidates[5] := IncludeTrailingPathDelimiter(PrimaryCfg) + 'Restaurar-Layout-Lazarus.cmd';
  end
  else
  begin
    Candidates[4] := '';
    Candidates[5] := '';
  end;

  Candidates[6] := IncludeTrailingPathDelimiter(BaseDir) + 'scripts' + PathDelim + 'Restaurar-Layout-Lazarus.cmd';
  Candidates[7] := IncludeTrailingPathDelimiter(BaseDir) + 'Restaurar-Layout-Lazarus.cmd';

  for i := Low(Candidates) to High(Candidates) do
  begin
    if (Candidates[i] <> '') and FileExists(Candidates[i]) then
      Exit(Candidates[i]);
  end;
end;

procedure ApplyCleanDockedLayout(AConfigDir: string = '');
var
  TargetDir, LayoutFile, AnchorOptFile, DockedFormOptFile: string;
  SL: TStringList;
begin
  try
    if AConfigDir <> '' then
      TargetDir := AConfigDir
    else if LazarusIDE <> nil then
      TargetDir := LazarusIDE.GetPrimaryConfigPath
    else
      Exit;

    if not DirectoryExists(TargetDir) then
      Exit;

    TargetDir := IncludeTrailingPathDelimiter(TargetDir);

    // 1. Gravar anchordocklayout.xml limpo
    LayoutFile := TargetDir + 'anchordocklayout.xml';
    SL := TStringList.Create;
    try
      SL.Text := CleanAnchorDockLayoutXML;
      SL.SaveToFile(LayoutFile);
    finally
      SL.Free;
    end;

    // 2. Garantir anchordockingoptions.xml ativo
    AnchorOptFile := TargetDir + 'anchordockingoptions.xml';
    SL := TStringList.Create;
    try
      SL.Text := '<?xml version="1.0" encoding="UTF-8"?>'#10 +
                 '<CONFIG>'#10 +
                 '  <EnableAnchorDock Value="True"/>'#10 +
                 '  <DoneAskUserEnableAnchorDock Value="True"/>'#10 +
                 '</CONFIG>'#10;
      SL.SaveToFile(AnchorOptFile);
    finally
      SL.Free;
    end;

    // 3. Garantir dockedformeditoroptions.xml ativo
    DockedFormOptFile := TargetDir + 'dockedformeditoroptions.xml';
    SL := TStringList.Create;
    try
      SL.Text := '<?xml version="1.0" encoding="UTF-8"?>'#10 +
                 '<CONFIG>'#10 +
                 '  <EnableDockedDesigner Value="True"/>'#10 +
                 '  <DoneAskUserEnableDockedDesigner Value="True"/>'#10 +
                 '</CONFIG>'#10;
      SL.SaveToFile(DockedFormOptFile);
    finally
      SL.Free;
    end;
  except
    // proteção contra falha de escrita em disco
  end;
end;

procedure RunRestorationScript;
var
  ScriptPath, ConfigPath, Ext: string;
  Proc: TProcess;
begin
  try
    ApplyCleanDockedLayout;

    ScriptPath := FindRestorationScript;
    if ScriptPath = '' then
      Exit;

    ConfigPath := '';
    if LazarusIDE <> nil then
      ConfigPath := LazarusIDE.GetPrimaryConfigPath;

    Ext := LowerCase(ExtractFileExt(ScriptPath));
    Proc := TProcess.Create(nil);
    try
      if Ext = '.ps1' then
      begin
        Proc.Executable := 'powershell.exe';
        Proc.Parameters.Add('-NoProfile');
        Proc.Parameters.Add('-ExecutionPolicy');
        Proc.Parameters.Add('Bypass');
        Proc.Parameters.Add('-File');
        Proc.Parameters.Add(ScriptPath);
        Proc.Parameters.Add('-Silent');
        if ConfigPath <> '' then
        begin
          Proc.Parameters.Add('-TargetConfigDir');
          Proc.Parameters.Add(ConfigPath);
        end;
      end
      else
      begin
        Proc.Executable := 'cmd.exe';
        Proc.Parameters.Add('/c');
        if ConfigPath <> '' then
          Proc.Parameters.Add('"' + ScriptPath + '" -Silent -TargetConfigDir "' + ConfigPath + '"')
        else
          Proc.Parameters.Add('"' + ScriptPath + '" -Silent');
      end;
      Proc.Options := [poNoConsole];
      Proc.Execute;
    finally
      Proc.Free;
    end;
  except
    // proteção contra falha ao executar script
  end;
end;

procedure ToggleThemeClicked(Sender: TObject);
var
  NewMode: TAppModeOpt;
  Msg, NewThemeName: string;
  Res: Integer;
  RestartDone: Boolean;
  RestartItem: TIDEMenuItem;
begin
  try
    if MetaDarkStyleDSGNOpt = nil then
    begin
      MetaDarkStyleDSGNOpt := TMetaDarkStyleDSGNOptions.Create;
      MetaDarkStyleDSGNOpt.LoadSafe;
    end;

    if MetaDarkStyleDSGNOpt.AppMode = amOptForceLight then
    begin
      NewMode := amOptForceDark;
      NewThemeName := 'Tema Escuro (Dark Mode)';
    end
    else
    begin
      NewMode := amOptForceLight;
      NewThemeName := 'Tema Claro (Light Mode)';
    end;

    Msg := 'O tema da IDE foi alterado para: ' + NewThemeName + '.' + LineEnding + LineEnding +
           'Para aplicar a renderizacao em todas as janelas e componentes nativos da IDE, ' +
           'e necessario reiniciar o Lazarus.' + LineEnding + LineEnding +
           'Deseja reiniciar a IDE agora?';

    Res := QuestionDlg('Alternar Tema da IDE', Msg, mtConfirmation, [mrYes, 'Reiniciar Agora', mrNo, 'Mais Tarde'], 0);

    MetaDarkStyleDSGNOpt.AppMode := NewMode;
    MetaDarkStyleDSGNOpt.SaveSafe;

    // Atualizar esquema de cores do editor de código e layout
    if NewMode = amOptForceLight then
    begin
      // Retornar ao padrão claro
      ApplyEditorColorScheme('Default');
      // Executar a restauração do layout para modo claro
      RunRestorationScript;
    end
    else
    begin
      // Ativar esquema escuro no editor de códigos
      DeployDarkModernColorScheme;
      ApplyEditorColorScheme('DarkModern');
      // Executar a restauração do layout para modo escuro
      RunRestorationScript;
    end;

    if Res = mrYes then
    begin
      RestartDone := False;
      try
        RestartDone := ExecuteIDECommand(nil, ecRestart);
      except
        RestartDone := False;
      end;

      if not RestartDone then
      begin
        try
          if itmFileIDEStart <> nil then
          begin
            RestartItem := itmFileIDEStart.FindByName('itmFileRestart');
            if (RestartItem is TIDEMenuCommand) and Assigned(TIDEMenuCommand(RestartItem).OnClick) then
            begin
              TIDEMenuCommand(RestartItem).OnClick(RestartItem);
              RestartDone := True;
            end;
          end;
        except
          RestartDone := False;
        end;
      end;
    end;
  except
    on E: Exception do
      ShowMessage('Erro ao alternar tema: ' + E.Message);
  end;
end;

procedure SetDarkStyle;
begin
 {$IF DEFINED(MSWINDOWS)}
  try
    DeployDarkModernColorScheme;
    LoadLResources;
    LoadPath(LazarusIDE.GetPrimaryConfigPath+'/userschemes','*.'+DSColorsTypeName);
    LoadPath(LazarusIDE.GetSecondaryConfigPath+'/userschemes','*.'+DSColorsTypeName);
    MetaDarkStyleDSGNOpt:=TMetaDarkStyleDSGNOptions.Create;
    MetaDarkStyleDSGNOpt.LoadSafe;
    PreferredAppMode:=AppModeOpt2PreferredAppMode(MetaDarkStyleDSGNOpt.AppMode);

    // Se a IDE está iniciando configurada para modo claro, assegura que o editor volte ao padrão claro
    if MetaDarkStyleDSGNOpt.AppMode = amOptForceLight then
      ApplyEditorColorScheme('Default');

    // Se o anchordocklayout.xml não existir, cria o layout limpo de fábrica
    if (LazarusIDE <> nil) and (LazarusIDE.GetPrimaryConfigPath <> '') then
    begin
      if not FileExists(IncludeTrailingPathDelimiter(LazarusIDE.GetPrimaryConfigPath) + 'anchordocklayout.xml') then
        ApplyCleanDockedLayout(LazarusIDE.GetPrimaryConfigPath);
    end;

    ApplyMetaDarkStyle(GetScheme(MetaDarkStyleDSGNOpt.ColorScheme));
  except
    // Safe startup: avoid crashing IDE during boot
  end;
 {$ENDIF}
end;

procedure Register;
var
  IDECommandCat: TIDECommandCategory;
begin
  try
    DeployDarkModernColorScheme;
    MetaDarkStyleOptionsID:=RegisterIDEOptionsEditor(GroupEnvironment,
                                                     TDarkStyleDSGNOptionsFrame,
                                                     MetaDarkStyleOptionsID)^.Index;

    // Localizar categoria válida na IDE
    IDECommandCat := IDECommandList.FindCategoryByName(CommandCategoryToolMenuName);
    if IDECommandCat = nil then
      IDECommandCat := IDECommandList.FindCategoryByName(CommandCategoryViewName);
    if IDECommandCat = nil then
      IDECommandCat := RegisterIDECommandCategory(nil, 'ThemeMenu', 'Theme');

    if IDECommandCat <> nil then
    begin
      ToggleThemeCommand := RegisterIDECommand(IDECommandCat, 'ToggleDarkStyleTheme',
        'Alternar Tema Claro/Escuro', CleanIDEShortCut, nil, @ToggleThemeClicked);

      if (ToggleThemeCommand <> nil) and (itmOptionsDialogs <> nil) then
        ToggleThemeMenuCmd := RegisterIDEMenuCommand(itmOptionsDialogs, 'ToggleDarkStyleTheme',
          'Alternar Tema Claro/Escuro', nil, nil, ToggleThemeCommand, 'menu_environment_options');

      if ToggleThemeCommand <> nil then
      begin
        ToggleThemeButtonCmd := RegisterIDEButtonCommand(ToggleThemeCommand);
        if (ToggleThemeButtonCmd <> nil) and (ToggleThemeMenuCmd <> nil) then
          ToggleThemeButtonCmd.ImageIndex := ToggleThemeMenuCmd.ImageIndex;
      end;
    end;
  except
    // Safe registration: avoid crashing IDE during package load
  end;
end;

initialization
  AddBootHandler(libhEnvironmentOptionsLoaded,@SetDarkStyle);
end.
