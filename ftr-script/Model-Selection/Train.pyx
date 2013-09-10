#-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.
#
# File Name : Train.pyx
#
# Purpose : Train the parameters of mixture diffusion model
#
# Creation Date : 26-02-2013
#
# Last Modified : Tue 10 Sep 2013 05:13:27 PM CDT
#
# Created By : Huan Gui (huangui2@illinois.edu)
#
#_._._._._._._._._._._._._._._._._._._._._.

import os
import sys
import math
import numpy as np
import random
import math
from copy import copy

from scipy.sparse import lil_matrix

def Train(Data_1, year, out_folder, weight, position):
    np.seterr(over='raise')
    cdef int itera,  pair_cnt, zeros, sample, i
    cdef double tol, loglikelihood, err

    Data = [0,0]
    Data[0] = Data_1[0][:, position]
    Data[1] = Data_1[1][:, position]
    field = len(Data[0][0]) - 2
    
    update = 1
    Y = Data[0][:, 0][:, np.newaxis]
    weight = np.array(weight)
#    beta = np.random.random(field)
    beta = np.ones(field)
    beta = np.array([])
    
    cdef double smooth = 0
    while update > 1e-3:
        pos_score_base = (Data[0][:, 2:] * beta ).sum(axis = 1)
        pos_score = Data[0][:, 2:] / (smooth + pos_score_base[:, np.newaxis])

        neg_Data = Data[1][:, 2:] - Data[0][:, 2:]
        neg_score_base = (neg_Data * beta).sum(axis = 1)
        neg_score = neg_Data / (smooth + neg_score_base[:, np.newaxis])

        total_score_base = (Data[1][:, 2:] * beta).sum(axis = 1)
        total_score = weight * Data[1][:, 2:] / (smooth + total_score_base[:, np.newaxis])

        Update = (pos_score * weight * Y + neg_score * weight * (1 - Y) ).sum(axis = 0)

        beta_new = (Update * beta) / total_score.sum(axis = 0)

        update = abs(beta_new - beta).sum()
        beta = copy(beta_new)
    return beta
