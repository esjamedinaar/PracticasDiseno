// Generador reutilizable de pulsos de UN ciclo de clk.
// CICLOS = numero de flancos para producir otro pulso.
// NO crea un nuevo reloj: entrega una habilitacion.
module gen_tick #(
    parameter integer CICLOS = 12500000
)(
    input wire clk,
    input wire habilitar,
    input wire reiniciar,
    output wire pulso
);
    reg [31:0] cuenta = 32'd0;
    assign pulso = habilitar && !reiniciar && (cuenta >= CICLOS - 1);

    always @(posedge clk) begin
        if (reiniciar || !habilitar || pulso)
            cuenta <= 32'd0;
        else
            cuenta <= cuenta + 32'd1;
    end
endmodule
