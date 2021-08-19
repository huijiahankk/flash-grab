function [ P_test ] = Ttest_byBootstrap( distribution , type_Ttest )
% Bootstrap distribution, 'O'/'T':One-tailed and two-tailed test
if nargin < 2
    type_Ttest = 'T';
end

resample_size = size(distribution,1);
resample_numbers = 10000;
Bootstrap = []; 
for i = 1:resample_numbers
    rand_subj = unidrnd(resample_size,resample_size,1);
    med_mean = mean(distribution(rand_subj,:));
    Bootstrap = [Bootstrap; med_mean];
end

switch type_Ttest
    case 'T'
        P_test = sum(Bootstrap<0)/resample_numbers+sum(Bootstrap>2*mean(Bootstrap))/resample_numbers;
        for i = 1:size(distribution,2)
            if P_test(i)>1
                P_test(i) = 2-P_test(i);
            end
        end
    case 'O'
        P_test = sum(Bootstrap<0)/resample_numbers;
        for i = 1:size(distribution,2)
            if P_test(i)>0.5
                P_test(i) = 1-P_test(i);
            end
        end
end

end
