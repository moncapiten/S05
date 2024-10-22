clear all;

% Data( media) position and name, to retrieve( save) files from( to) the correct position
dataPosition = '../../Data/';
filename = 'dataBode009';
%filename = 'AD8031';

mediaposition = '../../Media/';
medianame = strcat('bodePlotAndFit-', filename);

% flags, change the working code to condition the data differently based on necessity
flagSave = false;
flagdB = false;
flagDeg = false;
flagLimited = false;
limit = 85;

% data import and conditioning
rawData = readmatrix(strcat(dataPosition, filename, '.txt'));

ff = rawData(:, 1);
A = rawData(:, 2);
ph = rawData(:, 8);


if flagdB
    A = 10.^(A/20);
end
if flagDeg
    ph = ph.*pi/180;
end
if flagLimited
    A2 = A(1 : limit);
    f2 = ff(1 : limit);
    p2 = ph(1 : limit);
end

% setting of fit parameters and function
Ra = 3.2822e3;
Rb = 1490.3;
b = Rb / (Ra+Rb);
G = 100;

%G0 = 100;
G0 = G * b;
f0 = 4e5;
tau0 = 1/(2*pi*f0);
p0tf = [G0, tau0];

function y = tf(params, f)
    
    w = 2 * pi * f;
    G = params(1) ./ ( 1 +  w .* 1i * params(2) );
    y = abs(G);
end

function y = tp(params, f)
    
    w = 2 * pi * f;

    G = params(1) ./ ( 1 +  w .* 1i * params(2) );
    y = angle(G);
end



if flagLimited
    [beta, R3, ~, covbeta] = nlinfit(f2, A2, @tf, p0tf);
else
    [beta, R3, ~, covbeta] = nlinfit(ff, A, @tf, p0tf);
end






% double plot, no residuals
t = tiledlayout(2, 1, "TileSpacing", 'tight', 'Padding', 'compact');

ax1 = nexttile;
loglog(ff, A, 'o', Color = '#0027BD');
hold on
if flagLimited
    loglog(f2, A2, 'v', Color = 'green');
    loglog(f2, tf(p0tf, f2), '--', Color= 'magenta')
    loglog(f2, tf(beta, f2), '-', Color= 'red');
else
    loglog(ff, tf(p0tf, ff), '-', Color= 'magenta');
    loglog(ff, tf(beta, ff), '-', Color= 'red');
end



grid on
grid minor

hold off


ax2 = nexttile;
semilogx(ff, ph, 'o', Color= '#0027bd');
hold on
if flagLimited
    semilogx(f2, p2, 'v', Color= 'green');
    semilogx(f2, tp(p0tf, f2), '--', Color= 'magenta')
    semilogx(f2, tp(beta, f2), '-', Color= 'red');
else
    semilogx(ff, tp(p0tf, ff), '-', Color= 'magenta');
    semilogx(ff, tp(beta, ff), '-', Color= 'red');
end

grid on
grid minor
hold off

title(t, strcat('Gain and Phase of Amplifier - ', filename));

if flagLimited
    legend(ax1, 'Original Data', 'Fit Data', 'model - p0', 'model - fit', Location= 'ne');
else
    legend(ax1, 'Original Data', 'model - p0', 'model - fit', Location= 'ne');
end


linkaxes([ax1 ax2], 'x')
ylabel(ax1, 'Gain [pure]');
ylabel(ax2, 'Phase [radians]');
xlabel(ax2, 'Frequency [Hz]');

yticks(ax2, [-pi, -0.75*pi, -pi/2, -pi/4, 0, pi/4, pi/2, 0.75*pi, pi])
yticklabels(ax2, {'-pi', '-3/4\pi', '-\pi/2', '-\pi/4', '0', '\pi/4', '\pi/2', '3/4\pi', '\pi'})

dim = [.08 .55 .3 .3];
str = strcat('G_{\omega \rightarrow 0} = ', sprintf('%.2f', beta(1)/b ) );
annotation('textbox',dim,'String',str,'FitBoxToText','on', 'Interpreter', 'tex', 'BackgroundColor', 'white');
dim = [.08 .5 .3 .3];
str = sprintf('f_c = %.2e Hz', 1/(2*pi*beta(2) ) ) ;
annotation('textbox',dim,'String',str,'FitBoxToText','on', 'Interpreter', 'tex', 'BackgroundColor', 'white');
dim = [.08 .45 .3 .3];
str = sprintf('GBWP = %.2e', 1/(2*pi*beta(2)) * beta(1)/b  ) ;
annotation('textbox',dim,'String',str,'FitBoxToText','on', 'Interpreter', 'tex', 'BackgroundColor', 'white');


% saving only if flag set
if flagSave
    fig = gcf;
    orient(fig, 'landscape')
    print(fig, strcat(mediaposition, medianame, '.pdf'), '-dpdf')
end
