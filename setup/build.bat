@echo off

echo *********************************************
echo       AWindsoft QuizBuilder自动打包脚本
echo *********************************************

if exist *.exe del *.exe
del ..\bin\QuizBuilder.exe
del output\*.*


echo.
echo.
echo ^>^>^>^>^>^>编译主程序...%time%
set DCC32="C:\Program Files (x86)\CodeGear\RAD Studio\5.0\bin\dcc32.exe"
set DelphiPath=C:\Program Files (x86)\CodeGear\RAD Studio\5.0
set UPath="%DelphiPath%\Imports;%DelphiPath%\lib\Indy10;C:\Program Files (x86)\Raize\RC5\Lib\BDS2006;..\components\VCLZip305;..\components\FlashAx;..\components\PNGImage150;..\components\GIFImage22;..\components\FlashSDK230\ASCompiler;..\components\FlashSDK230\Sources"
set RPath="$(DELPHI)\Lib"
set EPath="..\bin"
set DCUPath="..\temp"

cd ..\source
%DCC32% -B -U%UPath% -I%IPath% -DRelease -N%DCUPath% -E%EPath% QuizBuilder.dpr
echo ^>^>^>^>^>^>主程序编译完成！...%time%

echo.
echo.
echo ^>^>^>^>^>^>打包安装程序...%time%
cd %~dp0
set ISCC=".\Inno Setup 5\ISCC.exe"
%ISCC% /Ooutput quizbuilder.iss
echo ^>^>^>^>^>^>安装程序打包完成！...%time%
pause




