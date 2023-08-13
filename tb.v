module tb(f_pwm,N_er,N_con,K_p,K_i,K_d);
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
assign N_con=N_prop;//+N_int+N_der;
endmodule


module tbbbb;
reg signed [9:0]N_er,K_p,K_i,K_d;
reg f_pwm;
wire signed [18:0]N_con;
wire signed [18:0]N_er_temp;
reg [19:0]N_ref;
tb dut(f_pwm,N_er,N_con,K_p,K_i,K_d);
reg signed [18:0]y; //Q4.15
real Nerreal,yreal;
initial begin
K_p=10'b0001_000000; //1
K_i=0;
K_d=0;
N_ref=19'b010_000000000000000;
N_er=N_ref[19:10]; //10'b010_0000000;
y=0;
end
initial begin
f_pwm = 0;
forever
#10 f_pwm = ~f_pwm;
end
assign N_er_temp = N_ref-y; // N_er = 2.00 - y
initial begin
#12;
forever begin
y=y+{N_con[18],N_con[18],{N_con[18:2]}}; //y=y+0.25*Ncon
yreal=y;
#2;
N_er = N_er_temp[18:9];
Nerreal=N_er;
$display("y=%4.15f", yreal/15'b111111111111111);
#18;
end
end
endmodule
