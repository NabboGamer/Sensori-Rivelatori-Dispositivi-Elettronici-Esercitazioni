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

% Acquisizione della capacità statica dell'elemento
C0 = realQuantityPicker("Inserire la misura desiderata per la capacità statica(F): ", "C0");

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

% Calcolo rho(presupponendo volume cilindrico)
rho = m / (areaFaccia * l);

% Calcolo c33;
[~, index_min] = min(Zin{1});
fr = f(1,index_min);
c33 = 4 * (fr^2) * (l^2) * rho;

% Calcolo beta33
beta33 = areaFaccia/(C0 * l);

proprietaMisurate = [rho, c33, beta33];

%% Stima della tipologia più probabile di ceramica partendo dai parametri calcolati al passo precedente
strutturaProprietaPzt = caricaStrutturaProprietaPzt();
r = size(strutturaProprietaPzt,1);

% % Colonna 3: nearest neighbor per proprietà (ranking "discreto")
% [strutturaProprietaPzt{:,3}] = deal(0);    % inizializza score a 0
% 
% for i = 1:3
%     indiceMigliore = 0;
%     differenzaMigliore = inf;
%     for j = 1:r
%         proprietaIterazione = strutturaProprietaPzt{j,2}(i);
%         differenzaProprieta = abs(proprietaMisurate(i) - proprietaIterazione);
%         if differenzaProprieta < differenzaMigliore
%             differenzaMigliore = differenzaProprieta;
%             indiceMigliore = j;
%         end
%     end
%     strutturaProprietaPzt{indiceMigliore,3} = strutturaProprietaPzt{indiceMigliore,3} + 1;
% end

% Colonna 4: errore relativo medio sulle 3 proprietà (ranking "continuo")
M = vertcat(strutturaProprietaPzt{:,2});                  % Nx3
errRel = abs((M - proprietaMisurate)./proprietaMisurate); % Nx3
errTot = mean(errRel,2);                                  % Nx1
for i = 1:r
    strutturaProprietaPzt{i,4} = errTot(i);
end

% Ordino le righe rispetto al loro risultato
strutturaProprietaPzt = sortrows(strutturaProprietaPzt, [4], {'ascend'});

% Mostra le prime 3: nome, errore medio
topN = min(3, r);
idx   = 1:topN;
nomi  = vertcat(strutturaProprietaPzt{idx,1});      % string array
% score = cell2mat(strutturaProprietaPzt(idx,3));     % Nx1 double
err   = cell2mat(strutturaProprietaPzt(idx,4));     % Nx1 double

T = table(nomi, err, 'VariableNames', {'Materiali più probabili', 'Errore Relativo Medio'});
T.("Materiali più probabili") = categorical(T.("Materiali più probabili"));
disp(newline)
disp(T)
