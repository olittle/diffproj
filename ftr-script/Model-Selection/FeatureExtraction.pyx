#-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.
#
# File Name : FeatureExtraction.pyx
#
# Purpose : Extract Feature
#
# Creation Date : 27-01-2013
#
# Last Modified : Fri 30 Aug 2013 06:17:44 AM CDT
#
# Created By : Huan Gui (huangui2@illinois.edu)
#
#_._._._._._._._._._._._._._._._._._._._._.

from copy import copy
from scipy.sparse import csr_matrix
from scipy.sparse import lil_matrix
import numpy as np
import sets
import sys
import os
import math

def Ftr_Ext(year, out_folder, topic):
    Feature = []
    Feature.append([])
    Feature.append([])

    author_set_prev = set()
    data = open("../../data/" + str(year - 2) + "/paper_author.txt")
    for line in data:
        value = int(line.split()[1])
        author_set_prev.add(value)

    pre_set = set()
    pre_data = open("../../data/" + str(year - 1) + "/author_paper_topic")

    for line in pre_data:
        value = line.split("\n")[0].split("\t")
        author = int(value[0])
        tpc = int(value[1])
        if topic == tpc and author in author_set_prev:
            pre_set.add(author)

    cdef double his_act = len(pre_set)
    cdef double his_all = len(author_set_prev)
    
    weight = []
    data = open(out_folder + str(topic) + "/Feature." + str(year), "r").readlines()
    data_len = len(data)

    for i in range(data_len):
        line = data[i].split("\n")[0]
        Feature[0].append(np.zeros(8))
        Feature[1].append(np.zeros(8))

        value = line.split("\n")[0].split("\t")

        for k in range(6):
            if k < 2:
                Feature[0][i][k] = int(value[k])
                Feature[1][i][k] = int(value[k])
            else:
                sub_v = value[k].split()
                Feature[0][i][k] = float(sub_v[0])
                Feature[1][i][k] = float(sub_v[1])

        Feature[0][i][6] = Feature[0][i][2:6].sum()  
        Feature[1][i][6] = Feature[1][i][2:6].sum()  

        Feature[0][i][7] = float(his_act)
        Feature[1][i][7] = float(his_all)

        weight.append(1.0) 
#        if Feature[0][i][1] in candidates:
#            weight.append(1.0)
#        else:
#            weight.append(w)

    Feature = np.array(Feature) 
    weight = np.array(weight)[:, np.newaxis]
    
    return Feature, weight
