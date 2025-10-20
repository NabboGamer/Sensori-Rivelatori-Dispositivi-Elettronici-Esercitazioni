% Questo script implementa la progettazione di un trasduttore 
% piezoelettrico a larga banda

addpath('../utility/');
addpath('../../core/');
evalin('base', 'clear'), close all; clc;

[areaFaccia, l, rho, ~, h33, ~, ~, v, f, omega, ~, C0] = ceramicPicker();

% Calcolo l'impedenza acustica specifica della ceramica
z1 = 400;   % Aria
zB = 7e+06; % Il Backing è fatto solitamente di materiali come il tungsteno-epossidico che ha una impedenza acustica specifica tra [5,10] MRayl
z_piezo = rho * v; % N.B.: Usare PZ27 per questa applicazione
z_load = 1.5e+06;  % Acqua
z2 = z_load;

%% Funzione di trasferimento in trasmissione e in ricezione della ceramica con backing
% Calcolo l'impedenza acustica della ceramica
Zel = 1e+06;
Z1 = areaFaccia*z1;
ZB = areaFaccia*zB;
ZoD = areaFaccia * z_piezo;
Z2 = areaFaccia*z2;

% Calcolo la matrice A(3x3)(indipendente rispetto alle impedenze dei materiali 
% presenti sulle porte) e B(2x2) senza Backing e con l'aggiunta del Backing
A = calcolaMatriceA(ZoD, omega, v, l, h33, C0);
B_without_backing = calcolaMatriceB(A, Z1);
B_with_backing = calcolaMatriceB(A, ZB);

[Zin_without_backing, FTT_without_backing, FTR_without_backing] = calcolaFunzioniDiTrasferimento(B_without_backing, Z2, Zel);
[Zin_with_backing, FTT_with_backing, FTR_with_backing] = calcolaFunzioniDiTrasferimento(B_with_backing, Z2, Zel);

legendTitle = strcat("Backing made of Tungsten Epoxy (7.0 [MRayl])");
figure(1);
stampaGrafici(f, Zin_without_backing{1}, Zin_without_backing{2}, "Comparing Zin without and with Backing", 'blue', "Zin", "Zin", " without backing", legendTitle);
hold on;
stampaGrafici(f, Zin_with_backing{1}, Zin_with_backing{2}, "Comparing Zin without and with Backing", 'orange', "Zin", "Zin", " with backing", legendTitle);

figure(2);
stampaGrafici(f, FTT_without_backing{1}, FTT_without_backing{2}, "Comparing TTF without and with Backing", 'blue', "TTF", "TTF", " without backing", legendTitle);
hold on;
stampaGrafici(f, FTT_with_backing{1}, FTT_with_backing{2}, "Comparing TTF without and with Backing", 'orange', "TTF", "TTF", " with backing", legendTitle);

% figure(3)
% stampaGrafici(f, FTR_without_backing{1}, FTR_without_backing{2}, "Comparing RTF without and with Backing", 'blue', "RTF", "RTF", " without backing");
% hold on;
% stampaGrafici(f, FTR_with_backing{1}, FTR_with_backing{2}, "Comparing RTF without and with Backing", 'orange', "RTF", "RTF", " with backing");

%% Funzione di trasferimento in trasmissione e in ricezione della ceramica con backing e matching plate

% Calcolo l'impedenza acustica specifica della del piatto
% (utilizzando la formula per massimizzare la banda passante)
% 
% Usando come piezo il PZ27 e come carico a destra l'acqua ottengo una z_plate
% circa di 5.3e+06. Osservando la tabella 4 nel paper "A Review of Acoustic 
% Impedance Matching Techniques for Piezoelectric Sensors and Transducers" 
% ricavo che il materiale E-Solder 3022 ha l'impedenza molto vicina a
% quest'ultima (5.92e+06) quindi decido di utilizzarlo per la creazione del
% piatto. Di conseguenza prelevo dalla tabella la densità di tale materiale.
z_plate = (2 * (z_load^2) * z_piezo ) ^ (1/3);
rho_plate = 1850; % Kg/m^3
v_plate = z_plate/rho_plate; % Ricavata invertendo la formula dell'impedenza acustica specifica del materiale

