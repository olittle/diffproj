#-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.
#
# File Name : Test.pyx
#
# Purpose :
#
# Creation Date : 27-01-2013
#
# Last Modified : Tue 10 Sep 2013 01:18:01 PM CDT
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

def Test(Test_Data, Test_weight, year, out_folder, Train_Data, Train_weight, topic, weight_out):
    np.seterr(over='raise')
    
    pos = (Test_Data[0][:, 0] * Test_weight[:, 0]).sum() 
    ground_truth = pos 

    index = np.arange(np.shape(Test_Data[0])[0])
    np.random.shuffle(index)
    Test_Data[0] = Test_Data[0][index]
    Test_Data[1] = Test_Data[1][index]
    data_weight = Test_weight[index]

    
    Area = []
    Expect = []

    AUC_arr = []
    AUPR_arr = []
    logL_arr = []
    Global_arr = []
    Expect_arr = []

    method = ["MR-APA", "MR-APPA", "MR-APAPA", "MR-APVPA", "MR-project", "R-Sub-APA", "R-Sub-APPA", "R-Sub-APAPA", "R-Sub-APVPA", "MLTM-R-S-1-2", "MLTM-R-S-1-3", "MLTM-R-S-1-4", "MLTM-R-S-2-3", "MLTM-R-S-2-4", "MLTM-R-S-3-4", "MLTM-R"]

    field_array = [ [2], [3], [4], [5], [6], [3,4,5], [2,4,5], [2,3,5], [2,3,4], [2, 3], [2, 4], [2, 5], [3, 4], [3, 5], [4, 5], [2, 3, 4, 5] ]

    for m in range(len(method)):

        Score = []
        TestY = []

        relevant = 0
        irrelevant = 0
        total = len(Test_Data[0])

        expect = 0

        PR_retrieve = 0
        PR_pos_retrieve = 0
        logL = 0

        path_set = [0, 1]
        for kk in field_array[m]:
            path_set.append(kk)
        path_set.append(7) 
        path_set = np.array(path_set)
        sub_beta = Train(Train_Data, year, out_folder, Train_weight, path_set)
#        sub_beta = Train(Test_Data, year, out_folder, Test_weight, path_set)
    
        print m, method[m], sub_beta

        weight_out.write(str(year - 1) + "\t" + str(topic) + "\t" + str(m) + "\t" + str(method[m]))
        for i in range(len(sub_beta[i])):
            weight_out.write("\t" + str(sub_beta[i]))
        weight_out.write("\n")
        
        for i in range(total):
            v = Test_Data[0][i][0]
            TestY.append(v)
            
            pi = (Test_Data[0][i, path_set[2:]] * sub_beta).sum() / (Test_Data[1][i, path_set[2:]] * sub_beta).sum() 

            if TestY[-1] == 1 :
                try:
                    logL += math.log(pi) * data_weight[i][0]
                except:
                    logL += -1e10
                relevant += 1
                    
            else :
                try:
                    logL += math.log(1 - pi) * data_weight[i][0]

                except:
                    logL += -1e10
                irrelevant += 1

            expect += pi * data_weight[i][0]
            Score.append(pi) 
            

        Dict = list(enumerate(Score))
        Dict = sorted(Dict, key = lambda Score:Score[1], reverse = True)

        retrieval = 0
        irretrieval = 0
        gap = 1
        rag = total + gap
        t = 0
        f = 0
        area = 0
        tp = 0 
        fp = 0 

        for k in range(gap, rag, gap):
            for j in range(k-gap, k):
                if j >= total:
                    break

                index = Dict[j][0]

                if TestY[index] == 1:
                    retrieval += data_weight[index]
                else:
                    irretrieval += data_weight[index]

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
                    retrieval += data_weight[index]
                else:
                    irretrieval += data_weight[index]

                recall += float(data_weight[index])
            try:
                tp = float(retrieval) / float(recall)
                fp = float(retrieval) / float(ground_truth)
            except:
                print retrieval, recall, ground_truth
                print data_weight[index]
                exit(1) 

            if f == 0 and t == 0:
                area += tp * fp
            else:
                area += 0.5 * (fp - f) * (tp + t)

            f = fp
            t = tp
        
        k = len(field_array[m]) 
        
        print year, topic, method[m], ground_truth, expect, "AUPR", area, "AUC", AUC, "logL", logL, "AICc", 2 * k - 2 * logL + 2 * k * (k + 1) / (total- k - 1), "BIC", -2 * logL + k * math.log(total)  
        
        AUC_arr.append(AUC)
        AUPR_arr.append(area)
        logL_arr.append(logL)
        Global_arr.append((float(expect) / float(ground_truth) + float(ground_truth) / float(expect) ) * 0.5 )
        Expect_arr.append(expect) 

    best_AICc = 1e20 
    best_m = 0 
    for m in range(len(method)):
# First 5 methods are not learned parameters models 
        k = len(field_array[m]) 
        AICc = 2 * k - 2 * logL_arr[m] + 2 * k * (k + 1) / (total- k - 1) 
        if AICc < best_AICc:
            best_AICc = AICc
            best_m = m

    AUC_arr.append(AUC_arr[best_m]) 
    AUPR_arr.append(AUPR_arr[best_m])
    logL_arr.append(logL_arr[best_m])
    Global_arr.append(Global_arr[best_m])
    Expect_arr.append(Expect_arr[best_m]) 

    best_BIC = 1e20 
    best_m = 0 
    for m in range(len(method)):
# First 5 methods are not learned parameters models 
        k = len(field_array[m]) 
        BIC = - 2 * logL_arr[m] + k  * math.log(total)  
        if BIC < best_BIC:
            best_BIC = BIC
            best_m = m

    AUC_arr.append(AUC_arr[best_m]) 
    AUPR_arr.append(AUPR_arr[best_m])
    logL_arr.append(logL_arr[best_m])
    Global_arr.append(Global_arr[best_m])
    Expect_arr.append(Expect_arr[best_m]) 

    return AUC_arr, AUPR_arr, logL_arr, Global_arr, ground_truth, Expect_arr

