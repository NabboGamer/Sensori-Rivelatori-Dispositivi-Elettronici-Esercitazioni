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
[~, index_max] = max(Zin{1});
fr = f(1,index_max);
c33 = 4 * (fr^2) * (l^2) * rho;

% Calcolo beta33
beta33 = areaFaccia/(C0 * l);

%% Stima della tipologia più probabile di ceramica partendo dai parametri calcolati al passo precedente
strutturaProprietaPzt = caricaStrutturaProprietaPzt();

% TODO: Per ogni riga della struttura precedente inserire una terza colonna
% che tiene conto dello score totale. Ogni punto score viene assegnato
% confrontando la singola proprietà calcolata(ad esempio rho) con tutte 
% quelle degli elementi della struttura e viene assegnato alla pzt avente
% la stessa proprietà in valore più vicino. Infine viene ordinata la
% struttura in base a quella colonna in ordine decresecnte(la pzt con lo
% score più alto sopra) e vengono stampati le prime 3 righe(solo colonna 1 
% nome e colonna 3 score totale)

