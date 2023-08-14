
kernel1<-function(u,h1){
  n_1<-length(u)
  temp<-rep(0,n_1)
  for(i in 1:n_1){
    if (abs(u)[i]<=abs(h1))
      temp[i]<-3/(4*h1)*(1-u[i]^2/h1^2)
  }
  return(temp)
}
mulkernel<-function(v_1,h_2){
  re<-mean((1/v_1)*kernel1(log(v_1)-log(V),h_2))
  results<-re
  return(results)
}
mulkernel_u<-function(v_1,h_2){
  re<-mean((1/v_1)*kernel1(log(v_1)-log(U),h_2))
  results<-re
  return(results)
}

mulkernel_cv<-function(n,v_1,h_2){
  re<-rep(0,n)
  for(index in 1:n){
    re[index]<-log(mean((1/v_1)*kernel1(log(v_1)-log(V[-index]),h_2)))
  }
  re
  results<-mean(re)
  return(results)
}

#Normal distribution
true.brier1<- function(y_test,y_pre,time,delt_t)
{
  mu<-mean(y_pre)
  sig_n<-abs(mean(y_pre^2)-mean(y_test^2))
  sigm<-sqrt(abs(mean(y_pre^2)-mu^2)+sig_n)
  
  brier.true <- numeric(length(time))
  del<-delt_t            
  for (i in 1:length(time))
  {
    alive <- dnorm(time[i],mean=mu,sd=sigm)#predict_data
    survival <- ifelse(y_test> time[i], 1, 0)#real_data
    brier.true[i] <- mean((alive-survival)^2)
  }
  brier.true<-1/max(time)*sum(brier.true)*delt_t
  return(brier.true)
}

#logistic distribution
true.brier2<- function(y_test,y_pre,time,delt_t)
{
  sig_n<-abs(mean(y_pre^2)-mean(y_test^2))
  mu<-mean(y_pre)
  sigm<-sqrt(3*abs(mean(y_pre^2)+sig_n-mu^2))/pi
  
  brier.true <- numeric(length(time))
  del<-delt_t            
  for (i in 1:length(time))
  {
    alive <- dlogis(time[i], location = mu, scale = sigm, log = FALSE)#predict_data
    survival <- ifelse(y_test> time[i], 1, 0)#real_data
    brier.true[i] <- mean((alive-survival)^2)
  }
  brier.true<-1/max(time)*sum(brier.true)*delt_t
  return(brier.true)
}

#Gumbel distribution
true.brier3<- function(y_test,y_pre,time,delt_t)
{
  euler<-0.5772
  sig_n<-abs(mean(y_pre^2)-mean(y_test^2))
  
  sigm<-sqrt(6*abs(mean(y_pre^2)-(mean(y_pre))^2+sig_n))/pi
  mu<-mean(y_pre)-euler*sigm
  
  brier.true <- numeric(length(time))
  del<-delt_t            
  for (i in 1:length(time))
  {
    alive <- dgumbel(time[i], loc = mu, scale = sigm, log = FALSE)#predict_data
    survival <- ifelse(y_test > time[i], 1, 0)#real_data
    brier.true[i] <- mean((alive-survival)^2)
  }
  brier.true<-1/max(time)*sum(brier.true)*delt_t
  return(brier.true)
}
