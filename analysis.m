% Load data
clear;
load('label_all.mat');
load('spectra_all.mat');
load('wavenumber.mat');
spectra_norm = normalize(spectra_all, 2, 'norm');

%%
mean_1st_con = mean(spectra_norm((label_all.iteration == 1 & label_all.BFT == 0), :), 1);
mean_1st_BFT = mean(spectra_norm((label_all.iteration == 1 & label_all.BFT == 1), :), 1);
std_1st_con = std(spectra_norm((label_all.iteration == 1 & label_all.BFT == 0), :), 1);
std_1st_BFT = std(spectra_norm((label_all.iteration == 1 & label_all.BFT == 1), :), 1);
n_1st_con = sum(label_all.iteration == 1 & label_all.BFT == 0);
n_1st_BFT = sum(label_all.iteration == 1 & label_all.BFT == 1);

mean_2nd_con = mean(spectra_norm((label_all.iteration == 2 & label_all.BFT == 0), :), 1);
mean_2nd_BFT = mean(spectra_norm((label_all.iteration == 2 & label_all.BFT == 1), :), 1);
std_2nd_con = std(spectra_norm((label_all.iteration == 2 & label_all.BFT == 0), :), 1);
std_2nd_BFT = std(spectra_norm((label_all.iteration == 2 & label_all.BFT == 1), :), 1);
n_2nd_con = sum(label_all.iteration == 2 & label_all.BFT == 0);
n_2nd_BFT = sum(label_all.iteration == 2 & label_all.BFT == 1);

%% Difference spectrum between parental BFT and control
mean_diff = mean_1st_BFT - mean_1st_con;
std_diff = sqrt(std_1st_con .^ 2 / n_1st_con + std_1st_BFT .^ 2 / n_1st_BFT);
figure;
shadedErrorBar(wavenumber, mean_diff, std_diff);


%% Difference spectrum between tumor-derived BFT and control
mean_diff = mean_2nd_BFT - mean_2nd_con;
std_diff = sqrt(std_2nd_con .^ 2 / n_2nd_con + std_2nd_BFT .^ 2 / n_2nd_BFT);
figure;
shadedErrorBar(wavenumber, mean_diff, std_diff);

%% Difference spectrum between tumor-derived BFT and parental BFT
mean_diff = mean_2nd_BFT - mean_1st_BFT;
std_diff = sqrt(std_1st_BFT .^ 2 / n_1st_BFT + std_2nd_BFT .^ 2 / n_2nd_BFT);
figure;
shadedErrorBar(wavenumber, mean_diff, std_diff);

%% Difference spectrum between tumor-derived control and parental control
mean_diff = mean_2nd_con - mean_1st_con;
std_diff = sqrt(std_1st_con .^ 2 / n_1st_con + std_2nd_con .^ 2 / n_2nd_con);
figure;
shadedErrorBar(wavenumber, mean_diff, std_diff);

%% Difference spectrum between tumor-derived BFT and parental control
mean_diff = mean_2nd_BFT - mean_1st_con;
std_diff = sqrt(std_1st_con .^ 2 / n_1st_con + std_2nd_BFT .^ 2 / n_2nd_BFT);
figure;
shadedErrorBar(wavenumber, mean_diff, std_diff);

%% Compare slides within each class
con_1st_s1 = spectra_norm((label_all.iteration == 1 & label_all.BFT == 0 & label_all.slide == 1), :);
con_1st_s2 = spectra_norm((label_all.iteration == 1 & label_all.BFT == 0 & label_all.slide == 2), :);
con_1st_s3 = spectra_norm((label_all.iteration == 1 & label_all.BFT == 0 & label_all.slide == 3), :);

con_2nd_s1 = spectra_norm((label_all.iteration == 2 & label_all.BFT == 0 & label_all.slide == 1), :);
con_2nd_s2 = spectra_norm((label_all.iteration == 2 & label_all.BFT == 0 & label_all.slide == 2), :);
con_2nd_s3 = spectra_norm((label_all.iteration == 2 & label_all.BFT == 0 & label_all.slide == 3), :);

BFT_1st_s1 = spectra_norm((label_all.iteration == 1 & label_all.BFT == 1 & label_all.slide == 1), :);
BFT_1st_s2 = spectra_norm((label_all.iteration == 1 & label_all.BFT == 1 & label_all.slide == 2), :);
BFT_1st_s3 = spectra_norm((label_all.iteration == 1 & label_all.BFT == 1 & label_all.slide == 3), :);

BFT_2nd_s1 = spectra_norm((label_all.iteration == 2 & label_all.BFT == 1 & label_all.slide == 1), :);
BFT_2nd_s2 = spectra_norm((label_all.iteration == 2 & label_all.BFT == 1 & label_all.slide == 2), :);
BFT_2nd_s3 = spectra_norm((label_all.iteration == 2 & label_all.BFT == 1 & label_all.slide == 3), :);

%%
figure;
plot(wavenumber, mean_1st_BFT - mean_1st_con, ...
    'LineWidth', 2, ...
    'Color', 'Black', ...
    'DisplayName', 'Primary BFT - Control');
hold on;
plot(wavenumber, mean(BFT_1st_s1, 1) - mean(BFT_1st_s2, 1), ...
    'DisplayName', 'Slide1 - Slide2');
plot(wavenumber, mean(BFT_1st_s2, 1) - mean(BFT_1st_s3, 1), ...
    'DisplayName', 'Slide2 - Slide3');
plot(wavenumber, mean(BFT_1st_s3, 1) - mean(BFT_1st_s1, 1), ...
    'DisplayName', 'Slide3 - Slide1');
legend;