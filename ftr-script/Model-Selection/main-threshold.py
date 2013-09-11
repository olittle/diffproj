#-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.
#
# File Name : Independent_Threshold_Model.py
#
# Purpose : Make Multiple Prediction
#
# Creation Date : 04-09-2013
#
# Last Modified : Tue 10 Sep 2013 10:27:39 PM CDT
#
# Created By : Huan Gui (huangui2@illinois.edu)
#
#_._._._._._._._._._._._._._._._._._._._._.

import sys
import os
import copy
from Ftr_Ext import Ftr_Ext
from Test import Test
from Train import Train
from random import shuffle
import numpy as np
from copy import copy

TopicSet = []
TargetSet = []
TopicTopicMap = {}
Start_set = {}
End_set = {}

topicfile = open("../../sourcedata/topic_target", "r")
topicdata = topicfile.readlines()
topicfile.close()
lcnt = 0

linetarget = int(sys.argv[1])

for line in topicdata:
    lcnt += 1
    if lcnt % 12 != linetarget:
        continue

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
result_out = open("best_m." + str(linetarget) , "w")


os.system("mkdir AUC")
os.system("mkdir AUPR")
os.system("mkdir logL")
os.system("mkdir global")
os.system("mkdir coefficient")

method = ["MR-APA", "MR-APPA", "MR-APAPA", "MR-APVPA", "MR-project", "R-Sub-APA", "R-Sub-APPA", "R-Sub-APAPA", "R-Sub-APVPA", "MLTM-R-S-1-2", "MLTM-R-S-1-3", "MLTM-R-S-1-4", "MLTM-R-S-2-3", "MLTM-R-S-2-4", "MLTM-R-S-3-4", "MLTM-R", "MLTM-R-AIC", "MLTM-R-BIC"]
mesure = ["AUC", "AUPR", "logL", "global"]


fout = {}
fout[1] = open("./AUC/AUC." + str(linetarget)   , "w")
fout[2] = open("./AUPR/AUPR." + str(linetarget) , "w")
fout[3] = open("./logL/logL."+str(linetarget)  , "w")
fout[4] = open("./global/global."+str(linetarget)  , "w")
weight_fout = open("./coefficient/coefficient." + str(linetarget), "w")

for topic in TargetSet:
    target = topic
    StartYear = Start_set[topic]
    EndYear = End_set[topic]

    for year in range(StartYear, EndYear):
                
        print "-.-.-.-.-.-.-.-.-.-.-.-.",topic, topic_match[topic][2], year, "-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-"
        
        if year == StartYear:
            Train_Data, weight = Ftr_Ext(year, out_folder, topic)
        else:
            Train_Data, weight = Test_Data, Test_weight

        result_arr = {}

        Test_Data, Test_weight = Ftr_Ext(year + 1, out_folder, topic) 
        result_arr[1], result_arr[2], result_arr[3], result_arr[4], ground_truth, result_arr[5] = Test(Test_Data, Test_weight, year + 1, out_folder, Train_Data, weight, topic, weight_fout)

        for i in result_arr:
            if i == 5:
                continue 

            result_arr[i] = np.array(result_arr[i])
            if i != 4:
                min_index = result_arr[i].argmin()
            else:
                min_index = result_arr[i].argmax()

            fout[i].write(str(topic) + "\t" +  str(topic_match[topic][2]) + "\t" + str(topic_match[topic][1] + "\t" + str(year)))
            
            if i == 4:
                fout[i].write("\t" + str(ground_truth))

            for kk in range(len(result_arr[i])):
                if i == 4:
                    fout[i].write("\t" + str(result_arr[5][kk]))
                    fout[i].write("\t" + str(result_arr[i][kk]))
                else:
                    fout[i].write("\t" + str(result_arr[i][kk]))
                    
            fout[i].write("\t" + str(min_index))
            fout[i].write("\n")

            print mesure[i-1], method[min_index], topic_match[topic][2], topic_match[topic][1]

result_out.close()
weight_out.close()
for i in fout:
    fout[i].close() 
