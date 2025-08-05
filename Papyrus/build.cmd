@ECHO off

call ..\set-paths.cmd
if %errorlevel% neq 0 exit /b %errorlevel%

SET CrowdControlPath=%~dp0
SET F4SEScriptSourcePath="%CrowdControlPath%..\F4SE-Plugin\f4se\Scripts\Source"
SET FalloutDataPath="%FalloutPath%\Data\"
SET CompilerPath="%FalloutPath%\Papyrus Compiler"
SET ArchiveToolPath="%FalloutPath%\Tools\Archive2"
SET ArchiveSource="%CrowdControlPath%archive.source"
SET ArchiveOutput="%FalloutPath%\Data\CrowdControl - Main.ba2"
SET PexPath=%CrowdControlPath%Scripts
SET PscPath="%PexPath%\Source"

copy /Y %FalloutDataPath%CrowdControl.esp ".\esp\"
if %errorlevel% neq 0 exit /b %errorlevel%

cd /D %CompilerPath%
if %errorlevel% neq 0 exit /b %errorlevel%

for /R "%PscPath%" %%F in ("*.psc") do (
    call :compile "%%F"
)
goto :startwait

:compile
start "" /B cmd /c PapyrusCompiler.exe %1 -f="Institute_Papyrus_Flags.flg" -i="%F4SEScriptSourcePath%;%PscPath%;%FalloutPath%\Data\Scripts\Source;%FalloutPath%\Data\Scripts\Source\User;%FalloutPath%\Data\Scripts\Source\Base" -o="%PexPath%" -op
exit /b

:startwait
:waitloop
tasklist /FI "IMAGENAME eq PapyrusCompiler.exe" | find /I "PapyrusCompiler.exe" >nul
if not errorlevel 1 (
    echo Waiting for script compilers to finish...
    timeout /t 1 >nul
    goto waitloop
)

type nul > "%CrowdControlPath%archive.source"

for /R "%PexPath%" %%F in ("*.pex") do (
    echo %%F >> "%CrowdControlPath%archive.source"
)

cd /D %ArchiveToolPath%
Archive2.exe -create=%ArchiveOutput% -sourceFile=%ArchiveSource% -root=%CrowdControlPath%
if %errorlevel% neq 0 exit /b %errorlevel%

cd /D %CrowdControlPath%
