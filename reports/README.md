# Synthesis Log Notes (Genus)

Two synthesis runs live here: an early one on just `aes_one_round_custom` (single round, while debugging the flow), and a later full run on the complete `aes_128` design once the clock constraint issue got fixed.

## Getting it to actually run (round-level run)

First attempt didn't go smoothly:

- `constraints.sdc` referenced a clock port called `clk` that didn't actually exist in the design under that name, so `read_sdc` threw errors trying to create the clock and set clock uncertainty on it.
- The SDC also tried setting a driving cell (`BUFX2`) that isn't in the SAED90nm library, so that failed too.
- I initially used the old `syn` command, which Genus flagged as obsolete — it wants `syn_generic`, `syn_map`, and `syn_opt` run as separate stages now.
- Also tried running `syn_map` before `syn_generic` had finished, which Genus rejected since mapping needs a generic-synthesized design to work from.

Fixed the clock name, dropped the invalid `BUFX2` reference, ran the stages in order (`syn_generic` → `syn_map` → `syn_opt_incr`), and it went through clean.

## Round-level results (`aes_one_round_custom`)

**Area:**

| Instance | Cell Count | Cell Area | Total Area |
|---|---|---|---|
| aes_one_round_custom | 1574 | 18229.248 µm² | 18229.248 µm² |

**Power:**

| Component | Value | % of total |
|---|---|---|
| Leakage | 1.09e-04 W | 9.74% |
| Internal | 9.06e-04 W | 80.57% |
| Switching | 1.09e-04 W | 9.70% |
| **Total** | **1.12e-03 W** | 100% |

All in the "logic" category since there's no register/latch/clock in this instance — just one round of combinational logic. Internal power dominating tracks with that: 16 parallel S-boxes into MixColumns and a final XOR is a lot of node toggling per evaluation, and nothing sequential to average the switching down.

**Timing:** this is where the earlier clock-naming issue in `constraints.sdc` came back to bite — `report_timing` flagged unconstrained paths not shown by default, meaning some paths weren't actually tied to a real clock. Needed a proper fix before trusting these numbers.

## Full-design results (`aes_128`, after fixing the clock constraint)

Once `clk` was correctly recognized in the SDC, I re-ran synthesis on the complete `aes_128` top level (all 10 rounds, FSM, key schedule) instead of just one round.

**Area:**

| Instance | Cell Count | Cell Area | Total Area |
|---|---|---|---|
| aes_128 | 12,186 | 107,478.836 µm² | 107,478.836 µm² |

Cell count is roughly 7–8x the single-round number, which makes sense — this is the full datapath plus control logic, not one round in isolation.

**Power:**

| Component | Value | % of total |
|---|---|---|
| Leakage | 4.91e-04 W | 1.88% |
| Internal | 1.66e-02 W | 63.64% |
| Switching | 8.99e-03 W | 34.48% |
| **Total** | **2.61e-02 W** | 100% |

Different mix than the round-level run — registers now show up (state flops, round counter) and there's a real clock tree contributing switching power. Internal power still leads, but switching's share is way up compared to the pure-combinational round, which tracks: a clocked design toggling every cycle over 10 rounds has a lot more switching activity than one static combinational block.

**Timing:** this is the actual fix for the earlier problem. `timing2.rpt` shows a real register-to-register path (`state_reg[36] → state_reg[1]`), correctly grouped under clock `clk`, evaluated at an 1800ps period:

| | |
|---|---|
| Data path delay | 1460 ps |
| Setup + uncertainty | 296 ps |
| Required time | 1504 ps |
| **Slack** | **+12 ps (MET)** |

So the design is meeting timing at this clock period, though the margin is thin (12ps) — worth checking if other paths are similarly tight before calling this locked in.

## Netlist

`net4.v` is the actual gate-level netlist for the full `aes_128` design post-synthesis — top module with proper I/O (`clk`, `rst`, `start`, `plaintext`, `key`, `ciphertext`, `done`), built from standard cells plus 16 `sbox_*` instances for the S-boxes. ~25.6k lines.

## Final takeaway

Round-level synthesis was mainly about getting the flow itself working (fixing SDC/command issues). Full `aes_128` synthesis is where the real numbers are: ~12.2k cells, ~107,479 µm², ~26 mW, and timing meeting at 1800ps with a 12ps margin. Next step is checking whether that margin holds up across more paths, or if it's worth tightening the clock period further.
