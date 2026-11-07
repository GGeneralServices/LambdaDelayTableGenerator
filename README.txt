LAMBDA DELAY TABLE GENERATOR - TunerStudio plugin, version 2.7
==============================================================

Measures the delay between injector pulse-width steps and the lambda sensor
response, live while you drive or from saved logs, and builds a Lambda Delay
table to paste into TunerStudio's VE Analyze. The session is kept between
TunerStudio runs, so the table is refined over as many drives as you like.

QUICK START
  First drive
    1. Connect TunerStudio to the ECU, then open Tools > TunerStudio
       Plugins > Lambda Delay Table Generator.
    2. Check the four live channels (RPM, MAP, Lambda/AFR, Pulse width).
       For rusEFI, Speeduino and MegaSquirt the defaults are already right
       (see WORKS WITH).
    3. Press Start live. Leave the plugin window open while you drive
       (move it aside if you need to); closing it stops collection.
    4. Drive. From steady cruise, give the throttle a quick, firm stab and
       hold the new position for about a second, then wait a few seconds
       before the next one. Do this at different speeds and loads, only
       where it is safe to do so. Each clean stab can become a measured
       event. To leave out stabs from idle, set Max idle RPM (see IGNORING
       IDLE).
    5. Watch the event list: green ACCEPT rows are measured delays, and the
       table at the bottom fills in as they arrive.
    6. Press Stop live when you are done.

  Check the events
    7. Set Show to "Accepted" and click each event. In the plot, the
       magenta dashed line should sit where lambda first starts to move.
         - Wrong place? Double-click where it really starts.
         - Not a clean event? Press Space (or Accept / Reject) to reject it.

  Make the table
    8. The table's MAP and RPM axes are generated automatically from where
       you drive ("Generate table axes automatically" is on). Choose how
       many MAP and RPM points you want; the table updates by itself. If
       you set a Max RPM Trigger, the axes wait until you have reached that
       RPM under load twice. To use your own axes instead, untick the box
       and type the values.
    9. Read the table: M cells are measured; R, S and C cells are
       estimated from the measured ones. More drives turn estimates into
       measurements.

  Put it into VE Analyze
   10. In VE Analyze, open the Lambda Delay table and set its axes to the
       same MAP and RPM values shown in the plugin.
   11. Press "Copy table for VE Analyze", click the top-left cell of the
       Lambda Delay table, and press Ctrl+V. Check that the high-MAP row is
       at the top.

  Next time
   12. Open the plugin again and your session is still there. Press Start
       live (or Add log...) to add more data, then repeat steps 7-11. The
       table gets better with every drive.

  Using a log instead of driving live
    Press Add log..., choose the .mlg or .msl file, check the channels in the
    dialog, and press OK. Then continue from step 7.

