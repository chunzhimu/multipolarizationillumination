module Stroboscopic(
	input wire SCLOCK,   //系统时钟50MHz
	input wire RESET,		//系统复位，低电平有效
	

	input wire SW17,
	input wire[3:0] SW3t0,
	
	
	
	output wire UART_TX,   //UART发送
	input wire UART_RX,    //UART接收
	
	

	output wire PWM1,
	output wire PWM2,
	output wire	PWM3,
	output wire	PWM4
	
);

reg bps_start_rx,bps_start_tx;
wire[7:0] rx_data,tx_data;
reg tx_int=0;
wire rx_data_ready/*synthesis keep*/;
//UART通信模块
my_uart_top uart(
				.clk(SCLOCK),
				.rst_n(RESET),
				.rs232_rx(UART_RX),
				.rs232_tx(UART_TX),
				

				.rx_data(rx_data),
				.rx_data_readyo(rx_data_ready),
				
				.tx_data(tx_data),
				.tx_int(0),
				.bps_start_txo(bps_start_tx)
				
				);
				
				
				
//-------UART接收数据处理整合模块-------------------------------				
parameter idle=4'b0000,s1=4'b0001,s2=4'b0010,s3=4'b0011,s4=4'b0111;

reg[3:0] c_state,n_state;

reg bps_start_rx_swp,bps_start_tx_swp;

//reg
always@(negedge SCLOCK or negedge RESET)
begin
	bps_start_tx_swp <= bps_start_tx;
	if(RESET==1'b0)
		begin
			c_state <= idle;
		end
	else					
		begin
			c_state <= n_state;
		end
end




//(* noprune *)
reg[3:0] dev_sel=0,ch_sel=0,data_cnt=0/*synthesis preserve*/;

reg[23:0] freq=0,duty=0/*synthesis noprune*/;
reg update=0;  //数据帧接收完毕，可以进行数据更新

//---------状态跳转state transation-------			
always@(negedge SCLOCK )
begin
	case(c_state)
	idle:
		begin
			n_state <= s1;
			update <= 0;
			data_cnt <= 0;
			freq<=0;
			duty<=0;
		end

	
	s1:  //device and channel selection
		begin
			if(rx_data_ready)  //假如下降沿，当前接收数据完成
				begin
					data_cnt <= data_cnt+1;
					case(data_cnt)
					4'd0:begin dev_sel <= rx_data[7:4];
									ch_sel <= rx_data[3:0];
									n_state <= s1;
						  end
					
					4'd1:begin freq <= rx_data;
									n_state <= s1;
						  end
					
					4'd2:begin freq <= (freq<<8)+rx_data;
									n_state <= s1;
						  end
					
					4'd3:begin freq <= (freq<<8)+rx_data;
									n_state <= s1;
						  end
						  
					
					4'd4:begin duty <= rx_data;
									n_state <= s1;
						  end
					
					4'd5:begin duty <= (duty<<8)+rx_data;
									n_state <= s1;
						  end
					
					4'd6:begin duty <= (duty<<8)+rx_data;
									n_state <= s1;
						  end
					
					4'd7:begin if(rx_data==8'hff)  //假如下降沿，当前接收数据完成
									begin
										n_state <= idle;
										update <= 1;
									end
						  end

					default:n_state <= idle;
					endcase
									
				end
		end
		

	default:
		begin
			n_state <= idle;
			update <= 0;
			data_cnt <=0;
		end
	
	endcase
end
				

//状态输出	
//----------PWM波参数设置------------------------------------------


parameter CNT_1M=50,CNT_100K=500,CNT_10K=5000,CNT_1K=50000;
parameter DutyH=1000;

reg[23:0] CNT_F1=CNT_1K,CNT_F2=CNT_1K,CNT_F3=CNT_1K,CNT_F4=CNT_1K;  //周期
reg[23:0] DutyH1=DutyH,DutyH2=DutyH,DutyH3=DutyH,DutyH4=DutyH;	 //占空比



