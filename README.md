<p align="center">
  <img src="https://img.shields.io/badge/Language-Verilog-blue?style=for-the-badge" alt="Verilog"/>
  <img src="https://img.shields.io/badge/Protocol-SPI-ff6600?style=for-the-badge" alt="SPI"/>
  <img src="https://img.shields.io/badge/IP_Core-Configurable-blueviolet?style=for-the-badge" alt="IP"/>
  <img src="https://img.shields.io/badge/Interview-Must_Know-critical?style=for-the-badge" alt="Interview"/>
</p>

# ðŸ“¡ SPI Master Controller â€” Verilog HDL

> A fully configurable, synthesizable SPI Master controller supporting all 4 SPI modes, multi-slave selection, parameterized clock divider, and MSB/LSB-first transmission â€” a must-have VLSI IP core for your portfolio.

---

## ðŸ” Overview

**SPI (Serial Peripheral Interface)** is one of the most widely used bus protocols in embedded and SoC designs. This project implements a **production-quality SPI Master** with all the features asked about in VLSI design interviews.

### Key Highlights
- ðŸ“¡ **All 4 SPI Modes** â€” CPOL/CPHA combinations (Mode 0-3)
- ðŸ”§ **Parameterized** â€” Configurable data width, clock divider, slave count
- ðŸŽ¯ **Multi-Slave** â€” Up to 4 slaves with individual chip-select
- ðŸ”„ **Bit Order** â€” MSB-first and LSB-first support
- âœ… **Loopback Testbench** â€” MOSIâ†’MISO self-verification (12 test vectors)
- ðŸ“Š **VCD Waveform** â€” Full protocol timing visualization
- ðŸ­ **Synthesizable** â€” Ready for FPGA/ASIC implementation

---

## ðŸ“¶ SPI Protocol

```
         â”Œâ”€â”€â”€â”€â”€ Transaction â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
CS_n  â”€â”€â”€â”˜                                            â””â”€â”€â”€
                                                        
SCLK     â”€â”€â”€â”€â”€â”  â”Œâ”€â”€â”  â”Œâ”€â”€â”  â”Œâ”€â”€â”  â”Œâ”€â”€â”  â”Œâ”€â”€â”  â”Œâ”€â”€â”  â”Œâ”€â”€
(Mode 0)      â””â”€â”€â”˜  â””â”€â”€â”˜  â””â”€â”€â”˜  â””â”€â”€â”˜  â””â”€â”€â”˜  â””â”€â”€â”˜  â””â”€â”€â”˜

MOSI     â”€â”€â•³â”€â”€D7â”€â”€â•³â”€â”€D6â”€â”€â•³â”€â”€D5â”€â”€â•³â”€â”€D4â”€â”€â•³â”€â”€D3â”€â”€â•³â”€â”€D2â”€â”€â•³â”€â”€D1â”€â”€â•³â”€â”€D0â”€â”€
MISO     â”€â”€â•³â”€â”€D7â”€â”€â•³â”€â”€D6â”€â”€â•³â”€â”€D5â”€â”€â•³â”€â”€D4â”€â”€â•³â”€â”€D3â”€â”€â•³â”€â”€D2â”€â”€â•³â”€â”€D1â”€â”€â•³â”€â”€D0â”€â”€
                â†‘     â†‘     â†‘     â†‘     â†‘     â†‘     â†‘     â†‘
             Sample points (Mode 0: rising edge)
```

### SPI Mode Table

| Mode | CPOL | CPHA | Clock Idle | Sample Edge | Shift Edge |
|:----:|:----:|:----:|:----------:|:-----------:|:----------:|
| 0 | 0 | 0 | LOW | Rising â†‘ | Falling â†“ |
| 1 | 0 | 1 | LOW | Falling â†“ | Rising â†‘ |
| 2 | 1 | 0 | HIGH | Falling â†“ | Rising â†‘ |
| 3 | 1 | 1 | HIGH | Rising â†‘ | Falling â†“ |

---

## âš™ï¸ Parameters

| Parameter | Default | Description |
|:---------:|:-------:|:------------|
| `DATA_WIDTH` | 8 | Transaction width (bits) |
| `CLK_DIV` | 4 | SCLK = sys_clk / (2Ã—CLK_DIV) |
| `NUM_SLAVES` | 4 | Number of slave devices |

---

## ðŸ“ File Structure

```
VLSI-SPI-Master-Controller/
â”œâ”€â”€ src/
â”‚   â””â”€â”€ spi_master.v          # SPI Master module
â”œâ”€â”€ testbench/
â”‚   â””â”€â”€ spi_master_tb.v       # Loopback testbench
â”œâ”€â”€ docs/
â”œâ”€â”€ .gitignore
â”œâ”€â”€ LICENSE
â””â”€â”€ README.md
```

---

## ðŸš€ Simulation Guide

```bash
iverilog -o spi_sim src/spi_master.v testbench/spi_master_tb.v
vvp spi_sim
gtkwave spi_master_tb.vcd
```

---

## ðŸ’¡ Applications

- ðŸ”Œ **SoC Peripherals** â€” ADC, DAC, Flash, EEPROM communication
- ðŸ“¡ **FPGA-to-Sensor** â€” SPI sensor interfacing (accelerometers, displays)
- ðŸ­ **ASIC IP Core** â€” Reusable bus interface for chip design
- ðŸ”§ **Debug Interface** â€” JTAG/SPI debug probes

---

## ðŸ‘¨â€ðŸ’» Author

**Daggolu Hari Krishna** â€” B.Tech ECE | JNTUA College of Engineering, Kalikiri

[![LinkedIn](https://img.shields.io/badge/LinkedIn-Connect-blue?style=flat-square&logo=linkedin)](https://www.linkedin.com/in/contacthari88/)
[![GitHub](https://img.shields.io/badge/GitHub-HariKrishna0088-black?style=flat-square&logo=github)](https://github.com/HariKrishna0088)

---

<p align="center">â­ Star this repo if you found it useful! â­</p>
