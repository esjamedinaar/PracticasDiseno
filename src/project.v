/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

// Practica 50 - Juego de reaccion rapida (OMDAZZ, 50 MHz).
// Todos los registros usan el reloj de la tarjeta; no se generan relojes.
module main #(
    parameter integer CYCLES_PER_MS = 50000,
    parameter integer RELEASE_CYCLES = 1000000,
    parameter integer SCAN_CYCLES = 50000,
    parameter [11:0] MIN_WAIT_MS = 12'd1000,
    parameter [11:0] RANDOM_MASK = 12'h7ff
)(
    input wire clk,
    input wire btn_n,
    input wire [3:0] sw_n,
    output wire [7:0] seg,
    output wire [3:0] dig,
    output wire [3:0] led_n,
    output wire beep
);
    // Boton activo en bajo: dos flip-flops para sincronizar.
    reg btn_meta = 1'b1, btn_sync = 1'b1;
    reg press_armed = 1'b0;
    reg [31:0] release_count = 32'd0;
    wire press = press_armed && !btn_sync;

    // La pulsacion se registra inmediatamente tras sincronizar.
    // Se exige una liberacion estable de 20 ms antes de aceptar otra.
    // Asi el antirrebote no agrega 20 ms al tiempo de reaccion.
    always @(posedge clk) begin
        btn_meta <= btn_n;
        btn_sync <= btn_meta;
        if (!btn_sync) begin
            press_armed <= 1'b0;
            release_count <= 32'd0;
        end else if (!press_armed) begin
            if (release_count >= RELEASE_CYCLES - 1) begin
                press_armed <= 1'b1;
                release_count <= 32'd0;
            end else begin
                release_count <= release_count + 32'd1;
            end
        end
    end

    // LFSR maximal de 12 bits. Se actualiza continuamente, incluso en reposo.
    // El instante de soltar el boton determina la espera pseudoaleatoria.
    reg [11:0] lfsr = 12'h001;
    always @(posedge clk)
        lfsr <= {lfsr[10:0],lfsr[11]^lfsr[10]^lfsr[9]^lfsr[3]};

    // Banderas de control, sin registro de estado enumerado ni case de FSM.
    reg wait_release = 1'b0;
    reg waiting = 1'b0;
    reg measuring = 1'b0;
    reg early = 1'b0;
    reg timeout = 1'b0;
    reg [11:0] wait_ms = 12'd0;
    reg [31:0] sub_ms = 32'd0;
    reg [15:0] time_bcd = 16'h0000;

    wire ms_tick = (sub_ms >= CYCLES_PER_MS - 1);

    // Incremento decimal: cuatro registros BCD, 0000 a 9999.
    function [15:0] bcd_inc;
        input [15:0] x;
        begin
            if (x == 16'h9999)
                bcd_inc = x;
            else if (x[3:0] != 4'd9)
                bcd_inc = x + 16'h0001;
            else if (x[7:4] != 4'd9)
                bcd_inc = {x[15:8],x[7:4]+4'd1,4'd0};
            else if (x[11:8] != 4'd9)
                bcd_inc = {x[15:12],x[11:8]+4'd1,8'h00};
            else
                bcd_inc = {x[15:12]+4'd1,12'h000};
        end
    endfunction

    always @(posedge clk) begin
        if (wait_release) begin
            // No iniciar la espera hasta que el usuario suelte ENTER.
            if (press_armed && btn_sync) begin
                wait_release <= 1'b0;
                waiting <= 1'b1;
                wait_ms <= MIN_WAIT_MS + (lfsr & RANDOM_MASK);
                sub_ms <= 32'd0;
            end
        end else if (waiting) begin
            if (press) begin
                // Pulsacion antes de la senal: intento invalido.
                waiting <= 1'b0;
                early <= 1'b1;
                sub_ms <= 32'd0;
            end else if (ms_tick) begin
                sub_ms <= 32'd0;
                if (wait_ms <= 12'd1) begin
                    wait_ms <= 12'd0;
                    waiting <= 1'b0;
                    measuring <= 1'b1;
                    time_bcd <= 16'h0000;
                end else
                    wait_ms <= wait_ms - 12'd1;
            end else
                sub_ms <= sub_ms + 32'd1;
        end else if (measuring) begin
            // Prioridad a la respuesta; incluye el ms que termina
            // exactamente en el flanco de deteccion de la pulsacion.
            if (press) begin
                if (ms_tick)
                    time_bcd <= bcd_inc(time_bcd);
                measuring <= 1'b0;
                sub_ms <= 32'd0;
            end else if (ms_tick) begin
                sub_ms <= 32'd0;
                time_bcd <= bcd_inc(time_bcd);
                if (time_bcd == 16'h9998) begin
                    timeout <= 1'b1;
                    measuring <= 1'b0;
                end
            end else
                sub_ms <= sub_ms + 32'd1;
        end else if (press) begin
            // Primera pulsacion, o nueva partida despues del resultado.
            wait_release <= 1'b1;
            early <= 1'b0;
            timeout <= 1'b0;
            time_bcd <= 16'h0000;
            sub_ms <= 32'd0;
        end
    end

    // PIN_84 LED[0] (LSB): senal de reaccion. LED[1]: espera.
    // LED[2]: salida anticipada. LED[3]: tiempo agotado.
    assign led_n = ~{timeout, early, (wait_release | waiting), measuring};

    // Display 0000 al iniciar, contador en milisegundos al medir,
    // resultado fijo tras responder. ---- si se presiona antes de tiempo.
    // 9999 + LED[3] encendido si no hubo respuesta en 9.999 s.
    wire [4:0] d3 = early ? 5'd17 : {1'b0,time_bcd[15:12]};
    wire [4:0] d2 = early ? 5'd17 : {1'b0,time_bcd[11:8]};
    wire [4:0] d1 = early ? 5'd17 : {1'b0,time_bcd[7:4]};
    wire [4:0] d0 = early ? 5'd17 : {1'b0,time_bcd[3:0]};
    wire scan_tick;
    gen_tick #(.CICLOS(SCAN_CYCLES)) scan(clk,1'b1,1'b0,scan_tick);
    pantalla_omdazz pantalla(clk,scan_tick,d3,d2,d1,d0,seg,dig);

    // Buzzer desactivado; los DIP no intervienen en el juego.
    assign beep = 1'b1;
    wire unused = &{1'b0,sw_n};
endmodule

