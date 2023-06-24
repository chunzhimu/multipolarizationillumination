`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////

// 
////////////////////////////////////////////////////////////////////////////////
module RxData_Trans(
				clk,
				rst_n,
				
				rx_data,
				rx_done,

				
				txdata,
				tx_DataEn,
				tx_done
				
			);

input clk;	// 50MHz主时钟
input rst_n;	//低电平复位信号

input[7:0] rx_data;  //接收到的8字节数据
input rx_done;			//接收完成，数据有效

output tx_DataEn;		//当前帧发送开始使能，数据更新
output[7:0] txdata;	//待发送数据
input tx_done;			//发送完毕



//--------状态机：4个独立LED组控制，调节频率和占空比（主要调节占空比）--------------------------------------------------
parameter idle=4'b0000, 
G1=4'b0001,
G2=4'b0010, 
G3=4'b0100, 
G4=4'b0101; 

reg[4:0] c_state,n_state;



//==========reg========
always@(negedge SCLOCK or negedge RESET)
begin

  if (RESET == 1'b0) 
		c_state <= idle;
	else
		c_state <= n_state;

end
	
	

/*************state transation****************/
always@(channel_sel,update_en)
	begin
		case(c_state)
		idle:
			begin
					if(update_en!= 0)
						if(channel_sel==0)
						n_state <= M2; //进入模式2

					else
						n_state <= idle;
			end
			
			
		M2:
		begin
			n_state <= D10;
		end			
		
			
		D10:
			begin
					if(state_Duration1 == 0)
						n_state <= D20; //不同占空比轮换
					else
						n_state <= D10;
			end			
			
			
		D20:
			begin
					if(state_Duration2 == 0)
						n_state <= D30; //不同占空比轮换
					else
						n_state <= D20;
			end			
						
			
		D30:
			begin
					if(state_Duration3 == 0)
						n_state <= D40; //不同占空比轮换
					else
						n_state <= D30;
			end						
			
			
		D40:
			begin
					if(state_Duration4 == 0)
						n_state <= D50; //不同占空比轮换
					else
						n_state <= D40;
			end						
			
			
		D50:
			begin
					if(state_Duration5 == 0)
						n_state <= D60; //不同占空比轮换
					else
						n_state <= D50;
			end					
			
			
		D60:
			begin
					if(state_Duration6 == 0)
						n_state <= D70; //不同占空比轮换
					else
						n_state <= D60;
			end		
	
			
		D70:
			begin
					if(state_Duration7 == 0)
						n_state <= D80; //不同占空比轮换
					else
						n_state <= D70;
			end		
	
			
		D80:
			begin
					if(state_Duration8 == 0)
						n_state <= D90; //不同占空比轮换
					else
						n_state <= D80;
			end		
	
			
		D90:
			begin
					if(state_Duration9 == 0)
						n_state <= D100; //不同占空比轮换
					else
						n_state <= D90;
			end		
	
			
		D100:
			begin
					if(state_Duration10 == 0)
						n_state <= idle; //回到初始状态
					else
						n_state <= D100;
			end		
	
		
		default:
			begin
				n_state <= idle;  //状态结束后直接进入初始状态，等待下一个状态
			end
		
		endcase
	end


/*************state output输出控制****************/
always@(negedge SCLOCK )
begin
	Mode_Sel <= SW17;
	state_contrl<= SW3t0;

	begin
		case(c_state)
		
		D100:
			begin
				cout<=1;
			end		
		
		D90:							
			begin
				cout<=pwm90;
			end
			
		D80:							
			begin
				cout<=pwm80;
			end			
			
			
		D70:							
			begin
				cout<=pwm70;
			end	
			
		D60:							
			begin
				cout<=pwm60;
			end	

			
		D50:							
			begin
				cout<=pwm50;
			end	
		D40:
			begin
				cout<=pwm40;
			end		
		
		D30:							
			begin
				cout<=pwm30;
			end
			
		D20:							
			begin
				cout<=pwm20;
			end			
			
			
		D10:							
			begin
				cout<=pwm10;
			end	
				
				
		idle:
			begin
				if(state_contrl==0)
					cout<=1;
				else if(state_contrl==1)
							cout<=pwm90;
				else if(state_contrl==2)
							cout<=pwm80;
				else if(state_contrl==3)
							cout<=pwm70;
				else if(state_contrl==4)
							cout<=pwm60;
				else if(state_contrl==5)
							cout<=pwm50;
				else if(state_contrl==6)
							cout<=pwm40;
				else if(state_contrl==7)
							cout<=pwm30;
				else if(state_contrl==8)
							cout<=pwm20;
				else if(state_contrl==9)
							cout<=pwm10;
				else
					cout<=1;			
			end
		
			
		default:
			begin
				cout<=0;
			end
		endcase
	end
end


/*************状态跳转变量控制****************/
always@(posedge clk1k )
begin
		case(c_state)
		
		D100:
			begin
				state_Duration10<=state_Duration10-1;
			end		
		
		D90:							
			begin
				state_Duration9<=state_Duration9-1;
			end
			
		D80:							
			begin
				state_Duration8<=state_Duration8-1;
			end			
			
			
		D70:							
			begin
				state_Duration7<=state_Duration7-1;
			end	
			
		D60:							
			begin
				state_Duration6<=state_Duration6-1;
			end	

			
		D50:							
			begin
				state_Duration5<=state_Duration5-1;
			end	
		D40:
			begin
				state_Duration4<=state_Duration4-1;
			end		
		
		D30:							
			begin
				state_Duration3<=state_Duration3-1;
			end
			
		D20:							
			begin
				state_Duration2<=state_Duration2-1;
			end			
			
			
		D10:							
			begin
				state_Duration1<=state_Duration1-1;
			end	
					
			
		default:
			begin
			end
			
			
		endcase
		
end	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
endmodule



