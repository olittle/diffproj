#-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.
#
# File Name : Data-Collect.py
#
# Purpose : Collect the result 
#
# Creation Date : 31-08-2013
#
# Last Modified : Mon 09 Sep 2013 03:01:12 AM CDT
#
# Created By : Huan Gui (huangui2@illinois.edu) 
#
#_._._._._._._._._._._._._._._._._._._._._.


import numpy as np 
from copy import copy 
import math 

#samplesize = {}
#fout = open("../../sourcedata/sample_size", "w")
#for year in range(1970, 2010):
#    data = open("../../data/" + str(year - 1) + "/paper_author.txt")
#    authors = set() 
#    for line in data:
#        value = int(line.split()[1])
#        authors.add(value)
#    
#    samplesize[year] = len(authors)
#        
#for year in samplesize:
#    fout.write(str(year) + "\t" + str(samplesize[year]) + "\n")
#
#fout.close()


samplesize = {} 
data = open("../../sourcedata/sample_size")
for line in data:
    value = line.split()
    year = int(value[0])
    size = int(value[1]) 
    samplesize[year] = size 
    

method = ["Homo-equal-weight", "Homo-APA", "Homo-APPA", "Homo-APAPA", "Homo-APVPA", "MH-APA", "MH-APPA", "MH-APAPA", "MH-APVPA", "MH-project", "M-Sub-APA", "M-Sub-APPA", "M-Sub-APAPA", "M-Sub-APVPA", "MLTM-S-1-2", "MLTM-S-1-3", "MLTM-S-1-4", "MLTM-S-2-3", "MLTM-S-2-4", "MLTM-S-3-4", "MLTM-M"]

field_array = [ [2,3,4,5], [2], [3], [4], [5], [2], [3], [4], [5], [6], [3,4,5], [2,4,5], [2,3,5], [2,3,4], [2, 3], [2, 4], [2, 5], [3, 4], [3, 5], [4, 5], [2, 3, 4, 5] ]

datacnt = 6

AUC = [] 
AUPR = []
logL = []
Global = []

cnt = -1 

for f_i in range(datacnt):

    data = open("./logL/logL." + str(f_i))
    for line in data:
        cnt += 1
        value = line.split("\n")[0].split("\t") 
        year = int(value[3])
        topic = int(value[0]) 
        
        target = value[4:4 + len(method)]
        for i in range(len(target)):
            target[i] = float(target[i])
        
        logL.append(copy(target))
        
        best_m = 0 
        best_AICc = 1e20 
        for i in range(len(target)):
            if i < 5:
                continue 
            k = float(len(field_array[i]))
            AICc = 2 * k - 2 * logL[cnt][i] + 2 * k * (k + 1) / (samplesize[year] - k - 1) 
            if AICc < best_AICc:
                best_AICc = AICc
                best_m = i 
        Global[cnt].append(Global[cnt][best_m]) 
        
            
        best_m = 0 
        best_BIC = 1e20 
        for i in range(len(target)):
            if i < 5:
                continue 
            k = float(len(field_array[i]))
            BIC = k * math.log(samplesize[year]) - 2 * logL[cnt][i]
            if BIC < best_BIC:
                best_BIC = BIC
                best_m = i 
        
        AUC[cnt].append(AUC[cnt][best_m]) 
        AUPR[cnt].append(AUPR[cnt][best_m]) 
        logL[cnt].append(logL[cnt][best_m]) 
        Global[cnt].append(Global[cnt][best_m])


AUC = np.array(AUC)
AUPR = np.array(AUPR)
logL = np.array(logL)
Global = np.array(Global)

print np.mean(Global[:, 0]) 
Global[:, 0] = (Global[:, 0] + 1.0) / 4.0 - 1.0 
print np.mean(Global[:, 0])

method = ["Homo-equal-weight", "Homo-APA", "Homo-APPA", "Homo-APAPA", "Homo-APVPA", "MH-APA", "MH-APPA", "MH-APAPA", "MH-APVPA", "MH-project", "M-Sub-APA", "M-Sub-APPA", "M-Sub-APAPA", "M-Sub-APVPA", "MLTM-S-1-2", "MLTM-S-1-3", "MLTM-S-1-4", "MLTM-S-2-3", "MLTM-S-2-4", "MLTM-S-3-4", "MLTM-M", "MLTM-AIC", "MLTM-BIC"]
for i in range(len(method)):
    m_AUC = AUC[:, i]
    m_AUPR = AUPR[:, i]
    m_logL = logL[:, i]
    m_Global = Global[:, i] 

    print method[i], "AUC", np.mean(m_AUC), np.std(m_AUC), "AUPR", np.mean(m_AUPR), np.std(m_AUPR), "logL", np.mean(m_logL), np.std(m_logL), "Global", np.mean(m_Global), np.std(m_Global)
    

#for i in range(len(AUC)):
#    print AUC[i]
#    print AUPR[i]
#    print logL[i]
#    print Global[i] 
#    

