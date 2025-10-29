% Questo script implementa la progettazione di un trasduttore 
% ultrasonico con concentratore a gradino la cui specifica
% di progetto richiede una frequenza di lavoro fω pari a 40kHz. Le 
% dimensioni L3 e L4 del concentratore sono fissate da tale specifica, in 
% quanto per ottenere massima amplificazione di velocità dovranno essere 
% pari a λ/4.

% In accordo con le specifiche, qui si implementa un concentratore a gradino:
% è il caso limite (degenere) del trasformatore di velocità a sezione multipla,
% in cui la parte a profilo esponenziale ha lunghezza l2→0.
%
% In questo limite NON è opportuno usare la matrice T del profilo esponenziale
% (eq. 3.77): quella formulazione è utile solo per l2 finito (l2>0) e diventa
% mal condizionata quando l2→0 a causa di termini con sin[kc·l2] e tan[kc·l2]
% al denominatore.
%
% Restano quindi due strade equivalenti:
% 1) Via "formule chiuse" generali del trasformatore a sezione multipla
%    (eq. 3.69–3.72) e loro specializzazione al gradino (eq. 3.74–3.75),
%    per calcolare FTT e Zin del concentratore su tutta la banda.
% 2) Via reti 2-porte usando solo i tratti a sezione costante (M3 e M4):
%    si applicano le matrici M dei cilindri (eq. 3.18–3.23) risalendo dal carico
%    per ottenere Z_in(acustica) e componendo le FTT come di consueto.
%
% In questo script si adotta la strada (2): gradino ideale modellato come
% giunzione di area a lunghezza nulla fra due tratti cilindrici (M3, M4),
% con calcolo di Zin e FTT tramite la catena di bipoli meccanici.

addpath('../utility/');
addpath('../../core/');
evalin('base', 'clear'), close all; clc;

fr = 40e+03;
f = linspace(fr - (fr / 2), fr + (fr / 2), 12000);
omega = 2*pi .* f;

%% Parametri relativi ai carichi(L1 e L2)
% Si utilizza l'aria come approssimazione del vuoto
z_L1 = 400;
z_L2 = z_L1;

%% Parametri relativi alle ceramicche(Ceq)
% Ricordati che è opportuno utilizzare facce circolari in questo caso
% poichè N è definito come il rapporto tra i raggi delle sezioni costanti
% del concentratore.
[areaFaccia, l_c, rho_c, ~, h33, ~, ~, v_c, ~, ~, ~, C0] = ceramicPicker();
z_c = rho_c * v_c; % Usare PZ27

%% Parametri relativi alle masse di precarico(M1 e M2)
[rho_l, z_l, v_l] = purelyMechanicalLayerMaterialPicker('Seleziona il materiale da utilizzare per le masse di precarico');
a = ( v_l / (2*pi*fr) ) * atan( ( z_c/ z_l ) * ( 1 / tan( (2*pi*fr*(l_c/2)) / v_c ) ) );
L1 = a;
L2 = L1;
k_l = omega/v_l;
S_l = areaFaccia;
Y_l = (v_l^2) * rho_l;
M1 = calcolaMatriceMFormulazioneAlternativa(k_l, S_l, Y_l, omega, L1);
M2 = calcolaMatriceMFormulazioneAlternativa(k_l, S_l, Y_l, omega, L2);

%% Parametri relativi alle sezioni cilindriche costanti del concentratore a gradino(M3 e M4)
[rho_t, z_t, v_t] = purelyMechanicalLayerMaterialPicker('Seleziona il materiale da utilizzare per il concentratore:');
% Ricordando come avevamo definito lambda nella modellazione del trasduttore a larga banda
lambda_t = v_t/fr;
% Come da specifica definisco lo spessore delle sezioni cilindriche
L3 = lambda_t/4;
L4 = L3;
k_t = omega/v_t;
S_t3 = areaFaccia;
% Si seleziona un target di guadagno Mp alla risonanza.
% Come è possibile osservare dal pdf "Catalog of ultrasonic horn" valori
% tipici per il guadagno alla risonanza per concentratori che lavorano a 
% 40kHz sono compresi in [1.4,4.0].
% Ricordando che alla risonanza per il concentratore a gradino vale la
% seguente relazione:
% Mp=N^2
% Dove Mp è il guadagno del concentratore anche detto fattore di
% amplificazione della velocità.
Mp = concentratorGainPicker();
N = sqrt(Mp);
% Ricordando la definizione di N:
% N=R1/R2
% Allora vale la seguente relazione(sezioni circolari):
% N^2=S1/S2
S_t4 = S_t3/(N^2);
Y_t = (v_t^2) * rho_t;

M3 = calcolaMatriceMFormulazioneAlternativa(k_t, S_t3, Y_t, omega, L3);
M4 = calcolaMatriceMFormulazioneAlternativa(k_t, S_t4, Y_t, omega, L4);