% Calcolo l'impedenza acustica del piatto
ZoP = areaFaccia * z_plate;

% La frequenza a cui si ha il matching si indica con f0 e come detto nelle
% slide è la frequenza in cui la FTT è massima
[~, index] = max(FTT_with_backing{1});
f0 = f(index);

% Quindi calcolo i parametri specifici del piatto
lambda_plate = v_plate / f0;
l_plate = lambda_plate / 4;
k_plate = omega ./ v_plate;

% Calcolo matrice M
M = calcolaMatriceM(ZoP, k_plate, l_plate);

%--------------------------------------------------------------------------------%
% Le dimostrazioni che portano alle formule successive(Zeq, FTT) non sono 
% presenti nè nelle dispense nè nelle slide fornite dal prof.(in quest'ultime vi 
% sono solo delle intuizioni) quindi le ho sviluppate a mano per intero. Tali
% dimostrazioni sono presenti nel pdf "Modellazione teorica di un trasduttore 
% elettromeccanico a larga banda".

Zeq = M{1,1} - ( (M{1,2} .^ 2) ./ (Z2 + M{1,1}) );

[Zin_without_backing_with_plate, FTT_without_backing_pzt, ~]   = calcolaFunzioniDiTrasferimento(B_without_backing, Zeq, Zel);
[Zin_with_backing_with_plate, FTT_with_backing_pzt, ~] = calcolaFunzioniDiTrasferimento(B_with_backing, Zeq, Zel);
% Trasformo in vettori di numeri complessi per effettuare più comodamente il calcolo successivo
FTT_without_backing_pzt = FTT_without_backing_pzt{1} .* exp(1j*deg2rad(FTT_without_backing_pzt{2}));
FTT_with_backing_pzt = FTT_with_backing_pzt{1} .* exp(1j*deg2rad(FTT_with_backing_pzt{2}));

FTT_plate = ( M{1,2} .* Z2 ) ./ ( M{1,1}.*Z2 + M{1,1}.^2 - M{1,2}.^2);

FTT_without_backing_with_plate = FTT_without_backing_pzt .* FTT_plate;
FTT_with_backing_with_plate = FTT_with_backing_pzt .* FTT_plate;

[moduloFTT_without_backing_with_plate, faseFTT_without_backing_with_plate] = calcolaModuloEFase(FTT_without_backing_with_plate, true, true);
FTT_without_backing_with_plate = {moduloFTT_without_backing_with_plate, faseFTT_without_backing_with_plate};
[moduloFTT_with_backing_with_plate, faseFTT_with_backing_with_plate] = calcolaModuloEFase(FTT_with_backing_with_plate, true, true);
FTT_with_backing_with_plate = {moduloFTT_with_backing_with_plate, faseFTT_with_backing_with_plate};

l_plate_scaled = l_plate * 1e+03;
l_plate_scaled = round(l_plate_scaled, 1);
legendTitle = strcat("Matching Plate made of E-Solder 3022 (", string(l_plate_scaled), " [mm])");
figure(4)
stampaGrafici(f, Zin_without_backing_with_plate{1}, Zin_without_backing_with_plate{2}, "Comparing Zin without and with Backing adding the matching plate", 'blue', "Zin", "Zin", " without backing with plate", legendTitle);
hold on;
stampaGrafici(f, Zin_with_backing_with_plate{1}, Zin_with_backing_with_plate{2}, "Comparing Zin without and with Backing adding the matching plate", 'orange', "Zin", "Zin", " with backing with plate", legendTitle);
figure(5)
stampaGrafici(f, FTT_without_backing_with_plate{1}, FTT_without_backing_with_plate{2}, "Comparing TTF without and with Backing adding the matching plate", 'blue', "TTF", "TTF", " without backing with plate", legendTitle);
hold on;
stampaGrafici(f, FTT_with_backing_with_plate{1}, FTT_with_backing_with_plate{2}, "Comparing TTF without and with Backing adding the matching plate", 'orange', "TTF", "TTF", " with backing with plate", legendTitle);

