@ECHO off
@ECHO.
@ECHO - Building Papyrus...
@ECHO.

call ..\set-paths.cmd
if %errorlevel% neq 0 exit /b %errorlevel%

SET CrowdControlPath=%~dp0
SET ScriptSourcePath="%FalloutPath%\Data\Scripts\Source\"
SET ScriptSourceUserPath="%FalloutPath%\Data\Scripts\Source\User\"
SET ScriptSourceFragmentPath="%FalloutPath%\Data\Scripts\Source\User\Fragments\Quests\"
SET ScriptDataPath="%FalloutPath%\Data\Scripts\"
SET ScriptDataFragmentPath="%FalloutPath%\Data\Scripts\Fragments\Quests\"
SET FalloutDataPath="%FalloutPath%\Data\"
SET CompilerPath="%FalloutPath%\Papyrus Compiler"
SET ArchiveToolPath="%FalloutPath%\Tools\Archive2"
SET ArchiveSource="%CrowdControlPath%archive.source"
SET ArchiveOutput="%FalloutPath%\Data\CrowdControl - Main.ba2"
SETLOCAL EnableDelayedExpansion

md %ScriptSourceUserPath%
for %%F in ("%CrowdControlPath%*.psc") do (
    copy /Y "%%F" %ScriptSourceUserPath%
    if !errorlevel! neq 0 exit /b !errorlevel!
)

md %ScriptSourceFragmentPath%
if not exist %ScriptSourceFragmentPath%QF_CrowdControlQuest_01000F99.psc (
    copy /Y ".\psc\QF_CrowdControlQuest_01000F99.psc" %ScriptSourceFragmentPath%
) else (
    cmd /c exit /b 0
)
if %errorlevel% neq 0 exit /b %errorlevel%

md %ScriptSourcePath%
if not exist %ScriptSourcePath%Actor.psc (
    copy /Y ".\psc\Actor.psc" %ScriptSourcePath%
) else (
    cmd /c exit /b 0
)
if %errorlevel% neq 0 exit /b %errorlevel%
if not exist %ScriptSourcePath%Form.psc (
    copy /Y ".\psc\Form.psc" %ScriptSourcePath%
) else (
    cmd /c exit /b 0
)
if %errorlevel% neq 0 exit /b %errorlevel%
if not exist %ScriptSourcePath%ObjectReference.psc (
    copy /Y ".\psc\ObjectReference.psc" %ScriptSourcePath%
) else (
    cmd /c exit /b 0
)
if %errorlevel% neq 0 exit /b %errorlevel%

md %ScriptDataFragmentPath%
if not exist %ScriptDataFragmentPath%QF_CrowdControlQuest_01000F99.pex (
    copy /Y ".\pex\QF_CrowdControlQuest_01000F99.pex" %ScriptDataFragmentPath%
) else (
    cmd /c exit /b 0
)
if %errorlevel% neq 0 exit /b %errorlevel%

if not exist %ScriptDataPath%Actor.pex (
    copy /Y ".\pex\Actor.pex" %ScriptDataPath%
) else (
    cmd /c exit /b 0
)
if %errorlevel% neq 0 exit /b %errorlevel%
if not exist %ScriptDataPath%Form.pex (
    copy /Y ".\pex\Form.pex" %ScriptDataPath%
) else (
    cmd /c exit /b 0
)
if %errorlevel% neq 0 exit /b %errorlevel%
if not exist %ScriptDataPath%ObjectReference.pex (
    copy /Y ".\pex\ObjectReference.pex" %ScriptDataPath%
) else (
    cmd /c exit /b 0
)
if %errorlevel% neq 0 exit /b %errorlevel%

copy /Y %FalloutDataPath%CrowdControl.esp ".\esp\"
if %errorlevel% neq 0 exit /b %errorlevel%

cd /D %CompilerPath%
if %errorlevel% neq 0 exit /b %errorlevel%

for %%F in ("%CrowdControlPath%*.psc") do (
    start "" /B cmd /c PapyrusCompiler.exe "%%F" -f="Institute_Papyrus_Flags.flg" -i="%FalloutPath%\Data\Scripts\Source;%FalloutPath%\Data\Scripts\Source\User;%FalloutPath%\Data\Scripts\Source\Base" -o="%FalloutPath%\Data\Scripts" -op
)

echo Waiting for all compilers to finish...
:waitloop
tasklist /FI "IMAGENAME eq PapyrusCompiler.exe" | find /I "PapyrusCompiler.exe" >nul
if not errorlevel 1 (
    timeout /t 1 >nul
    goto waitloop
)

SET PexPath=!FalloutPath!\Data\Scripts\
SET QuestPexPath=!FalloutPath!\Data\Scripts\Fragments\Quests\

type nul > "%CrowdControlPath%archive.source"

(
    echo !PexPath!Actor.pex
    echo !PexPath!CrowdControl.pex
    echo !PexPath!CrowdControlApi.pex
    echo !QuestPexPath!QF_CrowdControlQuest_01000F99.pex
) >> "%CrowdControlPath%archive.source"

for %%F in ("%CrowdControlPath%*.psc") do (
    echo !PexPath!%%~nF.pex >> "%CrowdControlPath%archive.source"
)

cd /D %ArchiveToolPath%
Archive2.exe -create=%ArchiveOutput% -sourceFile=%ArchiveSource%
if %errorlevel% neq 0 exit /b %errorlevel%

cd /D %CrowdControlPath%

ENDLOCAL
