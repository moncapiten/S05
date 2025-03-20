clear all;

% Data( media) position and name, to retrieve( save) files from( to) the correct position
dataPosition = '../../Data/';
filename = 'dataBode003';
%filename = 'AD8031';

mediaposition = '../../Media/';
medianame = strcat('simulationHPFnoR2-', filename);

% flags, change the working code to condition the data differently based on necessity
flagSave = false;
flagdB = false;
flagDeg = false;
flagR2 = false;
flagLimited = true;
limit = 70;

% data import and conditioning
rawData = readmatrix(strcat(dataPosition, filename, '.txt'));

ff = rawData(:, 1);
A = rawData(:, 2);
ph = rawData(:, 3);


if flagdB
    A = 10.^(A/20); %#ok<UNRCH>
end
if flagDeg
    ph = ph.*pi/180; %#ok<UNRCH>
end
if flagLimited
    A2 = A(1 : limit);
    f2 = ff(1 : limit);
    p2 = ph(1 : limit);
end

% setting of fit parameters and function
%b = 1;

R = 330; 
R2 = 100;
L = 0.1;

%tau0 = L/R;
if flagR2
    p0tf = [R, L, R2];
else
    p0tf = [R, L];
end


function y = H(params, w)
%    y = (params(2) + 1i * w * params(3)) ./ ( params(1) + params(2) + 1i * w * params(3) );

    R2 = 99.9;
    y = (R2 + 1i * w * params(2)) ./ ( params(1) + R2 + 1i * w * params(2) );
end


function y = tf(params, f)
    
    w = 2 * pi * f;
    y = abs(H(params, w));
end

function y = tp(params, f)
    
    w = 2 * pi * f;
    y = angle(H(params, w));
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
    loglog(ff, tf(p0tf, ff), '--', Color= 'magenta');
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
    semilogx(ff, tp(p0tf, ff), '--', Color= 'magenta');
    semilogx(ff, tp(beta, ff), '-', Color= 'red');
end

grid on
grid minor
hold off

title(t, strcat('Gain and Phase of HPF - ', filename));

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
str = strcat('R = ', sprintf('%.3f', beta(1) ), '\pm', sprintf('%.3f', sqrt(covbeta(1, 1)) ),  '\Omega' );
annotation('textbox',dim,'String',str,'FitBoxToText','on', 'Interpreter', 'tex', 'BackgroundColor', 'white');
dim = [.08 .5 .3 .3];
str = strcat('L = ', sprintf('%.3f', beta(2) ), '\pm', sprintf('%.3f', sqrt(covbeta(2, 2))*7 ),  'H' );
annotation('textbox',dim,'String',str,'FitBoxToText','on', 'Interpreter', 'tex', 'BackgroundColor', 'white');
if flagR2
    dim = [.08 .45 .3 .3];
    str = strcat('R2 = ', sprintf('%.3f', beta(3) ), '\pm', sprintf('%.3f', sqrt(covbeta(3, 3)) ),  '\Omega' );
    annotation('textbox',dim,'String',str,'FitBoxToText','on', 'Interpreter', 'tex', 'BackgroundColor', 'white');
end

% saving only if flag set
if flagSave
    fig = gcf;
    orient(fig, 'landscape')
    print(fig, strcat(mediaposition, medianame, '.pdf'), '-dpdf')
end
