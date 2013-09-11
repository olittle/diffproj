#-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.
#
# File Name : Test.pyx
#
# Purpose :
#
# Creation Date : 27-01-2013
#
# Last Modified : Wed 11 Sep 2013 02:42:30 PM CDT
#
# Created By : Huan Gui (huangui2@illinois.edu)
#
#_._._._._._._._._._._._._._._._._._._._._.

import random
from random import shuffle
import math
import os
import numpy as np
from Update_Beta import Update_Beta
from copy import copy

from Single_Beta import Single_Beta
from C_Gen import C_Gen
from Ftr_Ext import Ftr_Ext

def Test(year, out_folder, Train_Data, Train_weight, topic, weight_fout):
    
    author_set = set() 

    data = open("../../data/" + str(year-1) + "/paper_author.txt")
    for line in data:
        value = int(line.split()[1])
        author_set.add(value)
    
    positive = set()

    data = open("../../data/" + str(year) + "/author_paper_topic")
    for line in data:
        a_i = int(line.split()[0])
        t_i = int(line.split()[1])
        if t_i == topic and a_i in author_set:
            positive.add(a_i)

    Data, data_weight = Ftr_Ext(year, out_folder, topic) 

    data_weight = np.array(data_weight)[:, np.newaxis]
    Data = np.array(Data)
    index = np.arange(np.shape(Data)[0])
    np.random.shuffle(index)
    Data = Data[index]
    data_weight = data_weight[index]

    #print "ground_truth", pos
    #print "zero", zero_pos, zero_neg

    pos = len(positive) 
    ground_truth = pos

    field = 4

#    method = ["logit", "logit.APA", "logit.APPA", "logit.APAPA","logit.APVPA", "equal-weight"]

    method = ["Homo-equal-weight", "Homo-APA", "Homo-APPA", "Homo-APAPA", "Homo-APVPA", "MH-APA", "MH-APPA", "MH-APAPA", "MH-APVPA", "MH-project", "M-Sub-APA", "M-Sub-APPA", "M-Sub-APAPA", "M-Sub-APVPA", "MLTM-S-1-2", "MLTM-S-1-3", "MLTM-S-1-4", "MLTM-S-2-3", "MLTM-S-2-4", "MLTM-S-3-4", "MLTM-M"]

    field_array = [ [2,3,4,5], [2], [3], [4], [5], [2], [3], [4], [5], [6], [3,4,5], [2,4,5], [2,3,5], [2,3,4], [2, 3], [2, 4], [2, 5], [3, 4], [3, 5], [4, 5], [2, 3, 4, 5] ]
    
    # 0 Homo - with weight 1 for each field 
    # 1 HM  - learn with weight 
    # 2 HM-p - first project, then learn weight 

    Operation = [0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1] 

