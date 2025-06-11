% Clear the workspace and command window
clear;
clc;

% Import data from 'Press01.csv'
data = importdata('Press01.csv');
Press_C = data;

% Get the length of the data
t = length(Press_C);

% Initialize a column of zeros
a = zeros(t, 1);

% Add the column of zeros to the data matrix
Press_C = [Press_C, a];

% Create a new figure
figure();

% Plot the second column of Press_C
plot(Press_C(:, 2));
hold on;

% Plot the third column of Press_C
plot(Press_C(:, 3));

% Plot the fourth column of Press_C
plot(Press_C(:, 4));

%% Phase division
% Thresholds for phase determination
threshold_2 = 3;
threshold_3 = 3;
threshold_4 = 3;

% Index of the label channel
labelchannel = 9;

% Iterate through each row of Press_C
for i = 1:length(Press_C)
    if Press_C(i, labelchannel) == 0
        if Press_C(i, 2) < threshold_2
            if Press_C(i, 3) < threshold_3 && Press_C(i, 4) < threshold_4
                Press_C(i, labelchannel) = 4; % Swing phase, all three columns are less than the thresholds
            elseif Press_C(i, 3) >= threshold_3 || Press_C(i, 4) >= threshold_4
                Press_C(i, labelchannel) = 3; % Late stance phase, heel off, second column is less than the threshold, third or fourth column is greater than the threshold
            end
        else
            if Press_C(i, 3) < threshold_3 && Press_C(i, 4) < threshold_4
                Press_C(i, labelchannel) = 1; % Early stance phase, second column is greater than the threshold, third and fourth columns are less than the thresholds
            else
                Press_C(i, labelchannel) = 2; % Mid stance phase, all three columns are greater than the thresholds
            end
        end
    end
end

% Plot the last column of Press_C
plot(Press_C(:, end));

%% Remove incorrect standing stages
current_label = Press_C;
state = 0;

% Iterate through the data, excluding the first and last few points
for i = 2:length(current_label) - 50
    if current_label(i - 1, labelchannel) == 4 && current_label(i, labelchannel) == -1
        start_point = i;
        state = 1;
    end
    if state == 1 && current_label(i, labelchannel) == -1
        if (current_label(i + 1, labelchannel) == 2 ||...
            current_label(i + 1, labelchannel) == 3 || current_label(i + 1, labelchannel) == 4)
            end_point = i;
            Press_C(start_point:end_point, labelchannel) = 4;
            state = 0;
        elseif current_label(i + 1, labelchannel) == 1
            end_point = i;
            Press_C(start_point:end_point, labelchannel) = 1;
            state = 0;
        end
    end
end

% Plot the last column of Press_C
plot(Press_C(:, end));

%% Correct the convex shape, multiple points
current_label = Press_C;
state = 0;

% Iterate through the data, excluding the first and last few points
for i = 2:length(current_label) - 3
    if abs(current_label(i - 1, labelchannel) - current_label(i, labelchannel)) ~= 0 &&...
            current_label(i - 1, labelchannel) == current_label(i - 2, labelchannel)
        if current_label(i - 1, labelchannel) < current_label(i, labelchannel)
            start_point = i;
            state = 1;
        end
    end
    if state == 1 && abs(current_label(i, labelchannel) - current_label(i + 1, labelchannel)) ~= 0 &&...
            (current_label(i, labelchannel) == current_label(start_point, labelchannel)) &&...
            current_label(i, labelchannel) == current_label(i - 1, labelchannel) &&...
            current_label(i + 1, labelchannel) == current_label(start_point - 1, labelchannel)
        end_point = i;
        Press_C(start_point:end_point, labelchannel) = current_label(i + 1, labelchannel);
        state = 0;
    end
end

%% Single-point noise removal
current_label = Press_C;
state = 0;

% Iterate through the data, excluding the first and last few points
for i = 2:length(current_label) - 3
    if abs(current_label(i - 1, labelchannel) - current_label(i, labelchannel)) == 1 && current_label(i - 1, labelchannel) == current_label(i + 1, labelchannel)
        if current_label(i, labelchannel) < current_label(i - 1, labelchannel)
            Press_C(i, labelchannel) = current_label(i + 1, labelchannel);
        else
            start_point = i;
            state = 1;
        end
    end
    if state == 1 && current_label(i + 1, labelchannel) ~= current_label(i + 2, labelchannel)
        end_point = i + 2;
        Press_C(start_point:end_point, labelchannel) = current_label(i + 2, labelchannel);
        state = 0;
    end
end

%% Noise removal
current_label = Press_C;
iter_window = 15;

% Iterate through the data, excluding the first and last few points
for i = 2:length(Press_C) - iter_window
    if Press_C(i, labelchannel) ~= Press_C(i - 1, labelchannel)
        for j = 1:iter_window
            if Press_C(i - 1, labelchannel) == Press_C(i + j, labelchannel)
                Press_C(i:i + j, labelchannel) = Press_C(i - 1, labelchannel);
            end
        end
    end
end

% Plot the last column of Press_C
plot(Press_C(:, end));

%% Phase 3 correction, for phase 3 being shorter than actual
labelchannel = 9;
current_label = Press_C;
state = 0;
threshold = 3.1;

