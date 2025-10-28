% Questo script implementa la progettazione di un trasduttore 
% piezoelettrico ultrasonico con la struttura a sandwich(trasduttore 
% simmetrico) proposta da Paul Langevin, ovvero con due masse di precarico 
% ai due estremi e due ceramiche piezoelettriche poste al centro.


addpath('../utility/');
addpath('../../core/');
evalin('base', 'clear'); clc;

% Essendo un trasduttore ultrasonico deve lavorare ovvero deve avere la
% frequenza di risonanza(ovvero la frequenza in cui vi è il massimo
% spostamento longitudinale) posta a una frequenza superiore alle grequenze
% udibili ovvero >20kHz, lo standard è 40kHz.
fr = 40e+03;
f = linspace(fr - (fr / 10), fr + (fr / 10), 12000);
omega = 2*pi .* f;

%% Parametri relativi al carico
z_L1 = 400; % Aria che approssima il vuoto(siccome eq. Langevin valida solo nel vuoto)

%% Parametri relativi alla ceramica
[areaFaccia, l_c, rho_c, ~, h33, ~, ~, v_c, ~, ~, ~, C0] = ceramicPicker();
z_c = rho_c * v_c; % Usare PZ27

%% Parametri relativi alla massa di precarico
[rho_l, z_l, v_l] = preloadMassPicker();
% Come spiegato in precedenza è possibile esplicitare l'eq di Langevin
% rispetto alle masse di precarico
% N.B.: Per come è definita nelle dispense c è metà dello spessore della
%       ceramica piezoelettrica
a = ( v_l / (2*pi*fr) ) * atan( ( z_c/ z_l ) * ( 1 / tan( (2*pi*fr*(l_c/2)) / v_c ) ) );
k = omega/v_l;
s = areaFaccia;
Y = (v_l^2) * rho_l;
% Lo spessore della prima massa di precarico qui viene indicato come L1,
% nelle dispense è anche indicato come (z2-z1) dove z2 e z1 sono
% rispettivamente la posizione finale e iniziale della massa lungo l'asse z
L1 = a;
% Calcolo gli elementi distinti della matrice M1 che modella la prima(ma 
% in realtà entrambe essendo uguali) massa di precarico.
% Non ho utilizzato la apposita funzione per il calcolo della matrice M
% poichè come è possibile notare essa in questo contesto è stata eplicitata
% rispetto a parametri differenti anche essendo uguale alla M del plate.
M1_11 = (k .* s .* Y) ./ (1i .* omega .* tan(k .* L1));
M1_12 = (k .* s .* Y) ./ (1i .* omega .* sin(k .* L1));
M1_21 = M1_12;
M1_22 = M1_11;
M1 = {M1_11, M1_12;...
      M1_21, M1_22};

%% Calcolo le impende acustiche
Z_L1 =  z_L1 * areaFaccia;
ZoD = z_c * areaFaccia;
Zeq = M1{1,1} - ( (M1{1,2}.^2) ./ (Z_L1 + M1{1,1}) );

%% Funzione di trasferimento in trasmissione della ceramica con masse di precarico
% Calcolo la matrice A(3x3) e B(2x2)
numberOfCeramicPairs = 1;

new_l_c = l_c / (2 ^ numberOfCeramicPairs);
new_C0 = (2 ^ numberOfCeramicPairs) * C0;

A_couple = calcolaMatriceA(ZoD, omega, v_c, new_l_c, h33, new_C0);
G = calcolaMatriceG(A_couple, A_couple);
B_couple = calcolaMatriceB(G, Zeq);

% Notare il fatto che passo Z due volte siccome ho una massa di precarico ad ambo i lati
[Zin, FTT_pzt, ~] = calcolaFunzioniDiTrasferimento(B_couple, Zeq, Zeq);
FTT_pzt = db2mag(FTT_pzt{1}) .* exp(1j*deg2rad(FTT_pzt{2}));

% Come visto per il trasduttore a banda larga, anche qui si ha un elemento
% puramente meccanico modellato da una rete due porte tramite una matrice M
% quindi la sua FTT è calcoloabile come segue
FTT_mass = ( M1{1,2} .* Z_L1 ) ./ ( M1{1,1}.*Z_L1 + M1{1,1}.^2 - M1{1,2}.^2);

FTT = FTT_pzt .* FTT_mass;

[moduloFTT, faseFTT] = calcolaModuloEFase(FTT, true, true);
FTT = {moduloFTT, faseFTT};

f_iter = 0;
a_corrected = L1;
while(f_iter < fr)

    a_corrected = a_corrected - 1e-06;

    M1_11_iter = (k .* s .* Y) ./ (1i .* omega .* tan(k .* a_corrected));
    M1_12_iter = (k .* s .* Y) ./ (1i .* omega .* sin(k .* a_corrected));
    Z_iter = M1_11_iter - ( (M1_12_iter.^2) ./ (Z_L1 + M1_11_iter) );
    B_iter = calcolaMatriceB(G, Z_iter);
    [Zin_iter, FTT_pzt_iter, ~] = calcolaFunzioniDiTrasferimento(B_iter, Z_iter, Z_iter);
    FTT_pzt_iter = db2mag(FTT_pzt_iter{1}) .* exp(1j*deg2rad(FTT_pzt_iter{2}));
    FTT_mass_iter = ( M1_12_iter .* Z_L1 ) ./ ( M1_11_iter.*Z_L1 + M1_11_iter.^2 - M1_12_iter.^2);
    FTT_iter = FTT_pzt_iter .* FTT_mass_iter;
    [moduloFTT_iter, faseFTT_iter] = calcolaModuloEFase(FTT_iter, true, true);
    FTT_iter = {moduloFTT_iter, faseFTT_iter};

    [~, index] = max(FTT_iter{1});
    f_iter = f(index);
end

figure(3);
stampaGrafici(f, Zin{1}, Zin{2}, "Comparing Zin without and with a correction with two ceramics", 'blue', "Zin", "Zin", " without a correction");
hold on;
stampaGrafici(f, Zin_iter{1}, Zin_iter{2}, "Comparing Zin without and with a correction with two ceramics", 'orange', "Zin", "Zin", " with a correction");
figure(4);
stampaGrafici(f, FTT{1}, FTT{2}, "Comparing TTF without and with a correction with two ceramics", 'blue', "TTF", "TTF", " without a correction");
hold on;
stampaGrafici(f, FTT_iter{1}, FTT_iter{2}, "Comparing TTF without and with a correction with two ceramics", 'orange', "TTF", "TTF", " with a correction");
