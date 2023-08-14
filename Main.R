
rm(list = ls())
library(MASS)
library(bayesSurv)
library(reticulate)
library(evd)
library(zoo)
library(rms)
library(glmnet)
library(foreign)
library(e1071)
library(creditmodel)
library(randomForest)
setwd("G:/code")
use_python("F:/python/Anaconda3/python.exe",required = T)
py_config()
py_available()
source_python("XGBt.py")
source("untrans.r")

set.seed(1)
timesup =1
c1.seq<-seq(0.1,1,0.1)
briscore1<-briscore2<-briscore3<-array(0, dim = c(timesup,length(c1.seq)))
bri1<-bri2<-bri3<-matrix(0,timesup)
score<-matrix(0,timesup,length(c1.seq))
rmse<-c()
maescore<-matrix(0,timesup,length(c1.seq))
mae<-c()

p=24
data<-read.csv("adnidata.csv")
m=which(data$L==0)
data<-data[-m,]
df<-data[1:24]

df$bbb.PTGENDER[df$bbb.PTGENDER=="Male"]<-0
df$bbb.PTGENDER[df$bbb.PTGENDER=="Female"]=1
df$bbb.PTMARRY[df$bbb.PTMARRY=="Married"]=0
df$bbb.PTMARRY[df$bbb.PTMARRY=="Divorced"]=1
df$bbb.PTMARRY[df$bbb.PTMARRY=="Widowed"]=2
df$bbb.PTMARRY[df$bbb.PTMARRY=="Never married"]=3
df$bbb.PTGENDER<-as.numeric(df$bbb.PTGENDER)
df$bbb.PTMARRY<-as.numeric(df$bbb.PTMARRY)


Xtotal=apply(df, 2, min_max_norm)
df[,1:24]<-Xtotal
T<-data$L
n=length(T)

L_1 = R_1 = c()
d1_1 = d2_1 = d3_1 = rep(0,n)

U<-data$L
V<-data$R

indx<-NULL
indx_inv<-NULL

for(i in 1:n){
  Cn_1 =c(0,U[i],V[i])
  if(is.infinite(V[i])){
    indx<-c(indx,i)}
  else{
    if(T[i] < Cn_1[2]){
      d1_1[i] = 1
      L_1[i] = Cn_1[2]
      R_1[i] = Cn_1[3]
    }
    if (Cn_1[2] <=T[i] &&  T[i] <= max(Cn_1)) {
      L_1[i] = Cn_1[2]
      R_1[i] = Cn_1[3]
      d2_1[i] = 1
    }
    if(T[i] > max(Cn_1)){
      L_1[i] = Cn_1[2] 
      R_1[i] = Cn_1[3]
      d3_1[i] = 1
    }
    indx_inv<-c(indx_inv,i)
  }
}

del_1<-d1_1[indx_inv]
del_2<-d2_1[indx_inv]
del_3<-d3_1[indx_inv]
sum(del_1)
sum(del_2)
sum(del_3)
length(indx)
length(indx_inv)
U<-U[indx_inv]
V<-V[indx_inv]
y_inter<-T[indx_inv]
ytol<-log(T+1)
n=length(ytol)
f1<-bj(formula=Surv(ytol[indx],rep(1,length(indx)))~bbb.PTGENDER+bbb.PTMARRY+bbb.AGE+bbb.PTEDUCAT+bbb.APOE4+bbb.ADAS11.bl+bbb.ADAS13.bl+bbb.ADASQ4.bl+bbb.CDRSB.bl+bbb.MMSE.bl+bbb.RAVLT.immediate.bl+bbb.RAVLT.learning.bl+bbb.RAVLT.forgetting.bl+bbb.RAVLT.perc.forgetting.bl+bbb.DIGITSCOR.bl+bbb.TRABSCOR.bl+bbb.FAQ.bl+bbb.Ventricles.bl	+bbb.Hippocampus.bl+bbb.WholeBrain.bl+bbb.Entorhinal.bl+bbb.Fusiform.bl	+bbb.MidTemp.bl+bbb.ICV.bl,data=df[indx,],x=TRUE,y=TRUE)
f1$y.imputed[f1$y.imputed<0]<-0
ytol[indx]<-f1$y.imputed
for (times in 1:timesup){
  print("this is times=")
  print(times)
  
  
  for (zz in 1:length(c1.seq)){#c1.seq
    
    
    ############### 
    est_kernel<-rep(0,length(indx_inv))
    for(i in 1:length(indx_inv)){
      est_kernel[i]<-mulkernel(V[i],c1.seq[zz]*n^(-1/5))
    }
    
    est_kernel_u<-rep(0,length(indx_inv))
    for(i in 1:length(indx_inv)){
      est_kernel_u[i]<-mulkernel_u(U[i],c1.seq[zz]*n^(-1/5))
    }
    
 
  #1
     pha_1<-0
     pha_2<-(1/(U+1))/(est_kernel_u)
     pha_3<-(1/(U+1))/(est_kernel_u)
    
 #2
 #   pha_1<-0
 #   pha_2<-(1/(U+1))/(2*est_kernel_u)
 #   pha_3<-(1/(U+1))/(2*est_kernel_u)+(1/(V+1))/(2*est_kernel)
    
 #3
 #  pha_1<-0
 #  pha_2<-(2/(U+1))/(3*est_kernel_u)
 #  pha_3<-(2/(U+1))/(3*est_kernel_u)+(1/(V+1))/(3*est_kernel)
    h<-pha_1*del_1+pha_2*del_2+pha_3*del_3
  
    
    
    ytol[indx_inv]<-h
    index=sample(1:n,0.75*n)
    X_train=as.matrix(Xtotal[index,])
    X_test=as.matrix(Xtotal[-index,])
    h_tra=ytol[index]
    h_hat=ytol[-index]
    
    t0<-seq(min(ytol), max(ytol), by =(max(ytol)-min(ytol))/200)#(max(h)-min(h))/100
    delt_t=(max(ytol)-min(ytol))/200
    result<-XGfix(X_train=X_train,y_train=h_tra,X_test=X_test,y_test=h_hat)
    score[times,zz]<-sqrt(result$score)#RMSE
    maescore[times,zz]<-mean(abs(result$y_pre-h_hat))#MAE
    briscore1[times,zz]<-true.brier1(h_hat,result$y_pre,time =t0,delt_t=delt_t)
    briscore2[times,zz]<-true.brier2(h_hat,result$y_pre,time =t0,delt_t=delt_t)
    briscore3[times,zz]<-true.brier3(h_hat,result$y_pre,time =t0,delt_t=delt_t)
    
    
    
  }
  rmse[times]<-min(score[times,])#RMSE
  mae[times]<-min(maescore[times,])#MAE
  bri1[times]<-min(briscore1[times,])#bri_score_normal
  bri2[times]<-min(briscore2[times,])#bri_score_logistic
  bri3[times]<-min(briscore3[times,])#bri_score_gumbul
  
}

print(c("Xg.mean.RMSE=",mean(rmse)))
print(c("Xg.mean.MAE=",mean(mae)))
print(c("Xg.mean.Brier_Score.normal=",apply(bri1, 2, mean)))
print(c("Xg.mean.Brier_Score.logistic=",apply(bri2, 2, mean)))
print(c("Xg.mean.Brier_Score.gumbul=",apply(bri3, 2, mean)))



