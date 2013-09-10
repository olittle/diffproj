#-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.
#
# File Name : Train.pyx
#
# Purpose : Train the parameters of mixture diffusion model
#
# Creation Date : 26-02-2013
#
# Last Modified : Tue 20 Aug 2013 02:59:32 AM CDT
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
from sklearn.linear_model import LogisticRegression

from Update_Beta import Update_Beta

def Train(Data, year, out_folder, weight):

    cdef int itera,  pair_cnt, zeros, sample, i
    cdef double tol, loglikelihood, err
    act = "active"

    field = 4

    method = ["logit", "logit.APA","logit.APPA", "logit.APAPA","logit.APVPA"]
    neg_set = set()
    pos_set = set()

    Data = np.array(Data)
    Y = Data[:, 0][:, np.newaxis]
    Y_1 = Data[:, 0]
    weight = np.array(weight)


    beta = Update_Beta(Data, Y, field, weight)
    print "beta    ", beta

    return beta
