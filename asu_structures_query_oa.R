##%######################################################%##
#                                                          #
#### Structures Alliance Sorbonne Université - OpenAlex ####
#                                                          #
##%######################################################%##



# Packages ----------------------------------------------------------------
library(tidyverse)
library(openalexR)


# Requête -----------------------------------------------------------------
## Identifiants ROR membres de l'alliance
asu <- 
  c(
    "https://ror.org/02en5vm52", # Sorbonne Université
    "https://ror.org/03wkt5x30", # MNHN
    "https://ror.org/0175hh227", # CNAM
    "https://ror.org/00ghzk478", # INSEAD
    "https://ror.org/04y5kwa70" # UTC
  )

## Sélection variables 
var <- 
  c(
    "id",
    "display_name",
    "display_name_acronyms",
    "ror", 
    "ids",
    "associated_institutions"
  )

## Requête OpenAlex
asu_structures <- 
  oa_fetch(
  entity = "institutions",
  ror = asu,
  options = list(select = var),
  verbose = TRUE
)

# Pré-traitement
## Extraction identifiants wikidata
asu_structures <- 
  asu_structures %>% 
  hoist(ids, "wikidata")

## Correction wikidata
asu_structures <- 
  asu_structures %>% 
  mutate(
    wikidata = recode(wikidata, "https://www.wikidata.org/wiki/Q1144549" = "https://www.wikidata.org/wiki/Q41497113"), 
    wikidata = replace_na(wikidata, "https://www.wikidata.org/wiki/Q838691")
  ) 

## Extraction acronymes
asu_structures <- asu_structures %>% unnest(display_name_acronyms)

## Extraction structures associées
asu_structures <- 
  asu_structures %>% 
  unnest(associated_institutions, names_sep = "_")


# Sauvegarde --------------------------------------------------------------
asu_structures %>% rio::export(here::here("data", "asu_structures.xlsx"))

