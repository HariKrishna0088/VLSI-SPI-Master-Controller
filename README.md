<p align="center">
  <img src="https://img.shields.io/badge/Language-Verilog-blue?style=for-the-badge" alt="Verilog"/>
  <img src="https://img.shields.io/badge/Protocol-SPI-ff6600?style=for-the-badge" alt="SPI"/>
  <img src="https://img.shields.io/badge/IP_Core-Configurable-blueviolet?style=for-the-badge" alt="IP"/>
  <img src="https://img.shields.io/badge/Interview-Must_Know-critical?style=for-the-badge" alt="Interview"/>
</p>

# 📡 SPI Master Controller — Verilog HDL

> A fully configurable, synthesizable SPI Master controller supporting all 4 SPI modes, multi-slave selection, parameterized clock divider, and MSB/LSB-first transmission — a must-have VLSI IP core for your portfolio.

---

## 🔍 Overview

**SPI (Serial Peripheral Interface)** is one of the most widely used bus protocols in embedded and SoC designs. This project implements a **production-quality SPI Master** with all the features asked about in VLSI design interviews.

### Key Highlights
- 📡 **All 4 SPI Modes** — CPOL/CPHA combinations (Mode 0-3)
- 🔧 **Parameterized** — Configurable data width, clock divider, slave count
- 🎯 **Multi-Slave** — Up to 4 slaves with individual chip-select
- 🔄 **Bit Order** — MSB-first and LSB-first support
- ✅ **Loopback Testbench** — MOSI→MISO self-verification (12 test vectors)
- 📊 **VCD Waveform** — Full protocol timing visualization
- 🏭 **Synthesizable** — Ready for FPGA/ASIC implementation

---

## 📶 SPI Protocol

```
         ┌───── Transaction ──────────────────────────┐
CS_n  ───┘                                            └───
                                                        
SCLK     ─────┐  ┌──┐  ┌──┐  ┌──┐  ┌──┐  ┌──┐  ┌──┐  ┌──
(Mode 0)      └──┘  └──┘  └──┘  └──┘  └──┘  └──┘  └──┘

MOSI     ──╳──D7──╳──D6──╳──D5──╳──D4──╳──D3──╳──D2──╳──D1──╳──D0──
MISO     ──╳──D7──╳──D6──╳──D5──╳──D4──╳──D3──╳──D2──╳──D1──╳──D0──
                ↑     ↑     ↑     ↑     ↑     ↑     ↑     ↑
             Sample points (Mode 0: rising edge)
```

### SPI Mode Table

| Mode | CPOL | CPHA | Clock Idle | Sample Edge | Shift Edge |
|:----:|:----:|:----:|:----------:|:-----------:|:----------:|
| 0 | 0 | 0 | LOW | Rising ↑ | Falling ↓ |
| 1 | 0 | 1 | LOW | Falling ↓ | Rising ↑ |
| 2 | 1 | 0 | HIGH | Falling ↓ | Rising ↑ |
| 3 | 1 | 1 | HIGH | Rising ↑ | Falling ↓ |

---

## ⚙️ Parameters

| Parameter | Default | Description |
|:---------:|:-------:|:------------|
| `DATA_WIDTH` | 8 | Transaction width (bits) |
| `CLK_DIV` | 4 | SCLK = sys_clk / (2×CLK_DIV) |
| `NUM_SLAVES` | 4 | Number of slave devices |

---

## 📁 File Structure

```
VLSI-SPI-Master-Controller/
├── src/
│   └── spi_master.v          # SPI Master module
├── testbench/
│   └── spi_master_tb.v       # Loopback testbench
├── docs/
├── .gitignore
├── LICENSE
└── README.md
```

---

## 🚀 Simulation Guide

```bash
iverilog -o spi_sim src/spi_master.v testbench/spi_master_tb.v
vvp spi_sim
gtkwave spi_master_tb.vcd
```

---

## 💡 Applications

- 🔌 **SoC Peripherals** — ADC, DAC, Flash, EEPROM communication
- 📡 **FPGA-to-Sensor** — SPI sensor interfacing (accelerometers, displays)
- 🏭 **ASIC IP Core** — Reusable bus interface for chip design
- 🔧 **Debug Interface** — JTAG/SPI debug probes

---

## 👨‍💻 Author

**Daggolu Hari Krishna** — B.Tech ECE | JNTUA College of Engineering, Kalikiri

[![LinkedIn](https://img.shields.io/badge/LinkedIn-Connect-blue?style=flat-square&logo=linkedin)](https://linkedin.com/in/harikrishnadaggolu)
[![GitHub](https://img.shields.io/badge/GitHub-HariKrishna0088-black?style=flat-square&logo=github)](https://github.com/HariKrishna0088)

---

<p align="center">⭐ Star this repo if you found it useful! ⭐</p>
