% Questo script implementa la progettazione di un trasduttore 
% piezoelettrico ultrasonico con la struttura a sandwich(trasduttore 
% simmetrico) proposta da Paul Langevin, ovvero con due masse di precarico 
% ai due estremi e una ceramica piezoelettrica posta al centro.

% Esistono due criteri di progetto, ovvero come si determina lo spessore
% della massa di precarico:
% 
% 1) Criterio classico di Langevin:
%    Utilizza l'equazione di Langevin che permette il dimensionamento del
%    risonatore, infatti essa può essere esplicitata nella dimensione a
%    delle masse di precarico(eq. 3.79 delle dispense);
% 
% 2) Criterio generale:
%    Utilizza per il calcolo di a la derivata della funzione FTT generale
%    rispetto ad a e la pone uguale a 0(eq. 3.85 delle dispense). Tale
%    derivata è molto complessa e quindi la si calcola numericamente per
%    iterazioni successive.
% 

%  Esistono due possibili approcci per la simulazione di questa tipologia
%  di trasduttori:
% 
% 1) Approccio classico:
%    Tiene in considerazione tutto il trasduttore come fatto usualmente e
%    quindi calcolare le impedenze acustiche equivalenti e utilizzare le
%    solite matrici che modellano i vari pezzi collegatio fra loro;
% 
% 2) Approccio che sfrutta la simmetria;
%    Tieni in considerazione solo una metà del trasduttore sfruttando la
%    sua proprietà di simmetria rispetto al centro. Se si utilizza tale
%    approccio è necessario ricalcolare tutte le matrici poichè variano le
%    condizioni al contorno(o condizione alle interfacce dei componenti).

% Per la seguente modellazione si utilizzerà il primo criterio di progetto
% come da specifica e si utilizzerà il primo approccio poichè in questo
% modo non è necessario ricalcolare tutte le matrici.


addpath('../utility/');
addpath('../../core/');
evalin('base', 'clear'), close all; clc;

% Essendo un trasduttore ultrasonico deve lavorare ovvero deve avere la
% frequenza di risonanza(ovvero la frequenza in cui vi è il massimo
% spostamento longitudinale) posta a una frequenza superiore alle grequenze
% udibili ovvero >20kHz, lo standard è 40kHz.
fr = 40e+03;
f = linspace(fr - (fr / 2.5), fr + (fr / 2.5), 12000);
omega = 2*pi .* f;

% Parametri relativi al carico
z_L1 = 400; % Aria che approssima il vuoto(siccome eq. Langevin valida solo nel vuoto)

% Parametri relativi alla ceramica
[areaFaccia, l_c, rho_c, ~, h33, ~, ~, v_c, ~, ~, ~, C0] = ceramicPicker();
z_c = rho_c * v_c; % Usare PZ27

% Parametri relativi alla massa di precarico
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

M1_11 = (k .* s .* Y) ./ (1i .* omega .* tan(k .* L1));
M1_12 = (k .* s .* Y) ./ (1i .* omega .* sin(k .* L1));

% Calcolo le impende acustiche
Z_L1 =  z_L1 * areaFaccia;
% Notare come questa Z della massa di precarico è sostanzialmente una Zeq
Z = M1_11 - ( (M1_12.^2) ./ (Z_L1 + M1_11) );
ZoD = z_c * areaFaccia;

% Calcolo la matrice A(3x3) e B(2x2)
A = calcolaMatriceA(ZoD, omega, v_c, l_c, h33, C0);
B = calcolaMatriceB(A, Z);

% Notare il fatto che passo Z due volte siccome ho una massa di precarico ad ambo i lati
[Zin, FTT, FTR] = calcolaFunzioniDiTrasferimento(B, Z, Z);


