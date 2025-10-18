% Questo script implementa la progettazione di un trasduttore 
% piezoelettrico a larga banda

addpath('../utility/');
evalin('base', 'clear'), close all; clc;

[areaFaccia, l, rho, ~, h33, ~, ~, v, f, omega, ~, C0] = ceramicPicker();

% Calcolo l'impedenza acustica specifica della ceramica
z1 = 400;   % Aria
zB = 7e+06; % Il Backing è fatto solitamente di materiali come il tungsteno-epossidico che ha una impedenza acustica specifica tra [5,10] MRayl
z_piezo = rho * v; % N.B.: Usare PZ27 per questa applicazione
z_load = 1.5e+06;  % Acqua
z2 = z_load;

%% Funzione di trasferimento in trasmissione e in ricezione della ceramica con e senza backing
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

figure(1);
stampaGrafici(f, Zin_without_backing{1}, Zin_without_backing{2}, "Comparing Zin without and with Backing", 'blue', "Zin", "Zin", " without backing");
hold on;
stampaGrafici(f, Zin_with_backing{1}, Zin_with_backing{2}, "Comparing Zin without and with Backing", 'orange', "Zin", "Zin", " with backing");

figure(2);
stampaGrafici(f, FTT_without_backing{1}, FTT_without_backing{2}, "Comparing TTF without and with Backing", 'blue', "TTF", "TTF", " without backing");
hold on;
stampaGrafici(f, FTT_with_backing{1}, FTT_with_backing{2}, "Comparing TTF without and with Backing", 'orange', "TTF", "TTF", " with backing");

figure(3)
stampaGrafici(f, FTR_without_backing{1}, FTR_without_backing{2}, "Comparing RTF without and with Backing", 'blue', "RTF", "RTF", " without backing");
hold on;
stampaGrafici(f, FTR_with_backing{1}, FTR_with_backing{2}, "Comparing RTF without and with Backing", 'orange', "RTF", "RTF", " with backing");

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
legendTitle = strcat("Matching Plate of ", string(l_plate_scaled), " [mm]");
figure(4)
stampaGrafici(f, Zin_without_backing_with_plate{1}, Zin_without_backing_with_plate{2}, "Comparing Zin without and with Backing adding the matching plate", 'blue', "Zin", "Zin", " without backing with plate", legendTitle);
hold on;
stampaGrafici(f, Zin_with_backing_with_plate{1}, Zin_with_backing_with_plate{2}, "Comparing Zin without and with Backing adding the matching plate", 'orange', "Zin", "Zin", " with backing with plate", legendTitle);
figure(5)
stampaGrafici(f, FTT_without_backing_with_plate{1}, FTT_without_backing_with_plate{2}, "Comparing TTF without and with Backing adding the matching plate", 'blue', "TTF", "TTF", " without backing with plate", legendTitle);
hold on;
stampaGrafici(f, FTT_with_backing_with_plate{1}, FTT_with_backing_with_plate{2}, "Comparing TTF without and with Backing adding the matching plate", 'orange', "TTF", "TTF", " with backing with plate", legendTitle);

% Calcolo il valore massimo del modulo della FTT
A_max_without_backing_with_plate = max(moduloFTT_without_backing_with_plate);

A_max_with_backing_with_plate = max(moduloFTT_with_backing_with_plate);

% Calcolo il valore del modulo della FTT a -3dB e a -6dB
A_3dB_without_backing_with_plate = A_max_without_backing_with_plate - 3;
A_6dB_without_backing_with_plate = A_max_without_backing_with_plate - 6;

A_3dB_with_backing_with_plate = A_max_with_backing_with_plate - 3;
A_6dB_with_backing_with_plate = A_max_with_backing_with_plate - 6;

% Trovo gli indici delle frequenze a cui l'ampiezza è maggiore o uguale ad A_3dB e ad A_6dB
indices_3db_without_backing_with_plate = find(moduloFTT_without_backing_with_plate >= A_3dB_without_backing_with_plate);
indices_6db_without_backing_with_plate = find(moduloFTT_without_backing_with_plate >= A_6dB_without_backing_with_plate);

indices_3db_with_backing_with_plate = find(moduloFTT_with_backing_with_plate >= A_3dB_with_backing_with_plate);
indices_6db_with_backing_with_plate = find(moduloFTT_with_backing_with_plate >= A_6dB_with_backing_with_plate);

