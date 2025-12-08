function Y = filtroDiLee(R, sz)
    %FILTRODILEE è una implementazione in MATLAB del filtro di Lee per immagini

    % rif: https://www.imageeprocessing.com/2020/07/lee-filter-using-matlab_16.html
    % R è l'immagine di riferimento (Reference Image)
    % E è l'immagine di errore o rumorosa (Error or Noisy Image)
    % K è il kernel o finestra (Kernel or Window)
    % Y è l'immagine in uscita (Output Image)
    
    % Y = mean(K) + W * (C - mean(K));
    % W = variance(K) / (variance(K) + variance(R))
    
    % Definisce il tipo (conversione a double)
    R = double(R);
    
    % Prealloca la matrice di output
    Y = zeros(size(R));
    mn = round((sz-1)/2);
    Tot = sz(1,1) * sz(1,2);
    EImg = padarray(R, mn);
    
    % Varianza dell'immagine di riferimento
    Rvar = var(R(:));
    
    Indx = floor(median(1:Tot));
    for i = 1:size(R,1)
        for j = 1:size(R,2)
            K = EImg(i:i+sz(1,1)-1, j:j+sz(1,2)-1);
            varK = var(K(:));
            meanK = mean(K(:));
            W = varK ./ (varK + Rvar);
           
            Y(i,j) = meanK + W * (K(Indx) - meanK);
        end
    end
    
    Y = uint8(Y);
end
