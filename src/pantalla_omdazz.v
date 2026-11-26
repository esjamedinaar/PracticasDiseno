// Multiplexado con los mismos modulos y polaridad de la ALU original.
module pantalla_omdazz(
    input wire clk, tick,
    input wire [4:0] d3,d2,d1,d0,
    output wire [7:0] seg,
    output wire [3:0] dig
);
    wire [4:0] simbolo;
    multiplexor_4dig mux(clk,tick,d3,d2,d1,d0,simbolo,dig);
    decodificador_7seg decoder(simbolo,seg);
endmodule