%% Calcolo le impende acustiche
Z_L1 =  z_L1 * S_l;
Z_L2 =  z_L2 * S_t4;
ZoD = z_c * areaFaccia;

Zeq_left = M1{1,1} - (M1{1,2}.^2) ./ (Z_L1   + M1{1,1});
Zin_M4   = M4{1,1} - (M4{1,2}.^2) ./ (Z_L2   + M4{1,1});
Zin_M3   = M3{1,1} - (M3{1,2}.^2) ./ (Zin_M4 + M3{1,1});
Zeq_right= M2{1,1} - (M2{1,2}.^2) ./ (Zin_M3 + M2{1,1});

%%Funzione di trasferimento in trasmissione del sistema completo
% Calcolo la matrice A(3x3) e B(2x2)
numberOfCeramicPairs = 1;
new_l_c = l_c / (2 ^ numberOfCeramicPairs);
new_C0 = (2 ^ numberOfCeramicPairs) * C0;

A_couple = calcolaMatriceA(ZoD, omega, v_c, new_l_c, h33, new_C0);
G = calcolaMatriceG(A_couple, A_couple);
B_couple = calcolaMatriceB(G, Zeq_right);

[Zin, FTT_pzt, ~] = calcolaFunzioniDiTrasferimento(B_couple, Zeq_right, Zeq_left);
FTT_pzt = db2mag(FTT_pzt{1}) .* exp(1j*deg2rad(FTT_pzt{2}));

FTT_M4 = ( M4{1,2} .* Z_L2      ) ./ ( M4{1,1}.*Z_L2      + M4{1,1}.^2 - M4{1,2}.^2);
FTT_M3 = ( M3{1,2} .* Zin_M3    ) ./ ( M3{1,1}.*Zin_M4    + M3{1,1}.^2 - M3{1,2}.^2);
FTT_M2 = ( M2{1,2} .* Zeq_right ) ./ ( M2{1,1}.*Zeq_right + M2{1,1}.^2 - M2{1,2}.^2);

FTT = FTT_pzt .* FTT_M2 .* FTT_M3 .* FTT_M4;

[moduloFTT, faseFTT] = calcolaModuloEFase(FTT, true, true);
FTT = {moduloFTT, faseFTT};

% f_iter = 0;
% a_corrected = L1;
% while(f_iter < fr)
% 
%     a_corrected = a_corrected - 1e-06;
% 
%     M1_iter = calcolaMatriceMFormulazioneAlternativa(k_l, S_l, Y_l, omega, a_corrected);
%     M2_iter = calcolaMatriceMFormulazioneAlternativa(k_l, S_l, Y_l, omega, a_corrected);
% 
%     Zeq_left_iter = M1_iter{1,1} - (M1_iter{1,2}.^2) ./ (Z_L1   + M1_iter{1,1});
%     Zeq_right_iter = M2_iter{1,1} - (M2_iter{1,2}.^2) ./ (Zin_M3 + M2_iter{1,1});
% 
%     B_couple_iter = calcolaMatriceB(G, Zeq_right_iter);
% 
%     [Zin_iter, FTT_pzt_iter, ~] = calcolaFunzioniDiTrasferimento(B_couple_iter, Zeq_right_iter, Zeq_left_iter);
%     FTT_pzt_iter = db2mag(FTT_pzt_iter{1}) .* exp(1j*deg2rad(FTT_pzt_iter{2}));
% 
%     FTT_M2_iter = ( M2_iter{1,2} .* Zeq_right_iter ) ./ ( M2_iter{1,1}.*Zeq_right_iter + M2_iter{1,1}.^2 - M2_iter{1,2}.^2);
% 
%     FTT_iter = FTT_pzt_iter .* FTT_M2_iter .* FTT_M3 .* FTT_M4;
% 
%     [moduloFTT_iter, faseFTT_iter] = calcolaModuloEFase(FTT_iter, true, true);
%     FTT_iter = {moduloFTT_iter, faseFTT_iter};
% 
%     [~, index] = max(FTT_iter{1});
%     f_iter = f(index);
% end

figure(3);
stampaGrafici(f, Zin{1}, Zin{2}, "Impedance", 'blue', "Zin", "Zin");
% hold on;
% stampaGrafici(f, Zin_iter{1}, Zin_iter{2}, "Comparing Zin without and with a correction with two ceramics", 'orange', "Zin", "Zin", " with a correction");
figure(4);
stampaGrafici(f, FTT{1}, FTT{2}, "TTF", 'blue', "TTF", "TTF");
% hold on;
% stampaGrafici(f, FTT_iter{1}, FTT_iter{2}, "Comparing TTF without and with a correction with two ceramics", 'orange', "TTF", "TTF", " with a correction");
