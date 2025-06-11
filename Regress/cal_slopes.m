% Read and standardize the data
% Assume data_mat is already loaded, and we standardize it here
data_mat = zscore(data_mat);

% Extract input and output variables
x = data_mat(:, 3); % Input variable
y = data_mat(:, 5); % Output variable

% Set parameters
numBootstrap = 1000; % Number of bootstrap repetitions
n = length(x); % Number of data points
slopes = zeros(numBootstrap, 1); % Array to store slopes from each bootstrap iteration

% Bootstrap sampling and regression
for i = 1:numBootstrap
    % Sampling with replacement
    indices = randi(n, n, 1); % Generate random indices
    x_bootstrap = x(indices); % Sampled input data
    y_bootstrap = y(indices); % Sampled output data
    
    % Perform linear regression
    mdl = fitlm(x_bootstrap, y_bootstrap);
    
    % Extract and save the slope
    slopes(i) = mdl.Coefficients.Estimate(2); % The slope is at the second position of the coefficients
end

% Output statistical information of the slopes
disp('Statistical information of the slopes:');
disp(['Mean: ', num2str(mean(slopes))]);
disp(['Standard deviation: ', num2str(std(slopes))]);

% Save the slopes for further analysis
save('bootstrap_slopes.mat', 'slopes');