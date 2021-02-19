%% �������� 
load('data.mat');
flag = 0;       % flag of routing done, changed to 1 in process means undone, keeps in 0 means done
busy = 0;       % 0 for no routing active occur, 1 for routing active
global net;
net = zeros(M*N, M*N);      % for path count of xy routing

save('net.mat','net');
%% �����ʾ
figure(1);
h = bar3(net);
shading interp
for i = 1:numel(h)
  %�ر�ע��������һ�����
  index = logical(kron(net(:,i) == 0,ones(6,1)));
  zData = get(h(i),'ZData');
  zData(index,:) = nan;
  set(h(i),'CData',zData);   
end
title('��x��y ·��ʹ��ֱ��ͼ');
str = sprintf('mean: %f', mean2(net));
disp(str);
str = sprintf('std: %f \n',std2(net));
disp(str);

net1 = net;
mean = zeros(1,5);
std = zeros(1,5);
mean(1) = mean2(net1);
std(1) = std2(net1);