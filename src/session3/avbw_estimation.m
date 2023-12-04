function AvBwEstimation_skeleton(lambda,C)
%
% Plot the rate response curve, and use Spruce and IGI/PTR to estimate
% Available Bandwidth from packet train traces.
%
 
r_in = [];
r_out = [];
avbw_spruce = zeros(1,100);
avbw_igiptr = zeros(1,100);
 
for i=1:100
    [r_in_i,r_out_i] = importFileData(lambda,C,i);
    
    % ###############################
    %  Estimate lambda using Spruce
    % (you can use the value of C)
    % ###############################
    avbw_spruce_i = spruce_estimate(r_in_i, r_out_i, C);
 
    % ###############################
    %  Estimate lambda using IGI/PTR
    % (assume you do not know the value of C)
    % ###############################
    avbw_igiptr_i = igiptr_estimate(r_in_i, r_out_i);
 
    fprintf("AvBw Estimates:   Spruce: %f  \tIGI/PTR: %f\n",avbw_spruce_i,avbw_igiptr_i);
    avbw_spruce(i) = avbw_spruce_i;
    avbw_igiptr(i) = avbw_igiptr_i;
    
    r_in = [r_in ; r_in_i];
    r_out = [r_out ; r_out_i];
end
 
 
 
figure;
hold on;
xlim([0 100]);
xlabel('r_{in} (Mbps)');
ylabel('r_{in} / r_{out}');
grid on;
 
% ###############################
%  Plot the trace data on the rate response curve axes
% ###############################
 
 
scatter(r_in, r_in./r_out, 'filled', 'DisplayName', 'meassured rate')
 
% ###############################
%  Plot the theoretical rate response curve for lambda and C
 
trrc = [];
for i=1:1:size(r_in)
    if r_in(i) < (C-lambda)
        trrc(i) = 1;
    else
        trrc(i) = (r_in(i) + lambda)/C;
    end
 
end
 
scatter(r_in, trrc, 'DisplayName', 'expected rate')
% ###############################
 
% ###############################
%  Plot the mean AvBw estimates of Spruce and IGI/PTR
% ###############################
avg_avbw_spruce = mean(avbw_spruce);
xline(avg_avbw_spruce, "r", 'DisplayName', 'spruce')
 
avg_avbw_igiptr = mean(avbw_igiptr);
xline(avg_avbw_igiptr, "--b", 'DisplayName', 'IGI/PTR')
 
legend
 
end
 
 
% ScriptP86 >Spruce implementiert diesen ansatz...
function avbw = spruce_estimate(r_in, r_out, C)
    lam = C* ( C/r_out(20) - 1 );
    avbw = C-lam;  
end
 
function avbw = igiptr_estimate(r_in, r_out)
    for i=1:1:size(r_in)
        if ((r_in(i)-r_out(i))/r_in(i) > 0.1)
            avbw = r_in(i);
            break;
        end
    end
end
 
 
function [r_in, r_out] = importFileData(lambda,C,file_num)
    folder = strcat(int2str(lambda),"_et_",int2str(C),"_C_5_delta");
    filename = strcat(folder,"/",folder,"_",int2str(file_num),".csv");
    data = importdata(filename);
    r_in = data(2:end,1);
    r_out = data(2:end,2);
end