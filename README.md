# AES-128 Verilog Implementation

A simplified, educational Verilog implementation of the AES-128 block cipher, built and simulated Icarus Verilog.

## What is AES?

AES (Advanced Encryption Standard) is a symmetric block cipher — same key encrypts and decrypts — standardized by NIST in FIPS-197. AES-128 operates on 128-bit (16-byte) blocks of data using a 128-bit key, and is one of the most widely used encryption algorithms today (used in TLS, disk encryption, Wi-Fi security, etc).

### How AES-128 works

AES treats the 128-bit input as a 4×4 grid of bytes called the **state**. Encryption runs the state through **10 rounds** of transformations (for AES-128 specifically — AES-192/256 use more rounds):


<img width="440" height="454" alt="image" src="https://github.com/user-attachments/assets/b114218b-73db-420a-b92a-fc84d6efe6f8" />



1. **AddRoundKey (initial)** — XOR the plaintext with the first round key
2. **9 main rounds**, each doing:
   - **SubBytes** — replace every byte using a fixed lookup table (the S-box), which provides non-linearity
   - **ShiftRows** — cyclically shift each row of the state left by a different offset, spreading bytes across columns
   - **MixColumns** — mix each column using matrix multiplication in GF(2^8), diffusing byte-level changes across the whole column
   - **AddRoundKey** — XOR with that round's key
3. **Final round (round 10)** — same as above but **skips MixColumns**

Each round uses a different **round key**, derived from the original key through a process called **key expansion** (using S-box substitution, XOR with round constants (Rcon), and word rotation).

The result of all this is that a single-bit change in the plaintext or key causes roughly half the output bits to flip (avalanche effect), which is what makes AES cryptographically strong.

## This implementation

This repo contains two versions of the AES core, developed while working through the AES pipeline at the RTL level:

- **`aes_128`** — the top-level module currently wired to the testbench. Uses a simplified round function (XOR-based) instead of the full SubBytes/ShiftRows/MixColumns pipeline described above, so it's synthesis-friendly and easy to trace in simulation, but it is **not NIST-compliant** and won't produce standard AES ciphertext.
- **`aes_core`** (+ `subbytes`, `shiftrows`, `mixcolumns`, `addroundkey`, `key_expansion`, `sbox`) — a structurally accurate AES datapath with a real S-box lookup table and correct ShiftRows wiring. MixColumns is currently a passthrough (identity) and the key expansion is a placeholder, not the real AES key schedule. This module is **not yet connected to the testbench**.

See `design/README.md` and `testbench/README.md` for details on each.

## Goal

End goal is a full RTL-to-GDSII flow on this design (synthesis → floorplan → P&R → DRC/LVS → GDS) using the open-source OpenLane/sky130 flow, once the core logic is verified against standard AES test vectors.


