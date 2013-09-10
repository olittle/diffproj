#-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.
#
# File Name : UpdataLable.pyx
#
# Purpose :
#
# Creation Date : 27-01-2013
#
# Last Modified : Wed 20 Feb 2013 06:23:49 PM CST
#
# Created By : Huan Gui (huangui2@illinois.edu)
#
#_._._._._._._._._._._._._._._._._._._._._.

import os

def Update_Label(Data, pos_set, year, target):

    out_folder = "hll"
    if os.path.exists( out_folder + str(year + 1) + "/score/Feature." + str(target)):
        return Data

    pos = 0
    neg = 0
    DLen = len(Data)

    for i in range(DLen):
        a = Data[i][1]
        if a in pos_set:
            Data[i][0] = 1
            pos += 1
        else:
            Data[i][0] = 0
            neg += 1

    fout_1 = open(out_folder + str(year+1)+"/score/Feature."+str(target), "w")
    F_len = len(Data)
    for a in range(F_len):
        for i in range(6):
            if i > 1:
                fout_1.write(str(Data[a][i]) + "\t")
            else:
                fout_1.write(str(int(Data[a][i])) + "\t")
        fout_1.write("\n")
    fout_1.close()

    return Data
