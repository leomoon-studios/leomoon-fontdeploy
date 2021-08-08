SET sign=%CD%\..\..\..\#code-sign\signtool\signtool.exe
SET pfx=%CD%\..\..\..\#code-sign\signtool\cert.pfx
SET /p pass=<%cd%\..\..\..\#code-sign\signtool\cert.txt
SET url=https://leomoon.com

SET AppName=FontDeploy
SET app=%CD%\..\build\%AppName%.exe

"%ProgramFiles(x86)%\AutoIt3\AutoIt3.exe" "C:\Program Files (x86)\AutoIt3\SciTE\AutoIt3Wrapper\AutoIt3Wrapper.au3" /in "%AppName%.au3"
"%sign%" sign /fd SHA256 /d "%AppName%" /du "%url%" /f "%pfx%" /p %pass% /t "http://timestamp.comodoca.com/authenticode" "%app%"