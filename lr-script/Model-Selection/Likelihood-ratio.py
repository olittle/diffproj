#-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.
#
# File Name : Likelihood-ratio.py
#
# Purpose : likelihood ratio test 
#
# Creation Date : 09-09-2013
#
# Last Modified : Tue 10 Sep 2013 10:32:04 AM CDT
#
# Created By : Huan Gui (huangui2@illinois.edu) 
#
#_._._._._._._._._._._._._._._._._._._._._.

import numpy as np 
from copy import copy 
import math 
from scipy import stats

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

fout = open("./likelihood", "w") 
testout = open("./likelihood_test_out", "w")

for f_i in range(datacnt):

    data = open("./logL/logL." + str(f_i))
    for line in data:
        cnt += 1
        value = line.split("\n")[0].split("\t") 
        year = int(value[3])
        year += 1
        topic = int(value[0]) 
        
        print topic, year 
        target = value[4:4 + len(method)]
        for i in range(len(target)):
            target[i] = float(target[i])
        
        logL.append(copy(target))
        
        # Train null model for (topic, year) pair
        train_author = set()
        train_pos = set()
        test_author = set() 
        test_pos = set() 
        
        data = open("../../data/" + str(year - 2) + "/paper_author.txt")
        for line in data:
            value = line.split("\n")[0].split("\t")
            train_author.add(int(value[1]))
        data = open("../../data/" + str(year -1) + "/author_paper_topic") 
        for line in data:
            value = line.split("\n")[0].split("\t")
            t = int(value[1]) 
            if t == topic:
                train_pos.add(int(value[0]))
        
        data = open("../../data/" + str(year - 1) + "/paper_author.txt")
        for line in data:
            value = line.split("\n")[0].split("\t")
            test_author.add(int(value[1]))
            
        
        data = open("../../data/" + str(year) + "/author_paper_topic") 
        for line in data:
            value = line.split("\n")[0].split("\t")
            t = int(value[1]) 
            if t == topic:
                test_pos.add(int(value[0]))
               
        train_len = float(len(train_author))
        train_pos_len = float(len(train_pos)) 
        test_len = float(len(test_author)) 
        test_pos_len = float(len(test_pos)) 
        
        prob = train_pos_len / train_len 
        null_logL = test_pos_len * math.log(prob) + (test_len - test_pos_len) * math.log( 1 - prob)
     
        logL[cnt].append(null_logL) 
   
        print logL[cnt] 
        
        fout.write(str(year + 1) + "\t" + str(topic) + "\t" + str(test_len))
        for i in range(len(logL[cnt])):
            fout.write("\t" + str(logL[cnt][i]))
        fout.write("\n")
        print prob, null_logL
        
        # null v.s. Single meta-path
        single_0 = 5
        null_id = 21 
        testout.write(str(year) + "\t" + str(topic) + "\t" + str(test_len))
        for i in range(4):
            print logL[cnt][single_0 + i], logL[cnt][null_id]
            Lambda = 2 * (logL[cnt][single_0 + i] - logL[cnt][null_id])
            p_value = 1 - stats.chi2.cdf(Lambda, 1)
            testout.write("\t" + str(Lambda) + " " + str(p_value))
            print Lambda, p_value

        # Sub model v.s. full model 
        sub_0 = 10
        full_id = 20 
        for i in range(4):
            print logL[cnt][sub_0 + i], logL[cnt][full_id]
            Lambda = 2 * ( - logL[cnt][sub_0 + i] + logL[cnt][full_id]) 
            p_value = 1 - stats.chi2.cdf(Lambda, 1)
            testout.write("\t" + str(Lambda) + " " + str(p_value))
            print Lambda, p_value
        testout.write("\n")

fout.close()
testout.close() 

