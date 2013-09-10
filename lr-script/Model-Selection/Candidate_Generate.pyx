#-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.
#
# File Name : Candidate_Generate.pyx
#
# Purpose : Generate Candidate
#
# Creation Date : 27-01-2013
#
# Last Modified : Tue 20 Aug 2013 12:29:35 AM CDT
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

def C_Gen(pos_set, year, positive):

    Len = {}

    Len["author"] = 916989
    Len["paper"] = 1572279
    Len["venue"] = 6714
    Len["topic"] = 50001

    data_folder = "../../data/"

    P_Len = [0, 0,1,1]
    P_Sta = ["author",  "author", "author", "author"]
    P_Mid = ["author","paper", "author", "venue"]

    t_set = set()
    for x in pos_set:
        t_set.add(x)
    for x in positive:
        t_set.add(x)


    for m in range(len(P_Len)):

        p = P_Len[m]
        par1 = P_Sta[m]
        par2 = P_Mid[m]

        if p == 0:
            AXN = lil_matrix((Len["author"], Len["author"]))
        else:
            AXN = lil_matrix((Len[par1], Len[par2]))

        AXfile = data_folder + str(year) + "/"+par1+"_paper_"+par2
        if p == 0:


            AXfin = open(AXfile, "r")
            AXdata = AXfin.readlines()
            AXfin.close()
            for lines in AXdata:
                value = lines.split("\n")[0].split("\t")
                a = int(value[0])
                x = int(value[1])
                s = float(value[2])
                AXN[x, a] = 1

        else:

            AXfin = open(AXfile, "r")
            AXdata = AXfin.readlines()
            AXfin.close()
            for lines in AXdata:
                value = lines.split("\n")[0].split("\t")
                a = int(value[0])
                x = int(value[1])
                s = float(value[2])
                AXN[a, x] = 1

            AXNT = AXN.transpose()
            AXNT = csr_matrix(AXNT)

        for author in pos_set:

            if p == 1:
                SAX = AXN.getrow(author)
                SAX = csr_matrix(SAX)
                SAAN = SAX * AXNT
            else:
                SAAN = AXN.getrow(author)
                SAAN = csr_matrix(SAAN)
            can = SAAN.nonzero()[1]
            for c in can:
                t_set.add(c)

    return t_set
