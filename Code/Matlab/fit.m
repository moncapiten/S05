clear all;

dataPosition = '../../Data/';
filename = 'data001';

mediaposition = '../../Media/';
medianame = strcat('plot', filename);

flagSave = false;
flagFit = false;
% data import and creation of variance array
rawData = readmatrix(strcat(dataPosition, filename, '.txt'));

tt = rawData(:, 1);
vi = rawData(:, 2);
s_i = repelem(2.2e-2, length(tt));
vo = rawData(:, 3);
s_o = repelem(5.3e-2, length(tt));

% preparation of fitting function and p0 parameters
function y = funcSine(params, t)
    w = 2 * pi * params(2);
    y = params(1) .* sign( sin( w*t + params(3)) );%+ params(4);
end


function y = funcSquare(params, t)
    w = 2*pi*params(2);
    % t: time vector
    % duty: duty cycle in percentage (0 to 100)
    % freq: frequency of the square wave
    % amplitude: peak amplitude of the wave
    
    y = params(1) * (square( w * t + params(3), 0.01) );
end
%function y = funcSquare(params, t)
%    w = 2 * pi .* params(2);
%    y = params(1) .* sign( sin( w*t + params(3) ) ) ;%+ params(4);
%end

R1 = 997.1;
R2 = 100200;
G = 1+R2/R1;

Ra = 3282.2;
Rb = 1490.3;
A = Rb/(Ra+Rb);

f0 = 1;
%ai = A*0.1;
ai = 2;
%ao = G * ai;
ao = 5;
ph0i = 0;
ph0o = pi*13/16;
oi = 0;
oo = G * oi;


p0i = [ ai, f0, ph0i, oi];
p0o = [ ao, f0, ph0o, oo];








% fit and k^2 calculation
[betai, Ri, ~, covbetai] = nlinfit(tt, vi, @funcSquare, p0i);
%[betao, Ro, ~, covbetao] = nlinfit(tt, vo, @funcSine, p0o);
[betao, Ro, ~, covbetao] = nlinfit(tt, vo, @funcSine, p0o);

%vo1 = [];
%tt1 = [];
%for i = 1:length(Ro)
%    if abs(Ro(i)) < 0.7
%        vo1 = [vo1, vo(i)];
%        tt1 = [tt1, tt(i)];
%    end
%end

%length(vo) - length(vo1)

%[betao, Ro1, ~, covbetao] = nlinfit(tt1, vo1, @funcSquare, betao);




ki = 0;
for i = 1:length(Ri)
    ki = ki + Ri(i)^2/s_i(i)^2;
end
ki = ki/(length(tt)-4);

%ko = 0;
%for i = 1:length(Ro1)
%    ko = ko + Ro1(i)^2/s_o(i)^2;
%end
%ko = ko/(length(tt)-4);


%ki
%ko

if flagFit
    % plot seffing and execution
    t = tiledlayout(2, 2, "TileSpacing","tight", "Padding","tight");
    
    % plot of the data, prefit and fit
    ax1 = nexttile([1 2]);
    
    %errorbar(tt, vi, s_i, )
    %plot(tt, vi, 'o', Color="#0072BD");
    errorbar(tt, vi, s_i, 'o', Color= "#0027BD");
    hold on
    errorbar(tt, vo, s_o, 'v', Color= "Red");
%    errorbar(tt1, vo1, s_o(1:length(vo1)), 'v', Color= 'Green');
    %plot(tt, vo, 'o', Color="Red");
    
    plot(tt, funcSquare(p0i, tt), '--', Color = 'cyan');
    %plot(tt, funcSine(p0o, tt), '--', Color = '#FFa500');
    plot(tt, funcSquare(p0o, tt), '--', Color = '#FFa500');
    
    plot(tt, funcSquare(betai, tt), '-', Color = '#0047AB');
    %plot(tt, funcSine(betao, tt), '-', Color = 'Magenta');
    plot(tt, funcSquare(betao, tt), '-', Color = 'Magenta');

    hold off
    grid on
    grid minor
    
    
    % residual plots for both fits
    ax2 = nexttile([1 1]);
    plot(tt, repelem(0, length(tt)), '--', Color= 'black');
    hold on
    %errorbar(Ri, s_i, 'o', Color= '#0027BD');
    %plot(tt, Ri, 'o', Color= '#0072BD');
    errorbar(tt, Ri, s_i, 'o', Color= '#0072BD');
    %set(gca, 'XScale','log', 'YScale','lin')
    hold off
    grid on
    grid minor
    
    
    
    ax3 = nexttile([1 1]);
    plot(tt, repelem(0, length(tt)), '--', Color= 'black');
    hold on
    %errorbar(Ri, s_i, 'o', Color= '#0027BD');
    %plot(tt, Ri, 'o', Color= '#0072BD');
    errorbar(tt, Ro, s_o, 'v', Color= 'Red');
 %   errorbar(tt1, Ro1, s_o(1:length(Ro1)), 'v', Color= 'green');
    %set(gca, 'XScale','log', 'YScale','lin')
    hold off
    grid on
    grid minor
    
    
    
    % plot seffings
    title(t, strcat('Fit and residuals of Amplitude Fit - ', filename));
    t.TileSpacing = "tight";
    linkaxes([ax1, ax2, ax3], 'x');
    linkaxes([ax2, ax3], 'y');

    
    
    %xlabel(ax1, 'frequency [Hz]')
    ylabel(ax1, 'Amplitude [V]')
    legend(ax1, 'data - in', 'data - out', 'data - out (to fit)', 'modell in - p0', 'model out - p0', 'model in - fitted', 'model out - fitted', Location= 'ne')
    dimi = [.06 .65 .3 .3];
    dimo = [.06 .60 .3 .3];
    stri = ['$ k^2 \,\,\,in$ = ' sprintf('%.2f', ki) ];
    stro = ['$ k^2 \,\,\,out$ = ' sprintf('%.2f', ko) ];
    annotation('textbox', dimi, 'interpreter','latex','String',stri,'FitBoxToText','on', 'BackgroundColor', 'white');
    annotation('textbox', dimo, 'interpreter','latex','String',stro,'FitBoxToText','on', 'BackgroundColor', 'white');
    
    
    xlabel(ax1, 'time [s]');
    xlabel(ax2, 'time [s]');
    xlabel(ax3, 'time [s]');
    ylabel(ax2, 'Amplitude - Residuals [V]');
else
    errorbar(tt, vi, s_i, 'o', Color= "#0027BD");
    hold on
    errorbar(tt, vo, s_o, 'o', Color= "Red");
    grid on
    grid minor
    

    title(strcat('Data plot - ', filename))
    xlabel('time [s]');
    ylabel('Amplitude [V]')
    legend('data - in', 'data - out');
    hold off



end

% image saving
if flagSave
    fig = gcf;
    orient(fig, 'landscape')
    print(fig, strcat(mediaposition, medianame, '.pdf'), '-dpdf')
end


betai
betao





%sqrt(covbetao(1))/sqrt(covbetai(1))