% Iterate through the data, excluding the last point
for i = 1:length(current_label) - 1
    if current_label(i, labelchannel) == 3 && current_label(i + 1, labelchannel) == 4
        start_point = i;
        state = 1;
    end
    if state == 1 && current_label(i, 3) < threshold && current_label(i, 3) > current_label(i + 1, 3) && current_label(i, labelchannel) == 4
        end_point = i;
        Press_C(start_point:end_point, labelchannel) = 3;
        state = 0;
    end
end

%% Phase 4 correction, for phase 4 being shorter than actual (i.e., phase 3 being longer than actual)
current_label = Press_C;
state = 0;
threshold = 3;

% Iterate through the data, excluding the last few points
for i = 1:length(current_label) - 6
    if current_label(i, 3) > threshold && current_label(i, 3) > current_label(i + 5, 3) && current_label(i, labelchannel) == 3
        start_point = i;
        state = 1;
    end
    if state == 1 && current_label(i, labelchannel) == 3 && current_label(i + 1, labelchannel) == 4
        end_point = i;
        Press_C(start_point:end_point, labelchannel) = 4;
        state = 0;
    end
end

%% Outlier removal
outlier = 3;
referencevalue = 4;
rightvalue = 4;

% Iterate through the data, excluding the first point
for i = 2:length(Press_C)
    if Press_C(i, 9) == outlier
        if Press_C(i - 1, 9) == referencevalue
            Press_C(i, 9) = rightvalue;
        end
    end
end

% Replace outlier 1 with 4
for i = 1:length(Press_C) - 30
    if Press_C(i, labelchannel) == 1
        if Press_C(i + 20, labelchannel) == 4;
            Press_C(i:i + 19, labelchannel) = 4;
        end
    end
end

% Replace outlier 4 with 1
for i = 1:length(Press_C)
    if Press_C(i, labelchannel) == 4
        if Press_C(i - 1, labelchannel) == 1;
            Press_C(i, labelchannel) = 1;
        end
    end
end

%% Interactive optimization
% Create a new figure
figure();

% Plot the last column of Press_C
plot(Press_C(:, end));

% Get all the line objects in the current axes
lh = findall(gca, 'type', 'line');

% Get the y-data of the line objects
yc = get(lh, 'ydata');

% Convert the y-data to a matrix
x = yc';

% Update the label channel of Press_C with the new y-data
Press_C(:, 9) = x;

%% Mark phases using the fourth column data of the toe
% Initialize a new column with value 1
Press_C(1:length(Press_C), 10) = 1;

% Threshold for toe data
threshold_toe = 3;

% Index of the toe label channel
toe_label = 10;

% Index of the data channel (3 for toe data, 4 for toe tip data)
data_channel = 4;

% Iterate through each row of Press_C
for i = 1:length(Press_C)
    if Press_C(i, data_channel) >= threshold_toe
        Press_C(i, toe_label) = 3;
    end
end

%% Remove spikes
% Iterate through the data, excluding the first and last points
for i = 2:length(Press_C) - 1
    if Press_C(i, toe_label) == 3 && Press_C(i - 1, toe_label) == -1 && Press_C(i + 1, toe_label) == -1
        Press_C(i, toe_label) = 1;
    end
end
for i = 2:length(Press_C) - 1
    if Press_C(i, toe_label) == -1 && Press_C(i - 1, toe_label) == 3 && Press_C(i + 1, toe_label) == 3
        Press_C(i, toe_label) = 3;
    end
end

%% Remove labels with length less than 30
state = 0;

% Iterate through the data, excluding the first point
for i = 2:length(Press_C)
    if state == 0 && Press_C(i, toe_label) == 3
        state = 1;
        start_point = i;
    end
    if state == 1 && Press_C(i, toe_label) == -1
        end_point = i;
        state = 0;
        if end_point - start_point <= 30
            Press_C(start_point:end_point, toe_label) = -1;
        end
    end
end

% Replace 3 with 2 in the toe label channel
for i = 1:length(Press_C)
    if Press_C(i, toe_label) == 3
        Press_C(i, toe_label) = 2;
    end
end

%% Interactive optimization
% Create a new figure
figure();

% Plot the toe label channel of Press_C
plot(Press_C(:, toe_label));

% Get all the line objects in the current axes
lh = findall(gca, 'type', 'line');

% Get the y-data of the line objects
yc = get(lh, 'ydata');

% Convert the y-data to a matrix
x = yc';

% Update the toe label channel of Press_C with the new y-data
Press_C(:, 10) = x;

%% Synchronization
% If the start value of the synchronization signal is not 0, change this part of the data to 0 and then continue.
a = 1;
b = 10000;
synch = Press_C(:, 8);
synch(a:b, 1) = 0;

% Get the length of the data
t = length(Press_C);

% Find the index where the synchronization signal is 1
for i = 1:t
    if synch(i, 1) == 1
        z = Press_C(i, 1);
        break;
    end
end

% Calculate the length of the remaining data
b = t - i + 1;

% Initialize a matrix to store the processed data
Press_R = zeros(b, 3);

% Copy the relevant columns of Press_C to Press_R
Press_R(:, 1) = Press_C(i:t, 1);
Press_R(:, 2) = Press_C(i:t, 9);
Press_R(:, 3) = Press_C(i:t, 10);

% Adjust the first column of Press_R
Press_R(:, 1) = Press_R(:, 1) - z;

% Save the processed data
save('Press', 'Press_C', 'Press_R');