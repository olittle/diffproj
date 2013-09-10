#-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.
#
# File Name : Network.pyx
#
# Purpose :
#
# Creation Date : 02-02-2013
#
# Last Modified : Sat 02 Feb 2013 08:28:41 PM CST
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

def Network(year):

	Len = {}

	Len["author"] = 916989
	Len["paper"] = 1572279
	Len["venue"] = 6714
	Len["topic"] = 50001

	data_folder = "../../data/"

	P_Len = [0, 0,1]
	P_Sta = ["author",  "author", "author"]
	P_Mid = ["author","paper", "venue"]

	cand = {}
	
	for t in pos_set:
		cand[t] = {}
	result = {}
	for m in range(len(P_Len)):

		p = P_Len[m]
		par1 = P_Sta[m]
		par2 = P_Mid[m]
		
		if p == 0:	
			result[m] = lil_matrix((Len["author"], Len["author"]))
		else:
			result[m] = lil_matrix((Len[par1], Len[par2]))

		
		for y in range(year-2, year+1):	
			AXfile = data_folder + str(year) + "/"+par1+"_paper_"+par2
			AXfin = open(AXfile, "r")
			AXdata = AXfin.readlines()
			AXfin.close()
			for lines in AXdata:
				value = lines.split("\n")[0].split("\t")
				a = int(value[0])
				x = int(value[1])
				s = float(value[2])
				result[m][x, a] += s
	return result[0], result[1], result[2]
