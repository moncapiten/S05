clear all;

filename = ['data004'];
dataposition = '../../Data/';

mediaposition = '../../Media/Notch/'
medianame = strcat("PulsedOP77-", filename);

% importing data and manipulation to obtain transfer function
rawdata = readmatrix(strcat(dataposition, filename, '.txt'));



flagSave = true;
confPlot = 3;
flagp0 = false;
thr = 1;


tt = rawdata(:, 1);
vi = rawdata(:, 2);
vo = rawdata(:, 3);

if(confPlot > 1)
    dt = mean( diff( tt));
    fs = 1/dt
    N = length(tt);
    
    Hv = fft(vo)./fft(vi);
    Hv = Hv(1:N/2+1);
    fv = (0:N/2)*fs/N;
    
    
    % removing data overly contaminated by noise
    Hv(abs(fft(vo))<thr)=NaN;
    fv(abs(fft(vo))<thr)=NaN;
end

% flag to see original signals transform, in case useful


%************************************************************************************************************************
%{
yi = fftshift( fft(vi) );
yi = yi(N/2, end);
yo = fftshift( fft(vo) );
yo = yo(N/2, end);


% plots

if ~plotPulsed
    plot(fv, abs(yi), 'o', Color= 'Blue');
    hold on
    %plot(fv, abs(yo), 'v', Color= 'Red');
    grid on
    grid minor
    hold off

end
%}
%****************************************************************************************************************************



%R = 325;
%R2 = 97;
%L = 0.104;
%p0tf = [R, R2, L];


R = 330; 
R2 = 100;
C = 110e-9;
L = 0.1;

p0tf = [C, L];





function y = H(params, f)
    w = 2 * pi * f;
    
    %G = (params(2) + 1i * w * params(3)) ./ ( params(1) + params(2) + 1i * w * params(3) );
    R2 = 99.9;
    y  = ( 1i * w * R2 - w.^2 * params(2) ) ./ ( 1/params(1) + 1i*w*R2 - w.^2 * params(2));
end

function y = tf(params, f)
    w = 2 * pi * f;

    y = abs(H(params, w));

end







if confPlot == 3
    t = tiledlayout(2, 1, "TileSpacing","tight", "Padding","tight");
    title(t, strcat('Compound fit - '), filename);


end


if confPlot >=2
    if confPlot == 3
        ax1 = nexttile;
    end
    loglog(fv, abs(Hv), 'o');
    hold on
    if flagp0
        ff = logspace(0, 6, 100);
        loglog(ff, tf(p0tf, ff));
%        loglog(fv, tf(p0tf, ff), '--', Color = 'red');
    end
    grid on
    grid minor
    title(strcat('Fourier transform of pulsed measurement ', filename));
    ylabel('Amplitude [pure]');
    xlabel('Frequency [Hz]');
    %ylim([0.05, 2]);
    dim = [.15 .55 .3 .3];
    str = ['Threshold = ' sprintf('%.2f', thr) ];
    annotation('textbox',dim,'String',str,'FitBoxToText','on');
    hold off

end

if ~(confPlot == 2)
    if confPlot == 3
        ax2 = nexttile;
    end
    plot(tt, vi, 'o', Color= '#0027bd');
    hold on
    plot(tt, vo, 'v', Color= 'red');
    grid on
    grid minor
    title(strcat('Simple data plot - ', filename))
    ylabel('Voltage [V]');
    xlabel('Frequency [Hz]');

    hold off

end






% saving only if flag set
if flagSave
    fig = gcf;
    orient(fig, 'landscape')
    print(fig, strcat(mediaposition, medianame, '.pdf'), '-dpdf')
end
