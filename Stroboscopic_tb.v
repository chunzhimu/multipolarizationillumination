`timescale 1ns/1ps
module Stroboscopic_tb(



);

reg Swithches;
reg[3:0] Swithches;
integer i;

reg clk,reset;


Stroboscopic test(

.SCLOCK(),
.RESET(),

.SW17(),
.SW3t0(),

.PWM1()


);


initial 
	begin
		clk =0;
		reset =1;

		#20 clk =~clk;
		#20 clk =~clk;
		#20 clk =~clk;
		#20 clk =~clk;
		#20 clk =~clk;
		#20 clk =~clk;
		#20 clk =~clk;
		#20 clk =~clk;
		#20 clk =~clk;
		#20 clk =~clk;
		#20 clk =~clk;
		#20 clk =~clk;
		#20 clk =~clk;
		#20 clk =~clk;
		#20 clk =~clk;

	end

endmodule