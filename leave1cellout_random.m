function [predict_result, accuracy_cell_all, accuracy_spectrum_all, confusionMatrix] = leave1cellout_random(class1, class2, label_all, score_all)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

% label and score of class1
label = [ ...
    label_all(label_all.iteration == class1(1,1) & label_all.BFT == class1(1,2), :); ...
    label_all(label_all.iteration == class2(1,1) & label_all.BFT == class2(1,2), :); ...
    ];
label.cell_all = ones(size(label.cell, 1), 1);
for i = 2:size(label, 1)
    if isequal(label{i, 1:4}, label{i-1, 1:4})
        label.cell_all(i) = label.cell_all(i-1);
    else
        label.cell_all(i) = label.cell_all(i-1) + 1;
    end
end

Ncell_class1 = max(label.cell_all( ...
    label.iteration == class1(1,1) & label.BFT == class1(1,2) ...
    ));
Ncell_all = max(label.cell_all( ...
    label.iteration == class2(1,1) & label.BFT == class2(1,2) ...
    ));

idx = randperm(Ncell_all);
l_random = zeros(size(label.cell_all));
for m = 1:Ncell_class1
    l_random = l_random + (label.cell_all == idx(1,m));
end
for m = Ncell_class1+1 : Ncell_all
    l_random = l_random + 2*(label.cell_all == idx(1,m));
end
label_random = array2table([label.cell_all, l_random], ...
    'VariableNames', {'cell_all', 'class'});

score = [ ...
    score_all(label_all.iteration == class1(1,1) & label_all.BFT == class1(1,2), :); ...
    score_all(label_all.iteration == class2(1,1) & label_all.BFT == class2(1,2), :); ...
    ];

accuracy_cell_all = [];
accuracy_spectrum_all = [];
predict_result = [];
lambda_idx = 0.0001;

for i = 1 : max(label_random.cell_all)
    % Generating training and testing data and labels
    class1_train_idx = ...
        label_random.class == 1 & ...
        label_random.cell_all ~= i;
    class2_train_idx = (...
        label_random.class == 2 & ...
        label_random.cell_all ~= i);
    size_class = min(sum(class1_train_idx), sum(class2_train_idx));
    
    X_train = [...
        datasample(score(class1_train_idx, :), size_class, 1, 'Replace', false); ...
        datasample(score(class2_train_idx, :), size_class, 1, 'Replace', false)...
        ];
    Y_train = [ones(size_class, 1); 2*ones(size_class, 1)];
    X_test = score(label_random.cell_all == i, :);
    Y_test = label_random.class(label_random.cell_all == i);
    
%     Mdl = fitclinear(X_train, Y_train,...
%     'Learner', 'logistic', 'Regularization', 'lasso',...
%     'Lambda', lambda_idx);
    Mdl = fitclinear(X_train, Y_train,...
    'Learner', 'logistic', 'Regularization', 'lasso',...
    'Lambda', lambda_idx);

    pred = predict(Mdl, X_test);
    predict_result = [...
        predict_result; ...
        [size(pred, 1), sum(pred == Y_test) / size(pred, 1)]...
        ];
    
    accuracy_cell = mean(predict_result(:, 2));
    accuracy_spectrum = ...
        sum(predict_result(:, 1) .* predict_result(:, 2)) / ...
        sum(predict_result(:, 1));
    accuracy_cell_all = [accuracy_cell_all; accuracy_cell];
    accuracy_spectrum_all = [accuracy_spectrum_all; accuracy_spectrum];
    
end


% plot confusion matrix
t = 0.5;
confusionMatrix = [ ...
    0, 0, 0; ...
    0, 0, 0 ...
    ];

% Ncell_class1 = max(label.cell_all( ...
%     label.iteration == class1(1,1) & label.BFT == class1(1,2) ...
%     ));
% Ncell_all = max(label.cell_all( ...
%     label.iteration == class2(1,1) & label.BFT == class2(1,2) ...
%     ));

for i = 1 : Ncell_class1
    if predict_result(i, 2) > t
        confusionMatrix(1,1) = confusionMatrix(1,1) + 1;
    elseif predict_result(i, 2) < 1-t
        confusionMatrix(1,3) = confusionMatrix(1,3) + 1;
    else
        confusionMatrix(1,2) = confusionMatrix(1,2) + 1;
    end
end

for i = (Ncell_class1 + 1) : Ncell_all
    if predict_result(i, 2) > t
        confusionMatrix(2,1) = confusionMatrix(2,1) + 1;
    elseif predict_result(i, 2) < 1-t
        confusionMatrix(2,3) = confusionMatrix(2,3) + 1;
    else
        confusionMatrix(2,2) = confusionMatrix(2,2) + 1;
    end
end


end

