#-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.
#
# File Name : Independent_Threshold_Model.py
#
# Purpose : Make Multiple Prediction
#
# Creation Date : 04-09-2013
#
# Last Modified : Tue 10 Sep 2013 12:50:55 PM CDT
#
# Created By : Huan Gui (huangui2@illinois.edu)
#
#_._._._._._._._._._._._._._._._._._._._._.

import sys
import os
import copy
from C_Gen import C_Gen
from Ftr_Ext import Ftr_Ext
from Test import Test
from Train import Train
from Update_Label import Update_Label
from random import shuffle
import numpy as np
from copy import copy

TargetSet = []
Start_set = {}
End_set = {}

topicfile = open("../../sourcedata/topic_target", "r")
topicdata = topicfile.readlines()
topicfile.close()

for line in topicdata:
    value = line.split("\n")[0].split()
    tpc = int(value[0])
    sty = int(value[1])
    edy = int(value[2])
    TargetSet.append(tpc)
    Start_set[tpc] = sty
    End_set[tpc] = edy

topic_match = {}
data = open("../../sourcedata/keywords_match.txt")
for line in data:
    value = line.split("\n")[0].split("\t")
    kid = int(value[0])
    topic_match[kid] = value


out_folder = "../../data-threshold-cnt/"

target_index = int(sys.argv[1]) 

method = ["Homo-equal-weight", "Homo-APA", "Homo-APPA", "Homo-APAPA", "Homo-APVPA", "MH-APA", "MH-APPA", "MH-APAPA", "MH-APVPA", "MH-project", "M-Sub-APA", "M-Sub-APPA", "M-Sub-APAPA", "M-Sub-APVPA", "MLTM-S-1-2", "MLTM-S-1-3", "MLTM-S-1-4", "MLTM-S-2-3", "MLTM-S-2-4", "MLTM-S-3-4", "MLTM-M", "MLTM-Best-AIC", "MLTM-Best-BIC"]


mesure = ["AUC", "AUPR", "logL", "global"]

for x in measure:
    os.system("mkdir " + x) 
fout = {}
fout[1] = open("./AUC/AUC." + str(target_index)   , "w")
fout[2] = open("./AUPR/AUPR." + str(target_index)   , "w")
fout[3] = open("./logL/logL." + str(target_index)  , "w")
fout[4] = open("./global/globa." + str(target_index)  , "w")

x = 0

for topic in TargetSet:
    x += 1
    if x % 6 != target_index:
        continue 
    
    target = topic

    StartYear = Start_set[topic]
    EndYear = End_set[topic]

    for year in range(StartYear, EndYear):
        
        author_set = set() 
        candidates= set()
        
        Train_Data, weight = Ftr_Ext(year, out_folder, topic)
#        beta = Train(Train_Data, year, out_folder, weight)

        beta_0 = 0
        ground_truth = 0
        result_arr = {}
        result_arr[1], result_arr[2], result_arr[3], result_arr[4], best_m = Test(year + 1, out_folder,  Train_Data, weight, topic)
        result_out.write(str(topic) +"\t" +str(year)  +"\t" + str(best_m) + "\n")
        
        for i in result_arr:
            result_arr[i] = np.array(result_arr[i])
            if i != 4:
                min_index = result_arr[i].argmax()
            else:
                min_index = result_arr[i].argmin()
            fout[i].write(str(topic) + "\t" +  str(topic_match[topic][2]) + "\t" + str(topic_match[topic][1] + "\t" + str(year)))

            for kk in range(len(result_arr[i])):
                fout[i].write("\t" + str(result_arr[i][kk]) )
            fout[i].write("\t" + str(min_index))
            fout[i].write("\n")
            print mesure[i-1], method[min_index - 1], topic_match[topic][2], topic_match[topic][1]
            
result_out.close()
