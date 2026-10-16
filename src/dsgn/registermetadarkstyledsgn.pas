unit registerMetaDarkStyleDSGN;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Controls, Dialogs, Forms, Process,
  IDEOptionsIntf, IDEOptEditorIntf, LazIDEIntf,
  IDECommands, MenuIntf, ToolBarIntf,
  LazConfigStorage, BaseIDEIntf, Laz2_XMLCfg, Laz2_DOM, Laz2_XMLRead, Laz2_XMLWrite, PackageIntf,
  EnvironmentOpts,
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

procedure SimpleCopyFileSafe(const Src, Dst: string);
var
  FSIn, FSOut: TFileStream;
begin
  try
    if not FileExists(Src) then Exit;
    ForceDirectories(ExtractFilePath(Dst));
    FSIn := TFileStream.Create(Src, fmOpenRead or fmShareDenyNone);
    try
      FSOut := TFileStream.Create(Dst, fmCreate);
      try
        FSOut.CopyFrom(FSIn, FSIn.Size);
      finally
        FSOut.Free;
      end;
    finally
      FSIn.Free;
    end;
  except
  end;
end;

function FindRestorationScript: string;
var
  Pkg: TIDEPackage;
  PkgDir, BaseDir, PrimaryCfg, UserProf, PkgFilesXml, LineStr: string;
  Candidates: array of string;
  i, PosVal: Integer;
  SL: TStringList;
  DriveChar: Char;

  procedure AddCandidate(const APath: string);
  var
    Len: Integer;
  begin
    if APath = '' then Exit;
    Len := Length(Candidates);
    SetLength(Candidates, Len + 4);
    Candidates[Len]   := IncludeTrailingPathDelimiter(APath) + 'scripts' + PathDelim + 'Restaurar-Layout-Lazarus.ps1';
    Candidates[Len+1] := IncludeTrailingPathDelimiter(APath) + 'scripts' + PathDelim + 'Restaurar-Layout-Lazarus.cmd';
    Candidates[Len+2] := IncludeTrailingPathDelimiter(APath) + 'Restaurar-Layout-Lazarus.ps1';
    Candidates[Len+3] := IncludeTrailingPathDelimiter(APath) + 'Restaurar-Layout-Lazarus.cmd';
  end;

