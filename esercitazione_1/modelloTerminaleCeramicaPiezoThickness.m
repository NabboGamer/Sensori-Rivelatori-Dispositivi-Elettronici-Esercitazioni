% Questo script implementa il modello terminale dell'elemento 
% piezoelettrico(nel nostro caso una ceramica piezoelettrica) nel modo 
% tickness(siccome lo spessore è nettamente inferiore alle altre dimensioni)

addpath('../utility/');
evalin('base', 'clear'), close all; clc;

[areaFaccia, l, rho, c33, h33, ~, beta33, v, f, omega, theta, C0] = ceramicPicker();

% Impedenza acustica della ceramica in direzione z
ZoD = areaFaccia * v * rho;
        
% Impedenza acustica del carico
Zel = 1E+06; %1MOhm

% Impedenza acustica specifica del mezzo
z1 = specificAcousticImpedancePicker(1);
z2 = specificAcousticImpedancePicker(2);

% Impedenza acustica del mezzo
Z1 = areaFaccia * z1;
Z2 = areaFaccia * z2;

% Matrici A(3x3) e B (2x2)
A = calcolaMatriceA(ZoD, omega, v, l, h33, C0);
B_Z1 = calcolaMatriceB(A, Z2); % side 1
B_Z2 = calcolaMatriceB(A, Z1); % side 2

% Calcolo impedenza elettrica in ingresso
[Zin_Z2, FTT_Z2, FTR_Z2] = calcolaFunzioniDiTrasferimento(B_Z1, Z1, Zel);
[Zin_Z1, FTT_Z1, FTR_Z1] = calcolaFunzioniDiTrasferimento(B_Z2, Z2, Zel);

if(Z1 == Z2)
    var_z = "Zi";
    var_FTT = "TTF";
    % var_TTF_i = "TTF_i";
    var_FTR = "RTF";
else
    var_z = "Impedance Comparing";
    var_FTT = "TTF Comparing";
    % var_TTF_i = "TTF_i Comparing";
    var_FTR = "RTF Comparing";
end

figure(4);
stampaGrafici(f, Zin_Z1{1}, Zin_Z1{2}, var_z, 'blue');
hold on;

figure(5);
stampaGrafici(f, FTT_Z1{1}, FTT_Z1{2}, var_FTT, 'blue');
hold on;

% Grafico della funzione di trasferimento se la ceramica viene pilotata in corrente
% figure(6);
% Grafico(f,TTF_Z1_i{1},TTF_Z1_i{2}, var_TTF_i, 'blue');
% hold on;

figure(7);
stampaGrafici(f, FTR_Z1{1}, FTR_Z1{2}, var_FTR, 'blue');
hold on;

if(Z1 == Z2)
    figure(8);
    subplot(3,1,1);
    semilogx(f ./ 1e+06 , Zin_Z1{1}, 'linewidth', 2);
    title("Zi side1");
    ylabel('Magnitude(dB)');
    xlabel('Frequency [MHz]');
    grid on;
    subplot(3,1,2);
    plot(f ./ 1e+06, FTT_Z1{1}, 'linewidth', 2);
    title("TTF side1"); 
    ylabel('Magnitude(dB)');
    xlabel('Frequency [MHz]');
    grid on;
    subplot(3,1,3);
    plot(f ./ 1e+06, FTR_Z1{1}, 'linewidth', 2);
    title("RTF side1");
    ylabel('Magnitude(dB)');
    xlabel('Frequency [MHz]');
    grid on;

else
    % Se le due impedenze acustiche non sono uguali allora aggiungi al
    % grafico dell'impedenza di Z1 anche il grafico dell'impedenza di Z2
    figure(4);
    stampaGrafici(f, Zin_Z2{1}, Zin_Z2{2}, var_z, 'orange');
    ax1 = subplot(2,1,1);
    ax2 = subplot(2,1,2);
    legend(ax1, 'side 1', 'side 2');
    legend(ax2, 'side 1', 'side 2');

    % Stesso discorso per la funzione di trasferimento in trasmissione
    figure(5);
    stampaGrafici(f, FTT_Z2{1}, FTT_Z2{2}, var_FTT, 'orange');
    ax1 = subplot(2,1,1);
    ax2 = subplot(2,1,2);
    legend(ax1, 'side 1', 'side 2');
    legend(ax2, 'side 1', 'side 2');

%     figure(6);
%     Grafico(f,TTF_Z2_i{1}, TTF_Z2_i{2}, var_TTF_i, 'orange');
%     ax1 = subplot(2,1,1); % Primo subplot
%     ax2 = subplot(2,1,2); % Secondo subplot
%     legend(ax1, 'side 1', 'side 2');
%     legend(ax2, 'side 1', 'side 2');

    figure(7);
    stampaGrafici(f, FTR_Z2{1}, FTR_Z2{2}, var_FTR, 'orange');
    ax1 = subplot(2,1,1);
    ax2 = subplot(2,1,2);
    legend(ax1, 'side 1', 'side 2');
    legend(ax2, 'side 1', 'side 2');

    figure(8);
    subplot(3,2,1);
    semilogx(f ./ 1e+06, Zin_Z1{1}, 'linewidth', 2);
    title("Zi side1");
    ylabel('Magnitude(dB)');
    xlabel('Frequency [MHz]');
    grid on;
    subplot(3,2,3);
    semilogx(f ./ 1e+06, FTT_Z1{1}, 'linewidth', 2);
    title("TTF side1");
    ylabel('Magnitude(dB)');
    xlabel('Frequency [MHz]');
    grid on;
    subplot(3,2,5);
    semilogx(f ./ 1e+06, FTR_Z1{1}, 'linewidth', 2);
    title("RTF side1");
    ylabel('Magnitude(dB)');
    xlabel('Frequency [MHz]');
    grid on;
    subplot(3,2,2);
    semilogx(f ./ 1e+06, Zin_Z2{1}, 'linewidth', 2, 'Color', '#D95319');
    title("Zi side2");
    ylabel('Magnitude(dB)');
    xlabel('Frequency [MHz]');
    grid on;
    subplot(3,2,4);
    semilogx(f ./ 1e+06, FTT_Z2{1}, 'linewidth', 2, 'Color', '#D95319');
    title("TTF side2");
    ylabel('Magnitude(dB)');
    xlabel('Frequency [MHz]');
    grid on;
    subplot(3,2,6);
    semilogx(f ./ 1e+06, FTR_Z2{1}, 'linewidth', 2, 'Color', '#D95319');
    title("RTF side2");
    ylabel('Magnitude(dB)');
    xlabel('Frequency [MHz]');
    grid on;
end
