# Code and Data for Physical and Cognitive Contributions to Fatigue Perception: The Interplay Between Local Muscle Fatigue and Sensory Prediction Error

## EMG_Preprocessing
The `EMG_Preprocessing` folder contains programs for EMG data pre - processing and gait division. These programs are designed to perform a series of operations on EMG signals, including cleaning, filtering, and segmenting. Additionally, they are capable of calculating the median frequency of the EMG signals. The median frequency is an important parameter that can reflect the power distribution of the EMG signal in the frequency domain, which is useful for analyzing muscle fatigue and activity patterns. After pre - processing, the data can be further used to classify different gait phases. The pre - processed data can be used for further analysis.
## Experimental_Arrangement
The `Experimental_Arrangement` folder includes programs for randomly assigning experimental arrangements to each subject. It also contains Temporal Error and Spatial Error data. The experimental arrangement programs ensure that each subject participates in different experimental groups in a random order, which helps to reduce experimental bias.

## Regress
The `Regress` folder stores all the regression programs used in the data processing process, as well as programs for calculating model fitting.

## Statistical_Test
The `Statistical_Test` folder contains all the statistical testing programs used in the project. 

## Data
The `Data`  folder contains the data from the figures in the thesis. Each Excel spreadsheet includes two sheets, corresponding to Study 1h and Study 2 respectively. In EMG_MedianFrequency, there are the median frequencies of the rectus femoris muscle and the tibialis anterior muscle before and after each group of experiments. In HeartRate, there are the average heart rate values before and after each group of experiments. Regress contains the residual values, slopes, and model performance data of the partial regression analysis.

## Usage
To use the programs in this project, you need to have Python or MATLAB installed, depending on the programming language used in each program. Make sure to install all the necessary libraries before running the programs.

## Remarks
The primary datasets generated and analyzed during this study are available from the corresponding authors on reasonable request. When applying for the data, requesters need to provide the ethical review documents and sign a data usage agreement. 