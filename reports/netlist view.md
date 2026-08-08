# Results — Synthesis (Genus)

Screenshots from synthesizing `aes_one_round_custom` in Cadence Genus.
## Screenshots
<img width="1366" height="768" alt="Screenshot from 2025-11-10 10-33-03" src="https://github.com/user-attachments/assets/9de8e053-4d1d-408d-a13c-6bd924a322cc" />

1.  top-level schematic: MixColumns block feeding into a final XOR (AddRoundKey) to produce `state_out[127:0]`


<img width="1366" height="768" alt="Screenshot from 2025-11-10 10-32-44" src="https://github.com/user-attachments/assets/3eaf43a2-e778-4eee-9d2b-b880df659d0b" />

  
2. same schematic zoomed out, showing all 16 S-box instances in the SubBytes stage feeding into MixColumns


<img width="1366" height="768" alt="Screenshot from 2025-11-10 11-05-59" src="https://github.com/user-attachments/assets/9491d859-3a7a-4e82-8238-4b6addaff366" />


3. closer look at individual S-box instances (`custom_sbox_1`, `custom_sbox_5`, `custom_sbox_14`, `custom_sbox_2`, etc.) — each one taking in a byte and driving it out


<img width="1366" height="768" alt="Screenshot from 2025-11-10 11-38-16" src="https://github.com/user-attachments/assets/401472cf-ffb8-4173-bf4c-97dd2a5a781c" />


4.  post generic-mapping schematic (gate-level, before tech mapping) — 1297 StdCells, 1553 nets

<img width="1366" height="768" alt="Screenshot from 2025-11-10 11-38-44" src="https://github.com/user-attachments/assets/ae0d6cbf-df8f-477a-8e7b-55c5a6b388f2" />

5. same design, zoomed way out — this is basically what the synthesized netlist looks like as a block of interconnected logic (density/congestion view)

## What this shows

This is `aes_one_round_custom` (one round of the AES pipeline — SubBytes → MixColumns → AddRoundKey) after synthesis in Genus. The design has:

- 384 terms (ports)
- 1553 nets
- 1297 standard cells after mapping

The schematic views (1–3) show the structural hierarchy — SubBytes is 16 parallel S-box instances, one per byte, followed by MixColumns and a final XOR for AddRoundKey. The last two screenshots (4–5) are the flattened gate-level view after synthesis maps everything down to standard cells — that dense grid is just the interconnect between all 1297 cells.

## Note

This synthesis run is for one round of the datapath (`aes_one_round_custom`), not the full 10-round `aes_128`/`aes_core` top level yet.