%% Calcolo indici di banda passante per i 4 casi possibili

% Casi possibili(tabella a doppia entrata):
% 
% +---------+-----------+-----------+ 
% |         | X BACKING | V BACKING |
% +---------+-----------+-----------+    
% | X PLATE |   XB-XP   |   VB-XP   |
% +---------+-----------+-----------+
% | V PLATE |   XB-VP   |   VB-VP   |
% +---------+-----------+-----------+
% 

% Calcolo il valore massimo del modulo della FTT
A_max_without_backing_without_plate = max(FTT_without_backing{1});

A_max_with_backing_without_plate = max(FTT_with_backing{1});

A_max_without_backing_with_plate = max(moduloFTT_without_backing_with_plate);

A_max_with_backing_with_plate = max(moduloFTT_with_backing_with_plate);

% Calcolo il valore del modulo della FTT a -3dB e a -6dB
A_3dB_without_backing_without_plate = A_max_without_backing_without_plate - 3;
A_6dB_without_backing_without_plate = A_max_without_backing_without_plate - 6;

A_3dB_with_backing_without_plate = A_max_with_backing_without_plate - 3;
A_6dB_with_backing_without_plate = A_max_with_backing_without_plate - 6;

A_3dB_without_backing_with_plate = A_max_without_backing_with_plate - 3;
A_6dB_without_backing_with_plate = A_max_without_backing_with_plate - 6;

A_3dB_with_backing_with_plate = A_max_with_backing_with_plate - 3;
A_6dB_with_backing_with_plate = A_max_with_backing_with_plate - 6;

% Trovo gli indici delle frequenze a cui l'ampiezza è maggiore o uguale ad A_3dB e ad A_6dB
indices_3db_without_backing_without_plate = find(FTT_without_backing{1} >= A_3dB_without_backing_without_plate);
indices_6db_without_backing_without_plate = find(FTT_without_backing{1} >= A_6dB_without_backing_without_plate);

indices_3db_with_backing_without_plate = find(FTT_with_backing{1} >= A_3dB_with_backing_without_plate);
indices_6db_with_backing_without_plate = find(FTT_with_backing{1} >= A_6dB_with_backing_without_plate);

indices_3db_without_backing_with_plate = find(moduloFTT_without_backing_with_plate >= A_3dB_without_backing_with_plate);
indices_6db_without_backing_with_plate = find(moduloFTT_without_backing_with_plate >= A_6dB_without_backing_with_plate);

indices_3db_with_backing_with_plate = find(moduloFTT_with_backing_with_plate >= A_3dB_with_backing_with_plate);
indices_6db_with_backing_with_plate = find(moduloFTT_with_backing_with_plate >= A_6dB_with_backing_with_plate);

% Calcolo fl(f low) e fh(f high)(ovvero la frequenza più bassa e più alta alla quale la risposta resta sopra una certa soglia) a -3 dB e a -6dB
fl_3dB_without_backing_without_plate = f(indices_3db_without_backing_without_plate(1));
fh_3dB_without_backing_without_plate = f(indices_3db_without_backing_without_plate(end));
fl_6dB_without_backing_without_plate = f(indices_6db_without_backing_without_plate(1));
fh_6dB_without_backing_without_plate = f(indices_6db_without_backing_without_plate(end));

fl_3dB_with_backing_without_plate = f(indices_3db_with_backing_without_plate(1));
fh_3dB_with_backing_without_plate = f(indices_3db_with_backing_without_plate(end));
fl_6dB_with_backing_without_plate = f(indices_6db_with_backing_without_plate(1));
fh_6dB_with_backing_without_plate = f(indices_6db_with_backing_without_plate(end));

