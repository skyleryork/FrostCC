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

PapyrusCompiler.exe "%PscPath%" -f="Institute_Papyrus_Flags.flg" -i="%F4SEScriptSourcePath%;%PscPath%;%FalloutPath%\Data\Scripts\Source;%FalloutPath%\Data\Scripts\Source\User;%FalloutPath%\Data\Scripts\Source\Base" -o="%PexPath%" -a -op -q
if %errorlevel% neq 0 exit /b %errorlevel%

type nul > "%CrowdControlPath%archive.source"

for /R "%PexPath%" %%F in ("*.pex") do (
    echo %%F >> "%CrowdControlPath%archive.source"
)

cd /D %ArchiveToolPath%
Archive2.exe -create=%ArchiveOutput% -sourceFile=%ArchiveSource% -root=%CrowdControlPath%
if %errorlevel% neq 0 exit /b %errorlevel%

cd /D %CrowdControlPath%
