t134 = read.table(file='summary_134.txt',sep='\t',head=T,quote='',comment.char='')
t135 = read.table(file='summary_135.txt',sep='\t',head=T,quote='',comment.char='')

tot134 = sum(t134$count)
tot135 = sum(t135$count)

idmap = rbind(t134[,c(1,3)],t135[,c(1,3)])
idmap = unique(idmap)

t = merge(t134[,c(1,2)],t135[,c(1,2)],all.x=T,all.y=T,by='gi')

colnames(t) = c('gi','count.134','count.135')

t[is.na(t)] = 0

t = merge(t,idmap,by='gi')

write.table(t,file='summary_134_135.txt',sep='\t',row.names=F,quote=F)
