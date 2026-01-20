##%######################################################%##
#                                                          #
#### Structures Alliance Sorbonne Université - OpenAlex ####
#                                                          #
##%######################################################%##



# Packages ----------------------------------------------------------------
library(tidyverse)
library(openalexR)


# Requêtes ----------------------------------------------------------------
## Identifiants ROR membres ASU
asu_ror <- 
  c(
    "https://ror.org/02en5vm52", # Sorbonne Université
    "https://ror.org/03wkt5x30", # MNHN
    "https://ror.org/0175hh227", # CNAM
    "https://ror.org/00ghzk478", # INSEAD
    "https://ror.org/04y5kwa70" # UTC
  )

## Requête structures des membres ASU
list_structures <- 
  oa_fetch(
  entity = "institutions",
  ror = asu_ror,
  options = list(select = c("id", "associated_institutions")),
  verbose = TRUE
)

## Extraction structures ASU
list_structures_id <- 
  list_structures %>% 
  unnest(associated_institutions, names_sep = "_") %>% 
  pull(associated_institutions_id) %>% 
  unique()

## Requête données structures ASU
asu_structures <- 
  oa_fetch(
    entity = "institutions",
    id = list_structures_id,
    options = list(
      select = c(
        "id", 
        "display_name",
        "display_name_acronyms",
        "ror", 
        "ids",
        "type",
        "associated_institutions"
      )
    ),
    verbose = TRUE
  )

# Pré-traitement
## Extraction identifiants wikidata
asu_structures <- 
  asu_structures %>% 
  hoist(ids, "wikidata") %>% 
  select(-ids)

## Extraction institutions associées
asu_structures <- 
  asu_structures %>% 
  unnest(associated_institutions, names_sep = "_")
  
## Sélection et changement de nom variables
asu_structures <- 
  asu_structures %>% 
  select(
    "structure_id" = id,
    "structure" = display_name,
    "structure_acronyms" = display_name_acronyms,
    "structure_ror" = ror,
    "structure_wikidata" = wikidata,
    "etablissement_id" = associated_institutions_id,
    "etablissement" = associated_institutions_display_name,
    "etablissement_ror" = associated_institutions_ror,
    "etablissement_type" = associated_institutions_type,
    "etalissement_relations" = associated_institutions_relationship
  )


# Sauvegarde --------------------------------------------------------------
asu_structures %>% rio::export(here::here("data", "asu_structures.xlsx"))