fl_3dB_without_backing_with_plate = f(indices_3db_without_backing_with_plate(1));
fh_3dB_without_backing_with_plate = f(indices_3db_without_backing_with_plate(end));
fl_6dB_without_backing_with_plate = f(indices_6db_without_backing_with_plate(1));
fh_6dB_without_backing_with_plate = f(indices_6db_without_backing_with_plate(end));

fl_3dB_with_backing_with_plate = f(indices_3db_with_backing_with_plate(1));
fh_3dB_with_backing_with_plate = f(indices_3db_with_backing_with_plate(end));
fl_6dB_with_backing_with_plate = f(indices_6db_with_backing_with_plate(1));
fh_6dB_with_backing_with_plate = f(indices_6db_with_backing_with_plate(end));

% Calcolo fc(f central)(ovvero la frequenza "al centro" della banda delimitata da fl e fh) a -3 dB e a -6dB
fc_3dB_without_backing_without_plate = (fl_3dB_without_backing_without_plate + fh_3dB_without_backing_without_plate)/2;
fc_6dB_without_backing_without_plate = (fl_6dB_without_backing_without_plate + fh_6dB_without_backing_without_plate)/2;

fc_3dB_with_backing_without_plate = (fl_3dB_with_backing_without_plate + fh_3dB_with_backing_without_plate) / 2;
fc_6dB_with_backing_without_plate = (fl_6dB_with_backing_without_plate + fh_6dB_with_backing_without_plate) / 2;

fc_3dB_without_backing_with_plate = (fl_3dB_without_backing_with_plate + fh_3dB_without_backing_with_plate)/2;
fc_6dB_without_backing_with_plate = (fl_6dB_without_backing_with_plate + fh_6dB_without_backing_with_plate)/2;

fc_3dB_with_backing_with_plate = (fl_3dB_with_backing_with_plate + fh_3dB_with_backing_with_plate)/2;
fc_6dB_with_backing_with_plate = (fl_6dB_with_backing_with_plate + fh_6dB_with_backing_with_plate)/2;

% Calcolo la FBW(Fractional BandWidth)(ovvero quanto è larga la banda rispetto alla sua frequenza centrale espressa in %)
FBW_3dB_without_backing_without_plate = ( (fh_3dB_without_backing_without_plate - fl_3dB_without_backing_without_plate) / fc_3dB_without_backing_without_plate ) * 100;
FBW_6dB_without_backing_without_plate = ( (fh_6dB_without_backing_without_plate - fl_6dB_without_backing_without_plate) / fc_6dB_without_backing_without_plate ) * 100;

FBW_3dB_with_backing_without_plate = ( (fh_3dB_with_backing_without_plate - fl_3dB_with_backing_without_plate) / fc_3dB_with_backing_without_plate ) * 100;
FBW_6dB_with_backing_without_plate = ( (fh_6dB_with_backing_without_plate - fl_6dB_with_backing_without_plate) / fc_6dB_with_backing_without_plate ) * 100;

FBW_3dB_without_backing_with_plate = ( (fh_3dB_without_backing_with_plate - fl_3dB_without_backing_with_plate) / fc_3dB_without_backing_with_plate ) * 100;
FBW_6dB_without_backing_with_plate = ( (fh_6dB_without_backing_with_plate - fl_6dB_without_backing_with_plate) / fc_6dB_without_backing_with_plate ) * 100;

FBW_3dB_with_backing_with_plate = ( (fh_3dB_with_backing_with_plate - fl_3dB_with_backing_with_plate) / fc_3dB_with_backing_with_plate ) * 100;
FBW_6dB_with_backing_with_plate = ( (fh_6dB_with_backing_with_plate - fl_6dB_with_backing_with_plate) / fc_6dB_with_backing_with_plate ) * 100;

