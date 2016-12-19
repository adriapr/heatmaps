function trackingStation()

thd_binary = 0.1;
sizeClosing = 5;
showImages = false;

[dirName] = uigetdir();
filesTMP = dir(dirName);
dirName = strcat( dirName, '/');

% remove non-images files
nImages = 0;
% unknownSize = true;

for f = 1:size(filesTMP,1)
    % only read bmp or jpg files 
    if ~filesTMP(f).isdir && ( strcmp(filesTMP(f).name(end-3:end), '.JPG') || strcmp(filesTMP(f).name(end-3:end), '.jpg') )
        nImages = nImages + 1;
        files(nImages) = filesTMP(f);
    end
end

% load first image
imOld = im2single( mean( imread( strcat(dirName, files(1).name) ), 3) ) ./ 255;

[imH imW] = size( imOld );


% preset the filter
se = strel('disk', sizeClosing);

% prepare hot image
hotZones = zeros(size(imOld));

% for i = 2:3
for i = 2:nImages
    
    fprintf('(%4d) - %s', i, files(i).name); tic;

    % load new image
    imNew = im2single( mean( imread( strcat(dirName, files(i).name) ), 3) ) ./ 255;

    % substract one from the other
    diffIM = abs(imNew - imOld);
    
    % threshold substraction to detect movement
    diffBIN = im2bw(diffIM, thd_binary);
    
    % apply some opening
    imBLOBS = imopen(diffBIN, se);
    
    hotZones = hotZones + imBLOBS;
    
%     
%     % segment by regions and get properties
%     L = bwlabel(imBLOBS);
%     s  = regionprops(L, 'Extrema', 'Area');
%     
%     weights = cat(1, s.Area);
%     
%     bottom = zeros(size(weights,1), 2);
% 
%     for r = 1:size(weights,1)
%         bl = s(r).Extrema(5,:);
%         br = s(r).Extrema(6,:);
%         
%         bottom(r,:) = round((bl + br) / 2);
%         
%         % check borders
%         if bottom(r,1) < 1
%             bottom(r,1) = 1;
%         end 
%         if bottom(r,1) > imW
%             bottom(r,1) = imW;
%         end
%         if bottom(r,2) < 1
%             bottom(r,2) = 1;
%         end 
%         if bottom(r,2) > imH
%             bottom(r,2) = imH;
%         end
%         
%         % add to the accumulation matrix
%         hotZones( bottom(r,2), bottom(r,1) ) = hotZones( bottom(r,2), bottom(r,1) ) + weights(r);
%     end
    
    if showImages
        figure; imshow(imNew);
        figure; imshow(diffIM);
        figure; imshow(diffBIN);
        figure; imshow(imBLOBS);
%         hold on; plot(bottom(:,1), bottom(:,2), 'rx');
%         figure; imagesc(hotZones);
    end
    
    % update old image
    imOld = imNew;
    
    fprintf(' - %.4f sc\n', toc);
end

% smooth hotZones largely
% fil1 = fspecial('gaussian', 40, 8);
% fil1 = fspecial('gaussian', 25, 4);

% zones = conv2(hotZones, fil1, 'same');

figure; imagesc(hotZones);
% figure; imagesc(zones);

zonesBW = hotZones ./ max(max(hotZones));
figure; imshow(zonesBW);


save tmp5 zonesBW hotZones

['debug'];



