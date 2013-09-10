#-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.
#
# File Name : Test.pyx
#
# Purpose :
#
# Creation Date : 27-01-2013
#
# Last Modified : Wed 01 May 2013 07:58:00 PM CDT
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


def Test(year, fout, out_folder, weight, data_set):

	data = open(out_folder + str(year) + "/score/Feature.test." + data_set, "r").readlines()
	Data = []
	data_len = len(data)

	pos = 0
	prior = []
	zero_pos = 0 
	zero_neg = 0 
	
	d_i = 0 
	data_weight = []
	for i in range(data_len):
		line = data[i]
		Data.append(np.zeros(6))
		value = line.split("\n")[0].split("\t")
		if value[1] != '0':
			for k in range(6):
				if k < 2:
					Data[i][k] = int(value[k])
				else:
					Data[i][k] = float(value[k])
			if Data[i][0] == 1:
				pos += 1
			data_weight.append("1")
		else:
			if int(value[0]) == 1:
				zero_pos += int(value[6])
				pos += int(value[6]) 
				Data[i][0] = 1 

			else:
				zero_neg += int(value[6]) 
			data_weight.append(float(value[6]))
	del data 


		
	# shuffle the data 
	Data = np.array(Data) 
	index = np.arange(np.shape(Data)[0])
	np.random.shuffle(index)
	Data = Data[index]
	
	print "ground_truth", pos 
	print "zero", zero_pos, zero_neg 
	
	ground_truth = pos 

	field = 4 
			
	method = ["logit", "logit.APA", "logit.APPA", "logit.APAPA","logit.APVPA", "equal-weight"]

	metapath = [ 	[2, 3, 4,5], \
			[2],   [3], [4], [5], [2,3,4,5]
		] 

	fieldCntArray = [5, 2,2,2,2, 5] #, 3]

	folder = out_folder +str(year)+"/Result/"
	os.system("mkdir "+folder)
	
	Area = []
	Expect = []
	
	Y = Data[:, 0][:, np.newaxis] 
	data_weight = np.array(data_weight, dtype = np.float)[:, np.newaxis]
	 
#	for m in range(len(method) - 1, -1, -1):
	for m in range(len(method)):
		Score = []
		TestY = []
		
		relevant = 0
		irrelevant = 0
		total = len(Data)

		expect = 0
		
		score_out = open(folder + "Prob.1." + method[m], "w")
		PR_retrieve = 0
		PR_pos_retrieve = 0
		logL = 0 

		if m != 0 and method[m] != method[-1]:
			single_weight = Update_Beta(Data, Y, m - 1, data_weight) 
			print method[m] , single_weight 

		for i in range(total):
			v = Data[i] 
			TestY.append(v[0])
			
			if m == 0:
				temp = weight[0] + (weight[1:] * Data[i, 2:2+field]).sum()
				pi = 1.0 / ( 1.0 + math.exp(-1 * temp))
				
			
			elif method[m] != method[-1]:
				index = 0 
				pi = 1.0 / (1.0 + math.exp(-1 * single_weight[0] - single_weight[1] * v[metapath[m][index]])) 

			else:
				pi =  Data[i, 2: 2 + field].sum() / field

			if TestY[-1] == 1:
				relevant += 1
				logL += math.log(pi) * data_weight[i]
			else:
				irrelevant += 1
				logL += math.log(1 - pi) * data_weight[i]

			if pi >= 0.5:
				PR_retrieve += data_weight[i]
				if TestY[-1] == 1:
					PR_pos_retrieve += data_weight[i]

			expect += pi * data_weight[i]
			 
			score_out.write(str(v[0]) + "\t" + str(v[1]) + "\t" + str(pi) + "\n")
			Score.append(pi)
		
		relevant += zero_pos
		irrelevant += zero_neg 
	
		Precision_ = 0
		Recall_ = 0
		try:
			Precision_ = float(PR_pos_retrieve) / float(PR_retrieve)
			Recall_ = float(PR_pos_retrieve) / float(relevant)
			fscore = (2 * Precision_ * Recall_) / (Precision_ + Recall_)

			fout.write("Precision, Recall, fscore" + "\t" + str(Precision_) + "\t" + str(Recall_)+ "\t" + str(fscore) + "\n")
		except:
			fout.write("None above 0.5 threshold\n")
		
		print "Precision, Recall, fscore", Precision_, Recall_, fscore
		score_out.close()

		Dict = list(enumerate(Score))

		Dict = sorted(Dict, key = lambda Score:Score[1], reverse = True)
			
		retrieval = 0
		irretrieval = 0
		gap = 100
		rag = total + gap
		t = 0
		f = 0
		area = 0
		 
		ROC = folder + "ROC.1." + method[m]

		PR = open(ROC, "w")
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
			
			PR.write(str(tp) + "\t" + str(fp) + "\n")
			if f == 0 and t == 0:
				area += tp * fp
			else:
				area += 0.5 * (fp - f) * (tp + t)
			f = fp
			t = tp 
			
		if zero_pos > 0:	
			ratio = int(zero_neg / zero_pos)
		else:
			ratio = 0 
		
		for k in range(zero_pos):
			retrieval += 1 
			irretrieval += ratio
			tp = float(retrieval) / float(relevant)
			fp = float(irretrieval) / float(irrelevant)
			
			PR.write(str(tp) + "\t" + str(fp) + "\n")
			area += 0.5 * (fp - f) * (tp + t)

			f = fp
			t = tp 
		
		#print "relevant, irrelevant", relevant, irrelevant
		#print "retrieval, irretrieval", retrieval, irretrieval
		
		PR.close()
			
		AUC = copy(area)
		 
		retrieval = 0
		irretrieval = 0
		gap = 1
		rag = total + gap
		t = 0
		f = 0
		area = 0
		recall = 0 

		PR = folder + "PR.1." + method[m] 
		PR = open(PR, "w")
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
			
			PR.write(str(tp) + "\t" + str(fp) + "\n")
			if f == 0 and t == 0:
				area += tp * fp
			else:
				area += 0.5 * (fp - f) * (tp + t)

			f = fp
			t = tp 
		
		#print "relevant, irrelevant", relevant, irrelevant
		#print "retrieval, irretrieval", retrieval, irretrieval
		if zero_pos > 0 :	
			ratio = int(zero_neg / zero_pos)
		else:
			ratio = 0 

		for k in range(zero_pos):
			retrieval += 1 
			irretrieval += ratio
			tp = float(retrieval) / float(recall)
			fp = float(retrieval) / float(ground_truth)
			recall += 1 + ratio 
						
			PR.write(str(tp) + "\t" + str(fp) + "\n")
			area += 0.5 * (fp - f) * (tp + t)

			f = fp
			t = tp 
		#print "relevant, irrelevant", relevant, irrelevant
		#print "retrieval, irretrieval", retrieval, irretrieval
		#tp = 1
		#fp = 1 
		#area += 0.5 * (fp - f) * (tp + t)

		Area.append(area)
		Expect.append(expect)

		print year, method[m], ground_truth, expect, "AUPR", area, "AUC", AUC, "logL", logL
		PR.close()

	return Expect, Area	
