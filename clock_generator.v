module clock_generator(f_clk,f_adc_clock,f_dac_clock,f_sw);
input f_clk;
output reg f_adc_clock,f_dac_clock,f_sw;
parameter N_sw=499;                                // N_sw=fclk/fsw=100mhz/200khz
parameter N_adc=3;                                 // fclk/fadc =4
reg [9:0]counter1,counter2;
initial 
begin
counter1=0;
counter2=0;
end

always@(posedge f_clk)
begin
if(counter1<=10)
begin
f_sw<=1;
counter1<=counter1+1;
end
else if (counter1==N_sw)
begin
f_sw<=1;
counter1<=0;
end
else
begin
f_sw<=0;
counter1<=counter1+1;
end
end

always@(posedge f_clk)
begin
if(counter2<=0)
begin
f_adc_clock<=0;
f_dac_clock<=0;
counter2<=counter2+1;
end
else if(counter2==N_adc)
begin
f_adc_clock<=1;
f_dac_clock<=1;
counter2<=0;
end
else 
begin
f_adc_clock<=0;
f_dac_clock<=0;
counter2<=counter2+1;
end
end
endmodule

