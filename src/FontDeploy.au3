#NoTrayIcon
#RequireAdmin

#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=resources\icon.ico
#AutoIt3Wrapper_UseUpx=n
#AutoIt3Wrapper_UseX64=n
#AutoIt3Wrapper_Change2CUI=y
#AutoIt3Wrapper_Res_Language=1033
#AutoIt3Wrapper_Res_requestedExecutionLevel=requireAdministrator
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

;#pragma compile(UPX, False)
;#pragma compile(x64, False)
#pragma compile(Out, ..\build\FontDeploy.exe)
#pragma compile(Compression, 9)
#pragma compile(Comments, This program is freeware.)
#pragma compile(ProductName, LeoMoon FontDeploy)
#pragma compile(FileDescription, LeoMoon FontDeploy)
#pragma compile(FileVersion, 1.2.2.0)
#pragma compile(LegalCopyright, Amin Babaeipanah)
#pragma compile(CompanyName, LeoMoon Studios)
#pragma compile(LegalTrademarks, LeoMoon Studios)
#pragma compile(ProductVersion, 1.2.2.0)

AutoItSetOption("ExpandEnvStrings", 1)

#include <Array.au3>
#include <File.au3>
#Include <APIConstants.au3>
#Include <StaticConstants.au3>
#Include <WinAPIEx.au3>

If $CmdLine[0] == 0 Then
    _copyright()
    _fontInstall(@ScriptDir)
	Exit
ElseIf $CmdLine[0] == 1 Then
    If $CmdLine[1] == '--help' Or $CmdLine[1] == '-h' Then
        _copyright()
		_help()
		Exit
	Else
        If FileExists($CmdLine[1]) And StringInStr(FileGetAttrib($CmdLine[1]), "D") Then
            _copyright()
            _fontInstall($CmdLine[1])
            Exit
        Else
            _copyright()
            ConsoleWrite("[x] ERROR: Directory doesn't exist!"&@LF&@LF)
            _help()
            Exit
        EndIf
	EndIf
Else
    _copyright()
	ConsoleWrite("[x] ERROR: Too many arguments!"&@LF&@LF)
	_help()
	Exit
EndIf

Func _copyright()
    ConsoleWrite(''&@LF)
    ConsoleWrite('                 LeoMoon FontDeploy 1.2.2'&@LF)
    ConsoleWrite('          (c) LeoMoon Studios - www.leomoon.com'&@LF)
    ConsoleWrite(''&@LF)
EndFunc

Func _help()
	ConsoleWrite('HELP:'&@LF)
    ConsoleWrite('    By default this program will install TTF and OTF fonts'&@LF)
    ConsoleWrite("    at it's root directory without any arguments."&@LF)
	ConsoleWrite('        FontDeploy.exe'&@LF)
	ConsoleWrite(''&@LF)
    ConsoleWrite('    You can also define an absolute path inside double quotations.'&@LF)
    ConsoleWrite('        FontDeploy.exe "D:\install-fonts"'&@LF)
	ConsoleWrite(''&@LF)
	ConsoleWrite('    Here is an example of a path with environment varible.'&@LF)
	ConsoleWrite('        FontDeploy.exe "%CD%\fonts"'&@LF)
    ConsoleWrite(''&@LF)
    ConsoleWrite('    * Full absolute paths are supported.'&@LF)
    ConsoleWrite('    * Paths with environment variables are supported.'&@LF)
    ConsoleWrite(''&@LF)
EndFunc

