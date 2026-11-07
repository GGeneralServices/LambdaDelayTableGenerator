# Lambda Delay Table Generator

A [TunerStudio](https://www.tunerstudio.com/) plugin that measures the delay between injector pulse-width steps and the wideband lambda response, live while you drive or from saved logs, and builds a **Lambda Delay** table for TunerStudio's VE Analyze.

VE Analyze needs to know how long a fuelling change takes to show up on the wideband sensor. That delay depends on RPM, load, and the location of your Wideband 02 sensor. Using the default values makes VE Analyze correct the wrong cells. You should use the default Lambda Delay table to get things close, then generate an accurate Lambda Delay table to get things accurate.

## Features

- **Live or from logs.** Collect while driving, or add TunerStudio / MegaLogViewer logs: binary `.mlg` (format 1 and 2) and text `.msl`, `.txt`, `.csv`. Only the four needed channels are read, so logs with thousands of channels fit in memory.
- **Automatic event detection.** Finds pulse-width steps and the lambda response onset. Tip-ins from steady lambda are accepted; throttle closes, fuel-cut entries and exits, clipped or unstable lambda, idle and implausible readings are rejected with a reason. Review any event, move its onset by double-clicking the plot, or accept / reject it by hand.
- **One session, many drives.** Every live run and log is kept in a session that's saved automatically and reopened next time. Logs can be removed again, duplicates are refused, and sessions can be exported and imported.
- **Each recording analysed on its own**, at its own sample interval and with its own sensor clipping limits, so adding a log doesn't change the others and the order doesn't matter. Live runs are analysed incrementally, so long drives stay quick.
- **Automatic table axes** from where the engine actually runs, with the bottom MAP row kept where events can be measured. Optional Max RPM Trigger waits until the full RPM range has been driven under load before the table is generated.
- **Table fill:** measured cells, row medians in crank revolutions, and higher-MAP rows estimated by MAP ratio or copied. Formula fits (delay = a + b / RPM) are shown.
- **Output:** The table is not written directly to TunerStudio. To apply the table you'll need to copy it and pasted it into VE Analyze. You can also export the table and events as CSV.

## Supported ECUs

The plugin has no ECU-specific logic: it works with any ECU TunerStudio supports, using four channels (RPM, MAP, lambda or AFR, injector pulse width). Channel defaults are pre-filled for:

| ECU | Live channels | Log columns |
|---|---|---|
| rusEFI (and forks such as EpicEFI) | `RPMValue`, `MAPValue`, `lambdaValue`, `actualLastInjection` | RPM, MAP, Lambda, Fuel: Last inj pulse width |
| Speeduino | `rpm`, `map`, `lambda`, `pulseWidth` | RPM, MAP, Lambda, PW |
| MegaSquirt (MS2 / MS3) | `rpm`, `map`, `lambda1`, `pulseWidth1` | RPM, MAP, Lambda, PW |

AFR channels work too: tick AFR and enter your fuel's stoich ratio.

## Install

1. Download `LambdaDelayTableGenerator.jar` from [Releases](../../releases).
2. In TunerStudio: **Tools > TunerStudio Plugins > Add or Update a Plugin**, and choose the jar.
3. Restart TunerStudio, then open **Tools > TunerStudio Plugins > Lambda Delay Table Generator**.

Updating keeps your saved session. Full instructions are in the plugin's **Help** button (the same text as [README.txt](README.txt)).

## Quick start

1. Connect to your ECU and check the four live channels.
2. Press **Start live** and drive: from steady cruise, give the throttle quick, firm stabs across the RPM and load range.
3. Watch events appear; review any that look wrong.
4. Press **Copy table for VE Analyze** and paste it into VE Analyze's Lambda Delay table.

## Building from source

Needs a Java JDK 8 or newer, and `TunerStudioPluginAPI.jar`, which isn't included in this repository: copy it from your TunerStudio installation's `lib` folder into the project folder.

```sh
./build.sh        # Linux / macOS
build.bat         # Windows
```

The jar is written to `dist/`. The build also checks that the version numbers match, and that the help text (README.txt, which is built into the jar) states the values in `Defaults.java`. See [BUILD.txt](BUILD.txt).

## Project layout

| Path | Contents |
|---|---|
| `src/com/lambdadelay/` | Plugin source. `LambdaDelayPlugin` (UI), `Detector` (events), `TableBuilder` (table and fits), `Recording` / `Session` (data and session files), `LiveCollector` / `LiveAnalysis` (live), `LogLoader` / `MlgLoader` (logs), `UsageAxes` (automatic axes), `Defaults` (tunable values). |
| `test/` | Development test harnesses, including a fake TunerStudio that replays logs through the plugin API. Several expect sample logs that aren't in the repository. |
| `README.txt` | The in-plugin Help text. |
| `INSTALL.txt`, `BUILD.txt` | Install and build notes shipped with releases. |

## Status

Under active testing with EpicEFI hardware. Reports and logs are welcome via [Issues](../../issues).

## License

[MIT](LICENSE).

## Disclaimer

Not affiliated with EFI Analytics. TunerStudio is a trademark of EFI Analytics. Use at your own risk: always check tables before using them on an engine.
