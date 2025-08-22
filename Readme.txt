############
# SPI FPGA #
############

#######################################################################################################################
# Ps :                                                                                                                #
# 1. Both master and slave could support continuous data interaction.(Nss continues to pull down N data-cycles).      #
# 2. Slave only support about 12.5M and below cuz the slave module isn't triggered by SCLK, but by FPGA CLK.	        #
# All modules have its simulation file and testbench.                                                                 # 
# Whether the actual use of the module meets the requirements needs to consider the FPGA platform layout and routing. #
#######################################################################################################################

#########################################################################################################
# Any issures can leave a comment below or contact me via email, thank you.(Email : 1871462453@qq.com)  #
#########################################################################################################
