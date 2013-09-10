#-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.
#
# File Name : Extract-Coefficient.py
#
# Purpose : Extract the coefficients of the models
#
# Creation Date : 10-09-2013
#
# Last Modified : Tue 10 Sep 2013 12:44:41 PM CDT
#
# Created By : Huan Gui (huangui2@illinois.edu) 
#
#_._._._._._._._._._._._._._._._._._._._._.

import numpy as np 
from copy import copy 
import math 
from scipy import stats

method = ["MR-APA", "MR-APPA", "MR-APAPA", "MR-APVPA", "MR-project", "R-Sub-APA", "R-Sub-APPA", "R-Sub-APAPA", "R-Sub-APVPA", "MLTM-R-S-1-2", "MLTM-R-S-1-3", "MLTM-R-S-1-4", "MLTM-R-S-2-3", "MLTM-R-S-2-4", "MLTM-R-S-3-4", "MLTM-R"]

field_array = [ [2], [3], [4], [5], [6], [3,4,5], [2,4,5], [2,3,5], [2,3,4], [2, 3], [2, 4], [2, 5], [3, 4], [3, 5], [4, 5], [2, 3, 4, 5] ]

datacnt = 12

coe_out = open("./coefficient", "w")

for f_i in range(datacnt):
    data = open("./nohup/nohup." + str(f_id)).readlines()
    length = len(data) 
    
    for i in range(
    
