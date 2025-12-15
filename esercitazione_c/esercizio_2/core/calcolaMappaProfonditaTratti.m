function matriceOutput = calcolaMappaProfonditaTratti(matriceZXY, outDir, baseName, sliceIds)
    % CALCOLAMATRICEPROFONDITATRATTI si occupa di sommare lungo Z la matrice di input contenente i template e salvare i risultati

    if nargin < 4
        sliceIds = [];
    end

    matriceOutput = squeeze(sum(matriceZXY, 1));  % rows × cols (conteggi profondità)

    % Salvataggio MAT
    save(fullfile(outDir, baseName + ".mat"), "matriceOutput", "sliceIds");

    % Salvataggio JPG grayscale normalizzato
    imwrite(mat2gray(matriceOutput), fullfile(outDir, baseName + ".jpg"));

    % Salvataggio JPG a colori con colorbar
    fig = figure("Visible","off");
    imagesc(matriceOutput);
    axis image off;
    colormap(jet);
    colorbar;

    maxV = max(matriceOutput(:));
    if maxV <= 0
        clim([0 1]);
    else
        clim([0 maxV]);
    end

    exportgraphics(gca, fullfile(outDir, strcat(baseName + "_color.jpg")));
    close(fig);
end

