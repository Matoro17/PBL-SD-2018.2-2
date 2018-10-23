// Criando um módulo onde os pinos de entrada e saída estão dentro dos parênteses
module lcd_driver (dataa, datab, result, clk, clk_en, start, reset, done, rs, rw, en, db);

	// Recebe um caractere por vez
	input [31:0] dataa; // Dados de instrução ou ação
	input [31:0] datab; // Dados para escrever no LCDs
	input clk;
	input clk_en;
	input start;
	input reset;
	
	output reg [31:0] result;
	output reg done;
	output reg rs;  // Informar para o LCD se está sendo enviado uma instrução ou dados
					//(0) - Instrução (1) - Dados
	output rw; // Read-Write, informar se está sendo feito leitura ou escrita no LCD
					//(0) - escrita (1) - leitura
	output reg en; // Saída enable
	output reg[7:0] db; // Saída de dados para o LCD

	// Atribuindo o pino rw
	// (Número de bits, Será uma sequência binária, Valor do bit) = 1'b0
	assign rw = 1'b0;
	
	// Criando um banco de registradores com 17 bits
	reg [16:0] contador;
	
	localparam idle = 0, working = 1, finish = 2;
	
	// Criando um registrador para salvar o estado
	reg [1:0] state;
	
	// Sempre que haver clock inicia
	always @ (posedge clk or posedge reset) begin
		if (reset) begin
			contador <= 17'd0;
			rs       <= 1'b0;
			en       <= 1'b0;
			db       <= 8'b0;
			state    <= 1'b0;
		end else begin
			if (clk_en) begin
				case (state)
					idle:begin
						done <= 1'b0;
						if (start) begin
							state <= working;
							rs <= dataa[0];
							db <= datab[7:0];
							contador <= 17'd0;
							en <= 1'b1;
						end else begin
							state <= idle;
						end
					end
					working:begin
						done <= 1'b0;
						if (contador == 17'd100_000) begin
							state <= finish;
							en    <= 1'b0;
						end else begin
							contador <= contador + 1'd1;
							state <= working;
						end
					end
					finish:begin
						done <= 1'b1;
						result <= 1'b1;
						state <= idle;
					end
				endcase
			end
		end
	end
	
endmodule