% Calcolo fl(f low) e fh(f high)(ovvero la frequenza più bassa e più alta alla quale la risposta resta sopra una certa soglia) a -3 dB e a -6dB
fl_3dB_without_backing_with_plate = f(indices_3db_without_backing_with_plate(1));
fh_3dB_without_backing_with_plate = f(indices_3db_without_backing_with_plate(end));
fl_6dB_without_backing_with_plate = f(indices_6db_without_backing_with_plate(1));
fh_6dB_without_backing_with_plate = f(indices_6db_without_backing_with_plate(end));

fl_3dB_with_backing_with_plate = f(indices_3db_with_backing_with_plate(1));
fh_3dB_with_backing_with_plate = f(indices_3db_with_backing_with_plate(end));
fl_6dB_with_backing_with_plate = f(indices_6db_with_backing_with_plate(1));
fh_6dB_with_backing_with_plate = f(indices_6db_with_backing_with_plate(end));

% Calcolo fc(f central)(ovvero la frequenza "al centro" della banda delimitata da fl e fh) a -3 dB e a -6dB
fc_3dB_without_backing_with_plate = (fl_3dB_without_backing_with_plate + fh_3dB_without_backing_with_plate)/2;
fc_6dB_without_backing_with_plate = (fl_6dB_without_backing_with_plate + fh_6dB_without_backing_with_plate)/2;

fc_3dB_with_backing_with_plate = (fl_3dB_with_backing_with_plate + fh_3dB_with_backing_with_plate)/2;
fc_6dB_with_backing_with_plate = (fl_6dB_with_backing_with_plate + fh_6dB_with_backing_with_plate)/2;

% Calcolo la FBW(Fractional BandWidth)(ovvero quanto è larga la banda rispetto alla sua frequenza centrale espressa in %)
FBW_3dB_without_backing_with_plate = ( (fh_3dB_without_backing_with_plate - fl_3dB_without_backing_with_plate) / fc_3dB_without_backing_with_plate ) * 100;
FBW_6dB_without_backing_with_plate = ( (fh_6dB_without_backing_with_plate - fl_6dB_without_backing_with_plate) / fc_6dB_without_backing_with_plate ) * 100;

FBW_3dB_with_backing_with_plate = ( (fh_3dB_with_backing_with_plate - fl_3dB_with_backing_with_plate) / fc_3dB_with_backing_with_plate ) * 100;
FBW_6dB_with_backing_with_plate = ( (fh_6dB_with_backing_with_plate - fl_6dB_with_backing_with_plate) / fc_6dB_with_backing_with_plate ) * 100;

% Stampo i valori trovati per la FBW
cprintf('Comments',"\nBanda Frazionaria a -3dB senza backing con plate: FBW=%0.2f%%", string(FBW_3dB_without_backing_with_plate));
cprintf('Comments',"\nBanda Frazionaria a -6dB senza backing con plate: FBW=%0.2f%%", string(FBW_6dB_without_backing_with_plate));
cprintf('Comments',"\nBanda Frazionaria a -3dB con backing con plate: FBW=%0.2f%%", string(FBW_3dB_with_backing_with_plate));
cprintf('Comments',"\nBanda Frazionaria a -6dB con backing con plate: FBW=%0.2f%%", string(FBW_6dB_with_backing_with_plate));
cprintf('Text',"\n");

fig = gcf;                          % ultimo figure attivo
axs = findall(fig, 'Type', 'axes'); % tutti gli axes
ax1 = axs(end);                     % il "primo" subplot creato è l'ultimo della lista
hold(ax1, 'on');
plot(ax1,fl_3dB_without_backing_with_plate/1e+03, moduloFTT_without_backing_with_plate(indices_3db_without_backing_with_plate(1)),  'o', 'color', '#ed6b20',  'HandleVisibility', 'off');
plot(ax1,fh_3dB_without_backing_with_plate/1e+03, moduloFTT_without_backing_with_plate(indices_3db_without_backing_with_plate(end)),'o', 'color', '#ed6b20',  'HandleVisibility', 'off');
plot(ax1,fl_6dB_without_backing_with_plate/1e+03, moduloFTT_without_backing_with_plate(indices_6db_without_backing_with_plate(1)),  'o', 'color', '#ed20e6',  'HandleVisibility', 'off');
plot(ax1,fh_6dB_without_backing_with_plate/1e+03, moduloFTT_without_backing_with_plate(indices_6db_without_backing_with_plate(end)),'o', 'color', '#ed20e6',  'HandleVisibility', 'off');
plot(ax1,fl_3dB_with_backing_with_plate/1e+03, moduloFTT_with_backing_with_plate(indices_3db_with_backing_with_plate(1)),  'o', 'color', '#ed6b20',  'HandleVisibility', 'off');
plot(ax1,fh_3dB_with_backing_with_plate/1e+03, moduloFTT_with_backing_with_plate(indices_3db_with_backing_with_plate(end)),'o', 'color', '#ed6b20',  'HandleVisibility', 'off');
plot(ax1,fl_6dB_with_backing_with_plate/1e+03, moduloFTT_with_backing_with_plate(indices_6db_with_backing_with_plate(1)),  'o', 'color', '#ed20e6',  'HandleVisibility', 'off');
plot(ax1,fh_6dB_with_backing_with_plate/1e+03, moduloFTT_with_backing_with_plate(indices_6db_with_backing_with_plate(end)),'o', 'color', '#ed20e6',  'HandleVisibility', 'off');