begin
  Result := '';
  BaseDir := ExtractFilePath(ParamStr(0));
  if LazarusIDE <> nil then
    PrimaryCfg := LazarusIDE.GetPrimaryConfigPath
  else
    PrimaryCfg := '';

  SetLength(Candidates, 0);

  // 1. Tenta obter o diretório via pacote carregado
  PkgDir := '';
  if Assigned(PackageEditingInterface) then
  begin
    Pkg := PackageEditingInterface.FindPackageWithName('metadarkstyledsgn');
    if Pkg = nil then
      Pkg := PackageEditingInterface.FindPackageWithName('metadarkstyle');
    if Pkg = nil then
      Pkg := PackageEditingInterface.FindPackageWithName('lazdarkcomp');
    if Pkg = nil then
      Pkg := PackageEditingInterface.FindPackageWithName('metadarkstyledsgn226');

    if (Pkg = nil) and (PackageEditingInterface.GetPackageCount > 0) then
    begin
      for i := 0 to PackageEditingInterface.GetPackageCount - 1 do
      begin
        Pkg := PackageEditingInterface.GetPackages(i);
        if (Pkg <> nil) and ((Pos('metadark', LowerCase(Pkg.Name)) > 0) or (Pos('lazdark', LowerCase(Pkg.Name)) > 0)) then
          Break;
      end;
    end;

    if Pkg <> nil then
      PkgDir := Pkg.DirectoryExpanded;
  end;

  // 2. Se não encontrou o pacote em memória, consulta o packagefiles.xml no perfil da IDE
  if (PkgDir = '') and (PrimaryCfg <> '') then
  begin
    PkgFilesXml := IncludeTrailingPathDelimiter(PrimaryCfg) + 'packagefiles.xml';
    if FileExists(PkgFilesXml) then
    begin
      SL := TStringList.Create;
      try
        SL.LoadFromFile(PkgFilesXml);
        for i := 0 to SL.Count - 1 do
        begin
          LineStr := SL[i];
          if (Pos('Value="', LineStr) > 0) and 
             ((Pos('lazdarkcomp', LowerCase(LineStr)) > 0) or (Pos('metadark', LowerCase(LineStr)) > 0)) and 
             (Pos('.lpk"', LowerCase(LineStr)) > 0) then
          begin
            PosVal := Pos('Value="', LineStr) + 7;
            LineStr := Copy(LineStr, PosVal, Length(LineStr));
            PosVal := Pos('"', LineStr);
            if PosVal > 0 then
              LineStr := Copy(LineStr, 1, PosVal - 1);
            if FileExists(LineStr) then
            begin
              PkgDir := ExtractFilePath(LineStr);
              Break;
            end;
          end;
        end;
      finally
        SL.Free;
      end;
    end;
  end;

  // 3. Adiciona candidatos da pasta do componente encontrada
  if PkgDir <> '' then
    AddCandidate(PkgDir);

  // 4. Adiciona candidatos do perfil de configuração do Lazarus
  if PrimaryCfg <> '' then
    AddCandidate(PrimaryCfg);

  // 5. Adiciona candidatos da pasta base da IDE (ex: C:\lazarus)
  if BaseDir <> '' then
    AddCandidate(BaseDir);

  // 6. Adiciona candidatos da pasta Documentos do Usuário (ex: C:\Users\marco\Documents\ComponentesLazarus\lazdarkcomp)
  UserProf := GetEnvironmentVariable('USERPROFILE');
  if UserProf <> '' then
  begin
    AddCandidate(IncludeTrailingPathDelimiter(UserProf) + 'Documents' + PathDelim + 'ComponentesLazarus' + PathDelim + 'lazdarkcomp');
    AddCandidate(IncludeTrailingPathDelimiter(UserProf) + 'Documents' + PathDelim + 'ComponentesLazarus' + PathDelim + 'lazdarkcomp' + PathDelim + 'scripts');
    AddCandidate(IncludeTrailingPathDelimiter(UserProf) + 'Documents' + PathDelim + 'lazdarkcomp');
    AddCandidate(IncludeTrailingPathDelimiter(UserProf) + 'Documents' + PathDelim + 'lazdarkcomp' + PathDelim + 'scripts');
    AddCandidate(IncludeTrailingPathDelimiter(UserProf) + 'Documents' + PathDelim + 'metadark_safe');
  end;

  // 7. Varredura pelas unidades do sistema (C:, D:, E:, etc.)
  for DriveChar := 'C' to 'Z' do
  begin
    AddCandidate(DriveChar + ':\ComponentesLazarus\lazdarkcomp');
    AddCandidate(DriveChar + ':\ComponentesLazarus\lazdarkcomp\scripts');
    AddCandidate(DriveChar + ':\Componentes\lazdarkcomp');
    AddCandidate(DriveChar + ':\Componentes\lazdarkcomp\scripts');
    AddCandidate(DriveChar + ':\lazdarkcomp');
    AddCandidate(DriveChar + ':\lazdarkcomp\scripts');
    AddCandidate(DriveChar + ':\lazarus\scripts');
  end;

  // 8. Retorna o primeiro candidato que existir fisicamente
  for i := Low(Candidates) to High(Candidates) do
  begin
    if (Candidates[i] <> '') and FileExists(Candidates[i]) then
      Exit(Candidates[i]);
  end;
end;

function HasSourceNotebookInAnchorDocking(ANode: TDOMNode): Boolean;
var
  i: Integer;
  Elem: TDOMElement;
begin
  Result := False;
  if ANode = nil then Exit;
  if ANode.NodeType = ELEMENT_NODE then
  begin
    Elem := TDOMElement(ANode);
    if Elem.GetAttribute('Name') = 'SourceNotebook' then
      Exit(True);
  end;
  for i := 0 to ANode.ChildNodes.Count - 1 do
  begin
    if HasSourceNotebookInAnchorDocking(ANode.ChildNodes[i]) then
      Exit(True);
  end;
end;

procedure UpdateEnvironmentOptionsDockLayout(const AConfigDir: string);
var
  EnvFile: string;
  EnvDoc, LayoutDoc: TXMLDocument;
  SS: TStringStream;
  FS: TFileStream;
  DesktopsNode, DesktopNode, OldAnchor, NewAnchor, ChildNode, FormNode, PosNode, VisNode: TDOMNode;
  DskElem, FormElem, PosElem: TDOMElement;
  DskName, DockMaster: string;
  i, j, k: Integer;
  FormsList: array[0..4] of record
    Name, Left, Top, Width, Height: string;
  end;