Func _fontInstall($source)
	Local $aFonts = _FileListToArrayRec($source, "*.ttf;*.otf", 1,0,1)
	If IsArray($aFonts) Then
		For $i = 1 To $aFonts[0]
			Local $pName = ' (TrueType)'
			If StringRight($aFonts[$i],4) == '.otf' Then $pName = ' (OpenType)'
			Local $font = $aFonts[$i]
			Local $sFont = $source&'\'&$aFonts[$i]
            $fName = _fileGetProperty($sFont, 'Title')
            $fName = StringStripWS($fName, 1+2)
            If $fName <> '' Then
                $fName &= $pName
                $path = _WinAPI_ShellGetSpecialFolderPath($CSIDL_FONTS)
                If FileCopy($sFont, $path) Then
                    RegWrite('HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts', $fName, 'REG_SZ', $font)
                EndIf
                If Not _WinAPI_AddFontResourceEx($path & '\' & $font, 0, 1) Then
                    Return SetError(4, 0, 0)
                EndIf
                ConsoleWrite('[i] INSTALLED: "'&$fName&'" was installed successfully.'&@LF)
            Else
                ConsoleWrite('[x] SKIPPED: "'&$font&'" is corrupted and was skipped.'&@LF)
            EndIf
        Next
        ConsoleWrite(@LF&'All done.'&@LF)
    Else
        ConsoleWrite("[x] ERROR: No fonts found!"&@LF&@LF)
        _help()
    EndIf
    ;Sleep(100000)
EndFunc

Func _fileGetProperty($FGP_Path, $FGP_PROPERTY = "", $iPropertyCount = 300)
    If $FGP_PROPERTY = Default Then $FGP_PROPERTY = ""
    $FGP_Path = StringRegExpReplace($FGP_Path, '["'']', "") ; strip the quotes, if any from the incoming string
    If Not FileExists($FGP_Path) Then Return SetError(1, 0, "") ; path not found
    Local Const $objShell = ObjCreate("Shell.Application")
    If @error Then Return SetError(3, 0, "")
    Local Const $FGP_File = StringTrimLeft($FGP_Path, StringInStr($FGP_Path, "\", 0, -1))
    Local Const $FGP_Dir = StringTrimRight($FGP_Path, StringLen($FGP_File) + 1)
    Local Const $objFolder = $objShell.NameSpace($FGP_Dir)
    Local Const $objFolderItem = $objFolder.Parsename($FGP_File)
    Local $Return = "", $iError = 0, $iExtended = 0
    Local Static $FGP_PROPERTY_Text = "", $FGP_PROPERTY_Index = 0
    If $FGP_PROPERTY_Text = $FGP_PROPERTY And $FGP_PROPERTY_Index Then
        If $objFolder.GetDetailsOf($objFolder.Items, $FGP_PROPERTY_Index) = $FGP_PROPERTY Then
            Return SetError(0, $FGP_PROPERTY_Index, $objFolder.GetDetailsOf($objFolderItem, $FGP_PROPERTY_Index))
        EndIf
    EndIf
    If Int($FGP_PROPERTY) Then
        $Return = $objFolder.GetDetailsOf($objFolderItem, $FGP_PROPERTY - 1)
        If $Return = "" Then
            $iError = 2
        EndIf
    ElseIf $FGP_PROPERTY Then
        For $I = 0 To $iPropertyCount
            If $objFolder.GetDetailsOf($objFolder.Items, $I) = $FGP_PROPERTY Then
                $FGP_PROPERTY_Text = $FGP_PROPERTY
                $FGP_PROPERTY_Index = $I
                $iExtended = $I
                $Return = $objFolder.GetDetailsOf($objFolderItem, $I)
            EndIf
        Next
        If $Return = "" Then
            $iError = 2
        EndIf
    Else
        Local $av_ret[$iPropertyCount + 1][2] = [[0]]
        For $I = 1 To $iPropertyCount
            If $objFolder.GetDetailsOf($objFolder.Items, $I) Then
                $av_ret[$I][0] = $objFolder.GetDetailsOf($objFolder.Items, $I - 1)
                $av_ret[$I][1] = $objFolder.GetDetailsOf($objFolderItem, $I - 1)
                $av_ret[0][0] += 1
            EndIf
        Next
        ReDim $av_ret[$av_ret[0][0] + 1][2]
        If Not $av_ret[1][0] Then
            $iError = 2
            $av_ret = $Return
        Else
            $Return = $av_ret
        EndIf
    EndIf
    Return SetError($iError, $iExtended, $Return)
EndFunc