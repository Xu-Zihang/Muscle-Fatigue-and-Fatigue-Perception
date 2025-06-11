% Standardize the data matrix
% Assume data_mat is the input data matrix
data_mat = zscore(data_mat);

% Convert the data matrix to a table structure and specify variable names
data_table = array2table(data_mat, 'VariableNames', ...
    {'Pleasure', 'MuscleFatigueDiff', 'HeartRateDiff', 'FatigueDiff','Condition'});

% Generate interaction terms
data_table.Pleasure_Condition = data_table.Pleasure .* data_table.Condition;
data_table.Pleasure_MuscleFatigueDiff = data_table.Pleasure .* data_table.MuscleFatigueDiff;
data_table.Pleasure_HeartRateDiff = data_table.Pleasure .* data_table.HeartRateDiff;
data_table.Condition_MuscleFatigueDiff = data_table.Condition .* data_table.MuscleFatigueDiff;
data_table.Condition_HeartRateDiff = data_table.Condition .* data_table.HeartRateDiff;
data_table.MuscleFatigueDiff_HeartRateDiff = data_table.MuscleFatigueDiff .* data_table.HeartRateDiff;

% Set Bootstrap parameters
nBootstrap = 1000; % Number of resampling times
residuals_all = []; % Array to store all resampled residuals

% Bootstrap resampling process
for b = 1:nBootstrap
    % Randomly draw samples with replacement to generate sample indices
    bootstrap_idx = randi(size(data_table, 1), size(data_table, 1), 1);
    % Get the Bootstrap sample according to the indices
    bootstrap_sample = data_table(bootstrap_idx, :);
    
    % Fit a linear model, specifying the response variable and predictor variables and interaction terms
    mdl = fitlm(bootstrap_sample, 'FatigueDiff ~ Pleasure+MuscleFatigueDiff+HeartRateDiff+Pleasure_MuscleFatigueDiff+Pleasure_HeartRateDiff+MuscleFatigueDiff_HeartRateDiff');
    
    % Calculate predicted values based on the fitted model and the Bootstrap sample
    predicted = predict(mdl, bootstrap_sample);
    
    % Extract the actual values, which are the values of the response variable in the Bootstrap sample
    actual = bootstrap_sample.FatigueDiff;
    
    % Calculate the residuals, actual values minus predicted values
    residuals = actual - predicted;
    % Add the residuals of this resampling to the array storing all residuals
    residuals_all = [residuals_all; residuals]; 
end

% Display all residuals and provide an explanation
disp('Residuals of the regression model:');
disp(residuals_all);

% Save important data (the processed data table and all residuals) to a.mat file
save('data_and_residuals.mat', 'data_table','residuals_all');