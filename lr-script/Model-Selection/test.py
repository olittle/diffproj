#-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.
#
# File Name : test.py
#
# Purpose :
#
# Creation Date : 13-05-2013
#
# Last Modified : Mon 13 May 2013 10:39:30 AM CDT
#
# Created By : Huan Gui (huangui2@illinois.edu) 
#
#_._._._._._._._._._._._._._._._._._._._._.

import sys
import os 
import copy 
from C_Gen import C_Gen
from Ftr_Ext import Ftr_Ext
from Sample import Sample
from Test import Test
from Train import Train 
from Update_Label import Update_Label
from random import shuffle
import numpy as np 
from copy import copy 

TopicSet = []
TargetSet = []
TopicTopicMap = {}
Start_set = {}
End_set = {}

topicfile = open("../../rawdata/topic_target", "r")
topicdata = topicfile.readlines()
topicfile.close()
lcnt = 0

for line in topicdata:
#	lcnt += 1
#	if lcnt % 4 != linetarget:
#		continue

	value = line.split("\n")[0].split("\t")
	tpc = int(value[0])
	sty = int(value[1]) 
	edy = int(value[2]) 
	TargetSet.append(tpc)
	Start_set[tpc] = sty
	End_set[tpc] = edy 
	
	for year in range(sty, edy + 1):
		if not os.path.exists("../../data-cascade/" + str(tpc) + "/Feature." + str(year)):
			print tpc, year 
