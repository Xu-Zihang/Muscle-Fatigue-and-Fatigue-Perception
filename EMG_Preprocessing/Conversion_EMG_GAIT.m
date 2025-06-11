%%%%%%%%%% Extraction %%%%%%%%%%
clear; clc;
importdata('sub01.csv');
RAW = ans.data;
x = length(RAW);
EMG = zeros(x, 5);
EMG(:,1) = RAW(:,1);
a = 2;
for i = 1 : 4
    EMG(:, i+1) = RAW(:, a);
    a = a + 20;
end

save('RAW', 'RAW');
save('EMG_R.mat','EMG');
% 
%%%%%%%%%% Calibration %%%%%%%%%%
clear;
load('EMG_R.mat');load('Press.mat');
x = length(EMG);
a = 1;
EMG_C = zeros(x, 7);
EMG_C(:,1:5) = EMG(:,1:5); 
for i = 1 : x
    if EMG_C(i, 1) <  Press_R(a, 1)
        EMG_C(i, 6) = Press_R(a, 2); 
        EMG_C(i, 7) = Press_R(a, 3);
    else
        a = a + 1;
        EMG_C(i, 6) = Press_R(a, 2);
        EMG_C(i, 7) = Press_R(a, 3);
    end
end

save('EMG_GAIT.mat','EMG_C');
clear all; clc;

%%%%%%%%%% Normalization %%%%%%%%%%
clear all;
for i = 2 : 10
    a = sum(EMG_C(1:200,i))/200;
    EMG_C(:,i) =  EMG_C(:,i) - a;
end

save('EMG_CN','EMG_CN');