% Stampo i valori trovati per la FBW
cprintf('Text',"\n");
cprintf('Comments',"\nBanda Frazionaria a -3dB senza backing senza plate: FBW=%0.2f%%", string(FBW_3dB_without_backing_without_plate));
cprintf('Comments',"\nBanda Frazionaria a -6dB senza backing senza plate: FBW=%0.2f%%", string(FBW_6dB_without_backing_without_plate));
cprintf('Text',"\n");
cprintf('Comments',"\nBanda Frazionaria a -3dB con backing senza plate: FBW=%0.2f%%", string(FBW_3dB_with_backing_without_plate));
cprintf('Comments',"\nBanda Frazionaria a -6dB con backing senza plate: FBW=%0.2f%%", string(FBW_6dB_with_backing_without_plate));
cprintf('Text',"\n");
cprintf('Comments',"\nBanda Frazionaria a -3dB senza backing con plate: FBW=%0.2f%%", string(FBW_3dB_without_backing_with_plate));
cprintf('Comments',"\nBanda Frazionaria a -6dB senza backing con plate: FBW=%0.2f%%", string(FBW_6dB_without_backing_with_plate));
cprintf('Text',"\n");
cprintf('Comments',"\nBanda Frazionaria a -3dB con backing con plate: FBW=%0.2f%%", string(FBW_3dB_with_backing_with_plate));
cprintf('Comments',"\nBanda Frazionaria a -6dB con backing con plate: FBW=%0.2f%%", string(FBW_6dB_with_backing_with_plate));
cprintf('Text',"\n");

% Sezione utile per il disegno sul grafico delle bande passanti.
% Commentato poichè rendeva il grafico colmo di linee e incomprensibile.

% fig = gcf;                          % ultimo figure attivo
% axs = findall(fig, 'Type', 'axes'); % tutti gli axes
% ax1 = axs(end);                     % il "primo" subplot creato è l'ultimo della lista
% hold(ax1, 'on');
% color1 = "#ed20e6";
% color2 = "#0ff21a";
% 
% xl = fl_3dB_without_backing_with_plate/1e+03;
% yl = moduloFTT_without_backing_with_plate(indices_3db_without_backing_with_plate(1));
% xh = fh_3dB_without_backing_with_plate/1e+03;
% yh = moduloFTT_without_backing_with_plate(indices_3db_without_backing_with_plate(end));
% stampaLargezzaDiBanda(ax1, xl, yl, xh, yh, color1)
% xl = fl_6dB_without_backing_with_plate/1e+03;
% yl = moduloFTT_without_backing_with_plate(indices_6db_without_backing_with_plate(1));
% xh = fh_6dB_without_backing_with_plate/1e+03;
% yh = moduloFTT_without_backing_with_plate(indices_6db_without_backing_with_plate(end));
% stampaLargezzaDiBanda(ax1, xl, yl, xh, yh, color2);
% 
% xl = fl_3dB_with_backing_with_plate/1e+03;
% yl = moduloFTT_with_backing_with_plate(indices_3db_with_backing_with_plate(1));
% xh = fh_3dB_with_backing_with_plate/1e+03;
% yh = moduloFTT_with_backing_with_plate(indices_3db_with_backing_with_plate(end));
% stampaLargezzaDiBanda(ax1, xl, yl, xh, yh, color1)
% xl = fl_6dB_with_backing_with_plate/1e+03;
% yl = moduloFTT_with_backing_with_plate(indices_6db_with_backing_with_plate(1));
% xh = fh_6dB_with_backing_with_plate/1e+03;
% yh = moduloFTT_with_backing_with_plate(indices_6db_with_backing_with_plate(end));
% stampaLargezzaDiBanda(ax1, xl, yl, xh, yh, color2);

