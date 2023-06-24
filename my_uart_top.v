`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:
// Design Name:    
// Module Name:    my_uart_top
// Project Name:   
// Target Device:  
// Tool versions:  
// Description:
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 欢迎加入EDN的FPGA/CPLD助学小组一起讨论：http://group.ednchina.com/1375/
////////////////////////////////////////////////////////////////////////////////
module my_uart_top(
				clk,
				rst_n,
				rs232_rx,
				rs232_tx,
				
				rx_data,
				rx_data_readyo,
				
				tx_data,
				tx_int,
				bps_start_txo
				
				);

input clk;			// 50MHz主时钟
input rst_n;		//低电平复位信号

input rs232_rx;		// RS232接收数据信号
output rs232_tx;	//	RS232发送数据信号

output wire[7:0] rx_data;
output wire rx_data_readyo;

input wire[7:0] tx_data;
input wire tx_int;
output wire bps_start_txo;


wire bps_start_tx,bps_start_rx;	//接收到数据后，波特率时钟启动信号置位,发送和接收使能，高电平期间表示正在工作（正忙），低电平表示可使用
wire clk_bps1,clk_bps2;		// clk_bps_r高电平为接收数据位的中间采样点,同时也作为发送数据的数据改变点 

assign bps_start_txo=bps_start_tx;
//assign bps_start_rxo=bps_start_rx;


//----------------------------------------------------
//下面的四个模块中，speed_rx和speed_tx是两个完全独立的硬件模块，可称之为逻辑复制
//（不是资源共享，和软件中的同一个子程序调用不能混为一谈）
////////////////////////////////////////////
speed_select		speed_rx(	
							.clk(clk),	//波特率选择模块
							.rst_n(rst_n),
							.bps_start(bps_start_rx),  //如果该信号为低电平，则波特率生成模块计数清零，即停止生成波特率时钟
							.clk_bps(clk_bps1)		//数据更新使能信号，仅持续一个系统时钟
						);

my_uart_rx			my_uart_rx(		
							.clk(clk),	//接收数据模块
							.rst_n(rst_n),
							.rs232_rx(rs232_rx),
							.rx_data(rx_data),	
						   .rx_data_ready(rx_data_readyo),	

							.clk_bps(clk_bps1),		
							.bps_start(bps_start_rx)	//检测到RX引脚被拉低（下降沿），拉高使能波特率接收，接收完毕后变低
						);

///////////////////////////////////////////						
speed_select		speed_tx(	
							.clk(clk),	//波特率选择模块
							.rst_n(rst_n),
							.bps_start(bps_start_tx),
							.clk_bps(clk_bps2)
						);

my_uart_tx			my_uart_tx(		
							.clk(clk),	//发送数据模块
							.rst_n(rst_n),
							.tx_data0(tx_data),
							.tx_int(tx_int),
							
							.rs232_tx(rs232_tx),
							.clk_bps(clk_bps2),
							.bps_start(bps_start_tx)
						);

						
								
endmodule
