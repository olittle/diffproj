#-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.
#
# File Name : Training-likelihood.py
#
# Purpose : Calculate the log likelihood for training data, then compute AIC, and BIC, and do model selection 
#
# Creation Date : 11-09-2013
#
# Last Modified : Wed 11 Sep 2013 05:08:41 PM CDT
#
# Created By : Huan Gui (huangui2@illinois.edu) 
#
#_._._._._._._._._._._._._._._._._._._._._.

import numpy as np 
import random
from random import shuffle
import math
import os
import numpy as np
from copy import copy
from Ftr_Ext import Ftr_Ext
from logL_calc import logL_calc
import sys

samplesize = {} 
data = open("../../sourcedata/sample_size")
for line in data:
    value = line.split()
    year = int(value[0])
    size = int(value[1]) 
    samplesize[year] = size 

index_target = int(sys.argv[1])

fout = open("./training-likelihood." + str(index_target) , "w")

method = ["MR-APA", "MR-APPA", "MR-APAPA", "MR-APVPA", "MR-project", "R-Sub-APA", "R-Sub-APPA", "R-Sub-APAPA", "R-Sub-APVPA", "MLTM-R-S-1-2", "MLTM-R-S-1-3", "MLTM-R-S-1-4", "MLTM-R-S-2-3", "MLTM-R-S-2-4", "MLTM-R-S-3-4", "MLTM-R"]

field_array = [ [2], [3], [4], [5], [6], [3,4,5], [2,4,5], [2,3,5], [2,3,4], [2, 3], [2, 4], [2, 5], [3, 4], [3, 5], [4, 5], [2, 3, 4, 5] ]

data_folder = "../../data-threshold-cnt/"

datacnt = 12

logL_array = {}

cnt = 0 
for f_i in range(datacnt):
    if f_i % 4 != index_target:
        continue
    data = open("./coefficient/coefficient." + str(f_i))
    for line in data:
        value = line.split("\n")[0].split("\t") 
        beta = value[4:]
        for i in range(len(beta)):
            beta[i] = float(beta[i]) 
        beta = np.array(beta) 
        topic = int(value[1])
        year = int(value[0])
        trainyear = year - 1 
        m = int(value[2]) 
        if (trainyear, topic) not in logL_array:
            cnt += 1
            Train_Data, Data_weight = Ftr_Ext(year, data_folder, topic)
            logL_array[(trainyear, topic)] = np.zeros(16)
        
        logL = logL_calc(Train_Data, Data_weight, beta, m)
        
        logL_array[(trainyear, topic)][m] = logL 
    
        print year, topic, m, logL
        
        
for pair in logL_array:
    year = pair[0] + 1
    topic = pair[1] 
    fout.write(str(year) + "\t" + str(topic))
    
    for i in range(len(logL_array[pair])):
        fout.write("\t" + str(logL_array[pair][i]))
    fout.write("\n")
    
fout.close() 