%% Ottimizzazione dello spessore della piastra di adattamento l_plate
% Come dimostrato nel pdf "Procedura di ottimizzazione dello spessore di una piastra di adattamento"
% è possibile far variare l_plate nell'intervallo [0,λ/2] in modo da
% ottenere l'l_plate ottimale che massimizza la FBW.

% L'unica differenza che si osserva nell'applicazione di quanto dimostrato
% nel pdf sopra citato, è la seguente. Nella creazione dell'intervallo di variazione
% risulta necessario aggiungere agli estermi un epsilon per evitare i valori
% 0 e π per il θ_plate, che annullerebbero seni e tangenti, portando alla
% creazione nella matrice M di valori infiniti.
eps = 1e-06; 
l_plate_values = (0+eps):1e-06:((lambda_plate/2) - eps);

FBW_max = 0; 
l_plate_best = 0;
l_plate_best_previous = l_plate; 
for i = 1 : length(l_plate_values)
    l_plate = l_plate_values(i);

    M = calcolaMatriceM(ZoP, k_plate, l_plate);
    Zeq = M{1,1} - ( (M{1,2} .^ 2) ./ (Z2 + M{1,1}) );
    [Zin_with_backing_with_plate, FTT_with_backing_pzt, ~] = calcolaFunzioniDiTrasferimento(B_with_backing, Zeq, Zel);
    FTT_with_backing_pzt = FTT_with_backing_pzt{1} .* exp(1j*deg2rad(FTT_with_backing_pzt{2}));
    FTT_plate = ( M{1,2} .* Z2 ) ./ ( M{1,1}.*Z2 + M{1,1}.^2 - M{1,2}.^2);
    FTT_with_backing_with_plate = FTT_with_backing_pzt .* FTT_plate;
    [moduloFTT_with_backing_with_plate, faseFTT_with_backing_with_plate] = calcolaModuloEFase(FTT_with_backing_with_plate, true, true);
    FTT_with_backing_with_plate = {moduloFTT_with_backing_with_plate, faseFTT_with_backing_with_plate};

    A_max_with_backing_with_plate = max(moduloFTT_with_backing_with_plate);
    A_3dB_with_backing_with_plate = A_max_with_backing_with_plate - 3;
    indices_3db_with_backing_with_plate = find(moduloFTT_with_backing_with_plate >= A_3dB_with_backing_with_plate);
    fl_3dB_with_backing_with_plate = f(indices_3db_with_backing_with_plate(1));
    fh_3dB_with_backing_with_plate = f(indices_3db_with_backing_with_plate(end));
    fc_3dB_with_backing_with_plate = (fl_3dB_with_backing_with_plate + fh_3dB_with_backing_with_plate)/2;
    FBW_3dB_with_backing_with_plate = ( (fh_3dB_with_backing_with_plate - fl_3dB_with_backing_with_plate) / fc_3dB_with_backing_with_plate ) * 100;

    if FBW_3dB_with_backing_with_plate > FBW_max
        % Aggiorno i valori massimi
        FBW_max = FBW_3dB_with_backing_with_plate;
        l_plate_best = l_plate;
    end

end
 
% Output del calcolo dello spessore ottimale
cprintf('Text',"\n");
cprintf('Comments', "Lo spessore ottimale è: l_plate=%0.4f\n", l_plate_best);
cprintf('Comments', "La Banda Frazionaria a -3dB ottimale è: FBW=%0.2f%%\n", FBW_max);
cprintf('Text',"\n");
cprintf('Comments', "Spessore convertito: %0.4f → %0.4f\n", l_plate_best_previous, l_plate_best);

