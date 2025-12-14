function bottomHatF = filtroBottomHat4Way(img)
    % imgN = imread('utente6.jpg');
    % img = filtroWavelet(imgN,30);
    % h=fspecial('average',2);
    % img=imfilter(img,h);
    % im=img;
    % minimo=min(im(:));
    % massimo= max(im(:));
    % normalizedImg= (im-minimo)*((255- 70)/ (massimo-minimo))+ 70;
    % img=normalizedImg;
    
    n=141; %deve essere dispari (101 sembra buono)
    
    %Orizzontale
    se0=strel('line',n,0);
    tophatFiltered0 = imbothat(img,se0);
    %imwrite(tophatFiltered0,'horizontal.jpg');
    %imshow(tophatFiltered00);
    %figure;
    
    %Verticale
    se90=strel('line',n,90);
    tophatFiltered90=imbothat(img,se90);
    %imwrite(tophatFiltered90,'vertical.jpg');
    %imshow(tophatFiltered90);
    %figure;
    
    
    %45 gradi
    se45=strel('line',n/0.7,45);
    tophatFiltered45=imbothat(img,se45);
    %imwrite(tophatFiltered45,'45degrees.jpg');
    %imshow(tophatFiltered45);
    
    %figure;
    %135 gradi
    se135=strel('line',n/0.7,135);
    tophatFiltered135=imbothat(img,se135);
    %imwrite(tophatFiltered135,'135degrees.jpg');
    %imshow(tophatFiltered135);
    
    im1=imadd(tophatFiltered0,tophatFiltered90);
    im2=imadd(tophatFiltered45,tophatFiltered135);
    bottomHatF=imadd(im1,im2);

end
