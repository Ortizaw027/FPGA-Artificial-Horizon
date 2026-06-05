# FPGA Artificial Horizon

A real-time attitude indicator (artificial horizon) implemented in VHDL on the **Gowin Tang Nano 9K** FPGA. Reads 6-axis IMU data over SPI, fuses accelerometer and gyroscope measurements through a complementary filter, and renders a live horizon graphic on a 240×320 ILI9341 LCD at ~15 fps.

![Tang Nano 9K](https://img.shields.io/badge/Board-Tang%20Nano%209K-blue)
![Language](https://img.shields.io/badge/Language-VHDL-orange)
![License](https://img.shields.io/badge/License-MIT-green)

---

## Demo

> Board tilts → horizon tilts. Pitch moves the horizon line up and down. Roll rotates it. A fixed aircraft symbol stays centre-screen as the world moves beneath it.

---

## Features

- **Dual SPI buses** — independent masters for the IMU (~4.6 MHz) and LCD (~18.5 MHz)
- **Sensor calibration** — 1024-sample stationary average removes per-axis bias at startup
- **IIR low-pass filter** — first-order filter (α = 1/8) smooths noisy raw readings
- **Complementary filter** — blends gyro integration (short-term) with accel tilt estimate (long-term) to give drift-free pitch and roll
- **Per-pixel horizon rendering** — threshold computed individually for all 76,800 pixels each frame using a 256-entry Q1.14 sin/cos LUT; no frame buffer required
- **Fixed aircraft symbol** — centre dot + wing bars drawn in screen-space, always upright
- **Anti-tear latching** — pitch/roll values latched at frame start so attitude never changes mid-frame
- **Q8.8 angle format** — compact signed fixed-point throughout, ±180° range

---

## System Architecture

```
i_Clk (27 MHz)
     │
     ▼
 Gowin_rPLL  ──► 74 MHz system clock
     │
     ├──► SPI_Master (IMU)  ◄──► IMU_Controller ──► Attitude_Engine ──► LCD_Controller
     │         4.6 MHz                                                         │
     └──► SPI_Master (LCD)  ◄────────────────────────────────────────────────┘
               18.5 MHz
```

| Module | Role |
|---|---|
| `Top.vhd` | PLL, reset synchronisation, wiring |
| `SPI_Master.vhd` | Generic SPI master (modes 0–3, configurable clock divider) |
| `IMU_Controller.vhd` | IMU init sequence + 1 kHz polling FSM |
| `Attitude_Engine.vhd` | Calibration → IIR filter → complementary filter pipeline |
| `LCD_Controller.vhd` | ILI9341 init + per-pixel horizon renderer |

---

## Hardware

| Part | Notes |
|---|---|
| **Gowin Tang Nano 9K** | GW1NR-9 FPGA, 8.64K LUTs |
| **IMU** | SPI-mode 6-axis IMU (e.g. ICM-42688, BMI088) wired to IMU SPI pins |
| **LCD** | ILI9341 240×320 SPI display |

### Pin Assignments

| Signal | Direction | Function |
|---|---|---|
| `i_Clk` | In | 27 MHz crystal |
| `i_Rst_L` | In | Active-low reset button |
| `i_IMU_MISO / o_IMU_MOSI / o_IMU_SCLK / o_IMU_CS_n` | — | IMU SPI bus |
| `i_LCD_MISO / o_LCD_MOSI / o_LCD_SCLK / o_LCD_CS_n` | — | LCD SPI bus |
| `o_LCD_DC` | Out | LCD data/command select |
| `o_LCD_RST_n` | Out | LCD hardware reset |
| `o_LED_WHO` | Out | Lights when IMU init succeeds |

---

## Signal Flow Detail

### 1 · IMU_Controller

On power-up the FSM waits ~200 ms for the IMU to boot, then writes 7 configuration registers (range, bandwidth, output data rate). It then polls 12 bytes of raw accel + gyro data every ~1 ms (1 kHz), assembles 16-bit words MSB-first, and pulses `o_Data_Valid` when a complete set is ready.

### 2 · Attitude_Engine

Three pipelined stages fire one clock apart on each `Data_Valid` pulse:

**Stage 1 — Calibration & bias subtraction**
Accumulates 1024 samples into 32-bit sums, computes per-axis averages (right-shift by 10), and freezes them as bias offsets. The Z-axis bias has 16384 subtracted to normalise 1 g out. Every subsequent sample has its bias removed here.

**Stage 2 — IIR low-pass**
`output += (input − output) >> 3` — equivalent to a single-pole filter with α = 1/8, cutting high-frequency vibration noise.

**Stage 3 — Complementary filter**
```
pitch_acc = (61/64) × pitch_acc  +  gyro_delta  +  (3/64) × accel_estimate
```
Gyro integration gives fast, drift-prone updates. The accel linear arcsin estimate (gravity projection) provides a slow, stable correction. The 61:3 weighting keeps the gyro dominant while preventing long-term drift. Output is converted from Q16.16 to Q8.8 and clamped to ±180°.

### 3 · LCD_Controller

After initialising the ILI9341 (SLPOUT → COLMOD → DISPON), the controller loops continuously:

1. **Frame latch** — capture pitch & roll, precompute `sin(roll)`, `cos(roll)` (from a 256-entry ROM), and pitch pixel offset.
2. **CASET / PASET / RAMWR** — address the full 240×320 framebuffer.
3. **Per-pixel loop** — for each of 76,800 pixels compute:
   ```
   threshold = cx × (−sin roll) + cy × cos(roll) − pitch_offset
   ```
   where `cx = col − 120`, `cy = row − 160`. Sign of threshold selects sky (blue) or ground (brown); magnitude < 3 pixels selects the white horizon band. Aircraft symbol pixels are forced black in screen-space.

All pixel math is integer Q1.14 arithmetic — no floating point anywhere in the design.

---

## Building

The project targets the **Gowin IDE** (GOWIN_V1.9.x or later).

1. Create a new project, select device `GW1NR-9C QFN88P`.
2. Add all `.vhd` files to the project.
3. Add the Gowin `rPLL` IP core (`Gowin_rPLL`) configured for 27 MHz → 74.25 MHz output.
4. Set `Top` as the top-level module.
5. Import the physical constraints file (`.cst`) matching your board wiring.
6. Synthesise → Place & Route → Program.

> **Toolchain**: Gowin EDA + Gowin Programmer. No third-party dependencies beyond the Gowin primitives library.

---

## Fixed-Point Number Formats

| Format | Range | Used For |
|---|---|---|
| Q8.8 signed | ±127.996° | Pitch and roll outputs |
| Q1.14 signed | ±1.999 (unit vector) | Sin/cos LUT values |
| Q16.16 signed | ±32767.999° | Internal angle accumulator |

---

## Limitations & Known Issues

- **Calibration requires a stationary, level board** during the first ~1 second after reset. Moving the board during calibration will introduce a permanent attitude bias for that power cycle.
- The **linear arcsin approximation** (`ax * 360 / 32768`) is accurate to within ~2° at small angles but diverges beyond ±30°. A true arcsin LUT would improve large-angle accuracy.
- The LCD renders at ~15 fps. Frame rate is bounded by the pixel clock (18.5 MHz SPI × 1 byte per clock × 2 bytes per pixel × 76,800 pixels).
- The SPI_Master module is by **NANDLAND** and is not original work.

---

## Credits

- **SPI_Master.vhd** — [NANDLAND](https://www.nandland.com/) (used with attribution)
- All other modules — original VHDL

---

## License

MIT — see `LICENSE` for details.