% f_iter = 0;
% correct_l = L1;
% while(f_iter < fr)
% 
%     correct_l = correct_l - 1e-05;
% 
%     M1 = (k.*s.*Y)./(1i.*omega.*tan(k.*correct_l));
%     M2 = (k.*s.*Y)./(1i.*omega.*sin(k.*correct_l));
% 
%     Z_iter = M1 - (M2.^2./(ZL+M1));
% 
%     B_iter = Bmatrix(A,Z_iter);
% 
%     %Funzione di trasferimento in trasmissione.
%     [Z_in_iter,TTF_iter, ~, ~] = CalculateFunctions(B_iter, Z_iter, Z_iter, 0);
% 
%     index = TTF_iter{1} == max(TTF_iter{1});
%     f_iter = f(index);
% end
% 
% figure(1);
% Grafico(f, Z_in{1}, Z_in{2}, "Input Impedance", 'blue');
% hold on;
% Grafico(f, Z_in_iter{1}, Z_in_iter{2}, "Input Impedance", 'orange');
% ax1 = subplot(2,1,1); % Primo subplot
% ax2 = subplot(2,1,2); % Secondo subplot
% legend(ax1,'without l-correction', 'with l-correction');
% legend(ax2,'without l-correction', 'with l-correction');
% 
% figure(2)
% Grafico(f, TTF{1}, TTF{2}, "TTF", 'blue');
% hold on;
% Grafico(f, TTF_iter{1}, TTF_iter{2}, "TTF", 'orange');
% ax1 = subplot(2,1,1); % Primo subplot
% ax2 = subplot(2,1,2); % Secondo subplot
% legend(ax1,'without l-correction', 'with l-correction');
% legend(ax2,'without l-correction', 'with l-correction');

% %%
% % % Implementazione dell'estensione del modello terminale a due ceramiche.
% disp("Number of ceramics couple (1 = 2 ceramics, 2 = 4 ceramics, 3 = 8 ceramics, etc... ")
% n_ceramics = input('# Ceramics Couple: ');
% 
% l_couple = l/(2^n_ceramics);
% c0_couple = (2^n_ceramics)*c0;
% 
% %Matrici A(3x3), B(2x2) e G (3x3).
% A_couple = Amatrix(ZOD, omega, v_c, l_couple, h33, c0_couple);
% 
% %Accoppio le matrici
% G = CoupleCeramics(A_couple, A_couple);
% G_multiple = G;
% 
% if (n_ceramics > 1)
%     for n = 1:(n_ceramics-1)
%         G_multiple = CoupleCeramics(G_multiple, G_multiple);
%     end
%     G = G_multiple;
% end
% 
% B_couple = Bmatrix(G, Z);
% 
% [Z_couple, TTF_couple, ~, ~] = CalculateFunctions(B_couple, Z, Z, 0);
% 
% f_iter = 0;
% correct_l = L1;
% 
% while(f_iter < fr)
% 
%     correct_l = correct_l - 1e-5;
% 
%     M1 = (k.*s.*Y)./(1i.*omega.*tan(k.*correct_l));
%     M2 = (k.*s.*Y)./(1i.*omega.*sin(k.*correct_l));
% 
%     Z_iter = M1 - (M2.^2./(ZL+M1));
% 
%     B_iter = Bmatrix(G,Z_iter);
% 
%     %Funzione di trasferimento in trasmissione.
%     [Z_couple_iter,TTF_couple_iter, ~, ~] = CalculateFunctions(B_iter, Z_iter, Z_iter, 0);
% 
%     index = find(TTF_couple_iter{1} == max(TTF_couple_iter{1}));
%     f_iter = f(index);
% end
% 
% figure(3);
% Grafico(f, Z_couple{1}, Z_couple{2}, "Input Impedance", 'blue');
% hold on;
% Grafico(f, Z_couple_iter{1}, Z_couple_iter{2}, "Input Impedance", 'orange');
% ax1 = subplot(2,1,1); % Primo subplot
% ax2 = subplot(2,1,2); % Secondo subplot
% legend(ax1,'without l-correction', 'with l-correction');
% legend(ax2,'without l-correction', 'with l-correction');
% 
% figure(4)
% Grafico(f, TTF_couple{1}, TTF_couple{2}, "TTF", 'blue');
% hold on;
% Grafico(f, TTF_couple_iter{1}, TTF_couple_iter{2}, "TTF", 'orange');
% ax1 = subplot(2,1,1); % Primo subplot
% ax2 = subplot(2,1,2); % Secondo subplot
% legend(ax1,'without l-correction', 'with l-correction');
% legend(ax2,'without l-correction', 'with l-correction');