x1 = table2array(EMG_Feature);
x2 = table2array(Error);
x3 = table2array(HR);
y = table2array(SF); 

x1 = zscore(x1);
x2 = zscore(x2);
x3 = zscore(x3);
y = zscore(y);
%% 
% Define the model function
PF = @(coeffs,x1, x2,x3) coeffs(1)*(x1).*(x2)+coeffs(2)*(x2);

% Pre - allocate arrays to store the results of each loop
PFMSE_all = zeros(50, 5);
PFAIC_all = zeros(50, 5);
PFBIC_all = zeros(50, 5);

for loop_iter = 1:50
    % Define the cross - validation object
    cv = cvpartition(length(x1), 'KFold', 5);    

    for i = 1:5
        % Divide the dataset into training and test sets
        trainIdx = training(cv, i);
        testIdx = test(cv, i);
        
        % Define the error function
        errorPF = @(coeffs) (y(trainIdx) - PF(coeffs,x1(trainIdx),x2(trainIdx),x3(trainIdx)));
        % Initialize the parameter estimates with random values from (0, 1)
        initialGuess = rand(1, 2);
        % Set optimization options
        options = optimoptions('lsqnonlin', 'Algorithm', 'levenberg-marquardt');
        % Perform regression
        [PFCoeffs, PFresnorm] = lsqnonlin(errorPF, initialGuess,[],[],options);
        PFMSE_all(loop_iter, i) = mean((y(testIdx) - PF(PFCoeffs,x1(testIdx),x2(testIdx),x3(testIdx))).^2);
        PFN = length(initialGuess);
        n = length(y(testIdx)); 
        residuals = y(testIdx) - PF(PFCoeffs,x1(testIdx),x2(testIdx),x3(testIdx));
        sigma = std(residuals);
        pdf_values = normpdf(residuals, 0, sigma);
        loglikelihoods = sum(log(pdf_values));
        [PFAIC_all(loop_iter, i),PFBIC_all(loop_iter, i)] = aicbic(loglikelihoods,PFN,n);

    end
end

% Calculate the average values of AIC and BIC
AIC = mean(mean(PFAIC_all, 2));
BIC = mean(mean(PFBIC_all, 2));

% Save the data
save('results.mat', 'PFMSE_all', 'PFAIC_all', 'PFBIC_all', 'AIC', 'BIC');