WORKS WITH
  The plugin only uses standard TunerStudio plugin features and four
  channels, so it isn't tied to one ECU. It needs: RPM, MAP in kPa, a
  wideband lambda or AFR channel, and injector pulse width in ms.
  The channels are picked automatically for these ECUs:

    ECU            Live channels                       Log columns
    rusEFI/epicEFI RPMValue, MAPValue, lambdaValue,    RPM, MAP, Lambda,
                   actualLastInjection                 Fuel: Last inj pulse width
    Speeduino      rpm, map, lambda, pulseWidth        RPM, MAP, Lambda, PW
    MegaSquirt     rpm, map, lambda1, pulseWidth1      RPM, MAP, Lambda, PW
    (MS2/MS3)

  For any other ECU, pick the four channels from the lists (they hold every
  channel your ECU's definition has). If you pick an AFR channel instead of
  lambda, tick "AFR" and set stoich.

LAMBDA READINGS
  The plugin works in lambda. An AFR channel is divided by the stoich
  value you enter (a number from 5 to 20: gasoline 14.7, E85 9.8);
  anything else in the box is refused when you start live or add a log.

  Readings must be physically possible: lambda between 0.5 and 2.0. Others
  are junk (sensor warming up, wrong channel, AFR read as lambda):
    - An event whose lambda leaves that range anywhere from just before
      the step to the end of its response window is rejected as "Lambda
      outside 0.5-2.0". It is never used in the table: Accept / Reject and
      setting the onset by hand are refused for it, and a decision you made
      earlier is overridden.
    - Junk readings are not taken as the sensor's clipping limits.
  The status line warns (starting "Check lambda:") when a recording's
  readings look wrong, judged while the engine runs: typical values above
  3 (AFR read as lambda: add the log again with the AFR box ticked), typical
  values outside 0.5-2.0 (wrong channel, or wrong stoich), or more than 5%
  of readings outside 0.5-2.0. The warning also appears when a log is added.

  Logs can be binary .mlg (TunerStudio, or an ECU's own SD card log) or
  text (.msl, .txt or .csv). See LOGS.

BOOSTED ENGINES
  Everything works with boost. MAP is in kPa absolute (up to 500 kPa), as
  rusEFI, Speeduino and MegaSquirt report it: pick the MAP channel, not a
  boost gauge in psi. A turbo adds exhaust volume before a sensor fitted
  after it, so delays are usually longer, especially before it spools; the
  plugin measures that like any other delay, and MAP binning keeps spooled
  and unspooled conditions apart. For a good table under boost:
    - Get some measured events under boost: firm throttle stabs from steady
      light boost. Until then, boost rows are estimates (S, see HOW THE
      TABLE IS FILLED).
    - Automatic axes raise the top MAP point to cover boost once the engine
      has held it for 3 s in total (see TABLE AXES).
    - Max RPM Trigger's load test (60 kPa) is easily met under boost.

THE SESSION
  Everything you collect goes into one session: live runs, logs and
  imported sessions. New data is added after what is already there, and
  the events, your review decisions and the table cover the whole session.

  EACH RECORDING IS ANALYSED ON ITS OWN, once, when it's added: at its own
  sample interval (5-20 ms for logs, 10 ms for live runs) and with its own
  lambda clipping limits. So adding a log doesn't change the results of the
  others, and the order you add them in doesn't matter. Changing "Accept
  DFCO exits" analyses every recording again; the other settings only
  re-check results. The automatic axes, Max RPM Trigger and the table still
  use every recording together. The status line shows the clipping limits,
  or "differs by recording" if the recordings' limits aren't all the same.
  The label at the top right says how many recordings the session has, and
  "In this session", under the table buttons, lists them oldest first: each
  log by its file name, and each live run as "Live run <date time>". Logs
  that share a file name (e.g. LOG0001.mlg from different days) also show
  their length.

  REMOVING A LOG OR LIVE RUN: select it in "In this session" and press the
  small "-" button next to the heading, then OK. Everything that came from
  it goes: its data, its events and any changes you made to them by hand.
  The table, formula fits, automatic axes and Max RPM Trigger are worked out
  again from what's left, exactly as if it had never been added; the other
  recordings' events and hand-made changes stay as they were. Removing the
  last one leaves an empty session with your settings. A removed log can be
  added again; a live run can't, unless it's in a session you exported.
  "-" isn't available during live collection or while a task is running.

  A LOG CAN ONLY BE ADDED ONCE. Adding a log that is already in the session
  gives an error and nothing is added:
    - the same file (same name and size) is refused straight away;
    - the same drive under another name, or saved as .mlg and as .msl, is
      refused after reading, when its rows, length and RPM match a log
      already in the session.
  This also works after the session is reopened. Import session... with
  "Add to current session" is refused if the imported session holds a log
  that's already here ("Replace current session" still works). A log that
  only overlaps another one (e.g. the same drive logged from a later point)
  isn't caught, and neither is a log of a drive also collected live.

  KEPT BETWEEN RUNS (on by default)
    With "Keep between runs" ticked, the session is saved automatically and
    reopened the next time you open the plugin, so each drive adds to the
    same table. It is saved a few seconds after any change, every minute
    during live collection, and when the plugin window closes. Each
    TunerStudio project has its own saved session, in:
        <your user folder>\LambdaDelayTableGenerator\<project name>.ldsession
    Untick it to stop saving automatically (the setting is remembered).

    Start live / Stop live   Collect from the ECU. Each run is added.
    Add log...               Add a log to the session.
    Export session...        Save a copy (backup, or to share). Saves in
                             the background with a progress bar; Cancel
                             leaves an existing file as it was. Works while
                             live collection runs.
    Import session...        Open a saved copy. If the session already has
                             data you can add to it or replace it. Only
                             sessions saved by this version of the plugin
                             can be opened.
    New session              Start again with an empty session. If the
                             current one has data you are asked first:
                               Save, then start new - pick a file to save
                                 it to (as Export session); if you cancel
                                 the save, nothing changes.
                               Don't save - discard it, including the
                                 automatically saved copy.
                               Cancel - keep working on it.

  Size: data is kept compactly, about 16 bytes per sample in memory and
  4-6 on disk. An hour at 10 ms is about 6 MB in memory and 2 MB on disk.

LIVE MODE
  1. Connect to the ECU and open the plugin.
  2. Check the four live channels (see WORKS WITH for the defaults). If you
     pick an AFR channel, tick "AFR" and set stoich.
  3. Press Start live and drive. Every 2 seconds the new data is analysed;
     new events appear and the table updates. Only the newest part of the
     run is analysed each time (steps more than 5 s old are settled), so
     updates stay quick however long you drive. While live, the run's
     clipping limits come from its last 10 minutes. When you press Stop
     live, the run is analysed in full like a log, so a few results can
     change slightly at that point.
  4. KEEP THE PLUGIN WINDOW OPEN. TunerStudio disconnects plugins when their
     window closes, which stops collection (the data so far is kept).
  5. Watch the live update rate in the status line. 50 Hz or more is close to
     a 100 Hz log; below about 40 Hz short high-RPM delays become coarse.

LOGS
  Add log... takes binary .mlg logs and tab- or comma-delimited
  .msl/.txt/.csv logs from TunerStudio, MegaLogViewer or an ECU's SD card.
  A dialog asks which columns to use, pre-filled with RPM, MAP, Lambda and
  "Fuel: Last inj pulse width".

  .MLG LOGS: both versions of the format (1 and 2) are read. A file is
  recognised by its contents, so an .mlg log renamed to .msl still works.
    - Time comes from the log's Time channel, as in an .msl of the same
      drive. If a log has no Time channel, the time stamped on each record
      is used instead; those can't show a pause in logging longer than
      0.65 s, so a paused log looks shorter than it was.
    - Damaged records (failed checksum) are skipped. If the file is cut off,
      or something unreadable is found partway through, the data up to that
      point is used. The status line says so after the log is added.
    - Markers in the log are ignored.

  Only the four chosen columns (and Time) are read, so logs from ECUs that
  log thousands of channels (rusEFI and its forks log about 2,000) fit in
  memory however long they are. That's why the channel dialog comes first:
  it lists every column in the log, before the data is read. If a chosen
  column has no numbers in it, the log isn't added and a message says which.

  PROGRESS: while a log is added, a progress bar at the bottom right shows
  each stage:
    Reading the channel list    reading the column names (a moment)
    Choose the log's channels   waiting for the channel dialog
    Reading <file>  0-100%      reading the chosen columns
    Preparing <file>            lining the data up on the session's time grid
    Finding events in <file>    analysing (shown with a % on large sessions)
  When it finishes, the status line summarises what the log added, e.g.
    "Added drive.msl: 8.0 min, 123 PW steps, 8 accepted. Session now has
     132 accepted events."
  Press Cancel at any stage to stop. The session is left exactly as it was.
  The other buttons are disabled until the log is in (or cancelled).
  Importing a session and reopening your saved session show progress too.
  For scale: a 10-minute rusEFI .mlg with about 2,000 channels (575 MB)
  takes about a second to read.

TABLE AXES (BREAKPOINTS)
  The table is recalculated automatically whenever its axes change, from all
  accepted events in the session. There is nothing to press.

  GENERATE TABLE AXES AUTOMATICALLY (on by default)
    The MAP and RPM axes are worked out from where the engine actually runs
    in the session's data: every sample with the engine running and fuel on
    (fuel cut is left out, because VE Analyze doesn't tune it), leaving out
    data below the idle cutoff (see IGNORING IDLE).
      - The axes span the 2nd to 98th percentile of that driving time, so a
        rare moment at redline or full boost doesn't stretch them.
      - The top MAP point is then raised, if higher, to the highest MAP
        the engine held for at least 3 s in total (not necessarily in one
        go). Boost (or full throttle) is often under 2% of driving time,
        so without this the top point could stop below it. Brief spikes
        still don't count.
      - The bottom MAP point is then raised, if higher, to the 5th
        percentile of the accepted events' MAP. Light-load driving (lifting
        off, coasting) can't be measured, so a bottom row below every event
        would only ever hold copies. It moves as events are added, accepted
        or rejected, and only applies once there are at least 10 accepted
        events (with fewer, a couple of events would squeeze the axis).
      - Inside that span, points are placed half by where the time is spent
        and half evenly, so the areas you use most get more points without
        leaving gaps.
      - No automatic RPM point is below 1000 RPM (events below it go in
        the lowest column). Axes you type yourself can go lower.
      - RPM is rounded to 50 and MAP to 1 kPa. Points closer than 200 RPM
        or 5 kPa are merged, so you may get fewer points than you asked for
        when you drive in a narrow range.
    Set "MAP points" and "RPM points" to choose how many. While the box is
    ticked the axis fields are greyed and update by themselves as the
    session grows (including during live collection). Until the session has
    driving data, the fields are empty and no table is shown.

  MAX RPM TRIGGER
    Holds back the automatic axes until the session's driving covers your
    full RPM range, so they aren't set from a gentle first drive and then
    shift a lot later. Enter an RPM in "Max RPM Trigger" (bottom row of the
    Table axes panel). The axes are not generated until the engine has
    reached that RPM under load 2 separate times, in logs or live.
    Under load = for at least 0.3 s: MAP at least 60 kPa at 101.3 kPa baro, fuel on, RPM rising no faster than 3500 RPM/s.
    The MAP figure is scaled by the Baro box (see BARO).
    That leaves out revving with no load: in neutral the engine only stays
    at high MAP while it flares, and it flares much faster than a car in
    gear can accelerate. Sitting on a fuel-cut rev limiter doesn't count
    either. RPM must drop 250 RPM below the trigger before the next time can
    count, so one long pull counts once.

    While waiting, the table area and the status line show the progress,
    e.g. "Waiting for Max RPM Trigger: 4500 RPM reached under load 1 of 2
    times." Events are still collected and reviewed as usual. Choose a
    value you reach in normal hard acceleration, a little below where you
    usually shift.

    Leave it empty (as a new session starts) to generate the axes straight
    away. Changing it (or Baro) re-checks the whole session at once, and the
    status line says what happened:
      - raised above what the session has reached: the automatic axes are
        cleared and the table waits until the trigger is reached;
      - lowered, or emptied, so it's reached: the axes are generated again.
    Your own axes (automatic axes off) are never changed by the trigger.
    The value is saved with the session.

  BARO
    "Baro (kPa)" is the atmospheric pressure where you drive. It scales the
    MAP that Max RPM Trigger needs to count as under load: 60 kPa at
    101.3 kPa baro, so 50 kPa at 85 kPa and 41 kPa at 70 kPa. At altitude,
    full throttle gives a lower MAP, so without this a high-altitude pull
    might not count. Nothing else in the plugin depends on it.
    Use your ECU's baro reading if it has one, or the local station
    pressure. Weather reports usually give pressure corrected to sea level,
    which is too high at altitude. Roughly: sea level 101, 500 m 95,
    1000 m 90, 1500 m 85, 2000 m 80, 3000 m 70 kPa.
    A new session starts with 101.3. Empty means 101.3. It is saved with
    the session.

  YOUR OWN AXES
    Untick "Generate table axes automatically". The current values stay in
    the fields and you can edit them (comma separated). The points settings
    are greyed because they only apply to automatic axes.

  TURNING AUTOMATIC AXES BACK ON
    If the fields have values when you tick the box, you'll be warned that
    they will be replaced with values calculated from the current session
    data. If Max RPM Trigger hasn't been reached yet, the warning says so,
    and the values are replaced once it has.
      Yes  - the axes are calculated and replace the values.
      No   - nothing changes and the box stays unticked.

  If a value isn't valid (for example a typo), the status line says so and
  the last table stays until it's fixed.
  The axes, the setting and the number of points are saved with the
  session. A new session starts with automatic axes on. Sessions saved by
  versions before 1.8 open with the box unticked and their own axes kept.

IGNORING IDLE
  Max idle RPM (bottom row of the Table axes panel) sets the engine speed
  treated as idle. Data below it is ignored when building the table:
    - Events that start from below it are rejected, with the reason
      "Idle: below max idle RPM (1100)". An event counts as starting from
      below it if RPM was under the cutoff at any time in the half second
      before the pulse-width step (RPM starts rising as the throttle opens,
      so the step itself may already be above it).
    - Driving data below it is left out when the table axes are generated.

  A new session starts with 650 in the box, which keeps tip-ins from a
  normal idle. To leave those out, enter a value a little above your
  highest idle speed, including cold fast idle (for example 1100 for an
  engine that idles at 800-950 RPM). An empty box means no idle cutoff.

  Data below 400 RPM (engine stopped or cranking) is always ignored,
  whatever the box says.

  Changes apply at once to the whole session and are saved with it. You
  can still accept a rejected event by hand (Accept / Reject), and Revert
  manual change puts it back to rejected.

HELP
  The Help button (top row, right of New session) shows this text inside
  TunerStudio. Use Find to jump to a word. It always matches this version
  of the plugin.
  Hover the mouse over any button, box, label or event-list column
  heading for a one-line description; the details are in this Help. If a
  control is greyed out, its description also says why (for example
  "Stop live collection first"). If a status message is cut off, hover
  over it to read all of it.

REVIEWING EVENTS
  Click an event to plot it: black line = start of the PW change, magenta
  dashed line = start of the lambda response.
    - Accept / Reject button (or Space in the list) toggles an event.
    - Double-click the plot to set the onset by hand (this accepts it).
    - Revert manual change puts the selected event back exactly as the
      plugin found it: the automatic onset, the automatic accept/reject
      decision and its reason. Use it to undo a moved onset or a toggled
      decision. It only affects the selected event.
  Your decisions are saved with the session and kept as new data arrives.

GETTING THE TABLE INTO VE ANALYZE
  The Lambda Delay table belongs to VE Analyze, not the ECU, and the plugin
  API cannot write it. So:
    1. In VE Analyze, set the Lambda Delay table's axes to the same MAP and
       RPM values shown in the plugin.
    2. Press "Copy table for VE Analyze" (highest MAP row first, tab separated).
    3. Select the top-left cell of the Lambda Delay table and press Ctrl+V.
  Check the rows land the right way up.

HOW THE TABLE IS FILLED
  Each accepted delay is converted to crank revolutions and put in the
  nearest cell.
    M# = measured (# events)
    R  = that MAP row's median revolutions, at the breakpoint RPM
    S  = row had no data: estimated from the nearest lower-MAP row (with
         "Scale empty higher-MAP rows by MAP ratio" ticked)
    C  = row had no data: copied from the nearest row

  S rows: more MAP means more exhaust flow and a shorter trip to the
  sensor, but part of the delay (sensor response, engine cycle) doesn't
  shrink. So the fixed part is kept and only the rest is scaled:
      S = fixed + (lower row - fixed) x lower row's MAP / this row's MAP
  The fixed part is the "a" of the delay = a + b / RPM fit (shown under
  the table), kept between 15 and 80 ms. If it can't be measured (fewer
  than 3 accepted events, or too little RPM spread), 30 ms is used. A line
  under the table says which value was used. Without this, a 250 kPa row
  could come out at a fifth of the 55 kPa row's delay.

WHAT IS REJECTED AUTOMATICALLY
  - Events that start from idle (see IGNORING IDLE).
  - Throttle closes / DFCO entries: wall-film rich dip, not transport delay.
  - DFCO exits: read long because the sensor sits clipped lean (can be
    included with the checkbox).
  - Steps within 0.8 s of another, lambda already moving, lambda clipped.

  "Lambda not stable before step": in the 0.2 s before the step, lambda
  must not be noisy (standard deviation 0.012) or drift too far (0.02).
  Bigger steps are allowed more drift, up to 3 times as much, as long as
  the drift is away from where the response will take lambda (a lean
  drift before a tip-in): drift toward the response could be mistaken for
  it. When lambda clearly trends before the step, the onset is found as a
  departure from that trend. The noise limit doesn't grow: noisy steps
  give inaccurate delays. (Defaults.java: PRE_TOL_MODE and related values.)
