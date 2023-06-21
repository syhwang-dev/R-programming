hist(Nile)

hist(Nile, freq = F)
lines(density(Nile))

par(mfrow = c(1, 1))
# pdf("C:/Rwork/batch.pdf")
pdf("batch.pdf")
hist(rnorm(20))
dev.off()  # 그래픽 디바이스 닫기