#    folder = out_folder +str(topic)+"/Result-Submodule/"
#    if not os.path.exists(folder):
#        os.system("mkdir "+folder)
#    
#    folder = out_folder +str(topic)+"/Result-Submodule/" + str(year) + "/"
#    if not os.path.exists(folder):
#        os.system("mkdir "+folder)

    Area = []
    Expect = []

    Y = Data[:, 0][:, np.newaxis]

    AUC_arr = []
    AUPR_arr = []
    logL_arr = []
    Global_arr = []
    total = len(Data)
    

    for m in range(len(method)):

        Score = []
        TestY = []

        relevant = 0
        irrelevant = 0

        expect = 0

        PR_retrieve = 0
        PR_pos_retrieve = 0
        logL = 0

        path_set = [0, 1]
        for kk in field_array[m]:
            path_set.append(kk)
        path_set = np.array(path_set)

        op = Operation[m]
        if op == 1:
            single_weight = Update_Beta(Train_Data[:, path_set], Train_Data[:, 0][:, np.newaxis], len(field_array[m]), Train_weight)
            print method[m] , single_weight
            weight_fout.write(str(year) + "\t" + str(topic))
            weight_fout.write("\t" + str(m) + "\t" + method[m])
            for xx in range(len(single_weight)):
                weight_fout.write("\t" + str(single_weight[xx]))
            weight_fout.write("\n") 

        continue 


        for i in range(total):
            v = Data[i]
            TestY.append(v[0])
            
            if op == 0:
                pi = Data[i, path_set[2:]].sum() / float(len(path_set[2:]))
            if op == 1:
                tmp = single_weight[0] + (single_weight[1:] * Data[i, path_set[2:]]).sum() 
                pi = 1.0 / ( 1.0 + math.exp(-1 * tmp))

            if TestY[-1] == 1:
                relevant += 1
                try:
                    logL += math.log(pi) * data_weight[i][0]
                except:
                    logL += -1e10

            else:
                irrelevant += 1
                try:
                    logL += math.log(1 - pi) * data_weight[i][0]
                except:
                    logL += -1e10

             
            expect += pi * data_weight[i][0]

            Score.append(pi)
        logL = logL[0] 
        
        Dict = list(enumerate(Score))
        Dict = sorted(Dict, key = lambda Score:Score[1], reverse = True)

        retrieval = 0
        irretrieval = 0
        gap = 1
        rag = total + gap
        t = 0
        f = 0
        area = 0

        for k in range(gap, rag, gap):
            for j in range(k-gap, k):
                if j >= total:
                    break

                index = Dict[j][0]
                if TestY[index] == 1:
                    retrieval += 1
                else:
                    irretrieval += 1

            tp = float(retrieval) / float(relevant)
            fp = float(irretrieval) / float(irrelevant)

            if f == 0 and t == 0:
                area += tp * fp
            else:
                area += 0.5 * (fp - f) * (tp + t)
            f = fp
            t = tp

        AUC = copy(area)

        retrieval = 0
        irretrieval = 0
        t = 0
        f = 0
        area = 0
        recall = 0

        for k in range(gap, rag, gap):
            for j in range(k-gap, k):
                if j >= total:
                    break

                index = Dict[j][0]
                if TestY[index] == 1:
                    retrieval += 1
                else:
                    irretrieval += 1
                recall += 1
            tp = float(retrieval) / float(recall)
            fp = float(retrieval) / float(ground_truth)

            if f == 0 and t == 0:
                area += tp * fp
            else:
                area += 0.5 * (fp - f) * (tp + t)

            f = fp
            t = tp

        Area.append(area)
        Expect.append(expect)
        expect = expect[0]

        print year, topic, method[m], ground_truth, expect, "AUPR", area, "AUC", AUC, "logL", logL
        AUC_arr.append(AUC)
        AUPR_arr.append(area)
        logL_arr.append(logL)
        Global_arr.append((float(expect) / float(ground_truth) + float(ground_truth) / float(expect) ) * 0.5 - 1)

#        PR.close()
   
    return 

    best_AICc = 1e20 
    best_m = 5 
    for m in range(len(method)):
# First 5 methods are not learned parameters models 
        if m < 5:
            continue 
        k = len(field_array[m]) 
        AICc = 2 * k - 2 * logL_arr[m] + 2 * k * (k + 1) / (total- k - 1) 
        if AICc < best_AICc:
            best_AICc = AICc
            best_m = m

    AUC_arr.append(AUC_arr[best_m]) 
    AUPR_arr.append(AUPR_arr[best_m])
    logL_arr.append(logL_arr[best_m])
    Global_arr.append(Global_arr[best_m]) 

    best_BIC = 1e20 
    best_m = 5 
    for m in range(len(method)):
# First 5 methods are not learned parameters models 
        if m < 5:
            continue 
        k = len(field_array[m]) 
        BIC = - 2 * logL_arr[m] + k  * math.log(total)  
        if BIC < best_BIC:
            best_BIC = BIC
            best_m = m

    AUC_arr.append(AUC_arr[best_m]) 
    AUPR_arr.append(AUPR_arr[best_m])
    logL_arr.append(logL_arr[best_m])
    Global_arr.append(Global_arr[best_m]) 

    return AUC_arr, AUPR_arr, logL_arr, Global_arr, best_m
