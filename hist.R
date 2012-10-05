myRange <- function(a){
  r=range(a)+c(-0.5,+0.5)
  r[1] = floor(r[1])+0.5
  r[2] = ceiling(r[2])-0.5
  return(r)
}
t=read.table("dmet.txt")
r=myRange(data.matrix(t[3]))
hist(data.matrix(t[3]), breaks=seq(r[1], r[2]), main="Station Average Monthly DMET",
  ylab="Station Count", xlab=expression("Average Monthly DMET ×10"^{-2}*"K"))

