function [scoreFinale, matFinaleB, angoloScore, rigaScore, colonnaScore] = calcolaScore3D(mat1,mat2,alpha)
    %DEFINIAMO I TEMPLATE DA CONFRONTARE
    %mat1=mat1.ans;
    %mat2=mat2.ans;
    
    matMatchA = mat1;
    matMatchB = mat2;

    %DILATIAMO IL TEMPLATE A 
    %B = strel('square', 4);
    %matMatchA = imdilate(full(matMatchA),B);
    %matMatchA=sparse(matMatchA);
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
			   %punteggioScore=sum(sum(matMatchARot & matAppoggioTraslata));
                punteggioScore=sum(sum(abs(matMatchARot - matAppoggioTraslata)<alpha & matMatchARot>0 & matAppoggioTraslata>0)); %(A==B & A~=0 & B~=0)
                if(punteggioScore>maxScore)
                    maxScore=punteggioScore;
                    matFinaleB=matAppoggioTraslata;
                    angoloScore=angle;
                    matMatchARotFinale=matMatchARot;
                    denom = sum(sum(mat1>0))+sum(sum(matFinaleB>0));
                    rigaScore=i;
                    colonnaScore=j;
                end
            end
        end
    end    

    %CALCOLO IL PUNTEGGIO MASSIMO DEL MATCHING
    scoreFinale=(maxScore/denom)*2;
end