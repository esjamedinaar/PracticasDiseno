`default_nettype none

module tt_um_juego_reaccion (
    input  wire [7:0] ui_in,    // Entradas dedicadas
    output wire [7:0] uo_out,   // Salidas dedicadas
    input  wire [7:0] uio_in,   // Entradas bidireccionales
    output wire [7:0] uio_out,  // Salidas bidireccionales
    output wire [7:0] uio_oe,   // 1 = salida, 0 = entrada
    input  wire       ena,      // Habilitación del módulo
    input  wire       clk,      // Reloj
    input  wire       rst_n     // Reset activo en bajo (0 = reset)
);

    // Señales de E/S del juego
    wire       btn_react = ui_in[0];
    wire [6:0] seg;
    wire       led_1;
    wire       led_2;
    wire [3:0] dig_sel;

    // Salidas dedicadas: 7 segmentos + 1 LED
    assign uo_out[6:0] = seg;
    assign uo_out[7]   = led_1;

    // Salidas bidireccionales: 1 LED en uio_out[0] y 4 dígitos en uio_out[4:1]
    assign uio_out[0]   = led_2;
    assign uio_out[4:1] = dig_sel;
    assign uio_out[7:5] = 3'b000;

    // Habilitar uio[4:0] como salida y uio[7:5] como entrada
    assign uio_oe = 8'b0001_1111;

    // Evita advertencias por señales no utilizadas
    wire _unused = &{ena, uio_in, ui_in[7:1], 1'b0};

    // -------------------------------------------------------------------------
    // Instancia aquí tu lógica (por ejemplo, main.v y los submódulos de src/)
    // -------------------------------------------------------------------------
    // Si tus módulos usan reset activo en ALTO, pasa ~rst_n en lugar de rst_n.
    // Ejemplo:
    // main u_juego (
    //     .clk      (clk),
    //     .rst_n    (rst_n),
    //     .btn      (btn_react),
    //     .led_1    (led_1),
    //     .led_2    (led_2),
    //     .seg      (seg),
    //     .dig_sel  (dig_sel)
    // );

endmodule

`default_nettype wire
