@echo off

echo *********************************************
echo       AWindsoft QuizBuilder�Զ�����ű�
echo *********************************************

if exist *.exe del *.exe
del ..\bin\QuizBuilder.exe
del output\*.*


echo.
echo.
echo ^>^>^>^>^>^>����������...%time%
set DCC32="C:\Program Files (x86)\CodeGear\RAD Studio\5.0\bin\dcc32.exe"
set DelphiPath=C:\Program Files (x86)\CodeGear\RAD Studio\5.0
set UPath="%DelphiPath%\Imports;%DelphiPath%\lib\Indy10;C:\Program Files (x86)\Raize\RC5\Lib\BDS2006;..\components\VCLZip305;..\components\FlashAx;..\components\PNGImage150;..\components\GIFImage22;..\components\FlashSDK230\ASCompiler;..\components\FlashSDK230\Sources"
set RPath="$(DELPHI)\Lib"
set EPath="..\bin"
set DCUPath="..\temp"

cd ..\source
%DCC32% -B -U%UPath% -I%IPath% -DRelease -N%DCUPath% -E%EPath% QuizBuilder.dpr
echo ^>^>^>^>^>^>�����������ɣ�...%time%

echo.
echo.
echo ^>^>^>^>^>^>�����װ����...%time%
cd %~dp0
set ISCC=".\Inno Setup 5\ISCC.exe"
%ISCC% /Ooutput quizbuilder.iss
echo ^>^>^>^>^>^>��װ��������ɣ�...%time%
pause




