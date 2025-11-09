% Dato un file csv in ingresso, contenente le misurazioni di laboratorio 
% della Zin di una ceramica piezoelettrica, questo script si occupa di
% ricavare la tipologia più probabile di ceramica.

addpath('../utility/');
addpath('../../core/');
evalin('base', 'clear'), close all; clc;

%% Acquisizione parametri misurati della ceramica

% Acquisizione di forma e dimensioni dell'elemento
[areaFaccia, l] = geometryPicker();

% Acquisizione della massa dell'elemento
cprintf('Text',"\n");
m = realQuantityPicker("Inserire la misura desiderata per la massa(Kg): ", "m");

% Acquisizione modulo dell'impedenza di ingresso a flow
cprintf('Text',"\n");
flow = realQuantityPicker("Inserire la misura desiderata per la bassa frequenza: ", "flow");
Zi_flow = realQuantityPicker("Inserire la misura desiderata per l'impedenza di ingresso a bassa frequenza: ", "Zi_flow");

% Acquisizione della Zin dell'elemento tramite CSV esportato dall'analizzatore di impedenza
csv = csvPicker();
if isnumeric(csv) && isscalar(csv) && csv == -1
    return;
end
f = csv.f';
Zin = {csv.moduloZin', csv.faseZin'};
evalin( 'base', 'clear("csv")' );

%% Estrazione parametri circuito equivalente e stampa grafico teorico impedenza di ingresso
cprintf('Text',"\n");
C0 = realQuantityPicker("Inserire i parametri del Circuito Equivalente della ceramica a vuoto: ", "C0");
R1 = realQuantityPicker("Inserire i parametri del Circuito Equivalente della ceramica a vuoto: ", "R1");
L1 = realQuantityPicker("Inserire i parametri del Circuito Equivalente della ceramica a vuoto: ", "L1");
C1 = realQuantityPicker("Inserire i parametri del Circuito Equivalente della ceramica a vuoto: ", "C1");

w  = 2*pi*f(:);
Zs = R1 + (1i*w.*L1) + (1./(1i*w.*C1));
Zin_ceq = (Zs) ./ (1 + 1i*w.*C0.*Zs);

[moduloZin_ceq, faseZin_ceq] = calcolaModuloEFase(Zin_ceq, false, true);
Zin_ceq = {moduloZin_ceq, faseZin_ceq};

figure(1);
stampaGrafici(f, Zin{1}, Zin{2}, "Impedence Comparing", 'blue', "Zin", "Zin");
hold on;
stampaGrafici(f, Zin_ceq{1}, Zin_ceq{2}, "Impedence Comparing", 'orange', "Zin_c_e_q", "Zin");

%% Calcolo parametri caratteristici della ceramica a partire dai valori prelevati al passo precedente

% Tutte le formule presenti in questa sezione sono state discusse e ricavate
% nel pdf "Procedura di deduzione della tipologia di una ceramica piezoelettrica"

% Calcoli propedeutici per i prossimi parametri
V = areaFaccia * l;

[~, index_min] = min(Zin{1});
[~, index_max] = max(Zin{1});
fmin = f(1,index_min);
fmax = f(1,index_max);
Keff2 = ((fmax^2) - (fmin^2))/(fmax^2);

omegalow = 2 * pi * flow;
C0 = ( 1 / (omegalow * Zi_flow) ) * (1 - ( (pi^2)/8 * Keff2) );
beta33 = areaFaccia/(C0 * l);
thetas = (fmin * pi)/fmax;


% Calcolo rho(presupponendo volume cilindrico)
rho = m / V;

% Calcolo c33;
c33 = 4 * (fmax^2) * (l^2) * rho;

% Calcolo h33
h33 = sqrt( (c33 * beta33 * (thetas/2)) / (tan(thetas/2)) );

% Calcolo e33
e33 = h33 / beta33;

proprietaMisurate = [rho, c33, h33, e33];

%% Stima della tipologia più probabile di ceramica partendo dai parametri calcolati
strutturaProprietaPzt = caricaStrutturaProprietaPzt();
r = size(strutturaProprietaPzt, 1);

% M: matrice Nx4 da letteratura [rho, c33, h33, e33]
% p: vettore 1x4 misurato [rho, c33, h33, e33]
M = vertcat(strutturaProprietaPzt{:,2});
p = proprietaMisurate;

% Distanza euclidea standardizzata (z-score senza centratura esplicita)
tol = 1e-12;
sigma = std(M, 0, 1);                     % deviazione standard colonna-per-colonna
mask  = sigma > tol;                      % tieni solo feature informative (σ non ~0)

% Scarti standardizzati per le sole colonne informative
Delta = (M(:, mask) - p(mask)) ./ sigma(mask);   % NxK, K = numero di feature tenute
distanzaEuclidea = vecnorm(Delta, 2, 2);         % Nx1 distanza L2 per riga

% Assegna la metrica (colonna 3) senza loop
strutturaProprietaPzt(:, 3) = num2cell(distanzaEuclidea);

% Ordino per distanza crescente (più vicino = più probabile)
strutturaProprietaPzt = sortrows(strutturaProprietaPzt, 3, 'ascend');

% Mostra le prime 3: nome, distanza
topN = min(4, r);
idx  = 1:topN;
nomi = vertcat(strutturaProprietaPzt{idx, 1});   % string array
dist = cell2mat(strutturaProprietaPzt(idx, 3));  % Nx1 double

T = table(nomi, dist, 'VariableNames', {'Materiali più probabili', 'Distanza Euclidea Standardizzata'});
T.("Materiali più probabili") = categorical(T.("Materiali più probabili"));
disp(newline)
disp(T)
