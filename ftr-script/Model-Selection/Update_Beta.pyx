#-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.
#
# File Name : Update_Beta.pyx
#
# Purpose : Update Beta
#
# Creation Date : 21-02-2013
#
# Last Modified : Fri 03 May 2013 08:38:40 PM CDT
#
# Created By : Huan Gui (huangui2@illinois.edu) 
#
#_._._._._._._._._._._._._._._._._._._._._.

import numpy as np
import math 

def logistic(x, beta):
	temp = x * beta[1] + beta[0]
	return 1.0 /(1.0 + math.exp(-temp))

def Update_Beta(Data, Y, field, weight):
	
	cdef int datasize = len(Data)
	cdef double err = 1
	cdef double tol = 1e-5
	cdef int max_itera = 1000
	cdef int iteration = 0
	cdef double c = 1
	cdef int i, k 

	beta = np.zeros( 1 + field, dtype = np.float) 
	while err > tol:
	
		p_xi_beta = 1.0 / (1.0 + np.exp( -1 * (Data[:, 2:] * beta[1:]).sum(axis = 1) - beta[0]))

		p_xi_beta = p_xi_beta[:, np.newaxis] 
		
		Y_p_xi_beta = Y[:, 0] - p_xi_beta[:,0]
		Y_p_xi_beta = Y_p_xi_beta[:, np.newaxis]		

		First_Order_PDE = np.zeros(1 + field, dtype = float)			 
		for i in range(field):
			First_Order_PDE[1+i] = (weight[:, 0] * Data[:, i + 2] * Y_p_xi_beta[:, 0]).sum(axis = 0)
		First_Order_PDE[0] = (weight[:, 0] * Y_p_xi_beta[:, 0]).sum( axis = 0 )

		First_Order_PDE = First_Order_PDE - beta * c
		
		Second_Order_PDE = np.zeros((1+field,1+field), dtype=float)
		middle_result = p_xi_beta - p_xi_beta * p_xi_beta
		
		Second_Order_PDE[0, 0] = (-1) * (weight[:, 0] * middle_result[:, 0]).sum()
			
		for i in range(field):
			Second_Order_PDE[1+i, 0] = (-1) * (weight[:, 0] * Data[:, i + 2] * middle_result[:, 0]).sum()
			Second_Order_PDE[0, 1+i] = Second_Order_PDE[1+i, 0]
		for i in range(field):
			for j in range(i + 1):
				Second_Order_PDE[i+1, j+1] = (-1) * (weight[:, 0] * Data[:, i + 2] * Data[:, j + 2] * middle_result[:, 0]).sum()
				Second_Order_PDE[j+1, i+1] = Second_Order_PDE[i + 1, j + 1] 
		Second_Order_PDE = Second_Order_PDE - np.identity(1 + field) * c

		Second_Order_PDE = np.linalg.inv(Second_Order_PDE)
		
		update = np.dot(Second_Order_PDE, First_Order_PDE)
		err = abs(update).sum(axis=0)
	
		iteration += 1
		
		if iteration % 100 == 0:
			print "iteration", iteration, err
			print beta, update
		if iteration > max_itera:
			break 
		if err < tol:
			break 
		beta = beta - update 
	return beta	