% l_plate = best_l_plate;
% 
% M11 = (ZoP./(1i.*tan((omega./v_plate).*l_plate)));
% M12 = (ZoP./(1i.*sin((omega./v_plate).*l_plate)));
% 
% Z = M11-((M12.^2)./(Z2.*(1+(M11./Z2))));
% 
% [Zin_b, ~, ~, ~] = CalculateFunctions(B_b, Z, Zel, 0);
% [Zin, ~, ~, ~] = CalculateFunctions(B, Z, Zel, 0);
% 
% figure(5)
% Grafico(f, Zin{1}, Zin{2},'Z_i_n Backing with l-correction', 'blue');
% hold on;
% Grafico(f, Zin_b{1}, Zin_b{2},'Z_i_n Backing with l-correction', 'orange');
% legend('without backing', 'with backing');
% 
% TTF = (1./(((M11+(M11.^2./Z2))./M12)-(M12./Z2))).*((Z.*B{2})./(B{3}.*(B{1}+Z)-(B{2}.^2)));
% [TTF_modulo, TTF_fase] = conv_i(TTF);
% TTF_b = (1./(((M11+(M11.^2./Z2))./M12)-(M12./Z2))).*((Z.*B_b{2})./(B_b{3}.*(B_b{1}+Z)-(B_b{2}.^2)));
% [TTF_modulo_b, TTF_fase_b] = conv_i(TTF_b);
% 
% figure(6)
% Grafico(f,TTF_modulo, TTF_fase,'TTF Backing with l-correction', 'blue');
% hold on;
% Grafico(f, TTF_modulo_b, TTF_fase_b, 'TTF Backing with l-correction', 'orange');
% legend('without backing', 'with backing');
% 
% % Calcola il valore massimo dell'ampiezza
% A_max = max(TTF_modulo);
% A_max_b = max(TTF_modulo_b);
% 
% % Calcola il livello -3 dB
% A_3dB = A_max -3;
% A_6dB = A_max -6;
% 
% A_3dB_b = A_max_b -3;
% A_6dB_b = A_max_b -6;
% 
% % Trova le frequenze a cui l'ampiezza è prossima a A_3dB
% indices_3db = find(TTF_modulo >= A_3dB);
% indices_6db = find(TTF_modulo >= A_6dB);
% 
% indices_3db_b = find(TTF_modulo_b >= A_3dB_b);
% indices_6db_b = find(TTF_modulo_b >= A_6dB_b);
% 
% % Limite inferiore e superiore della banda a -3 dB
% f_low_3dB = f(indices_3db(1));
% f_high_3dB = f(indices_3db(end));
% f_low_6dB = f(indices_6db(1));
% f_high_6dB = f(indices_6db(end));
% 
% f_low_3dB_b = f(indices_3db_b(1));
% f_high_3dB_b = f(indices_3db_b(end));
% f_low_6dB_b = f(indices_6db_b(1));
% f_high_6dB_b = f(indices_6db_b(end));
% 
% fc_3dB = (f_low_3dB + f_high_3dB)/2;
% fc_6dB = (f_low_6dB + f_high_6dB)/2;
% 
% fc_3dB_b = (f_low_3dB_b + f_high_3dB_b)/2;
% fc_6dB_b = (f_low_6dB_b + f_high_6dB_b)/2;
% 
% fractional_bandwidth_3dB = ((f_high_3dB - f_low_3dB)/fc_3dB)*100;
% fractional_bandwidth_6dB = ((f_high_6dB - f_low_6dB)/fc_6dB)*100;
% 
% fractional_bandwidth_3dB_b = ((f_high_3dB_b - f_low_3dB_b)/fc_3dB_b)*100;
% fractional_bandwidth_6dB_b = ((f_high_6dB_b - f_low_6dB_b)/fc_6dB_b)*100;
% 
% % Calcola la larghezza di banda
% fprintf('Fractional bandwidth at -3dB without backing %0.3f%%\n', fractional_bandwidth_3dB);
% fprintf('Fractional bandwidth at -6dB without backing %0.3f%%\n', fractional_bandwidth_6dB);
% fprintf('Fractional bandwidth at -3dB with backing %0.3f%%\n', fractional_bandwidth_3dB_b);
% fprintf('Fractional bandwidth at -6dB with backing %0.3f%%\n', fractional_bandwidth_6dB_b);
