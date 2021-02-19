function result = vir_channel_control_chip(curr_chip,j,VIR_CHAN)
%description: virtual channel control
%parameter: VIR_CHAN
%result == 1 表示此时间步，该路由包不能被处理
%detail: each source node can send out only one packet in one time step
%detail: each buffer can process only VIR_CHAN packets in one time step
global pack;
global chip;

result = 0;

if pack(j).buff_pos == 6 && chip(curr_chip).left_out == VIR_CHAN;   %virtual channel control
    result = 1;
    return;
end
if pack(j).buff_pos == 7 && chip(curr_chip).right_out == VIR_CHAN;   %virtual channel control
    result = 1;
    return;
end
if pack(j).buff_pos == 8 && chip(curr_chip).up_out == VIR_CHAN;   %virtual channel control
    result = 1;
    return;
end
if pack(j).buff_pos == 9 && chip(curr_chip).down_out == VIR_CHAN;   %virtual channel control
    result = 1;
    return;
end
end