begin
  try
    EnvFile := IncludeTrailingPathDelimiter(AConfigDir) + 'environmentoptions.xml';
    if not FileExists(EnvFile) then
      Exit;

    EnvDoc := nil;
    LayoutDoc := nil;
    SS := nil;
    try
      ReadXMLFile(EnvDoc, EnvFile);
      if EnvDoc = nil then Exit;

      DesktopsNode := EnvDoc.DocumentElement.FindNode('Desktops');
      if DesktopsNode = nil then Exit;

      if DesktopsNode is TDOMElement then
        TDOMElement(DesktopsNode).SetAttribute('ActiveDesktop', 'default docked');

      FormsList[0].Name := 'SourceNotebook';
      FormsList[0].Left := '329'; FormsList[0].Top := '100'; FormsList[0].Width := '1223'; FormsList[0].Height := '620';

      FormsList[1].Name := 'MessagesView';
      FormsList[1].Left := '329'; FormsList[1].Top := '725'; FormsList[1].Width := '1223'; FormsList[1].Height := '241';

      FormsList[2].Name := 'ObjectInspectorDlg';
      FormsList[2].Left := '5'; FormsList[2].Top := '100'; FormsList[2].Width := '324'; FormsList[2].Height := '866';

      FormsList[3].Name := 'ProjectInspector';
      FormsList[3].Left := '1563'; FormsList[3].Top := '100'; FormsList[3].Width := '357'; FormsList[3].Height := '340';

      FormsList[4].Name := 'MainIDE';
      FormsList[4].Left := '-9'; FormsList[4].Top := '-9'; FormsList[4].Width := '1920'; FormsList[4].Height := '966';

      SS := TStringStream.Create(CleanAnchorDockLayoutXML);
      ReadXMLFile(LayoutDoc, SS);

      for i := 0 to DesktopsNode.ChildNodes.Count - 1 do
      begin
        DesktopNode := DesktopsNode.ChildNodes[i];
        if (DesktopNode.NodeType = ELEMENT_NODE) and (Pos('Desktop', DesktopNode.NodeName) = 1) then
        begin
          DskElem := TDOMElement(DesktopNode);
          DskName := DskElem.GetAttribute('Name');
          DockMaster := DskElem.GetAttribute('DockMaster');

          if (DockMaster = 'TIDEAnchorDockMaster') or
             (Pos('dock', LowerCase(DskName)) > 0) or
             (Pos('mauricio', LowerCase(DskName)) > 0) then
          begin
            DskElem.SetAttribute('DockMaster', 'TIDEAnchorDockMaster');

            OldAnchor := DskElem.FindNode('AnchorDocking');
            if OldAnchor <> nil then
              DskElem.RemoveChild(OldAnchor).Free;

            if (LayoutDoc <> nil) and (LayoutDoc.DocumentElement <> nil) then
            begin
              NewAnchor := EnvDoc.CreateElement('AnchorDocking');
              for j := 0 to LayoutDoc.DocumentElement.ChildNodes.Count - 1 do
              begin
                ChildNode := EnvDoc.ImportNode(LayoutDoc.DocumentElement.ChildNodes[j], True);
                NewAnchor.AppendChild(ChildNode);
              end;
              DskElem.AppendChild(NewAnchor);
            end;

            for k := Low(FormsList) to High(FormsList) do
            begin
              FormNode := DskElem.FindNode(FormsList[k].Name);
              if FormNode = nil then
              begin
                FormNode := EnvDoc.CreateElement(FormsList[k].Name);
                DskElem.AppendChild(FormNode);
              end;
              FormElem := TDOMElement(FormNode);

              PosNode := FormElem.FindNode('CustomPosition');
              if PosNode = nil then
              begin
                PosNode := EnvDoc.CreateElement('CustomPosition');
                FormElem.AppendChild(PosNode);
              end;
              PosElem := TDOMElement(PosNode);
              PosElem.SetAttribute('Left', FormsList[k].Left);
              PosElem.SetAttribute('Top', FormsList[k].Top);
              PosElem.SetAttribute('Width', FormsList[k].Width);
              PosElem.SetAttribute('Height', FormsList[k].Height);

              VisNode := FormElem.FindNode('Visible');
              if VisNode = nil then
              begin
                VisNode := EnvDoc.CreateElement('Visible');
                FormElem.AppendChild(VisNode);
              end;
              TDOMElement(VisNode).SetAttribute('Value', 'True');
            end;
          end;
        end;
      end;

      WriteXMLFile(EnvDoc, EnvFile);
    finally
      if LayoutDoc <> nil then LayoutDoc.Free;
      if SS <> nil then SS.Free;
      if EnvDoc <> nil then EnvDoc.Free;
    end;

    // Se o XMLCfg do EnvironmentOptions estiver em memoria, recarrega a partir do disco atualizado
    if (EnvironmentOptions <> nil) and (EnvironmentOptions.XMLCfg <> nil) and FileExists(EnvFile) then
    begin
      try
        FS := TFileStream.Create(EnvFile, fmOpenRead or fmShareDenyNone);
        try
          EnvironmentOptions.XMLCfg.Clear;
          EnvironmentOptions.XMLCfg.ReadFromStream(FS);
        finally
          FS.Free;
        end;
      except
        // ignora se recarga em memoria falhar
      end;
    end;
  except
    // protecao contra erro de IO
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

    // 4. Atualizar diretamente o environmentoptions.xml em disco e em memoria
    UpdateEnvironmentOptionsDockLayout(TargetDir);
  except
    // proteção contra falha de escrita em disco
  end;
