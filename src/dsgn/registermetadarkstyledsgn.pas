unit registerMetaDarkStyleDSGN;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, ComCtrls, Dialogs,
  IDEOptionsIntf, IDEOptEditorIntf, LazIDEIntf, lazconf,
  IDECommands, MenuIntf, ToolBarIntf, IDEImagesIntf,
  uDarkStyleParams, uDarkStyleSchemes, uMetaDarkStyle,
  MetaDarkStyleDSGNOptionsFrame, MetaDarkStyleDSGNOptions;

var
  MetaDarkStyleOptionsID: integer = 1000;
  ToggleThemeCommand: TIDECommand = nil;
  ToggleThemeButtonCmd: TIDEButtonCommand = nil;
  ToggleThemeMenuCmd: TIDEMenuCommand = nil;

procedure Register;

implementation

type
  { TToggleThemeHelper }
  TToggleThemeHelper = class
  public
    procedure ToggleThemeClicked(Sender: TObject);
    procedure AsyncEnsureToolbarButton(Data: PtrInt);
  end;

var
  ToggleThemeHelper: TToggleThemeHelper = nil;

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
    SchemeDir := IncludeTrailingPathDelimiter(GetPrimaryConfigPath) + 'userschemes';
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

procedure TToggleThemeHelper.ToggleThemeClicked(Sender: TObject);
var
  NewMode: TAppModeOpt;
  Msg, NewThemeName: string;
  Res: Integer;
  RestartCmd: TIDECommand;
begin
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
         'Para aplicar a renderização em todas as janelas e componentes nativos da IDE, ' +
         'é necessário reiniciar o Lazarus.' + LineEnding + LineEnding +
         'Deseja reiniciar a IDE agora?';

  Res := QuestionDlg('Alternar Tema da IDE', Msg, mtConfirmation, [mrYes, 'Reiniciar Agora', mrNo, 'Mais Tarde'], 0);

  // Salva a nova configuração
  MetaDarkStyleDSGNOpt.AppMode := NewMode;
  MetaDarkStyleDSGNOpt.SaveSafe;

  if Res = mrYes then
  begin
    RestartCmd := IDECommandList.FindIDECommand(ecRestart);
    if RestartCmd <> nil then
      RestartCmd.Execute(nil);
  end;
end;

procedure TToggleThemeHelper.AsyncEnsureToolbarButton(Data: PtrInt);
var
  MainForm: TForm;
  CoolBar: TCoolBar;
  ToolBar: TToolBar;
  Btn, Sep: TToolButton;
  i, j: Integer;
  Found: Boolean;
  ImgIdx: Integer;
begin
  MainForm := LazarusIDE.GetMainBar;
  if MainForm = nil then Exit;

  CoolBar := nil;
  for i := 0 to MainForm.ControlCount - 1 do
    if MainForm.Controls[i] is TCoolBar then
    begin
      CoolBar := TCoolBar(MainForm.Controls[i]);
      Break;
    end;

  if CoolBar = nil then Exit;

  Found := False;
  for i := 0 to CoolBar.Bands.Count - 1 do
  begin
    if (CoolBar.Bands[i].Control is TToolBar) then
    begin
      ToolBar := TToolBar(CoolBar.Bands[i].Control);
      for j := 0 to ToolBar.ButtonCount - 1 do
      begin
        if ToolBar.Buttons[j].Name = 'btnToggleDarkTheme' then
        begin
          Found := True;
          Break;
        end;
      end;
    end;
    if Found then Break;
  end;

  if not Found and (CoolBar.Bands.Count > 0) and (CoolBar.Bands[0].Control is TToolBar) then
  begin
    ToolBar := TToolBar(CoolBar.Bands[0].Control);

    Sep := TToolButton.Create(ToolBar);
    Sep.Style := tbsSeparator;
    Sep.Parent := ToolBar;

    Btn := TToolButton.Create(ToolBar);
    Btn.Name := 'btnToggleDarkTheme';
    Btn.Caption := 'Tema';
    if (MetaDarkStyleDSGNOpt <> nil) and (MetaDarkStyleDSGNOpt.AppMode = amOptForceLight) then
      Btn.Hint := 'Tema atual: Claro (Light). Clique para alternar para Escuro (Dark)'
    else
      Btn.Hint := 'Tema atual: Escuro (Dark). Clique para alternar para Claro (Light)';
    Btn.ShowHint := True;

    ImgIdx := -1;
    if IDEImages <> nil then
      ImgIdx := IDEImages.GetImageIndex('menu_environment_options');
    if ImgIdx < 0 then
      ImgIdx := IDEImages.LoadImage('menu_environment_options');
    if ImgIdx >= 0 then
      Btn.ImageIndex := ImgIdx;

    Btn.OnClick := @ToggleThemeClicked;
    Btn.Parent := ToolBar;
  end;
end;

procedure SetDarkStyle;
begin
 {$IF DEFINED(MSWINDOWS)}
  DeployDarkModernColorScheme;
  LoadLResources;
  LoadPath(GetPrimaryConfigPath+'/userschemes','*.'+DSColorsTypeName);
  LoadPath(GetSecondaryConfigPath+'/userschemes','*.'+DSColorsTypeName);
  MetaDarkStyleDSGNOpt:=TMetaDarkStyleDSGNOptions.Create;
  MetaDarkStyleDSGNOpt.LoadSafe;
  PreferredAppMode:=AppModeOpt2PreferredAppMode(MetaDarkStyleDSGNOpt.AppMode);
  ApplyMetaDarkStyle(GetScheme(MetaDarkStyleDSGNOpt.ColorScheme));

  if ToggleThemeHelper <> nil then
    Application.QueueAsyncCall(@ToggleThemeHelper.AsyncEnsureToolbarButton, 0);
 {$ENDIF}
end;

procedure Register;
var
  IDECommandCat: TIDECommandCategory;
begin
  DeployDarkModernColorScheme;
  MetaDarkStyleOptionsID:=RegisterIDEOptionsEditor(GroupEnvironment,
                                                   TDarkStyleDSGNOptionsFrame,
                                                   MetaDarkStyleOptionsID)^.Index;

  if ToggleThemeHelper = nil then
    ToggleThemeHelper := TToggleThemeHelper.Create;

  IDECommandCat := IDECommandList.FindCategoryByName('Environment');
  if IDECommandCat = nil then
    IDECommandCat := IDECommandList.FindCategoryByName('View');

  ToggleThemeCommand := RegisterIDECommand(IDECommandCat, 'ToggleDarkStyleTheme',
    'Alternar Tema Claro/Escuro', CleanIDEShortCut, @ToggleThemeHelper.ToggleThemeClicked, nil);

  ToggleThemeMenuCmd := RegisterIDEMenuCommand(itmOptionsDialogs, 'ToggleDarkStyleTheme',
    'Alternar Tema Claro/Escuro', nil, nil, ToggleThemeCommand, 'menu_environment_options');

  ToggleThemeButtonCmd := RegisterIDEButtonCommand(ToggleThemeCommand);
  if (ToggleThemeButtonCmd <> nil) and (ToggleThemeMenuCmd <> nil) then
    ToggleThemeButtonCmd.ImageIndex := ToggleThemeMenuCmd.ImageIndex;
end;

initialization
  ToggleThemeHelper := TToggleThemeHelper.Create;
  AddBootHandler(libhEnvironmentOptionsLoaded,@SetDarkStyle);

finalization
  FreeAndNil(ToggleThemeHelper);
end.
