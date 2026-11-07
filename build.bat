@echo off
setlocal
REM Rebuilds LambdaDelayTableGenerator.jar from source.
REM Needs a Java JDK (8 or newer) and TunerStudioPluginAPI.jar in this folder
REM (copy it from [TunerStudio install folder]\lib\).
cd /d "%~dp0"
if not exist TunerStudioPluginAPI.jar (
  echo Copy TunerStudioPluginAPI.jar from your TunerStudio lib folder into this folder first.
  pause
  exit /b 1
)

REM --- The Help text is README.txt. Check its version matches the plugin's. ---
set V=
for /f "tokens=2 delims==;" %%a in ('findstr /C:"public static final String VERSION" src\com\lambdadelay\LambdaDelayPlugin.java') do set V=%%a
set V=%V: =%
set V=%V:"=%
findstr /B /C:"LAMBDA DELAY TABLE GENERATOR - TunerStudio plugin, version %V%" README.txt >nul
if errorlevel 1 (
  echo README.txt's first line does not say version %V%.
  echo Update README.txt for this version before building.
  pause
  exit /b 1
)

findstr /C:"Implementation-Version: %V%" manifest.mf >nul
if errorlevel 1 (
  echo manifest.mf's Implementation-Version is not %V%.
  pause
  exit /b 1
)

REM --- README.txt (the Help text) must state the defaults in Defaults.java ---
set IDLE=
set RUN=
for /f "tokens=2 delims==;" %%a in ('findstr /C:"NEW_SESSION_MAX_IDLE_RPM =" src\com\lambdadelay\Defaults.java') do set IDLE=%%a
for /f "tokens=2 delims==;" %%a in ('findstr /C:"ENGINE_RUNNING_RPM =" src\com\lambdadelay\Defaults.java') do set RUN=%%a
set IDLE=%IDLE: =%
set RUN=%RUN: =%
findstr /C:"starts with %IDLE% in the box" README.txt >nul
if errorlevel 1 (
  echo README.txt doesn't say a new session starts with %IDLE% in the box ^(Defaults.java^).
  pause
  exit /b 1
)
findstr /C:"Data below %RUN% RPM" README.txt >nul
if errorlevel 1 (
  echo README.txt doesn't say data below %RUN% RPM is ignored ^(Defaults.java^).
  pause
  exit /b 1
)
for /f "tokens=2 delims==;" %%a in ('findstr /C:"TRIGGER_TIMES =" src\com\lambdadelay\Defaults.java') do set TT=%%a
for /f "tokens=2 delims==;" %%a in ('findstr /C:"TRIGGER_MIN_SECONDS =" src\com\lambdadelay\Defaults.java') do set TS=%%a
for /f "tokens=2 delims==;" %%a in ('findstr /C:"TRIGGER_MIN_MAP_KPA =" src\com\lambdadelay\Defaults.java') do set TM=%%a
for /f "tokens=2 delims==;" %%a in ('findstr /C:"TRIGGER_MAX_RPM_RISE =" src\com\lambdadelay\Defaults.java') do set TR=%%a
for /f "tokens=2 delims==;" %%a in ('findstr /C:"TRIGGER_RESET_DROP =" src\com\lambdadelay\Defaults.java') do set TD=%%a
for /f "tokens=2 delims==;" %%a in ('findstr /C:"REFERENCE_BARO_KPA =" src\com\lambdadelay\Defaults.java') do set RB=%%a
for /f "tokens=2 delims==;" %%a in ('findstr /C:"NEW_SESSION_BARO_KPA =" src\com\lambdadelay\Defaults.java') do set NB=%%a
set TT=%TT: =%
set TS=%TS: =%
set TM=%TM: =%
set TR=%TR: =%
set TD=%TD: =%
set RB=%RB: =%
set NB=%NB: =%
findstr /C:"Under load = for at least %TS% s: MAP at least %TM% kPa at %RB% kPa baro, fuel on, RPM rising no faster than %TR% RPM/s." README.txt >nul
if errorlevel 1 (
  echo README.txt doesn't state the Max RPM Trigger rule in Defaults.java ^(%TS% s, %TM% kPa, %TR% RPM/s^).
  pause
  exit /b 1
)
findstr /C:"A new session starts with %NB%." README.txt >nul
if errorlevel 1 (
  echo README.txt doesn't say a new session starts with baro %NB% ^(Defaults.java^).
  pause
  exit /b 1
)
for /f "tokens=2 delims==;" %%a in ('findstr /C:"AXIS_TOP_MIN_SECONDS =" src\com\lambdadelay\Defaults.java') do set AT=%%a
for /f "tokens=2 delims==;" %%a in ('findstr /C:"FIXED_DELAY_DEFAULT_MS =" src\com\lambdadelay\Defaults.java') do set FD=%%a
for /f "tokens=2,3 delims==,;" %%a in ('findstr /C:"FIXED_DELAY_MIN_MS =" src\com\lambdadelay\Defaults.java') do set FMIN=%%a
for /f "tokens=4 delims==,;" %%a in ('findstr /C:"FIXED_DELAY_MIN_MS =" src\com\lambdadelay\Defaults.java') do set FMAX=%%a
set AT=%AT: =%
set FD=%FD: =%
set FMIN=%FMIN: =%
set FMAX=%FMAX: =%
findstr /C:"held for at least %AT% s in total" README.txt >nul
if errorlevel 1 (
  echo README.txt doesn't say the top MAP point uses MAP held for %AT% s ^(Defaults.java^).
  pause
  exit /b 1
)
findstr /C:"kept between %FMIN% and %FMAX% ms" README.txt >nul
if errorlevel 1 (
  echo README.txt doesn't say the fixed part is kept between %FMIN% and %FMAX% ms ^(Defaults.java^).
  pause
  exit /b 1
)
findstr /C:"%FD% ms is used" README.txt >nul
if errorlevel 1 (
  echo README.txt doesn't say %FD% ms is used when the fixed part can't be measured ^(Defaults.java^).
  pause
  exit /b 1
)
findstr /C:"under load %TT% separate times" README.txt >nul
if errorlevel 1 (
  echo README.txt doesn't say the trigger must be reached under load %TT% separate times ^(Defaults.java^).
  pause
  exit /b 1
)
findstr /C:"drop %TD% RPM below the trigger" README.txt >nul
if errorlevel 1 (
  echo README.txt doesn't say RPM must drop %TD% RPM below the trigger ^(Defaults.java^).
  pause
  exit /b 1
)