always@(posedge SCLOCK or negedge RESET)
begin
	if(RESET==1'b0)
		begin
			CNT_F1 <= CNT_1K;
			CNT_F2 <= CNT_1K;
			CNT_F3 <= CNT_1K;
			CNT_F4 <= CNT_1K;
			
			DutyH1 <= DutyH;
			DutyH2 <= DutyH;
			DutyH3 <= DutyH;
			DutyH4 <= DutyH;
		end
	else					
		begin
			if(update==1)
				begin
				if(dev_sel == 0) //当前只有一个设备，因而这里不写后面的
						begin
							if(ch_sel == 0)
								begin
									CNT_F1 <= freq;
									DutyH1 <= duty;
								end
							else if(ch_sel == 1)
								begin
									CNT_F2 <= freq;
									DutyH2 <= duty;
								end
							else if(ch_sel == 2)
								begin
									CNT_F3 <= freq;
									DutyH3 <= duty;
								end
							else if(ch_sel == 2'd3)
								begin
									CNT_F4 <= freq;
									DutyH4 <= duty;
								end
						end

				end
		end
end	
				
				






reg clk1=0,clk2=0,clk3=0,clk4=0;


/*-------------------######--50MHz to 10KHz---########-----------------------------
 --10KHz clock generate
 -----------------------------------------------------------------------*/
(* noprune *) reg[23:0] CNT1,CNT2,CNT3,CNT4;

always@(posedge SCLOCK or negedge RESET)
begin
	if(RESET==1'b0)
		begin
			CNT1 <= 16'b0;
			clk1 <= 1'b0;

		end
	else	
		begin
			if((update==1)&(ch_sel == 0))
			begin
				CNT1 <=0;
			end
			
			else
		
			if(CNT1 == CNT_F1-1)
				begin
					clk1 <= ~clk1;
					CNT1 <=0;
				end
			else
				if(CNT1 == DutyH1-1)
				begin
					clk1 <= ~clk1;
					CNT1 <=CNT1+ 1'b1;
				end	
			else
				begin
					CNT1 <=CNT1 + 1'b1;
				end
		end
end



//(* noprune *) reg[15:0] CNT2;
always@(posedge SCLOCK or negedge RESET)
begin
	if(RESET==1'b0)
		begin
			CNT2 <= 16'b0;
			clk2 <= 1'b0;

		end
	else	
		begin
			if((update==1) &(ch_sel == 1))
			begin
				CNT2 <=0;
			end
		
			else
		
			if(CNT2 == CNT_F2-1)
				begin
					clk2 <= ~clk2;
					CNT2 <=0;
				end
			else
				if(CNT2 == DutyH2-1)
				begin
					clk2 <= ~clk2;
					CNT2 <=CNT2 + 1'b1;
				end
			else
				begin
					CNT2 <=CNT2 + 1'b1;
				end
		end
end



//(* noprune *) reg[15:0] CNT3;
always@(posedge SCLOCK or negedge RESET)
begin
	if(RESET==1'b0)
		begin
			CNT3 <= 16'b0;
			clk3 <= 1'b0;

		end
	else	
		begin
			if((update==1) &(ch_sel == 2))
			begin
				CNT3 <=0;
			end
		
			else
			if(CNT3 == CNT_F3-1)
				begin
					clk3 <= ~clk3;
					CNT3 <=0;
				end
			else
				if(CNT3 == DutyH3-1)
				begin
					clk3 <= ~clk3;
					CNT3 <=CNT3 + 1'b1;
				end
			else
				begin
					CNT3 <=CNT3 + 1'b1;
				end
		end
end



//(* noprune *) reg[15:0] CNT4;
always@(posedge SCLOCK or negedge RESET)
begin
	if(RESET==1'b0)
		begin
			CNT4 <= 16'b0;
			clk4 <= 1'b0;

		end
	else	
		begin
			if((update==1) &(ch_sel ==2'd3))
			begin
				CNT4 <=0;
			end
			else
			if(CNT4 == CNT_F4-1)
				begin
					clk4 <= ~clk4;
					CNT4 <=0;
				end
			else
				if(CNT4 == DutyH4-1)
				begin
					clk4 <= ~clk4;
					CNT4 <=CNT4 + 1'b1;
				end
			else
				begin
					CNT4 <=CNT4 + 1'b1;
				end
		end
end



assign PWM1=clk1;
assign PWM2=clk2;
assign PWM3=clk3;
assign PWM4=clk4;





endmodule