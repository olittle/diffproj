#-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.
#
# File Name : Independent_Threshold_Model.py
#
# Purpose : Make Multiple Prediction
#
# Creation Date : 04-09-2013
#
# Last Modified : Wed 29 May 2013 12:17:01 AM PDT
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

linetarget = int(sys.argv[1]) 

for line in topicdata:
	lcnt += 1
	if lcnt % 8 != linetarget:
		continue

	value = line.split("\n")[0].split("\t")
	tpc = int(value[0])
	sty = int(value[1]) 
	edy = int(value[2]) 
	TargetSet.append(tpc)
	Start_set[tpc] = sty
	End_set[tpc] = edy 

topic_match = {}
data = open("../../rawdata/keywords_match.txt")
for line in data:
	value = line.split("\n")[0].split("\t")
	kid = int(value[0]) 
	topic_match[kid] = value



out_folder = "../../data-threshold-cnt/"  
result_out = open(out_folder + "topic.coifficient.pool.ftr" , "w")
	
method = ["APA", "APPA", "APAPA", "APVPA", "equal-weight", "All-Path"]
mesure = ["AUC", "AUPR", "logL", "global"]
fout = {}
for kk in range(5):
	fout[1] = open("./AUC/AUC"   , "w") 
	fout[2] = open("./AUPR/AUPR" , "w") 
	fout[3] = open("./logL/logL"  , "w") 
	fout[4] = open("./global/global"  , "w") 

fout = open("./result." + str(linetarget) , "w") 

for topic in TargetSet:
	target = topic 
	
	StartYear = Start_set[topic]
	EndYear = End_set[topic] 
        
	author_set = set()
	for year in range(1936, StartYear - 1):
		data = open("../../data/" + str(year) + "/paper_author.txt")
		for line in data:
			value = int(line.split()[1])
			author_set.add(value) 

	for year in range(StartYear, EndYear):
		data = open("../../data/" + str(year - 1) + "/paper_author.txt")  
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
		print "-.-.-.-.-.-.-.-.-.-.-.-.",topic, topic_match[topic][2], year, "-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-"
		
		Train_Data, weight = Ftr_Ext(year, out_folder, topic, author_set)
	        
                try:
                        beta = Train(Train_Data, year, out_folder, weight) 
                        fout.write(str(topic) + "\t" + str(year))
                        for b in beta:
                                fout.write("\t" + str(b))
                        fout.write("\n")
                except:
                        pass

                continue

		beta_0 = 0 	
		ground_truth = 0 	
		result_arr = {}

		result_arr[1], result_arr[2], result_arr[3], result_arr[4] = Test(year + 1, out_folder, beta, Train_Data, weight, topic, copy(author_set))
		
		for i in result_arr:
			result_arr[i] = np.array(result_arr[i]) 
			if i != 4:
				min_index = result_arr[i].argmax() 
			else:
				min_index = result_arr[i].argmin() 

			fout[i].write(str(topic) + "\t" +  str(topic_match[topic][2]) + "\t" + str(topic_match[topic][1] + "\t" + str(year)))
			 
			for kk in range(len(result_arr[i])):
				fout[i].write("\t" + str(result_arr[i][kk]) )
			fout[i].write("\t" + str(min_index))

			fout[i].write("\n")

			print mesure[i-1], method[min_index - 1], topic_match[topic][2], topic_match[topic][1] 

		result_out.write(topic_match[topic][0] + "\t" + topic_match[topic][1] + "\t" + topic_match[topic][2] + "\t" + str(beta) + "\n") 
result_out.close() 