if exist build rmdir /s /q build
mkdir build
for /f "tokens=2 delims==;" %%a in ('findstr /C:"AXIS_MIN_RPM =" src\com\lambdadelay\Defaults.java') do set MR=%%a
set MR=%MR: =%
findstr /C:"below %MR% RPM" README.txt >nul
if errorlevel 1 (
  echo README.txt doesn't state the %MR% RPM axis minimum ^(Defaults.java AXIS_MIN_RPM^).
  pause
  exit /b 1
)
for /f "tokens=2 delims==;" %%a in ('findstr /C:"AXIS_MAP_FLOOR_EVENT_PCT =" src\com\lambdadelay\Defaults.java') do set FP=%%a
set FP=%FP: =%
for /f "tokens=2 delims==;" %%a in ('findstr /C:"AXIS_MAP_FLOOR_MIN_EVENTS =" src\com\lambdadelay\Defaults.java') do set FN=%%a
set FN=%FN: =%
findstr /C:"at least %FN% accepted" README.txt >nul
if errorlevel 1 (
  echo README.txt doesn't state the %FN%-event minimum for the MAP floor ^(Defaults.java AXIS_MAP_FLOOR_MIN_EVENTS^).
  pause
  exit /b 1
)
findstr /C:"raised, if higher, to the %FP%th" README.txt >nul
if errorlevel 1 (
  echo README.txt doesn't state the %FP%th percentile MAP floor ^(Defaults.java AXIS_MAP_FLOOR_EVENT_PCT^).
  pause
  exit /b 1
)
for /f "tokens=2 delims==;" %%a in ('findstr /C:"LAMBDA_MIN =" src\com\lambdadelay\Defaults.java') do set LMIN=%%a
for /f "tokens=2 delims==;" %%a in ('findstr /C:"LAMBDA_MAX =" src\com\lambdadelay\Defaults.java') do set LMAX=%%a
for /f "tokens=2 delims==;" %%a in ('findstr /C:"STOICH_MIN =" src\com\lambdadelay\Defaults.java') do set SMIN=%%a
for /f "tokens=2 delims==;" %%a in ('findstr /C:"STOICH_MAX =" src\com\lambdadelay\Defaults.java') do set SMAX=%%a
set LMIN=%LMIN: =%
set LMAX=%LMAX: =%
set SMIN=%SMIN: =%
set SMAX=%SMAX: =%
findstr /C:"lambda between %LMIN% and %LMAX%" README.txt >nul
if errorlevel 1 (
  echo README.txt doesn't say lambda must be between %LMIN% and %LMAX% ^(Defaults.java^).
  pause
  exit /b 1
)
findstr /C:"a number from %SMIN% to %SMAX%" README.txt >nul
if errorlevel 1 (
  echo README.txt doesn't say stoich must be a number from %SMIN% to %SMAX% ^(Defaults.java^).
  pause
  exit /b 1
)
javac --release 8 -cp TunerStudioPluginAPI.jar -d build src\com\lambdadelay\*.java
if errorlevel 1 ( pause & exit /b 1 )
copy /y README.txt build\com\lambdadelay\README.txt >nul
jar cfm LambdaDelayTableGenerator.jar manifest.mf -C build .
echo.
echo Built LambdaDelayTableGenerator.jar, version %V%, with README.txt as its Help text.
pause
