#librerie necessarie
library(ggplot2)
library(tidyquant)
library(timetk)
library(tseries)
library(timeSeries)
library(forecast)
library(seastests)
library(rugarch)
library(fDMA)
library(dplyr)
set.seed(29)
amazon = tq_get("AMZN",                    
                  from = '2015-06-01',
                  to = "2021-06-01",
                  get = "stock.prices")
amazon %>%
  ggplot(aes(x = date, y = adjusted)) +
  geom_line() +
  ggtitle("Amazon") +
  labs(x = "Date", "Price") +
  scale_x_date(date_breaks = "years", date_labels = "%Y") +
  labs(x = "Data", y = "Adjusted Price") +
  theme_minimal()


AMZN_annual_returns = amazon %>%
  group_by(symbol) %>%
  tq_transmute(select     = adjusted, 
               mutate_fun = periodReturn, 
               period     = "yearly", 
               type       = "arithmetic")
AMZN_annual_returns

AMZN_annual_returns %>%
  ggplot(aes(x = date, y = yearly.returns, fill = symbol)) +
  geom_col() +
  geom_hline(yintercept = 0, color = palette_light()[[1]]) +
  scale_y_continuous(labels = scales::percent) +
  labs(title = "Amazon: Annual Returns",
       y = "Annual Returns", x = "") + 
  facet_wrap(~ symbol, ncol = 2, scales = "free_y") +
  theme_minimal() + 
  scale_fill_tq()

AMZN_daily_log_returns = amazon %>%
  group_by(symbol) %>%
  tq_transmute(select     = adjusted, 
               mutate_fun = periodReturn, 
               period     = "daily", 
               type       = "log",
               col_rename = "daily.returns")

AMZN_daily_log_returns %>%
  ggplot(aes(x = daily.returns, fill = symbol)) +
  geom_density(alpha = 0.5) +
  labs(title = "Amazon: Charting the Daily Log Returns",
       x = "Daily Returns", y = "Density") +
  theme_minimal() +
  scale_fill_tq() + 
  facet_wrap(~ symbol, ncol = 2)

AMZN_macd = amazon %>%
  group_by(symbol) %>%
  tq_mutate(select     = close, 
            mutate_fun = MACD, 
            nFast      = 12, 
            nSlow      = 26, 
            nSig       = 9, 
            maType     = SMA) %>%
  mutate(diff = macd - signal) %>%
  select(-(open:volume))
AMZN_macd

AMZN_macd %>%
  filter(date >= as_date("2021-05-01")) %>%
  ggplot(aes(x = date)) + 
  geom_hline(yintercept = 0, color = palette_light()[[1]]) +
  geom_line(aes(y = macd, col = symbol)) +
  geom_line(aes(y = signal), color = "blue", linetype = 2) +
  geom_bar(aes(y = diff), stat = "identity", color = palette_light()[[1]]) +
  facet_wrap(~ symbol, ncol = 2, scale = "free_y") +
  labs(title = "AMZN: Moving Average Convergence Divergence",
       y = "MACD", x = "", color = "") +
  theme_minimal() +
  scale_color_tq()

#Stationarity test
#adf.test(AMZN_daily_log_returns$daily.returns, alternative = "stationary")
# p-value = 0.01 -> si rifiuta l'ipotesi nulla
ts= ts(AMZN_daily_log_returns)[,3]

# seasonality test
isSeasonal(ts, freq=1)

#stationary test
adf.test(ts, alternative= "stationary") 
#ARCH EFFECT

archtest(as.vector(AMZN_daily_log_returns$daily.returns))
# presenza ARCH effect

n = length(ts)
n
nV=round(n/3)  # Validation set (33% del totale)
nV
nT=n-nV  # training set - osservazioni
train=ts[c(1:nT)]
valid=ts[c((nT+1):n)]

auto_model1=auto.arima(train, ic="aic", stationary=FALSE,seasonal=FALSE)
auto_model1



res1=auto_model1$residuals

Box.test(res1, lag = 12, type = "Box-Pierce", fitdf=0) 
Box.test(res1, lag = 12, type = "Ljung-Box",  fitdf=0)

checkresiduals(auto_model1, include.mean=FALSE, plot=TRUE)

acf(train, lag=10)
pacf(train, lag=10)

arima_model=arima(train, order=c(1,0,1) )
arima_model

BIC(auto_model1)
BIC(arima_model)


# GARCH MODEL assumendo una distribuzione Normale
#sGARCH
library(rugarch)

s_garchMod = ugarchspec(mean.model = list(armaOrder = c(1, 1), include.mean = TRUE
), 
variance.model = list(model = 'sGARCH', 
                      garchOrder = c(1, 1)),
distribution.model = "norm")

s_garchFit = ugarchfit(spec=s_garchMod, data=ts)
s_garchFit


## Risultati del modello
coef(s_garchFit)

s_rhat = s_garchFit@fit$fitted.values
plot.ts(s_rhat)
s_hhat = ts(s_garchFit@fit$sigma^2)
plot.ts(s_hhat)
fit.val     = coef(s_garchFit)
fit.sd      = diag(vcov(s_garchFit))
true.val = s_garchFit@fit$tval

fit.conf.lb = fit.val + qnorm(0.025) * fit.sd
fit.conf.ub = fit.val + qnorm(0.975) * fit.sd
print(fit.val)

print(fit.sd)

print(true.val)
plot(true.val, pch = 1, col = "red",
     ylim = range(c(fit.conf.lb, fit.conf.ub, true.val)),
     xlab = "", ylab = "", axes = FALSE)
box(); axis(1, at = 1:length(fit.val), labels = names(fit.val)); axis(2)
points(coef(s_garchFit), col = "blue", pch = 7)
for (i in 1:length(fit.val)) {
  lines(c(i,i), c(fit.conf.lb[i], fit.conf.ub[i]))
}
legend( "topleft", legend = c("true value", "estimate", "confidence interval"),
        col = c("red", "blue", 1), pch = c(1, 7, NA), lty = c(NA, NA, 1), inset = 0.01)


par(mfrow=c(2, 3))
par(mar = c(2, 2, 2, 2))
plot(s_garchFit,which="all")

# confronto tra modelli
infocriteria(s_garchFit)[2] #BIC= -5.264179
BIC(auto_model1) # = -5165.248 -> è il valore più basso e quindi quello da 
                 # scegliere. auto_model1 è il modello da scegliere
BIC(arima_model) # = -5151.545