end;

procedure RunRestorationScript;
var
  ScriptPath, ConfigPath, Ext, DestDir: string;
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

    // Copia preventivamente os scripts para a pasta de configurações da IDE
    if (ConfigPath <> '') and DirectoryExists(ConfigPath) then
    begin
      try
        DestDir := IncludeTrailingPathDelimiter(ConfigPath) + 'scripts';
        ForceDirectories(DestDir);
        SimpleCopyFileSafe(ScriptPath, IncludeTrailingPathDelimiter(DestDir) + ExtractFileName(ScriptPath));
        SimpleCopyFileSafe(ChangeFileExt(ScriptPath, '.cmd'), IncludeTrailingPathDelimiter(DestDir) + 'Restaurar-Layout-Lazarus.cmd');
        SimpleCopyFileSafe(ChangeFileExt(ScriptPath, '.ps1'), IncludeTrailingPathDelimiter(DestDir) + 'Restaurar-Layout-Lazarus.ps1');
      except
      end;
    end;

    // Se o script for .cmd, mas existir o equivalente .ps1, prioriza executar diretamente via PowerShell
    if (LowerCase(ExtractFileExt(ScriptPath)) = '.cmd') and 
       FileExists(ChangeFileExt(ScriptPath, '.ps1')) then
      ScriptPath := ChangeFileExt(ScriptPath, '.ps1');

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
        Proc.Parameters.Add(ScriptPath);
        Proc.Parameters.Add('-Silent');
        if ConfigPath <> '' then
        begin
          Proc.Parameters.Add('-TargetConfigDir');
          Proc.Parameters.Add(ConfigPath);
        end;
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

procedure ApplyObjectInspectorYellowColors(const AConfigDir: string);
var
  EnvFile: string;
  EnvDoc: TXMLDocument;
  DesktopsNode, DesktopNode, OINode, ColorNode, ValNode, RefNode: TDOMNode;
  i: Integer;
  Modified: Boolean;
