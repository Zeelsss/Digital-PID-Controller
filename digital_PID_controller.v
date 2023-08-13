module digital_PID_controller(f_pwm,N_er,N_con,K_p,K_i,K_d);
input signed[9:0]N_er,K_p,K_i,K_d;
input f_pwm;
output signed [18:0]N_con;
wire signed [19:0]N_prop_temp,N_int_temp1;
reg signed [19:0]N_der_temp;
wire signed [18:0]N_prop,N_int_temp2,N_int_inst,N_der; //N_prop_temp=K_p.Ne(q4.6*Q1.9)
reg signed [18:0]N_int,N_int_temp3,N_int_temp4;
reg signed [9:0]N_er_prev;
parameter u_int_max=19'sb0_111111111111111110;
assign N_prop_temp=K_p*N_er;
assign N_int_temp1=K_i*N_er;

always@(posedge f_pwm)
begin
N_der_temp=K_d*(N_er-N_er_prev);
N_er_prev=N_er;
end
assign N_prop={N_prop_temp[18:0]};       //resize 19 to 18  by neglate msb bit
assign N_int_temp2={N_int_temp1[18:0]};
assign N_der={N_der_temp[18:0]};

always@(posedge f_pwm)
begin
N_int_temp4=N_int_temp2+N_int_temp3;
N_int_temp3=N_int_temp4;
end

assign N_int_inst={N_int_temp4[18],N_int_temp4[18],N_int_temp4[18],{N_int_temp4[18:3]}};

always@(posedge f_pwm)
begin
if(N_int_inst>u_int_max)
N_int<=u_int_max;
else
N_int<=N_int_inst;
end
assign N_con=N_prop+N_int+N_der;
endmodule
