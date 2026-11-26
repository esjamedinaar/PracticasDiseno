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

    wire [7:0] seg_bus;
    wire [3:0] dig_sel;
    wire [3:0] led_n_bus;
    wire       beep_sig;

    // Si tu botón en ui_in[0] es activo en alto (1 = pulsado), usa ~ui_in[0].
    // Si ya es activo en bajo (0 = pulsado), usa ui_in[0].
    wire btn_n_mapped = ~ui_in[0];

    // Salidas dedicadas: SEG_A..SEG_G en uo_out[6:0] y LED_1 en uo_out[7]
    // led_n_bus[0] es ~measuring (0 cuando mide/reacción activa); se invierte para activo en alto.
    assign uo_out[6:0] = seg_bus[6:0];
    assign uo_out[7]   = ~led_n_bus[0];

    // Salidas bidireccionales: LED_2 en uio_out[0] y DIG_0..DIG_3 en uio_out[4:1]
    // led_n_bus[2] es ~early (0 cuando hay salida anticipada); se invierte para activo en alto.
    assign uio_out[0]   = ~led_n_bus[2];
    assign uio_out[4:1] = dig_sel;
    assign uio_out[7:5] = 3'b000;
    assign uio_oe       = 8'b0001_1111;

    wire _unused = &{ena, rst_n, uio_in, ui_in[7:1], seg_bus[7], led_n_bus[3:1], beep_sig, 1'b0};

    main #(
        .CYCLES_PER_MS(50000),
        .RELEASE_CYCLES(1000000),
        .SCAN_CYCLES(50000)
    ) u_main (
        .clk   (clk),
        .btn_n (btn_n_mapped),
        .sw_n  (4'b1111),
        .seg   (seg_bus),
        .dig   (dig_sel),
        .led_n (led_n_bus),
        .beep  (beep_sig)
    );

endmodule

`default_nettype wire
