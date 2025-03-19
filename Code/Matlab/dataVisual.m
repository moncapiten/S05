dataPosition = '../../Data/000%/';
filename = 'data006';

flagSave = false;

%dataPosition = '../../Data/';
%filename = 'data009';

Rl  = 470;
Rph = 221.72e3;


% data import and creation of variance array
rawData = readmatrix(strcat(dataPosition, filename, '.txt'));

tt = rawData(:, 1);
vi = rawData(:, 2);
vo = rawData(:, 3);


%io = vo/R;

plot(tt, vi, 'o', Color = '#0027BD');
hold on
plot(tt, vo, 'o', Color = '#FF7F00');


thr1 = 2.95;
thr2 = 3.8;


if filename(end) == '4'
    thr1 = 2.3;
    thr2 = 3.1;
    Rph = 100.3e3;
elseif filename(end) == '5'
    thr1 = 2.0;
    thr2 = 2.8;
    Rph = 100.3e3;
elseif filename(end) == '6' || filename(end) == 'A'
    thr1 = 1.85;
    thr2 = 2.6;
    Rph = 22.131e3;
end


Vl = [];
Vp = [];
ttw = [];
for i = 1:length(tt)
    if tt(i) > thr1 && tt(i) < thr2
        ttw(end+1) = tt(i);
        Vl(end+1) = vo(i);
        Vp(end+1) = vi(i);
    end
end
plot(ttw, Vp, 'x', Color = '#00FF00');
plot(ttw, Vl, 'x', Color = '#00FF00');
%plot(tt, io, 'v', Color = 'magenta');

grid on
grid minor
title('Amlitude and Ottset of input signal');
legend('photodiode', 'LED', 'Amplitude in - 45k divider', 'Ottset in - 45k divider', Location= 'ne')
ylabel(' I [A]')
xlabel('V-I supply Voltagə [V]')

hold off

%Il = mean( Vl) / Rl
Ip = mean( Vp) / Rph
%s_Il = std( Vl)
s_Vp = std( Vp ) / mean(Vp) * Ip




if flagSave
    fig = gcf;
    orient(fig, 'landscape')
    print(fig, strcat(mediaposition, medianame, '.pdf'), '-dpdf')
end
