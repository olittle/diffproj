#-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.
#
# File Name : FeatureExtraction.pyx
#
# Purpose : Extract Feature
#
# Creation Date : 27-01-2013
#
# Last Modified : Tue 10 Sep 2013 12:51:12 PM CDT
#
# Created By : Huan Gui (huangui2@illinois.edu)
#
#_._._._._._._._._._._._._._._._._._._._._.


from scipy.sparse import csr_matrix
from scipy.sparse import lil_matrix
import numpy as np
import sets
import sys
import os
import math
from C_Gen import C_Gen 

def Ftr_Ext(year, out_folder, topic):

    data = open(out_folder + str(topic) + "/Feature." + str(year), "r").readlines()
    Feature = []
    weight = []
    data_len = len(data)

    for i in range(data_len):
        line = data[i].split("\n")[0]
        Feature.append(np.zeros(7))
        value = line.split("\n")[0].split("\t")
        x1 = 0
        x2 = 0 
        for k in range(6):
            if k < 2:
                Feature[i][k] = int(value[k])
            else:
                temp = value[k].split()
                x1 += float(temp[0])
                x2 += float(temp[1])
                if float(temp[0]) != 0:
                    Feature[i][k] = float(temp[0]) / float(temp[1])
        if x2 != 0:
            Feature[i][6] = x1 / x2 

        weight.append(1.0)

    Feature = np.array(Feature)
    weight = np.array(weight)[:, np.newaxis]
    return Feature, weight


