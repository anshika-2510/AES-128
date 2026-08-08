
# Design — RTL Source

Verilog source for the AES-128 encryption modules.

## Modules

### `aes_128` (top-level, used by testbench)
Clocked AES engine with a simple `start`/`busy`/`done` control flow.

- **Ports:** `clk`, `rst`, `start`, `in[127:0]`, `key[127:0]` → `out[127:0]`
- On `start`, does an initial AddRoundKey (`in ^ key`), then runs 10 rounds
- Each round applies a placeholder round function (XOR with a fixed pattern) instead of real SubBytes/ShiftRows/MixColumns
- Key schedule is a fake/fixed XOR pattern, not the real AES key expansion
- **Note:** this module trades cryptographic correctness for a clean, synthesizable, easy-to-simulate control structure. Good for testing the FSM and timing, not for correct ciphertext.

### `aes_core` (structural datapath, not yet wired to testbench)
A more faithful AES round pipeline built from discrete submodules:

| Module | Function |
|---|---|
| `subbytes` | Applies the real AES S-box to all 16 bytes of state |
| `shiftrows` | Correctly permutes state bytes per the AES ShiftRows spec |
| `mixcolumns` | **Placeholder** — currently passthrough (identity), needs GF(2^8) matrix multiply |
| `addroundkey` | XORs state with round key |
| `key_expansion` | **Placeholder** — simple XOR-based schedule, not the real Rcon/SubWord/RotWord expansion |
| `sbox` | Full 256-entry AES S-box lookup table |

Final round (round 10) skips MixColumns per the AES spec, using ShiftRows output XORed with the last round key.

## Known limitations

- `mixcolumns` and `key_expansion` are both placeholders — ciphertext from either module won't match standard AES test vectors yet
- `aes_core` is not currently instantiated in the testbench — only `aes_128` is
- No pipelining — everything is round-at-a-time over 10 clock cycles

## Next steps

1. Implement real MixColumns (GF(2^8) multiply by 2 and 3)
2. Implement proper AES-128 key expansion (Rcon table + SubWord + RotWord)
3. Swap testbench over to `aes_core` and validate against FIPS-197 test vectors

# Testbench

Simulation testbench for the `aes_128` module (Icarus Verilog / EDA Playground).

## What it does

- Instantiates `aes_128` as the DUT
- Generates a clock (10ns period, `#5` half-period)
- Applies reset, then a known plaintext + key pair
- Pulses `start` for one clock cycle to kick off encryption
- Waits for the encryption to complete (~2000ns, generous margin for 10 rounds)
- Dumps waveforms to `dump.vcd` for viewing in GTKWave
- Prints plaintext, key, and resulting ciphertext to console

## Test vector used

```
Plaintext : 00112233445566778899AABBCCDDEEFF
Key       : 000102030405060708090A0B0C0D0E0F
```

This is the standard FIPS-197 AES-128 test vector — however, since `aes_128`'s round function is a simplified placeholder (not real SubBytes/ShiftRows/MixColumns), the output **will not match** the official FIPS-197 expected ciphertext (`69c4e0d86a7b0430d8cdb78070b4c55a`) yet. It's used here as a recognizable reference vector for when the real datapath (`aes_core`) is validated.


## To do

- Update this testbench (or add a new one) targeting `aes_core` once MixColumns/key expansion are fixed
- Add self-checking assertion against the FIPS-197 expected ciphertext instead of just printing to console
