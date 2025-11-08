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
m = realQuantityPicker("Inserire la misura desiderata per la massa(Kg): ", "m");

% Acquisizione modulo dell'impedenza di ingresso a flow
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
figure(1);
stampaGrafici(f, Zin{1}, Zin{2}, "Zin: input impedance", 'blue', "Zin", "Zin");

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

%% Stima della tipologia più probabile di ceramica partendo dai parametri calcolati al passo precedente
% strutturaProprietaPzt = caricaStrutturaProprietaPzt();
% r = size(strutturaProprietaPzt,1);
% 
% % Colonna 4: errore relativo medio sulle 3 proprietà (ranking "continuo")
% M = vertcat(strutturaProprietaPzt{:,2});                  % Nx3
% errRel = abs((M - proprietaMisurate)./proprietaMisurate); % Nx3
% errTot = mean(errRel,2);                                  % Nx1
% for i = 1:r
%     strutturaProprietaPzt{i,4} = errTot(i);
% end
% 
% % Ordino le righe rispetto al loro risultato
% strutturaProprietaPzt = sortrows(strutturaProprietaPzt, [4], {'ascend'});
% 
% % Mostra le prime 3: nome, errore medio
% topN = min(3, r);
% idx   = 1:topN;
% nomi  = vertcat(strutturaProprietaPzt{idx,1});      % string array
% % score = cell2mat(strutturaProprietaPzt(idx,3));     % Nx1 double
% err   = cell2mat(strutturaProprietaPzt(idx,4));     % Nx1 double
% 
% T = table(nomi, err, 'VariableNames', {'Materiali più probabili', 'Errore Relativo Medio'});
% T.("Materiali più probabili") = categorical(T.("Materiali più probabili"));
% disp(newline)
% disp(T)
