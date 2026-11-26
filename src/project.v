`default_nettype none

module tt_um_juego_reaccion (
    input  wire [7:0] ui_in,    // Entradas dedicadas (botones, sensores, etc.)
    output wire [7:0] uo_out,   // Salidas dedicadas (LEDs, segmentos, etc.)
    input  wire [7:0] uio_in,   // Entradas bidireccionales (cuando uio_oe = 0)
    output wire [7:0] uio_out,  // Salidas bidireccionales (cuando uio_oe = 1)
    output wire [7:0] uio_oe,   // Dirección: 1 = salida, 0 = entrada
    input  wire       ena,      // Habilitación del tile (1 cuando está activo)
    input  wire       clk,      // Reloj
    input  wire       rst_n     // Reset asíncrono activo en bajo (0 = reset)
);

    // 1. Define la dirección de los pines bidireccionales (uio)
    // Ejemplo: todos como entrada (0) si no usas uio_out
    assign uio_oe  = 8'b0000_0000;
    assign uio_out = 8'b0000_0000;

    // 2. Evita warnings por señales sin usar si no conectas todos los bits
    wire _unused = &{ena, uio_in, ui_in[7:2], 1'b0};

    // 3. Instancia aquí tu módulo principal y conecta tus submódulos
    // ...

endmodule

`default_nettype wire
