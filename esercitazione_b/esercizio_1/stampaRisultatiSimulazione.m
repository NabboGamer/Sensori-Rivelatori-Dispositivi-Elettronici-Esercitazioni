% Questo script si occupa di stampare i risultati ottenuti dalla
% simulazione in ANSYS

evalin('base', 'clear'); close all; clc;

%% Impedenza d'ingresso
opts = detectImportOptions('./out/impedance.txt', ...
                           'FileType','text', ...
                           'NumHeaderLines', 18, ...
                           'Delimiter', ' ', ...
                           'ConsecutiveDelimitersRule','join');

T = readtable('./out/impedance.txt', opts);
% Rimuove Var1 poichè ad essa viene assegnato lo spazio iniziale
T(:,1) = []; 

f     = T{:,1}';     % Frequenza [Hz]
ReZin = T{:,4}';     % Parte reale
ImZin = T{:,5}';     % Parte immaginaria
Zin   = ReZin + 1i*ImZin;

[moduloZin, faseZin] = calcolaModuloEFase(Zin, false, true);


%------------------------------------------------------------------------STAMPA------------------------------------------------------------------------%
figure(1);
ax1 = subplot(2,1,1);
modifiedLegendString = "|Zin|";
modifiedyAxisString = "|Zin|";
f = f ./ 1e+03;
moduloZin = moduloZin ./ 1e+03;
semilogy(f, moduloZin, "Color", '#0072BD', 'DisplayName', modifiedLegendString);
ylabel(ax1, modifiedyAxisString + ' [kΩ]');
xlabel(ax1,'Frequency [kHz]');
grid on;
hold on;
[~, index_min] = min(moduloZin);
[~, index_max] = max(moduloZin);
plot(f(1,index_max), moduloZin(index_max), 'black.','HandleVisibility','off');
labelString = strcat("Max", [newline 'Module: '], " ", string(moduloZin(index_max)), [newline 'Frequency: '], " ", string(f(1,index_max)));
text(ax1, f(1,index_max), moduloZin(index_max), labelString, 'Clipping', 'on');
xmax = xline(f(1,index_max),'-.', '','Color','black', 'HandleVisibility', 'off');
xmax.LabelVerticalAlignment = 'bottom';
xmax.LabelHorizontalAlignment = 'left';
plot(f(1,index_min), moduloZin(index_min), 'black.', 'HandleVisibility','off');
labelString = strcat("Min", [newline 'Module: '], " ", string(moduloZin(index_min)), [newline 'Frequency: '], " ", string(f(1,index_min)));
text(ax1, f(1,index_min), moduloZin(index_min), labelString, 'Clipping', 'on');
xmin = xline(f(1,index_min),'-.', '','Color','black', 'HandleVisibility', 'off');
xmin.LabelVerticalAlignment = 'bottom';
xmin.LabelHorizontalAlignment = 'left';
lgd1 = legend(ax1, 'Location', 'northeast');
set(ax1,'XMinorTick','on','YMinorTick','on');
ax2 = subplot(2,1,2);
modifiedLegendString = "Arg(Zin)";
modifiedyAxisString = "Arg(Zin)";
plot(f, faseZin, "Color", '#0072BD', 'DisplayName', modifiedLegendString);
ylabel(ax2, modifiedyAxisString + " [deg]");
xlabel(ax2, 'Frequency [kHz]');
grid on;
hold on;
lgd2 = legend(ax2, 'Location', 'northeast');
set(ax2,'XMinorTick','on','YMinorTick','on');
sgtitle("Impedance")
% -----------------------------------------------------------------------------------------------------------------------------------------------------%


%% Spostamento
opts = detectImportOptions('./out/displacement.txt', ...
                           'FileType','text', ...
                           'NumHeaderLines', 18, ...
                           'Delimiter', '\t', ...
                           'ConsecutiveDelimitersRule','join');

R = readtable('./out/displacement.txt', opts);

f     = R{:,1}';     % Frequenza [Hz]
magS  = R{:,2}';     % Ampiezza
phS   = R{:,3}';     % Fase


%------------------------------------------------------------------------STAMPA------------------------------------------------------------------------%
figure(2);
ax3 = subplot(2,1,1);
modifiedLegendString = "s";
modifiedyAxisString = "s";
f = f ./ 1e+03;
semilogy(f, magS, "Color", '#0072BD', 'DisplayName', modifiedLegendString);
ylabel(ax3, modifiedyAxisString + ' [m/V]');
xlabel(ax3,'Frequency [kHz]');
grid on;
hold on;
[~, index_min] = min(magS);
[~, index_max] = max(magS);
plot(f(1,index_max), magS(index_max), 'black.','HandleVisibility','off');
labelString = strcat("Max", [newline 'Module: '], " ", string(magS(index_max)), [newline 'Frequency: '], " ", string(f(1,index_max)));
text(ax3, f(1,index_max), magS(index_max), labelString, 'Clipping', 'on');
xmax = xline(f(1,index_max),'-.', '','Color','black', 'HandleVisibility', 'off');
xmax.LabelVerticalAlignment = 'bottom';
xmax.LabelHorizontalAlignment = 'left';
lgd3 = legend(ax3, 'Location', 'northeast');
set(ax3,'XMinorTick','on','YMinorTick','on');
ax4 = subplot(2,1,2);
modifiedLegendString = "Arg(s)";
modifiedyAxisString = "Arg(s)";
plot(f, phS, "Color", '#0072BD', 'DisplayName', modifiedLegendString);
ylabel(ax4, modifiedyAxisString + " [deg]");
xlabel(ax4, 'Frequency [kHz]');
grid on;
hold on;
lgd4 = legend(ax4, 'Location', 'northeast');
set(ax2,'XMinorTick','on','YMinorTick','on');
sgtitle("Displacement")
% -------------------------------------------------------------------------------------------------------------------------------------------------------%