% l_plate_values = (l_plate/3):1e-06:(3*l_plate);
% max_fractional_bandwidth = 0; 
% best_l_plate = 0; 
% 
% for i = 1:length(l_plate_values)
%     l_plate = l_plate_values(i);
% 
%     M11 = (ZoP./(1i.*tan((omega./v_plate).*l_plate)));
%     M12 = (ZoP./(1i.*sin((omega./v_plate).*l_plate)));
% 
%     Z = M11-((M12.^2)./(Z2.*(1+(M11./Z2))));
% 
%     TTF_b = (1./(((M11+(M11.^2./Z2))./M12)-(M12./Z2))).*((Z.*B_b{2})./(B_b{3}.*(B_b{1}+Z)-(B_b{2}.^2)));
%     [TTF_modulo_b, ~] = conv_i(TTF_b);
% 
%     % Calcola il valore massimo dell'ampiezza
%     A_max_b = max(TTF_modulo_b);
% 
%     % Calcola il livello -3 dB
%     A_3dB_b = A_max_b - 3; 
% 
%     % Trova le frequenze a cui l'ampiezza è prossima a A_3dB
%     indices_3db_b = find(TTF_modulo_b >= A_3dB_b);
% 
%     % Limite inferiore e superiore della banda a -3 dB
%     f_low_3dB_b = f(indices_3db_b(1));
%     f_high_3dB_b = f(indices_3db_b(end));
% 
%     fc_3dB_b = (f_low_3dB_b + f_high_3dB_b)/2;
% 
%     fractional_bandwidth_3dB_b = ((f_high_3dB_b - f_low_3dB_b)/fc_3dB_b)*100;
% 
%     if fractional_bandwidth_3dB_b > max_fractional_bandwidth
%         %Aggiorna i valori massimi e salva l'indice dell'iterazione
%         max_fractional_bandwidth = fractional_bandwidth_3dB_b;
%         best_l_plate = l_plate;
%         best_iteration = i;
%     end
% 
% end
% 
% %Output del risultato ottimale
% fprintf('La lunghezza ottimale l_plate che massimizza la larghezza di banda frazionaria a -3 dB è: %0.4f\n', best_l_plate);
% fprintf('La larghezza di banda frazionaria a -3 dB ottimale è: %0.3f%%\n', max_fractional_bandwidth);
% 
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
% 
% plot(f_low_3dB./1e+06,TTF_modulo(indices_3db(1)),'o', 'color', '#4DBEEE', 'HandleVisibility','off');
% plot(f_high_3dB./1e+06,TTF_modulo(indices_3db(end)),'o', 'color', '#4DBEEE', 'DisplayName','bandwidth at -3dB');
% plot(f_low_6dB./1e+06,TTF_modulo(indices_6db(1)),'o', 'color', 'blue', 'HandleVisibility','off');
% plot(f_high_6dB./1e+06,TTF_modulo(indices_6db(end)),'o', 'color', 'blue', 'DisplayName','bandwidth at -6dB');
% 
% plot(f_low_3dB_b./1e+06,TTF_modulo_b(indices_3db_b(1)),'o', 'color', '#EDB120', 'HandleVisibility','off');
% plot(f_high_3dB_b./1e+06,TTF_modulo_b(indices_3db_b(end)),'o', 'color', '#EDB120', 'DisplayName','bandwidth at -3dB');
% plot(f_low_6dB_b./1e+06,TTF_modulo_b(indices_6db_b(1)),'o', 'color', 'red', 'HandleVisibility','off');
% plot(f_high_6dB_b./1e+06,TTF_modulo_b(indices_6db_b(end)),'o', 'color', 'red', 'DisplayName','bandwidth at -6dB');