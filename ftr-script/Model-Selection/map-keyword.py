#-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.
#
# File Name : map-keyword.py
#
# Purpose :
#
# Creation Date : 10-09-2013
#
# Last Modified : Tue 10 Sep 2013 01:15:16 AM CDT
#
# Created By : Huan Gui (huangui2@illinois.edu) 
#
#_._._._._._._._._._._._._._._._._._._._._.

# Map keywords to likelihood ratio test 

Map = {}
data = open("../../sourcedata/keywords_match.txt")

for line in data:
    value = line.split("\n")[0].split("\t")
    Map[value[0]] = value[2] 
    
data = open("./likelihood_test_out")
fout = open("./likelihood_test_out_topic", "w")

for line in data:
    value = line.split() 
    for i in range(2):
        fout.write(value[i] + "\t") 
    fout.write(Map[value[1]]) 
    for i in range(2, len(value)):
        fout.write("\t" + value[i] )
    
    fout.write("\n")

fout.close() 

