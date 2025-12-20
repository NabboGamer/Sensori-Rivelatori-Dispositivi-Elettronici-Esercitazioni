function templateImg = generaTemplateDoG(percorsoImmagine, percorsoProcessing, numStr, scelta)
    
    %% 1) Lettura immagine
    I = imread(percorsoImmagine);
    
    %% 2) Resize immagine
    im1 = imresize(I, [107 160], 'bicubic'); % imposto la grandezza dell'immagine -> 107x160 pixels
    im2 = imresize(im1, 1.4, 'bicubic');     % immagine scalata di un fattore 1.4  -> 150×224 pixels
    imwrite(im2, strcat(percorsoProcessing, '01.resize_', numStr, '.jpg'));
    
    %% 3) Applicazione filtro
    switch scelta
        case "lee"
            filteredImage = filtroDiLee(im2, [9,9]);
            imwrite(filteredImage, strcat(percorsoProcessing, '02.LEE_', numStr, '.jpg'));
            % cprintf('Comments', "Applicato filtro di Lee all'immagine corrente\n");
    
        case "srad"
            filteredImage = filtroSRAD(im2, 40, 1.5, [10 15 40 40]);
            imwrite(filteredImage, strcat(percorsoProcessing, '03.SRAD_', numStr, '.jpg'));
            % cprintf('Comments', "Applicato filtro SRAD all'immagine corrente\n");
    
    end

    %% 5) Applicazione filtro DoG
    gaussian1 = fspecial('gaussian', 11, 15);
    dog1 = conv2(filteredImage, gaussian1, 'same');
    gaussian2 = fspecial('gaussian', 11, 20);
    dog2 = conv2(filteredImage, gaussian2, 'same');
    dogFilterImage2 = dog2 - dog1;
    imwrite(dogFilterImage2, strcat(percorsoProcessing, '04.DoG_', numStr, '.jpg'));
    
    %% 6) Aumento contrasto
    contrastAdjusted = imadjust(dogFilterImage2, stretchlim(dogFilterImage2), []);
    imwrite(contrastAdjusted, strcat(percorsoProcessing, '05.contrast_', numStr, '.jpg'));
    
    %% 7) Binarizzazione
    A = contrastAdjusted;
    meanValue = mean2(A);
    threshold = meanValue * 1.5; %più è alto il fattore di scala meno dettagli saranno presenti
    A_bw = A > threshold;
    imwrite(A_bw, strcat(percorsoProcessing, '06.binarizzation_', numStr, '.jpg'));
    
    %% 8) Cleaning
    CC = bwconncomp(A_bw);
    S = regionprops(CC, 'Area');
    L = labelmatrix(CC);
    BW2 = ismember(L, find([S.Area] >= 50));
    imwrite(BW2, strcat(percorsoProcessing, '07.cleaning_', numStr, '.jpg'));
    
    %% 9) Closing
    se = strel('disk', 3);
    closing = imclose(BW2, se);
    imwrite(closing, strcat(percorsoProcessing, '08.closing_', numStr, '.jpg'));
    
    %% 10) Filling
    filling = imfill(closing, 'holes');
    imwrite(filling, strcat(percorsoProcessing, '09.filling_', numStr, '.jpg'));
    
    %% 11) Thinning
    thinning = bwmorph(filling, 'thin', inf);
    imwrite(thinning, strcat(percorsoProcessing, '10.thinning_', numStr, '.jpg'));
    
    %% 12) Pruning
    pruning = bwmorph(thinning, 'spur', 5);
    imwrite(pruning, strcat(percorsoProcessing, '11.pruning_', numStr, '.jpg'));
    
    %% 13) Cleaning delle linee piccole
    cleanLines = bwareaopen(pruning, 30);
    imwrite(cleanLines, strcat(percorsoProcessing, '12.cleanLines_', numStr, '.jpg'));
    templateImg = cleanLines;
    
    %% 14) Dilatazione
    dilatation_mask = strel('disk', 1);
    dilatedImageDat = imdilate(cleanLines, dilatation_mask);
    imwrite(dilatedImageDat, strcat(percorsoProcessing, '13.dilatation_', numStr, '.jpg'));
    
    %% 15) Sovrapposizione
    rgbImage = cat(3, im2, im2, im2);
    
    [m, n1] = size(im2);
    for i = 1:m
        for j = 1:n1
            if dilatedImageDat(i, j) == 1
                rgbImage(i, j, 1) = 255;
                rgbImage(i, j, 2) = 255;
                rgbImage(i, j, 3) = 255;
            end
        end
    end
    
    imwrite(rgbImage, strcat(percorsoProcessing, '14.sovrapposta_', numStr, '.jpg'));

end
