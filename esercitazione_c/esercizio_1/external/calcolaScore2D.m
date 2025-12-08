function scoreFinale = calcolaScore2D(mat1,mat2)
    
    %DEFINIAMO I TEMPLATE DA CONFRONTARE
    matMatchA = mat1;
    matMatchB = mat2;
    
    %CALCOLO IL DENOMINATORE DELLA FORMULA CHE SERVE PER CALCOLARE IL
    %MATCHING
    %denom = sum(sum(matMatchA))+sum(sum(matMatchB));
    
    %DILATIAMO IL TEMPLATE A
    B = strel('square', 4); %9
    matMatchA = imdilate(matMatchA,B);
    %matMatchB = bwmorph(BW3,'spur',10);

    dimens=size(matMatchA);
    rigaMatchA=dimens(1);
    colonnaMatchA=dimens(2);
    
    
    %AGGIUNGIAMO 50 RIGHE E 50 COLONNE SOPRA, SOTTO, DESTRA E SINISTRA AL
    %TEMPLATE B
    matriceGrandeB=matMatchB;
    matriceGrandeB=[ zeros(25,colonnaMatchA); matriceGrandeB(:,:)]; % righe aggiunte sopra
    matriceGrandeB=[ matriceGrandeB(:,:); zeros(25,colonnaMatchA)]; % righe aggiunte sotto
    matriceGrandeB=[ zeros(rigaMatchA+50,25), matriceGrandeB(:,:)]; % colonne aggiunte sinistra
    matriceGrandeB=[ matriceGrandeB(:,:), zeros(rigaMatchA+50,25)]; % colonne aggiunte destra


    %CONFRONTO IL TEMPLATE A CON QUELLO B, MUOVENDO B IN MODO TALE DA
    %TROVARE IL MASSIMO MATCHING
    matAppoggioTraslata=zeros(rigaMatchA,colonnaMatchA);
    matFinaleB=matMatchB;
    maxScore=0;
    punteggioScore=0;
      
    denom = 1;
    for angle=-5:5
        matMatchARot=imrotate(matMatchA,angle,'bilinear','crop');
        for i=0:50 %(riga+16-riga+1)
            for j=0:50
                matAppoggioTraslata=matriceGrandeB([i+1:rigaMatchA+i],[j+1:colonnaMatchA+j]);
                punteggioScore=sum(sum(matMatchARot & matAppoggioTraslata));
                if(punteggioScore>maxScore)
                    maxScore=punteggioScore;
                    matFinaleB=matAppoggioTraslata;
                    angoloScore=angle;
                    matMatchARotFinale=matMatchARot;
                    denom = sum(sum(mat1))+sum(sum(matFinaleB));
                    rigaScore=i;
                    colonnaScore=j;
                end
            end
        end
    end    

    %CALCOLO IL PUNTEGGIO MASSIMO DEL MATCHING
    scoreFinale=(maxScore/denom)*2;
end
