setwd("XXX")
pacman::p_load(plyr, dplyr, readr, tidyr, stringr, openxlsx, ggplot2, gdata, forcats, ggpmisc,
               readxl, purrr, tvthemes, ggthemes, usmap, scales, ggthemes, gtools, haven, ggpubr)
rm(list = ls())
options(scipen = 999)
my.formula <- y ~ x

#########################

# LOAD DATA
couselect <- c('ARG',	'AUT', 'BEL',	'BRA', 'CAN',	'CHE', 'CHL',	'CZE', 'DEU',	'ESP', 'IND',	
               'ITA', 'NOR', 'POL', 'SVK',	'SWE', 'USA')
df <- read_dta("data/final.dta") %>% subset(., DATE <= as.Date('2021-02-28'))

#########################
#########################

proVar <- c('procureMIX180')
i <- 1

# FIGURE A6
temp <- df %>% 
  select(ISO, DATE, peopleVacc100, procure = proVar[i]) %>%
  group_by(ISO) %>% 
  dplyr::summarize(peopleVacc100 = mean(peopleVacc100, na.rm = T), procure = mean(procure, na.rm = T)) %>% 
  ungroup()
ggscatter(temp,  x = "procure", y = "peopleVacc100", add = "reg.line", size = 0) +
  geom_text(data = temp, aes(x = procure, y = peopleVacc100, label = ISO)) +
  stat_regline_equation(aes(label =  paste(..eq.label.., ..rr.label.., sep = "~~~~")), size = 5) +
  scale_y_continuous(breaks = c(0:15)) + scale_x_continuous(breaks = seq(0, 150, 10)) +
  xlab('procurement of vaccination at t-180 (in % population)') + 
  ylab('share of people vaccinated (first dose) in %') +
  theme_classic()

# FIGURE A7
temp <- df %>% 
  select(ISO, DATE, peopleVacc100, procure = proVar[i]) %>%
  group_by(ISO, DATE) %>% 
  dplyr::summarize(peopleVacc100 = mean(peopleVacc100, na.rm = T), procure = mean(procure, na.rm = T)) %>% 
  ungroup()
ggscatter(temp,  x = 'procure', y = "peopleVacc100", add = "reg.line", size = 0) +
  stat_regline_equation(aes(label =  paste(..rr.label.., sep = "~~~~")), size = 3) +
  theme_classic() + facet_wrap(~ISO, scales = 'free') +
  xlab('procurement of vaccination at t-180 (in % population)') + 
  ylab('share of people vaccinated (first dose) in %')

# FIGURE A8
temp1 <- temp %>% 
  group_by(DATE, quartile) %>%
  dplyr::summarize(peopleVacc100 = median(peopleVacc100, na.rm = T)) %>%
  ungroup()
ggplot() +
  geom_line(data = temp1, aes(x = DATE, y = peopleVacc100, color = quartile), size = 1.3) +
  ylab('share of people vaccinated (first dose) in %') + xlab('') +
  scale_color_manual(values = c('brown3', 'darkblue')) +
  scale_y_continuous(breaks = c(0:15)) + 
  scale_x_date(limits = c(as.Date('2020-12-20'), as.Date('2021-02-28'))) +
  theme_classic() + theme(legend.position = 'bottom', legend.title = element_blank())

# FIGURE A9
quartiles <- df %>% 
  subset(., ISO %in% couselect) %>%
  select(ISO, RID, lnhoscapita) %>% unique() %>%
  group_by(ISO) %>% dplyr::summarize(Q25 = quantile(lnhoscapita, probs = c(0.25)),
                                     Q75 = quantile(lnhoscapita, probs = c(0.75))) %>%
  ungroup()
temp <- df %>% 
  left_join(., quartiles, by = 'ISO') %>%
  select(ISO, RID, DATE, peopleVacc100, lnhoscapita, Q25, Q75) %>%
  mutate(belowQ25 = lnhoscapita <= Q25, aboveQ75 = lnhoscapita >= Q75) %>%
  subset(., !(belowQ25 == F & aboveQ75 == F)) %>%
  mutate(quartile = case_when(aboveQ75 == T ~ 'aboveQ75', belowQ25 == T ~ 'belowQ25')) %>%
  group_by(DATE, ISO, quartile) %>% dplyr::summarize(peopleVacc100 = mean(peopleVacc100, na.rm = T)) %>% ungroup() %>%
  mutate(quartile = case_when(quartile == 'aboveQ75' ~ '\u22653rd quartile of hospital per capita',
                              quartile == 'belowQ25' ~ '\u22641st quartile of hospital per capita'))
ggplot() +
  geom_line(data = temp, aes(x = DATE, y = peopleVacc100, color = quartile), size = 0.75) +
  ylab('share of people vaccinated (first dose) in %') + xlab('') +
  scale_color_manual(values = c('brown3', 'darkblue')) +
  scale_x_date(limits = c(as.Date('2020-12-20'), as.Date('2021-02-28'))) +
  theme_classic() + 
  theme(legend.position = 'bottom', legend.title = element_blank(),
        axis.text.x = element_text(angle = 90, hjust = 1, vjust = 0.5)) +
  facet_wrap(~ISO, scales = 'free_y')
