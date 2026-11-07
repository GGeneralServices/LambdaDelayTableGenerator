#!/bin/sh
# Same steps as build.bat (used for packaging here).
set -e
cd "$(dirname "$0")"
API=${API:-TunerStudioPluginAPI.jar}
V=$(grep 'public static final String VERSION' src/com/lambdadelay/LambdaDelayPlugin.java | sed 's/.*"\(.*\)".*/\1/')
head -1 README.txt | grep -q "^LAMBDA DELAY TABLE GENERATOR - TunerStudio plugin, version $V\b" || { echo "README.txt is not version $V"; exit 1; }
grep -q "Implementation-Version: $V" manifest.mf || { echo "manifest.mf is not version $V"; exit 1; }
# README.txt (the Help text) must state the defaults in Defaults.java
D=src/com/lambdadelay/Defaults.java
IDLE=$(grep 'NEW_SESSION_MAX_IDLE_RPM =' $D | sed 's/.*= *\([0-9]*\);.*/\1/')
RUN=$(grep 'ENGINE_RUNNING_RPM =' $D | sed 's/.*= *\([0-9]*\);.*/\1/')
grep -q "starts with $IDLE in the box" README.txt || { echo "README.txt doesn't say a new session starts with $IDLE in the box (Defaults.java)"; exit 1; }
grep -q "Data below $RUN RPM" README.txt || { echo "README.txt doesn't say data below $RUN RPM is ignored (Defaults.java)"; exit 1; }
val() { grep "$1 =" $D | sed 's/.*= *\([0-9.]*\);.*/\1/'; }
TT=$(val TRIGGER_TIMES); TS=$(val TRIGGER_MIN_SECONDS); TM=$(val TRIGGER_MIN_MAP_KPA); TR=$(val TRIGGER_MAX_RPM_RISE); TD=$(val TRIGGER_RESET_DROP); RB=$(val REFERENCE_BARO_KPA); NB=$(val NEW_SESSION_BARO_KPA)
RULE="Under load = for at least $TS s: MAP at least $TM kPa at $RB kPa baro, fuel on, RPM rising no faster than $TR RPM/s."
grep -qF "A new session starts with $NB." README.txt || { echo "README.txt doesn't say a new session starts with baro $NB (Defaults.java)"; exit 1; }
AT=$(val AXIS_TOP_MIN_SECONDS); FD=$(val FIXED_DELAY_DEFAULT_MS)
FMIN=$(grep "FIXED_DELAY_MIN_MS =" $D | sed 's/.*FIXED_DELAY_MIN_MS = *\([0-9.]*\),.*/\1/'); FMAX=$(grep "FIXED_DELAY_MAX_MS =" $D | sed 's/.*FIXED_DELAY_MAX_MS = *\([0-9.]*\);.*/\1/')
grep -qF "held for at least $AT s in total" README.txt || { echo "README.txt doesn't say the top MAP point uses MAP held for $AT s (Defaults.java)"; exit 1; }
grep -qF "kept between $FMIN and $FMAX ms" README.txt || { echo "README.txt doesn't say the fixed part is kept between $FMIN and $FMAX ms (Defaults.java)"; exit 1; }
grep -qF "$FD ms is used" README.txt || { echo "README.txt doesn't say $FD ms is used when the fixed part can't be measured (Defaults.java)"; exit 1; }
grep -qF "$RULE" README.txt || { echo "README.txt doesn't contain: $RULE (Defaults.java)"; exit 1; }
grep -qF "under load $TT separate times" README.txt || { echo "README.txt doesn't say the trigger must be reached under load $TT separate times (Defaults.java)"; exit 1; }
grep -qF "drop $TD RPM below the trigger" README.txt || { echo "README.txt doesn't say RPM must drop $TD RPM below the trigger (Defaults.java)"; exit 1; }
MR=$(val AXIS_MIN_RPM)
grep -qF "below $MR RPM" README.txt || { echo "README.txt doesn't state the $MR RPM axis minimum (Defaults.java AXIS_MIN_RPM)"; exit 1; }
FP=$(val AXIS_MAP_FLOOR_EVENT_PCT)
FN=$(val AXIS_MAP_FLOOR_MIN_EVENTS)
grep -qF "at least $FN accepted" README.txt || { echo "README.txt doesn't state the $FN-event minimum for the MAP floor (Defaults.java AXIS_MAP_FLOOR_MIN_EVENTS)"; exit 1; }
grep -qF "raised, if higher, to the ${FP}th" README.txt || { echo "README.txt doesn't state the ${FP}th percentile MAP floor (Defaults.java AXIS_MAP_FLOOR_EVENT_PCT)"; exit 1; }
LMIN=$(val LAMBDA_MIN); LMAX=$(val LAMBDA_MAX); SMIN=$(val STOICH_MIN); SMAX=$(val STOICH_MAX)
grep -qF "lambda between $LMIN and $LMAX" README.txt || { echo "README.txt doesn't say lambda must be between $LMIN and $LMAX (Defaults.java)"; exit 1; }
grep -qF "a number from $SMIN to $SMAX" README.txt || { echo "README.txt doesn't say stoich must be a number from $SMIN to $SMAX (Defaults.java)"; exit 1; }
rm -rf build/classes dist; mkdir -p build/classes dist
if ! javac --release 8 -Xlint:-options -cp "$API" -d build/classes src/com/lambdadelay/*.java > build/javac.log 2>&1; then
  grep -v "^Note:" build/javac.log; echo "Compile failed - jar not built"; exit 1
fi
grep -v "^Note:" build/javac.log || true
cp README.txt build/classes/com/lambdadelay/README.txt
jar cfm dist/LambdaDelayTableGenerator.jar manifest.mf -C build/classes .
echo "Built version $V"
