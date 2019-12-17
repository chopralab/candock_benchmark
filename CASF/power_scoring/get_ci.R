#!/usr/bin/env Rscript

args = commandArgs(trailingOnly=TRUE)

require(boot);
require(readr);
require(dplyr);

data_all<-read_tsv(paste0(args[1], "_", args[2], "_processed_score")) %>% as.data.frame
aa<-c(1:nrow(data_all));

mycore<-function(x,indices) {
	data_1<-matrix(NA,nrow(data_all),2);
	for(i in 1:nrow(data_all)) {
        	data_1[i,1]=data_all[x[indices][i],2];
        	data_1[i,2]=data_all[x[indices][i],3];
    	}

	data_2<-data.frame(data_1);
        names(data_2)<-c("a","b");
        cor(data_2$a,data_2$b);
};

data.boot<-boot(aa,mycore,R=10000,stype="i",sim="ordinary");
sink(paste0(args[1], "_", args[2], "-ci.results"));
a<-boot.ci(data.boot,conf=0.9,type=c("bca"));
print(data.boot);
print(a);
sink();

