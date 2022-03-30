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

%% Use only the selected wavenumber
clear;
load('label_all.mat');
load('spectra_all.mat');
load('wavenumber.mat');
spectra_norm = normalize(spectra_all, 2, 'norm');

wn_selected = [807, 831, 911, 1157, 1165, 1351, 1605, 1662, ...
    997, 1123, 1238, 1312, 1331, 1579, 1637, 1662];
wn_index = NaN(1, size(wn_selected, 2));
spectra_selected = NaN(size(spectra_norm, 1), size(wn_selected, 2));
for l = 1 : size(wn_selected, 2)
    [n,wn] = min(abs(wavenumber - wn_selected(1,l)));
    wn_index(1, l) = wn;
    spectra_selected(:,l) = mean(spectra_norm(:,wn-2:wn+2),2);
end

disp('Use the selected wavenumbers.');
disp('Primary Control vs Primary BFT');
[a, ~, ~, confusionMatrix] = leave1cellout([1, 0],[1, 1], label_all, spectra_selected);
disp('Confusion Matrix');
disp(confusionMatrix);

disp('Tumor-derived Control vs Tumor-derived BFT');
[~, ~, ~, confusionMatrix] = leave1cellout([2, 0],[2, 1], label_all, spectra_selected);
disp('Confusion Matrix');
disp(confusionMatrix);

disp('Primary BFT vs Tumor-derived BFT');
[~, ~, ~, confusionMatrix] = leave1cellout([1, 1],[2, 1], label_all, spectra_selected);
disp('Confusion Matrix');
disp(confusionMatrix);

disp('Primary Control vs Tumor-derived Control');
[~, ~, ~, confusionMatrix] = leave1cellout([1, 0],[2, 0], label_all, spectra_selected);
disp('Confusion Matrix');
disp(confusionMatrix);
