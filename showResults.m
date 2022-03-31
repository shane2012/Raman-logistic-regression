% Load data
clear;
load('label_all.mat');
load('spectra_all.mat');
load('wavenumber.mat');
spectra_norm = normalize(spectra_all, 2, 'norm');
[~, score_all, ~] = pca(spectra_norm, 'NumComponents', 20);

% Classification
disp('Primary Control vs Primary BFT');
[a, ~, ~, confusionMatrix] = leave1cellout([1, 0],[1, 1], label_all, score_all);
disp('Confusion Matrix');
disp(confusionMatrix);

disp('Tumor-derived Control vs Tumor-derived BFT');
[~, ~, ~, confusionMatrix] = leave1cellout([2, 0],[2, 1], label_all, score_all);
disp('Confusion Matrix');
disp(confusionMatrix);

disp('Primary BFT vs Tumor-derived BFT');
[~, ~, ~, confusionMatrix] = leave1cellout([1, 1],[2, 1], label_all, score_all);
disp('Confusion Matrix');
disp(confusionMatrix);

disp('Primary Control vs Tumor-derived Control');
[~, ~, ~, confusionMatrix] = leave1cellout([1, 0],[2, 0], label_all, score_all);
disp('Confusion Matrix');
disp(confusionMatrix);

%% Classification using randomized labels
clear;
load('label_all.mat');
load('spectra_all.mat');
load('wavenumber.mat');
spectra_norm = normalize(spectra_all, 2, 'norm');
[~, score_all, ~] = pca(spectra_norm, 'NumComponents', 20);

disp('Primary Control vs Primary BFT');
[a, ~, ~, confusionMatrix] = leave1cellout_random([1, 0],[1, 1], label_all, score_all);
disp('Confusion Matrix');
disp(confusionMatrix);

disp('Tumor-derived Control vs Tumor-derived BFT');
[~, ~, ~, confusionMatrix] = leave1cellout_random([2, 0],[2, 1], label_all, score_all);
disp('Confusion Matrix');
disp(confusionMatrix);

disp('Primary BFT vs Tumor-derived BFT');
[~, ~, ~, confusionMatrix] = leave1cellout_random([1, 1],[2, 1], label_all, score_all);
disp('Confusion Matrix');
disp(confusionMatrix);

disp('Primary Control vs Tumor-derived Control');
[~, ~, ~, confusionMatrix] = leave1cellout_random([1, 0],[2, 0], label_all, score_all);
disp('Confusion Matrix');
disp(confusionMatrix);