begin
  if AConfigDir = '' then Exit;
  EnvFile := IncludeTrailingPathDelimiter(AConfigDir) + 'environmentoptions.xml';
  if not FileExists(EnvFile) then Exit;

  EnvDoc := nil;
  Modified := False;
  try
    try
      ReadXMLFile(EnvDoc, EnvFile);
      if (EnvDoc = nil) or (EnvDoc.DocumentElement = nil) then Exit;

      DesktopsNode := EnvDoc.DocumentElement.FindNode('Desktops');
      if DesktopsNode is TDOMElement then
      begin
        for i := 0 to DesktopsNode.ChildNodes.Count - 1 do
        begin
          DesktopNode := DesktopsNode.ChildNodes[i];
          if (DesktopNode.NodeType = ELEMENT_NODE) and (Pos('Desktop', DesktopNode.NodeName) = 1) then
          begin
            OINode := DesktopNode.FindNode('ObjectInspectorOptions');
            if OINode = nil then
            begin
              OINode := EnvDoc.CreateElement('ObjectInspectorOptions');
              DesktopNode.AppendChild(OINode);
              Modified := True;
            end;

            ColorNode := OINode.FindNode('Color');
            if ColorNode = nil then
            begin
              ColorNode := EnvDoc.CreateElement('Color');
              OINode.AppendChild(ColorNode);
              Modified := True;
            end;

            ValNode := ColorNode.FindNode('Value');
            if ValNode = nil then
            begin
              ValNode := EnvDoc.CreateElement('Value');
              TDOMElement(ValNode).SetAttribute('Value', 'clYellow');
              ColorNode.AppendChild(ValNode);
              Modified := True;
            end
            else if TDOMElement(ValNode).GetAttribute('Value') <> 'clYellow' then
            begin
              TDOMElement(ValNode).SetAttribute('Value', 'clYellow');
              Modified := True;
            end;

            RefNode := ColorNode.FindNode('References');
            if RefNode = nil then
            begin
              RefNode := EnvDoc.CreateElement('References');
              TDOMElement(RefNode).SetAttribute('Value', 'clYellow');
              ColorNode.AppendChild(RefNode);
              Modified := True;
            end
            else if TDOMElement(RefNode).GetAttribute('Value') <> 'clYellow' then
            begin
              TDOMElement(RefNode).SetAttribute('Value', 'clYellow');
              Modified := True;
            end;
          end;
        end;
      end;

      if Modified then
        WriteXMLFile(EnvDoc, EnvFile);
    except
      // Safe fallback
    end;
  finally
    if EnvDoc <> nil then EnvDoc.Free;
  end;
end;

procedure SetDarkStyle;
var
  TargetDir, EnvFile: string;
  EnvDoc: TXMLDocument;
  DesktopsNode, DesktopNode, AnchorNode: TDOMNode;
  DskElem: TDOMElement;
  DskName, DockMaster, ActiveDesktop: string;
  NeedsRepair: Boolean;
  i: Integer;
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

    if (LazarusIDE <> nil) and (LazarusIDE.GetPrimaryConfigPath <> '') then
    begin
      TargetDir := IncludeTrailingPathDelimiter(LazarusIDE.GetPrimaryConfigPath);

      // 1. Se o anchordocklayout.xml não existir, cria o layout limpo de fábrica
      if not FileExists(TargetDir + 'anchordocklayout.xml') then
        ApplyCleanDockedLayout(TargetDir);

      // 2. Verificar se o environmentoptions.xml tem o layout docado bagunçado/corrompido
      EnvFile := TargetDir + 'environmentoptions.xml';
      if FileExists(EnvFile) then
      begin
        NeedsRepair := False;
        EnvDoc := nil;
        try
          ReadXMLFile(EnvDoc, EnvFile);
          if (EnvDoc <> nil) and (EnvDoc.DocumentElement <> nil) then
          begin
            DesktopsNode := EnvDoc.DocumentElement.FindNode('Desktops');
            if DesktopsNode is TDOMElement then
            begin
              ActiveDesktop := TDOMElement(DesktopsNode).GetAttribute('ActiveDesktop');
              for i := 0 to DesktopsNode.ChildNodes.Count - 1 do
              begin
                DesktopNode := DesktopsNode.ChildNodes[i];
                if (DesktopNode.NodeType = ELEMENT_NODE) and (Pos('Desktop', DesktopNode.NodeName) = 1) then
                begin
                  DskElem := TDOMElement(DesktopNode);
                  DskName := DskElem.GetAttribute('Name');
                  DockMaster := DskElem.GetAttribute('DockMaster');
                  if (DockMaster = 'TIDEAnchorDockMaster') or
                     (ActiveDesktop <> '') and (DskName = ActiveDesktop) then
                  begin
                    AnchorNode := DskElem.FindNode('AnchorDocking');
                    if (AnchorNode = nil) or not HasSourceNotebookInAnchorDocking(AnchorNode) then
                    begin
                      NeedsRepair := True;
                      Break;
                    end;
                  end;
                end;
              end;
            end;
          end;
        finally
          if EnvDoc <> nil then EnvDoc.Free;
        end;

        if NeedsRepair then
          ApplyCleanDockedLayout(TargetDir);

        if MetaDarkStyleDSGNOpt.AppMode <> amOptForceLight then
          ApplyObjectInspectorYellowColors(TargetDir);
      end;
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
