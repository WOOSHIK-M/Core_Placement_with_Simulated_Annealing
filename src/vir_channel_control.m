function result = vir_channel_control(curr,j,VIR_CHAN,INTERVAL)
%% description: virtual channel control
%parameter: VIR_CHAN
%result == 1 表示此时间步，该路由包不能被处理
%detail: each source node can send out only one packet in one time step
%detail: each buffer can process only VIR_CHAN packets in one time step
global pack;
global node;

result = 0;
if pack(j).buff_pos == 0 && node(curr).time > INTERVAL   %injection interval control
    result = 1;
    return;
end
if pack(j).buff_pos == 0 && node(curr).local_in_out == 1   %each source node can send out only one packet in each cycle
    result = 1;
    return;
end
if pack(j).buff_pos == 1 && node(curr).left_out == VIR_CHAN   %virtual channel control
    result = 1;
    return;
end
if pack(j).buff_pos == 2 && node(curr).right_out == VIR_CHAN   %virtual channel control
    result = 1;
    return;
end
if pack(j).buff_pos == 3 && node(curr).up_out == VIR_CHAN   %virtual channel control
    result = 1;
    return;
end
if pack(j).buff_pos == 4 && node(curr).down_out == VIR_CHAN   %virtual channel control
    result = 1;
    return;
end

end
