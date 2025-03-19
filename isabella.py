import tdwf
import matplotlib
matplotlib.use('TkAgg')
import matplotlib.pyplot as plt 
import numpy as np
import scipy.optimize as so
import math
    
# -[Parametri di controllo]------------------------------------------------------
nper = 5     
nf   = 100        
npt  = 8192      
f0   = 1e3     
f1   = 1e6
flag_return = False
flag_show = True

# Calcolo dei vettori
fv = np.logspace(np.log10(f0), np.log10(f1), nf) 

# -[Configurazione AD2]--------------------------------------------------------
#   1. Connessiene con AD2 e selezione configurazione 
ad2 = tdwf.AD2()
#   1. Configurazione power supply
ad2.vdd = +5
ad2.vss = -5
ad2.power(True)
#   2. Configurazione generatore di funzioni
wavegen = tdwf.WaveGen(ad2.hdwf)
wavegen.w1.config(offs = 0.7,
               ampl =  0.5,
               freq = 1e3,
               func = tdwf.funcSine,
               duty = 50)


wavegen.w1.start()
#   3. Configurazione oscilloscopio
scope = tdwf.Scope(ad2.hdwf)
scope.fs = 1e6
scope.npt = npt
scope.ch1.rng = 5
scope.ch2.rng = 5

#-[Ciclo di misura]------------------------------------------------------------
#   1. Creazione figura e link agli eventi
fig, [[ax1, ax3], [ax2, ax4]] = plt.subplots(2,2,figsize=(12,6),                                
    gridspec_kw={'width_ratios': [1, 2]})
fig.canvas.manager.set_window_title('Spazzata frequenza')

#   2. Ciclo di misura


flag_first = True
Am   = np.full((nf, 2), np.nan)
phim = np.full((nf, 2), np.nan)
# Initial guess
for ar in range(2 if flag_return else 1):  # go and return loop
    for ii in range(len(fv)):  # frequency loop
        # 1. Impostazione dlela frequenza e del sampling
        if ar==0:
            findex = ii
        else:
            findex = len(fv)-ii-1
        ff = fv[findex]
        # Decimation factor
        df = math.ceil(100e6*nper/(npt*ff))
        scope.fs = 100e6/df
        scope.npt = int(scope.fs*nper/ff)
        scope.trig(True, hist = 0.1)
        wavegen.w1.freq = ff 
        # 2. Campionamento e analisi risultati
        scope.sample()
        fitfunc = lambda x,A,phi,b: A * np.cos(2*np.pi*ff*x + phi)+b
        pp1,cm1 = so.curve_fit(fitfunc, scope.time.vals, scope.ch1.vals, p0=[1,0,0])
        pp2,cm2 = so.curve_fit(fitfunc, scope.time.vals, scope.ch2.vals, p0=[1,0,0])
        epp1 = np.sqrt(np.diagonal(cm1))
        epp2 = np.sqrt(np.diagonal(cm2))
        if pp1[0] < 0:
            pp1[0] *= -1
            pp1[1] += np.pi    
        if pp2[0] < 0:
            pp2[0] *= -1
            pp2[1] += np.pi    
        # 3. Aggiornamento dei dati
        Am[findex, ar]   = pp2[0]/pp1[0]
        phim[findex, ar] = (pp2[1]-pp1[1] + np.pi) % (2*np.pi) - np.pi 
       

        # 4. Aggiornamento plots
        if flag_first:
            flag_first = False
            if flag_show:
                hp1, = ax1.plot(1000*scope.time.vals, scope.ch1.vals, "-", label="Ch1", color="tab:orange")
                hp2, = ax2.plot(1000*scope.time.vals, scope.ch2.vals, "-", label="Ch2", color="tab:blue")
                ax1.grid(True)
                ax2.grid(True)
                ax1.set_xticklabels([])
                ax1.set_ylabel("Ch1 [V]", fontsize=15)
                ax2.set_xlabel("Time [msec]", fontsize=15)
                ax2.set_ylabel("Ch2 [V]", fontsize=15)
                ax1.set_xlim([0, nper/ff])
                ax2.set_xlim([0, nper/ff])
                ax1.set_title(f"Starting")
            hp3A, = ax3.loglog(fv, Am[:, 0], ".", markerfacecolor = "none", 
                               label="Amp go", color="tab:orange")
            hp4A, = ax4.semilogx(fv, phim[:, 0], ".",  markerfacecolor = "none",
                                 label="phi go", color="tab:orange")
            if flag_return:
                hp3R, = ax3.loglog(fv, Am[:, 1], "v",  markerfacecolor = "none",
                                   label="Amp return", color="tab:blue")
                hp4R, = ax4.semilogx(fv, phim[:, 1], "v",  markerfacecolor = "none",
                                     label="phi return", color="tab:blue")
            ax3.grid(True)
            ax4.grid(True)            
            ax3.set_xticklabels([])
            ax3.yaxis.tick_right()
            ax3.yaxis.set_label_position('right')
            ax3.set_ylabel("Gain [pure]", fontsize=15)
            ax4.set_xlabel("Freq [Hz]", fontsize=15)
            ax4.yaxis.tick_right()
            ax4.yaxis.set_label_position('right')
            ax4.set_yticks([-np.pi,-np.pi/2,0,np.pi/2,np.pi])
            ax4.set_yticklabels(["-180","-90","0","+90","+180"])
            ax4.set_ylabel("Phase [deg]", fontsize=15)
            ax3.legend()
            ax4.legend()
            plt.tight_layout()
            plt.show(block=False)    
        else:
            if ff > 1e3:
                title = f"{ff/1e3:.1f}kHz"
            else:
                title = f"{ff:.1f}Hz"
            if scope.fs > 1e6:
                ax1.set_title(title+f" [{scope.npt:d}pts @ {scope.fs/1e6:.1f}MSa/s, ]")
            elif scope.fs > 1e3:
                ax1.set_title(title+f" [{scope.npt:d}pts @ {scope.fs/1e3:.1f}kSa/s, ]")
            else:
                ax1.set_title(title+f" [{scope.npt:d}pts @ {scope.fs:.1f}Sa/s, ]")
            if flag_show:
                hp1.set_xdata(1000*scope.time.vals)
                hp1.set_ydata(scope.ch1.vals)
                hp2.set_xdata(1000*scope.time.vals)
                hp2.set_ydata(scope.ch2.vals)
                ax1.set_xlim([-500*nper/ff, +500*nper/ff])
                ax2.set_xlim([-500*nper/ff, +500*nper/ff])
                mi = scope.ch2.vals.min()
                ma = scope.ch2.vals.max()
                dm = ma-mi
                m0 = (ma+mi)/2
                ax2.set_ylim([m0-0.6*dm,m0+0.6*dm])
            if ar==0:
                hp3A.set_ydata(Am[:, 0])
                hp4A.set_ydata(phim[:, 0])
                ax3.set_xlim([f0,ff])
                ax3.set_ylim([0.5*min(Am[:, 0]),2*max(Am[:, 0])])
                ax4.set_xlim([f0,ff])
            else:
                hp3R.set_ydata(Am[:, 1])
                hp4R.set_ydata(phim[:, 1])
            fig.canvas.draw()
            fig.canvas.flush_events()
        
# ---------------------------------------
ad2.close()