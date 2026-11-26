// Codigos EXACTOS del proyecto OMDAZZ original que funciono.
// Patrones por orden: bit0=a, bit1=b...bit6=g, bit7=dp.
// El display fisico se activa con cero, por ello seg = ~pat.
module decodificador_7seg (
    input wire [4:0] simbolo,
    output wire [7:0] seg
);
    reg [7:0] pat;
    always @(*) begin
        case (simbolo)
            5'd0:  pat=8'h3F;
            5'd1:  pat=8'h06;
            5'd2:  pat=8'h5B;
            5'd3:  pat=8'h4F;
            5'd4:  pat=8'h66;
            5'd5:  pat=8'h6D;
            5'd6:  pat=8'h7D;
            5'd7:  pat=8'h07;
            5'd8:  pat=8'h7F;
            5'd9:  pat=8'h6F;
            5'd10: pat=8'h77; // A
            5'd11: pat=8'h7C; // b
            5'd12: pat=8'h39; // C
            5'd13: pat=8'h5E; // d
            5'd14: pat=8'h79; // E
            5'd15: pat=8'h71; // F
            5'd17: pat=8'h40; // -
            5'd18: pat=8'h73; // P
            5'd19: pat=8'h3F; // O
            default: pat=8'h00; // blanco
        endcase
    end
    assign seg = ~pat;
endmodule
