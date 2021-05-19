setwd("XXX")
pacman::p_load(plyr, dplyr, readr, tidyr, stringr, openxlsx, ggplot2, gdata, forcats, 
               readxl, purrr, tvthemes, ggthemes, usmap, scales, ggthemes, gtools)
rm(list = ls())
options(scipen = 999)

#########################

# FILEPATH
files <- list.files('res', full.names = T, recursive = T) %>%
  subset(., grepl('txt', .) & grepl('extended\\/FIGUREA10', .))
df <- data.frame(stringsAsFactors = F)
for(i in 1:length(files)){
  # LOAD
  temp <- read.delim(files[i], header = FALSE)
  index <- temp %>% subset(., grepl('VARIABLES|Observations', V1)) %>% row.names() %>% as.numeric() %>% sort(.)
  index_vacc <- temp %>% subset(., grepl('L\\.peopleVacc100', V1)) %>% row.names() %>% as.numeric() %>% sort(.)
  
  # EXTRACT
  DEP <- temp %>% subset(., V1 %in% c('VARIABLES')) %>% t() %>% as.data.frame() %>% set_names('obs') %>% .[-1,] %>% gsub(',', '', .)
  LAG <- temp %>% subset(., V1 %in% c('LAG')) %>% t() %>% as.data.frame() %>% set_names('obs') %>% .[-1,] %>% gsub(',', '', .)
  FSTAT <- temp %>% subset(., V1 %in% c('FSTAT')) %>% t() %>% as.data.frame() %>% set_names('obs') %>% .[-1,] %>% gsub(',', '', .)
  GLOBALTERM <- temp %>% subset(., V1 %in% c('GLOBALTERM')) %>% t() %>% as.data.frame() %>% set_names('obs') %>% .[-1,] %>% gsub(',', '', .)
  LOCALTERM1 <- temp %>% subset(., V1 %in% c('LOCALTERM1')) %>% t() %>% as.data.frame() %>% set_names('obs') %>% .[-1,] %>% gsub(',', '', .)

  df <- temp[(index_vacc):(index[2]-2), ] %>%
    subset(., V1 != '') %>% t(.) %>% as.data.frame() %>%
    set_names(gsub(' ', '', .[1,])) %>% .[-1,] %>%
    mutate(DEP = DEP, LAG = LAG, FSTAT = FSTAT, GLOBALTERM = GLOBALTERM, 
           LOCALTERM1 = LOCALTERM1) %>%
    gather(., INDEP, coef, -c(DEP, LAG, GLOBALTERM, LOCALTERM1, FSTAT)) %>%
    mutate(INDEP = gsub(".*\\.", '', INDEP)) %>%
    mutate(LAG = as.numeric(LAG), FSTAT = as.numeric(FSTAT)) %>%
    subset(., coef != '') %>% subset(., !INDEP %in% c('Constant')) %>% 
    mutate(NSTAR = str_count(coef, "\\*") %>% as.character()) %>% 
    mutate(SIGN = as.numeric(grepl('\\*', coef)) %>% as.character()) %>%
    mutate(SIGN = case_when(NSTAR == '3' ~ '01% SI', NSTAR == '2' ~ '05% SI', NSTAR == '1' ~ '10% SI', NSTAR == '0' ~ 'None')) %>%
    mutate(SIGN = case_when(NSTAR %in% c('2', '3') ~ 'significant (p-value <5%)', TRUE ~ 'not significant (p-value >5%)')) %>%
    mutate(coefnum = gsub('\\*|\\,', '', coef) %>% as.numeric()) %>%
    mutate(lab = paste0(round(FSTAT, 0) %>% as.character(.))) %>%
    mutate(INST = paste(GLOBALTERM, LOCALTERM1, sep = ' - ')) %>%
    bind_rows(., df)
}
df <- df %>%
  mutate(DEP = case_when(DEP == 'D.aod550_pop' ~ 'AOD (change)',
                         DEP == 'D.case_pop' ~ ' new Covid19 cases',
                         DEP == 'D.mobility' ~ 'Mobility (change)',
                         DEP == 'D.ntl_pop' ~ 'NTL (change)'))

#############

# PLOT
gterm <- unique(df$GLOBALTERM)
n <- length(unique(df$LOCALTERM1))
inst <- combinations(n = n, r = 1, v = unique(df$LOCALTERM1)) %>%
  as.data.frame() %>% mutate(IV = paste(V1, sep = ' - ')) %>% pull(IV) %>% 
  expand.grid(lterm = ., gterm = gterm, stringsAsFactors = F) %>%
  mutate(IV = paste(gterm, lterm, sep = ' - ')) %>% pull(IV)

temp <- df %>% subset(., INST == inst[i]) %>% unique()
ggplot() + 
  geom_label(data = temp, aes(x = LAG, y = coefnum, label = lab), vjust = 1.5, size = 1.5, label.size = 0, alpha = 0) +
  geom_point(data = temp, aes(x = LAG, y = coefnum, color = SIGN), size = 1.5) +
  geom_hline(yintercept = 0, color = 'red', size = 0.5) +
  scale_color_manual(values = c('significant (p-value <5%)' = 'darkblue', 'not significant (p-value >5%)' = 'brown3')) +
  facet_wrap(~DEP, scales = 'free', nrow = 2) + 
  theme_classic() + labs(x = 'lag', y = 'coefficient') + 
  scale_x_continuous(breaks = seq(0, 30, 5)) +
  theme(legend.position = 'bottom', 
        legend.direction = 'horizontal',
        legend.title = element_blank())
