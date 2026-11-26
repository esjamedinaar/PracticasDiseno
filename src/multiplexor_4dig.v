// Elige uno de los 4 displays en cada pulso de escaneo.
// dig[3] corresponde al display izquierdo.
module multiplexor_4dig (
    input wire clk,
    input wire tick_scan,
    input wire [4:0] d3, d2, d1, d0,
    output reg [4:0] simbolo,
    output wire [3:0] dig
);
    reg [1:0] pos = 2'd0;
    reg [3:0] dig_on;

    always @(posedge clk)
        if (tick_scan)
            pos <= pos + 2'd1;

    always @(*) begin
        dig_on = 4'b0000;
        simbolo = 5'd16;
        case (pos)
            2'd0: begin dig_on = 4'b1000; simbolo = d3; end
            2'd1: begin dig_on = 4'b0100; simbolo = d2; end
            2'd2: begin dig_on = 4'b0010; simbolo = d1; end
            2'd3: begin dig_on = 4'b0001; simbolo = d0; end
        endcase
    end
    assign dig = ~dig_on; // Seleccion activa en bajo.
endmodule
