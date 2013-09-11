#-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.
#
# File Name : logL_calc.pyx
#
# Purpose :
#
# Creation Date : 11-09-2013
#
# Last Modified : Wed 11 Sep 2013 04:51:29 PM CDT
#
# Created By : Huan Gui (huangui2@illinois.edu) 
#
#_._._._._._._._._._._._._._._._._._._._._.

import random
from random import shuffle
import math
import os
import numpy as np
from copy import copy
from Train import Train 
def logL_calc(Test_Data, data_weight, sub_beta, m):
    
    method = ["MR-APA", "MR-APPA", "MR-APAPA", "MR-APVPA", "MR-project", "R-Sub-APA", "R-Sub-APPA", "R-Sub-APAPA", "R-Sub-APVPA", "MLTM-R-S-1-2", "MLTM-R-S-1-3", "MLTM-R-S-1-4", "MLTM-R-S-2-3", "MLTM-R-S-2-4", "MLTM-R-S-3-4", "MLTM-R"]

    field_array = [ [2], [3], [4], [5], [6], [3,4,5], [2,4,5], [2,3,5], [2,3,4], [2, 3], [2, 4], [2, 5], [3, 4], [3, 5], [4, 5], [2, 3, 4, 5] ]
    
    path_set = [0, 1]
    for kk in field_array[m]:
        path_set.append(kk)
    path_set.append(7) 
    path_set = np.array(path_set)
    
    total = len(Test_Data[0])
    logL = 0 
    
    for i in range(total):
        v = Test_Data[0][i][0]
        
        pi = (Test_Data[0][i, path_set[2:]] * sub_beta).sum() / (Test_Data[1][i, path_set[2:]] * sub_beta).sum() 

        if v == 1 :
            try:
                logL += math.log(pi) * data_weight[i][0]
            except:
                logL += -1e10
                
        else :
            try:
                logL += math.log(1 - pi) * data_weight[i][0]
            except:
                logL += -1e10
                
    return logL 

