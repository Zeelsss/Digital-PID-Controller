module PID_CONTROLLER(clk,clk_adc,clk_dac,pwm_high,pwm_low,adc_data,dac_data,Q_load,Q_L_R_tran);

//i/p , o/p declaration
input clk,Q_L_R_tran;                                //saclar input
output clk_adc,clk_dac,pwm_high,pwm_low,Q_load;      //scalar output     
input signed [9:0]adc_data;                          //vector signed input 10 bit
output [11:0]dac_data;                               //12-bit output data 2's comp.

//wires and reg
reg signed [9:0]N_out;
wire signed [9:0] N_e;
wire signed [18:0] N_con;
wire f_pwm;                                          // internal Switching Freq.

//PID CONTROLLER GAINS
parameter K_p=10'sb0001_010000;                      //propotional control gain - Q4.6 = 1.25
parameter K_i=10'sb0_001100011;                      //integral control gain - Q1.9 = 
parameter K_d=10'sb0111_111111;                      //differential control gain = Q4.6 = 8

//reference voltage commands : Vref and delta_Vref
parameter N_ref_nom=10'sb0_010001010;                //Vref
parameter delta_N_ref=10'sb0_000001110;              //delta Vref
wire signed [9:0]N_ref;
reg signed [9:0]N_ref_temp;

//Output voltage from ADC and generate error Voltage
always@(posedge f_pwm)
begin                                                //capturing volatage sample
N_out<={adc_data[9:1],1'b0};                         //last bit ignored b/c to reduce the resolution of dpwm then adc resolution
end
assign N_e=N_ref-N_out;

//clock generation circuit
clock_generator u1(.f_clk(clk),.f_adc_clock(clk_adc),.f_dac_clock(clk_dac),.f_sw(f_pwm));

//digital PID ConTROLLER
digital_PID_controller u2(.f_pwm(f_pwm),.N_er(N_e),.N_con(N_con),.K_p(K_p),.K_i(K_i),.K_d(K_d));

//DPWM and deadtime
DPWM_dead_time_circuit u6(.clk(clk),.f_pwm(f_pwm),.cont_out(N_con),.Q_H(pwm_high),.Q_L(pwm_low));

//Creating transient events
parameter N_tran=100;
reg[9:0]counter1;
reg Q_tran;
wire Q_tran__type;
assign Q_tran_type=Q_L_R_tran;                      //0 for load tran , 1 for ref. tran
initial
begin
counter1=0;
end
always@(posedge f_pwm)
begin
if(counter1<=N_tran/2)
begin
Q_tran<=0;
N_ref_temp<=N_ref_nom;
counter1<=counter1+1;
end
else if(counter1==N_tran)
begin
Q_tran<=0;
N_ref_temp<=N_ref_nom;
counter1<=0;
end
else 
begin
Q_tran<=1;
N_ref_temp<=N_ref_nom+delta_N_ref;
counter1<=counter1+1;
end
end
assign Q_load=Q_tran_type?0:Q_tran;
assign N_ref=Q_tran_type?N_ref_temp:N_ref_nom;
assign dac_data=12'b0;
endmodule
