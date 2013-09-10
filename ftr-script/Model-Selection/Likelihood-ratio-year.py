#-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.
#
# File Name : Likelihood-ratio.py
#
# Purpose : likelihood ratio test 
#
# Creation Date : 09-09-2013
#
# Last Modified : Tue 10 Sep 2013 03:43:29 AM CDT
#
# Created By : Huan Gui (huangui2@illinois.edu) 
#
#_._._._._._._._._._._._._._._._._._._._._.

import numpy as np 
from copy import copy 
import math 
from scipy import stats

Test = ["null v.s. APA", "null v.s. APPA", "null v.s. APAPA", "null v.s. APVPA",  ]

Lambda_dict = {}
for i in range(8):
    Lambda_dict[i] = {} 

count = {} 
logL = []

testout = open("./likelihood_test_out_year", "w")

data = open("./likelihood")
for line in data:
    value = line.split()
    L = value[3:]
    for x in range(len(L)):
        L[x] = float(L[x])
    logL.append(copy(L))

    year = int(value[0]) 
    
    if year not in Lambda_dict[0]:
        for i in range(8):
            Lambda_dict[i][year] = []
            count[year] = 0 
    count[year] += 1
        
    # null v.s. Single meta-path
    single_0 = 0
    null_id = 16 
    
    for i in range(4):
        Lambda = 2 * (logL[-1][single_0 + i] - logL[-1][null_id])
        Lambda_dict[i][year].append(Lambda)

    # Sub model v.s. full model 
    sub_0 = 5
    full_id = 15 
    for i in range(4):
        Lambda = 2 * ( - logL[-1][sub_0 + i] + logL[-1][full_id]) 
        Lambda_dict[i+4][year].append(Lambda)

for i in range(8):
    for year in count:
        Lambda_dict[i][year] = np.array(Lambda_dict[i][year]).sum() 


for year in count:
    testout.write(str(year) + "\t")
    for i in range(8):
        p_value = 1 - stats.chi2.cdf(Lambda_dict[i][year], count[year]) 
        print year, i, p_value, Lambda_dict[i][year], count[year]  
        testout.write(str(p_value) + "\t")
    testout.write("\n")

testout.close() 

