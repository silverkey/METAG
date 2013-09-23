make.perc = function(df) {
  df$count.134.pc = round(df$count.134/tot134*100,6)
  df$count.135.pc = round(df$count.135/tot135*100,6)
  df
}

t134 = read.table(file='summary_134.txt',sep='\t',head=T,quote='',comment.char='')
t135 = read.table(file='summary_135.txt',sep='\t',head=T,quote='',comment.char='')

tot134 = sum(t134$count)
tot135 = sum(t135$count)

t = read.table(file='summary_134_135.txt.taxon',sep='\t',head=T,comment.char='',quote='')

species.134 = as.data.frame(tapply(t$count.134,t$species,sum))
species.135 = as.data.frame(tapply(t$count.135,t$species,sum))
species = merge(species.134,species.135,by=0)
colnames(species) = c('species','count.134','count.135')
species = make.perc(species)
write.table(species,file='summary_species_134_135.txt',sep='\t',row.names=F,quote=F)

genus.134 = as.data.frame(tapply(t$count.134,t$genus,sum))
genus.135 = as.data.frame(tapply(t$count.135,t$genus,sum))
genus = merge(genus.134,genus.135,by=0)
colnames(genus) = c('genus','count.134','count.135')
genus = make.perc(genus)
write.table(genus,file='summary_genus_134_135.txt',sep='\t',row.names=F,quote=F)

family.134 = as.data.frame(tapply(t$count.134,t$family,sum))
family.135 = as.data.frame(tapply(t$count.135,t$family,sum))
family = merge(family.134,family.135,by=0)
colnames(family) = c('family','count.134','count.135')
family = make.perc(family)
write.table(family,file='summary_family_134_135.txt',sep='\t',row.names=F,quote=F)

order.134 = as.data.frame(tapply(t$count.134,t$order,sum))
order.135 = as.data.frame(tapply(t$count.135,t$order,sum))
order = merge(order.134,order.135,by=0)
colnames(order) = c('order','count.134','count.135')
order = make.perc(order)
write.table(order,file='summary_order_134_135.txt',sep='\t',row.names=F,quote=F)

class.134 = as.data.frame(tapply(t$count.134,t$class,sum))
class.135 = as.data.frame(tapply(t$count.135,t$class,sum))
class = merge(class.134,class.135,by=0)
colnames(class) = c('class','count.134','count.135')
class = make.perc(class)
write.table(class,file='summary_class_134_135.txt',sep='\t',row.names=F,quote=F)

phylum.134 = as.data.frame(tapply(t$count.134,t$phylum,sum))
phylum.135 = as.data.frame(tapply(t$count.135,t$phylum,sum))
phylum = merge(phylum.134,phylum.135,by=0)
colnames(phylum) = c('phylum','count.134','count.135')
phylum = make.perc(phylum)
write.table(phylum,file='summary_phylum_134_135.txt',sep='\t',row.names=F,quote=F)




calculate.enrichments = function(div.sel,div.uni,n.sel,n.uni,go) {
  div = merge(div.sel,div.uni,by.x='goid',by.y='goid',all.y=T)
  div$count.x[is.na(div$count.x)] = 0
  div$pval = apply(div,1,function(x) prop.test(c(as.numeric(x[2]),as.numeric(x[3])),c(n.sel,n.uni),alternative=prop.alt)$p.value)
  div = merge(div,go,by.x='goid',by.y='go_id')
  if(prop.alt == 'g') div = div[(div$count.x/n.sel >= mult*(div$count.y/n.uni)) & div$count.x>=min,]
  if(prop.alt == 'l') div = div[(div$count.x/n.sel <= mult*(div$count.y/n.uni)) & div$count.x>=min,]
  if(prop.alt == 't') div = div[div$count.x>=min,]
  div$padj = p.adjust(div$pval,method='fdr')
  div[order(div$padj,decreasing=T),]
}

