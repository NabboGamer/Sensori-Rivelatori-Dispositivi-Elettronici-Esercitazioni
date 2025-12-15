function matriceOutput = filtraggioInProfondita(matriceZXY, sizeNeighboorhod)

    neighboorhod = strel('square', sizeNeighboorhod);

    matriceTemp = matriceZXY > 0;  % garantisco binario
    [depth, rows, cols] = size(matriceTemp);

    matriceOutput = false(depth, rows, cols);

    % Primo slice
    current = squeeze(matriceTemp(1,:,:));
    matriceOutput(1,:,:) = imdilate(current, neighboorhod);

    % Propagazione in profondità
    for i = 1:(depth-1)
        current = squeeze(matriceTemp(i,:,:));
        dilatedCurrent = imdilate(current, neighboorhod);

        next = squeeze(matriceTemp(i+1,:,:));
        filteredNext = dilatedCurrent & next;

        matriceTemp(i+1,:,:) = filteredNext;
        matriceOutput(i+1,:,:) = imdilate(filteredNext, neighboorhod);
    end
end
