#-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.
#
# File Name : WeightedPercentage_setup.py
#
# Purpose : build Negative.pyx
#
# Creation Date : 25-10-2012
#
# Last Modified : Fri 30 Aug 2013 05:29:01 AM CDT
#
# Created By : Huan Gui (huangui2@illinois.edu) 
#
#_._._._._._._._._._._._._._._._._._._._._.

import os
import sys
from numpy import * 
from scipy.sparse import lil_matrix
from scipy.sparse import csr_matrix

from distutils.core import setup
from distutils.extension import Extension
from Cython.Distutils import build_ext

ext_modules = [Extension("Ftr_Ext", ["FeatureExtraction.pyx"])]

setup(
	name = "Generate Positive and Negative Dataset with parameters",
	cmdclass = {"build_ext":build_ext},
	ext_modules = ext_modules
)

ext_modules = [Extension("Test", ["Test.pyx"])]

setup(
	name = "Generate Positive and Negative Dataset with parameters",
	cmdclass = {"build_ext":build_ext},
	ext_modules = ext_modules
)

ext_modules = [Extension("Train", ["Train.pyx"])]

setup(
	name = "Generate Positive and Negative Dataset with parameters",
	cmdclass = {"build_ext":build_ext},
	ext_modules = ext_modules
)

