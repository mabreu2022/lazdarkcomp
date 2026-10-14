unit registerMetaDarkStyleDSGN;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Controls, Dialogs,
  IDEOptionsIntf, IDEOptEditorIntf, LazIDEIntf,
  IDECommands, MenuIntf, ToolBarIntf,
  uDarkStyleParams, uDarkStyleSchemes, uMetaDarkStyle,
  MetaDarkStyleDSGNOptionsFrame, MetaDarkStyleDSGNOptions;

var
  MetaDarkStyleOptionsID: integer = 1000;
  ToggleThemeCommand: TIDECommand = nil;
  ToggleThemeButtonCmd: TIDEButtonCommand = nil;
  ToggleThemeMenuCmd: TIDEMenuCommand = nil;

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
