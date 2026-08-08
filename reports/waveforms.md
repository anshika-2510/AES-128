# Results — Simulation Waveforms

Waveform dumps from simulating `aes_128` in Cadence SimVision (Xcelium).

<img width="1366" height="768" alt="Screenshot from 2025-11-10 12-18-41" src="https://github.com/user-attachments/assets/c7f503af-daa6-4789-946c-d33947783095" />

<img width="1366" height="768" alt="Screenshot from 2025-11-10 12-19-10" src="https://github.com/user-attachments/assets/edc3b1bb-700e-4921-a2f2-1adc2067c3dd" />

## What it shows

- **`state_in`** loads the plaintext (`00112233_44556677_8899AABB_CCDDEEFF`) and later a second test value (`FFEEDDCC_BBAA9988_77665544_33221100`)
- **`round_key`** starts at the initial key (`00010203_04050607_08090A0B_0C0D0E0F`) and updates each round via the fake key schedule (XOR with a fixed pattern), ending at `0F0E0D0C_0B0A0908_07060504_03020100`
- **`state_out`** is `x` (undefined) until the round pipeline settles, then transitions to `76FA138E_EC0DAE4F_18B95AFB_A05FFC09` for the first input and `239C7FCA_9B7AD938_6FCE2D8C_F5399A4D` for the second

## Notes

- These outputs are from the simplified `aes_128` module (XOR-based round function, fake key schedule) — **not** real AES ciphertext, so they won't match FIPS-197 test vectors
- `state_out` bit expansion (image 2) is just for visually confirming the output settles correctly and isn't glitching — not meant to be read bit-by-bit
- Once `aes_core` (real S-box + ShiftRows + fixed MixColumns/key expansion) is validated, this results folder should get a second set of waveforms compared against the official FIPS-197 vectors
