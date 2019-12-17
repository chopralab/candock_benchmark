#!/usr/bin/env Rscript

args = commandArgs(trailingOnly=TRUE)

require(boot);
require(readr);
require(dplyr);

data_all<-read_tsv(paste0(args[1], "_", args[2], "_", args[3], ".dat")) %>% as.data.frame
data<-as.matrix(data_all[,2]);

mymean<-function(x,indices) sum(x[indices])/nrow(data_all);
data.boot<-boot(data,mymean,R=10000,stype="i",sim="ordinary");

sink(paste0(args[1], "_", args[2], "_", args[3], "-ci.results") );
a<-boot.ci(data.boot,conf=0.9,type=c("bca"));
print(data.boot);
print(a);
sink();

