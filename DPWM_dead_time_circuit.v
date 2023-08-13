module DPWM_dead_time_circuit(clk,f_pwm,cont_out,Q_H,Q_L);
input clk,f_pwm;
input signed [18:0]cont_out;    //Q4.15
output Q_H,Q_L;
wire rst;
reg q_pwm;
reg[7:0]shift=0;
reg pwm_delay;
wire signed [11:0]controller_output;
reg signed [11:0]counter;       //Q4.8

initial
begin
counter=0;
end
assign controller_output={cont_out[18:7]};

always@(posedge clk)
begin
if(counter<=1)
begin
q_pwm<=1;
counter=counter+1;
end
else if(counter<=controller_output)
begin
q_pwm<=1;
counter=counter+1;
end
else if(counter==499)
begin
q_pwm<=0;
counter=0;
end
else 
begin
q_pwm<=0;
counter=counter+1;
end
end

always@(posedge clk)
begin
shift[0]<=q_pwm;
shift[1]<=shift[0];
shift[2]<=shift[1];
shift[3]<=shift[2];
shift[4]<=shift[3];
pwm_delay<=shift[4];
end
assign Q_H=q_pwm & pwm_delay;
assign Q_L=~(q_pwm | pwm_delay);
endmodule


  