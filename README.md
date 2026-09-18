# met4media

`met4media` is an easy-to-use R package that enables users to compare the metabolite profiles of novel cell culture media with those of user specified media and/or a database of publicly available commercial cell culture media. The package is primarily designed to support media development using complex substrates, such as plant-based hydrolysates. 

The package provides functionality for metabolite standardization, categorization, comparison, and visualization. It standardizes metabolite names across datasets to account for differences in naming conventions. Metabolites can also be categorized into classes such as amino acids and vitamins, facilitating comparison of media composition. Finally, the package enables visualization of metabolite composition using bar plots and heatmaps.

# Installation

Installation in R can be performed directly from github using the `devtools` package:

```R
library(devtools)
install_github('Kathy-Isaac/met4media')
```

# Table of contents

1. [Standardization](#standardization)
2. [Categorization](#categorization)
3. [Comparison](#load-comparison-datasets)
4. [Visualization](#visualization)
   1. [Bar plot](#bar-plot)
   2. [Heatmap](#heatmap)

# Standardization
The 'standardize' function standardizes metabolite names across datasets to account for differences in naming conventions. Its input argument is a dataframe with a 'Name' column containing metabolite names to be standardized. It outputs a dataframe with columns containing the standardized name, HMDB ID and KEGG ID. The function is a wrapper that uses MetaboAnalyst API.

```R
example <-  data.frame(
  Name = c("Glucose", "Tyrosine", "Valine"),
  Concentration = c(4500, 3000, 2000)
)

example <- standardize(example)
```

**Table 1. Example input to standardize function.**

| Name | Concentration | 
|---|---:|
| Glucose | 4500 |
| Tyrosine | 3000 |
| Valine | 2000 |

**Table 2. Example output from standardize function.**

| Name | Concentration | Compound | KEGG | HMDB |
|---|---:|---:|---:|---:|
| Glucose | 4500 | D-Glucose | C00031 | HMDB0000122 |
| Tyrosine | 3000 | L-Tyrosine | C00082 | HMDB0000158 |
| Valine | 2000 | L-Valine | C00183 | HMDB0000883 |

