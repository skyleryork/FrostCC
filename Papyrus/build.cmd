@ECHO off
@ECHO.
@ECHO - Building Papyrus...
@ECHO.

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
SET PexFragmentsPath="%PexPath%\Fragments\Quests"
SET PexLootPath="%PexPath%\Loot"
SET PscPath="%PexPath%\Source"
SET PscFragmentsPath="%PexPath%\Source\Fragments\Quests"
SET PscLootPath="%PexPath%\Source\Loot"
SETLOCAL EnableDelayedExpansion

copy /Y %FalloutDataPath%CrowdControl.esp ".\esp\"
if %errorlevel% neq 0 exit /b %errorlevel%

cd /D %CompilerPath%
if %errorlevel% neq 0 exit /b %errorlevel%

for %%F in ("%PscPath%\*.psc") do (
    start "" /B cmd /c PapyrusCompiler.exe "%%F" -f="Institute_Papyrus_Flags.flg" -i="%F4SEScriptSourcePath%;%PscPath%;%FalloutPath%\Data\Scripts\Source;%FalloutPath%\Data\Scripts\Source\User;%FalloutPath%\Data\Scripts\Source\Base" -o="%PexPath%" -op
)
for %%F in ("%PscFragmentsPath%\*.psc") do (
    start "" /B cmd /c PapyrusCompiler.exe "%%F" -f="Institute_Papyrus_Flags.flg" -i="%F4SEScriptSourcePath%;%PscPath%;%FalloutPath%\Data\Scripts\Source;%FalloutPath%\Data\Scripts\Source\User;%FalloutPath%\Data\Scripts\Source\Base" -o="%PexPath%" -op
)
for %%F in ("%PscLootPath%\*.psc") do (
    start "" /B cmd /c PapyrusCompiler.exe "%%F" -f="Institute_Papyrus_Flags.flg" -i="%F4SEScriptSourcePath%;%PscPath%;%FalloutPath%\Data\Scripts\Source;%FalloutPath%\Data\Scripts\Source\User;%FalloutPath%\Data\Scripts\Source\Base" -o="%PexPath%" -op
)

echo Waiting for script compilers to finish...
:waitloop
tasklist /FI "IMAGENAME eq PapyrusCompiler.exe" | find /I "PapyrusCompiler.exe" >nul
if not errorlevel 1 (
    timeout /t 1 >nul
    goto waitloop
)

type nul > "%CrowdControlPath%archive.source"

for %%F in ("%PexPath%\*.pex") do (
    echo %%F >> "%CrowdControlPath%archive.source"
)
for %%F in ("%PexFragmentsPath%\*.pex") do (
    echo %%F >> "%CrowdControlPath%archive.source"
)
for %%F in ("%PexLootPath%\*.pex") do (
    echo %%F >> "%CrowdControlPath%archive.source"
)

cd /D %ArchiveToolPath%
Archive2.exe -create=%ArchiveOutput% -sourceFile=%ArchiveSource% -root=%CrowdControlPath%
if %errorlevel% neq 0 exit /b %errorlevel%

cd /D %CrowdControlPath%

ENDLOCAL
