import numpy as np
import matplotlib.pyplot as plt
from scipy.optimize import curve_fit
import tdwf
from time import sleep

ad2 = tdwf.AD2()    

# Set the power supply to +5V/-5V

ad2.vdd = +5
ad2.vss = -5
ad2.power(True)










sleep(10)















ad2.close()









