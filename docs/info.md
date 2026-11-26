<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

## How it works

Reaction game implemented in Verilog using a reaction button input (`ui[0]`), two status LEDs (`uo[7]` and `uio[0]`), and four time-multiplexed 7-segment displays (`uo[6:0]` for segments and `uio[4:1]` for digit enable lines), driven by clock tick generation and display multiplexing modules.

## How to test

Apply `rst_n = 0` to reset the design, release `rst_n = 1` with `ena = 1`, drive `clk`, and toggle `ui[0]` (`BTN_REACT`) to start/respond while observing `uo_out` and `uio_out`.

## External hardware

Connect one push button to `ui[0]`, two LEDs (to `uo[7]` and `uio[0]`), and four 7-segment displays with digit select lines on `uio[4:1]` and segment lines on `uo[6:0]`.
