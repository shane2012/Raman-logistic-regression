function [spectra_all, label_all] = processSlide(folderName)
%processSlide process the spectra from each slide.
%   Input:
%   folderName is a string of the name of the folder containing spectra in
%   .txt format. In the folder there must be a background signal file named
%   as 'yyyymmdd_background.txt'.

load('wavenumber.mat', 'wavenumber');


datalist = dir(folderName);

% Acquire background spectra

bg_idx = 0;
for i = 3:length(datalist)
    C = strsplit(datalist(i).name(1 : end-4), '_');
    if strcmp(C{5}, 'background')
        bg = readtable(datalist(i).name);
        bg = table2array(bg);
        bg_idx = 1;
    end
end

if bg_idx == 0
    error('Background spectra not in the folder!');
end

bg_interp = [];

for i = 2 : size(bg, 1)
    s = interp1(bg(1, 3:end), bg(i, 3:end), wavenumber);
    bg_interp = [bg_interp; s];
end

background = mean(normalize(bg_interp, 2, 'norm'));


% Generate the label for each spectrum

spectra_all = [];
label_all = cell2table(cell(0,3), 'VariableNames', {'BFT', 'slide', 'cell'});

for i = 1:length(datalist)
    disp(['Processing: ', datalist(i).name]);
    C = strsplit(datalist(i).name(1 : end-4), '_');
    
    if size(C,2) ~= 5
        disp([datalist(i).name, ' not processed.']);
        continue
    end
    
    if strcmp(C{5}, 'background')
        disp('This is the background spectra!');
        continue
    end
    
    if strcmp(C{3}, 'BFT')
        label = table(1, str2double(C{4}), str2double(C{5}),...
            'VariableNames', {'BFT', 'slide', 'cell'});
    elseif strcmp(C{3}, 'con')
        label = table(0, str2double(C{4}), str2double(C{5}),...
            'VariableNames', {'BFT', 'slide', 'cell'});
    else
        disp('Wrong label in the file name: ', datalist(i).name);
        break
    end
    
    spectra = readtable(datalist(i).name);
    spectra = table2array(spectra);
    wavenumber_current = spectra(1, 3:end);
    rows = sum(spectra(2:end, 1) == spectra(2, 1));
    columns = sum(spectra(2:end, 2) == spectra(2, 2));
    
    spectra = spectra(2:end, 3:end);
    
    spectra_cell = zeros(size(spectra, 1), size(wavenumber, 2));
    filter_index = zeros(size(spectra, 1), 1);
    
    for j = 1 : size(spectra, 1)

        % Processing on each spectrum
        
        spectrum = spectra(j,:);
        if i == 3 && j == 1
            fSpectrum = figure;
            plot(wavenumber_current, spectrum);
            hold on;
        end
        
        % Interpolation to get the same wavenumber 
        spectrum = interp1(wavenumber_current, spectrum, wavenumber);
        if i == 3 && j == 1
            plot(wavenumber, spectrum);
        end
        
        % Background removal using signal from quartz slide
        [spectrum, ~] = berger(spectrum, background, 5);
        if i == 3 && j == 1
            plot(wavenumber, spectrum);
        end        
        
        % Smoothing using S-Golay method
        spectrum = smooth(spectrum, 15, 'sgolay', 7)';
        if i == 3 && j == 1
            plot(wavenumber, spectrum);
        end
        
        spectra_cell(j, :) = spectrum;
        filter_index(j, 1) = mean(spectrum(1, 499:538));

        
    end

        
    % Filtering out cell signals using some criteria
    filter_mask = filter_index > 50;
    if i == 3
        fSpectra = figure;
        subplot(1,2,1);
        plot(wavenumber, spectra_cell);
        subplot(1,2,2);
        plot(wavenumber, spectra_cell(filter_mask, :));
        
        filter_map = reshape(filter_index, [rows, columns]);
        mask_map = reshape(filter_mask, [rows, columns]);
        mask_map = double(mask_map);
        fCell = figure;
        subplot(1,2,1);
        heatmap(filter_map);
        colormap jet;
        subplot(1,2,2);
        heatmap(mask_map);
        colormap jet;
    end
    
    spectra_all = [spectra_all; spectra_cell(filter_mask, :)];
    label_all = [label_all; repmat(label, sum(filter_mask), 1)];

end

end
