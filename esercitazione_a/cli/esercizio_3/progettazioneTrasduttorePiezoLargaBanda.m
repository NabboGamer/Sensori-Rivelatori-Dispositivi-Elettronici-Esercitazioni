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

%% Funzione di trasferimento in trasmissione della ceramica con backing
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

%% Funzione di trasferimento in trasmissione della ceramica con backing e matching plate

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
[~, index] = max(FTT_without_backing{1});
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
FTT_without_backing_pzt = db2mag(FTT_without_backing_pzt{1}) .* exp(1j*deg2rad(FTT_without_backing_pzt{2}));
FTT_with_backing_pzt = db2mag(FTT_with_backing_pzt{1}) .* exp(1j*deg2rad(FTT_with_backing_pzt{2}));

FTT_plate = ( M{1,2} .* Z2 ) ./ ( M{1,1}.*Z2 + M{1,1}.^2 - M{1,2}.^2);

FTT_without_backing_with_plate = FTT_without_backing_pzt .* FTT_plate;
FTT_with_backing_with_plate = FTT_with_backing_pzt .* FTT_plate;

[moduloFTT_without_backing_with_plate, faseFTT_without_backing_with_plate] = calcolaModuloEFase(FTT_without_backing_with_plate, true, true);
FTT_without_backing_with_plate = {moduloFTT_without_backing_with_plate, faseFTT_without_backing_with_plate};
[moduloFTT_with_backing_with_plate, faseFTT_with_backing_with_plate] = calcolaModuloEFase(FTT_with_backing_with_plate, true, true);
FTT_with_backing_with_plate = {moduloFTT_with_backing_with_plate, faseFTT_with_backing_with_plate};

l_plate_scaled = l_plate * 1e+03;
l_plate_scaled = round(l_plate_scaled, 2);
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

fc_3dB_with_backing_without_plate = (fl_3dB_with_backing_without_plate + fh_3dB_with_backing_without_plate)/2;
fc_6dB_with_backing_without_plate = (fl_6dB_with_backing_without_plate + fh_6dB_with_backing_without_plate)/2;

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
    [~, FTT_with_backing_pzt, ~] = calcolaFunzioniDiTrasferimento(B_with_backing, Zeq, Zel);
    FTT_with_backing_pzt = db2mag(FTT_with_backing_pzt{1}) .* exp(1j*deg2rad(FTT_with_backing_pzt{2}));
    FTT_plate = ( M{1,2} .* Z2 ) ./ ( M{1,1}.*Z2 + M{1,1}.^2 - M{1,2}.^2);
    FTT_with_backing_with_plate = FTT_with_backing_pzt .* FTT_plate;
    [moduloFTT_with_backing_with_plate, ~] = calcolaModuloEFase(FTT_with_backing_with_plate, true, true);

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
l_plate_best_previous_scaled = l_plate_best_previous * 1e03;
l_plate_best_scaled = l_plate_best * 1e03;
cprintf('Text',"\n");
cprintf('Comments', "Lo spessore ottimale è: l_plate=%0.3fe-3\n", l_plate_best_scaled);
cprintf('Comments', "La Banda Frazionaria a -3dB ottimale è: FBW=%0.2f%%\n", FBW_max);
cprintf('Comments', "Spessore convertito: %0.3fe-3 → %0.3fe-3", l_plate_best_previous_scaled, l_plate_best_scaled);

%% Funzione di trasferimento in trasmissione della ceramica con backing e matching plate con spessore ottimizzato

l_plate = l_plate_best;

M = calcolaMatriceM(ZoP, k_plate, l_plate);
Zeq = M{1,1} - ( (M{1,2} .^ 2) ./ (Z2 + M{1,1}) );
[Zin_with_backing_with_plate, FTT_with_backing_pzt, ~] = calcolaFunzioniDiTrasferimento(B_with_backing, Zeq, Zel);
FTT_with_backing_pzt = db2mag(FTT_with_backing_pzt{1}) .* exp(1j*deg2rad(FTT_with_backing_pzt{2}));
FTT_plate = ( M{1,2} .* Z2 ) ./ ( M{1,1}.*Z2 + M{1,1}.^2 - M{1,2}.^2);
FTT_with_backing_with_plate = FTT_with_backing_pzt .* FTT_plate;
[moduloFTT_with_backing_with_plate, faseFTT_with_backing_with_plate] = calcolaModuloEFase(FTT_with_backing_with_plate, true, true);
FTT_with_backing_with_plate = {moduloFTT_with_backing_with_plate, faseFTT_with_backing_with_plate};

l_plate_scaled = l_plate * 1e+03;
l_plate_scaled = round(l_plate_scaled, 2);
legendTitle = strcat("Matching Plate made of E-Solder 3022 (", string(l_plate_scaled), " [mm])");
figure(6)
stampaGrafici(f, Zin_with_backing_with_plate{1}, Zin_with_backing_with_plate{2}, "Zin with Backing and Optimized Matching Plate", 'orange', "Zin", "Zin", " with backing with plate", legendTitle);
figure(7)
stampaGrafici(f, FTT_with_backing_with_plate{1}, FTT_with_backing_with_plate{2}, "TTF with Backing and Optimized Matching Plate", 'orange', "TTF", "TTF", " with backing with plate", legendTitle);

A_max_with_backing_with_plate = max(moduloFTT_with_backing_with_plate);
A_3dB_with_backing_with_plate = A_max_with_backing_with_plate - 3;
A_6dB_with_backing_with_plate = A_max_with_backing_with_plate - 6;
indices_3db_with_backing_with_plate = find(moduloFTT_with_backing_with_plate >= A_3dB_with_backing_with_plate);
indices_6db_with_backing_with_plate = find(moduloFTT_with_backing_with_plate >= A_6dB_with_backing_with_plate);
fl_3dB_with_backing_with_plate = f(indices_3db_with_backing_with_plate(1));
fh_3dB_with_backing_with_plate = f(indices_3db_with_backing_with_plate(end));
fl_6dB_with_backing_with_plate = f(indices_6db_with_backing_with_plate(1));
fh_6dB_with_backing_with_plate = f(indices_6db_with_backing_with_plate(end));
fc_3dB_with_backing_with_plate = (fl_3dB_with_backing_with_plate + fh_3dB_with_backing_with_plate)/2;
fc_6dB_with_backing_with_plate = (fl_6dB_with_backing_with_plate + fh_6dB_with_backing_with_plate)/2;
FBW_3dB_with_backing_with_plate = ( (fh_3dB_with_backing_with_plate - fl_3dB_with_backing_with_plate) / fc_3dB_with_backing_with_plate ) * 100;
FBW_6dB_with_backing_with_plate = ( (fh_6dB_with_backing_with_plate - fl_6dB_with_backing_with_plate) / fc_6dB_with_backing_with_plate ) * 100;

cprintf('Comments',"\nBanda Frazionaria a -3dB con backing e plate ottimizzato: FBW=%0.2f%%", string(FBW_3dB_with_backing_with_plate));
cprintf('Comments',"\nBanda Frazionaria a -6dB con backing e plate ottimizzato: FBW=%0.2f%%", string(FBW_6dB_with_backing_with_plate));
cprintf('Text',"\n");
