'+-----------------------------------------------------------------------------+
'| MM17DRead v0.1 * Status reader program for MM17D device                     |
'| Copyright (C) 2023 Pozsár Zsolt <pozsarzs@gmail.com>                        |
'| mkshortcut.vbs                                                              |
'| Make shortcut                                                               |
'+-----------------------------------------------------------------------------+

set WshShell = WScript.CreateObject("WScript.Shell" )
set oShellLink = WshShell.CreateShortcut(Wscript.Arguments.Named("shortcut") & ".lnk")
oShellLink.TargetPath = Wscript.Arguments.Named("target")
oShellLink.WindowStyle = 1
oShellLink.Save
