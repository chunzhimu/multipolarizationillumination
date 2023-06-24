module timer(clk, rst, start, setcount, timeout);
input clk;
input rst;
input start;
input [15:0] setcount;
output timeout;

reg [15:0]count;
reg timeout;
always@(posedge clk or negedge rst)
if(!rst) begin
    count<=16'b0;
    timeout<=1'b0;
end
else begin
    if(count==setcount) begin
        count<=16'b0;
        timeout<=1'b1;
    end
    else if (start==1'b1) begin
        count<=count+1'b1;
        timeout<=1'b0;
    end
    else begin
        count<=16'b0;
        timeout<=1'b0;
    end
end
endmodule