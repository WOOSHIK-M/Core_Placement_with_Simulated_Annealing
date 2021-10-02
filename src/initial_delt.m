function initial_delt(M,N)
%description: initial delt
global delt;

for j = 1:N
    for i = 1:M-1
        a = i+M*(j-1);
        b = i+M*(j-1)+1;
        delt(a,b).grad = 0;     %BP mark, 0 for LTP, larger than 0 for LTD
        delt(a,b).src = [];     %node number that caused BP mark
        delt(a,b).src_buff = [];    %buff of node that caused BP mark 
        delt(b,a).grad = 0;
        delt(b,a).src = [];
        delt(b,a).src_buff = [];
    end 
end
for j = 1:N-1
    for i = 1:M
        a = i+M*(j-1);
        b = i+M*(j-1)+1;
        delt(a,b).grad = 0;
        delt(a,b).src = [];
        delt(a,b).src_buff = [];
        delt(b,a).grad = 0;
        delt(b,a).src = [];
        delt(b,a).src_buff = [];
    end 
end

end