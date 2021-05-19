setwd("XXX")
pacman::p_load(plyr, dplyr, readr, tidyr, stringr, openxlsx, ggplot2, gdata, forcats, 
               readxl, purrr, tvthemes, ggthemes, usmap, scales, ggthemes)
rm(list = ls())
options(scipen = 999)

#########################

# FILEPATH
files <- list.files('res', full.names = T, recursive = T) %>%
  subset(., grepl('txt', .) & grepl('extended\\/FIGUREA5', .))

# LOAD
temp <- read.delim(files, header = FALSE)
index <- temp %>% subset(., grepl('VARIABLES|Observations', V1)) %>% row.names() %>% as.numeric() %>% sort(.)
index_vacc <- temp %>% subset(., grepl('L21\\.peopleVacc100', V1)) %>% row.names() %>% as.numeric() %>% sort(.)

# EXTRACT
DEP <- temp %>% subset(., V1 %in% c('VARIABLES')) %>% t() %>% as.data.frame() %>% set_names('obs') %>% .[-1,] %>% gsub(',', '', .)
DROP <- temp %>% subset(., V1 %in% c('DROP')) %>% t() %>% as.data.frame() %>% set_names('obs') %>% .[-1,] %>% gsub(',', '', .)
df <- temp[(index_vacc):(index[2]-2), ] %>%
  subset(., V1 != '') %>% t(.) %>% as.data.frame() %>%
  set_names(gsub(' ', '', .[1,])) %>% .[-1,] %>%
  mutate(DEP = DEP, DROP = DROP) %>%
  gather(., INDEP, coef, -c(DEP, DROP)) %>%
  mutate(INDEP = gsub(".*\\.", '', INDEP)) %>%
  subset(., coef != '') %>% subset(., !INDEP %in% c('Constant')) %>% 
  mutate(NSTAR = str_count(coef, "\\*") %>% as.character()) %>% 
  mutate(SIGN = as.numeric(grepl('\\*', coef)) %>% as.character()) %>%
  mutate(SIGN = case_when(NSTAR == '3' ~ '01% SI', NSTAR == '2' ~ '05% SI', NSTAR == '1' ~ '10% SI', NSTAR == '0' ~ 'None')) %>%
  mutate(SIGN = case_when(NSTAR %in% c('2', '3') ~ 'significant (p-value <5%)', TRUE ~ 'not significant (p-value >5%)')) %>%
  mutate(coefnum = gsub('\\*|\\,', '', coef) %>% as.numeric()) %>%
  mutate(DEP = case_when(DEP == 'D.aod550_pop' ~ 'AOD (change)',
                         DEP == 'D.case_pop' ~ ' new Covid19 cases',
                         DEP == 'D.mobility' ~ 'Mobility (change)',
                         DEP == 'D.ntl_pop' ~ 'NTL (change)'))


#########################

# PLOT
ggplot() + 
  geom_point(data = df, aes(x = DROP, y = coefnum, color = SIGN), size = 1.5) +
  geom_hline(yintercept = 0, color = 'red', size = 0.5) +
  scale_color_manual(values = c('significant (p-value <5%)' = 'darkblue', 'not significant (p-value >5%)' = 'brown3')) +
  facet_wrap(~DEP, scales = 'free', nrow = 2) + 
  theme_classic() + labs(x = 'lag', y = 'coefficient') + 
  theme(legend.position = 'bottom', 
        legend.direction = 'horizontal',
        legend.title = element_blank(),
        axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1))

