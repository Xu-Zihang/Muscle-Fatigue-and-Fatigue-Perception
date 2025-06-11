% Extract variables from the data matrix
x1 = data_mat(:, 1); % EMG_feature
x2 = data_mat(:, 2); % Error_feature
x3 = data_mat(:, 3); % HeartRate
x4 = data_mat(:, 4); % Pleasure
y = data_mat(:, 5); % Fatigue_perception

% Define the model function
PF = @(coeffs, x1, x2, x3, x4) coeffs(1) * (x1) + coeffs(2) * (x2) + coeffs(3) * (x3) + coeffs(4);

% Bootstrap parameters
numBootstraps = 1000;
PFAIC = zeros(numBootstraps, 1);
PFBIC = zeros(numBootstraps, 1);
PFMSE = zeros(numBootstraps, 1);

for i = 1:numBootstraps
    % Sampling with replacement
    bootIdx = randi(length(x1), [length(x1), 1]);
    
    % Generate the training set
    trainX1 = x1(bootIdx);
    trainX2 = x2(bootIdx);
    trainX3 = x3(bootIdx);
    trainX4 = x4(bootIdx);
    trainY = y(bootIdx);
    
    % Define the error function
    errorPF = @(coeffs) (trainY - PF(coeffs, trainX1, trainX2, trainX3, trainX4));
    
    % Initialize the parameter estimates randomly from the range (0, 1)
    initialGuess = rand(1, 4);
    
    % Set options for the least squares optimization
    options = optimoptions('lsqnonlin', 'Algorithm', 'levenberg-marquardt');
    
    % Perform regression
    [PFCoeffs, ~] = lsqnonlin(errorPF, initialGuess, [], [], options);
    
    % Calculate the Mean Squared Error (MSE)
    MSE = mean((trainY - PF(PFCoeffs, trainX1, trainX2, trainX3, trainX4)).^2);
    PFMSE(i) = MSE;
    
    % Calculate residuals and log-likelihood
    residuals = trainY - PF(PFCoeffs, trainX1, trainX2, trainX3, trainX4);
    sigma = std(residuals);
    pdf_values = normpdf(residuals, 0, sigma);
    loglikelihoods = sum(log(pdf_values));
    
    % Calculate Akaike Information Criterion (AIC) and Bayesian Information Criterion (BIC)
    PFN = length(initialGuess);
    n = length(trainY);
    [PFAIC(i), PFBIC(i)] = aicbic(loglikelihoods, PFN, n);
end

% Save the results
save('bootstrap_results.mat', 'PFAIC', 'PFBIC', 'PFMSE');