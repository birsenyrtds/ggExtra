# ggExtra - Add marginal histograms to ggplot2, and more ggplot2 enhancements

[![CRAN version](https://www.r-pkg.org/badges/version/ggExtra)](https://cran.r-project.org/package=ggExtra)
[![R-CMD-check](https://github.com/daattali/ggExtra/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/daattali/ggExtra/actions/workflows/R-CMD-check.yaml)

> *Copyright 2016 Dean Attali. Licensed under the MIT license.*

`ggExtra` is a collection of functions and layers to enhance ggplot2.

The flagship function is `ggMarginal()`, which adds marginal plots
(histograms, density plots, boxplots, and more) to ggplot2 scatterplots.

You can view a live interactive demo here:
https://daattali.com/shiny/ggExtra-ggMarginal-demo/


## New feature: ggMarginalSignif()

This development branch introduces `ggMarginalSignif()`, a helper function
that extends `ggMarginal()` by adding statistical significance annotations
to marginal violin plots around a scatter plot.

It supports:

- grouped marginal violin plots
- pairwise comparisons using `ggsignif`
- custom annotation labels
- independent positioning of annotations
- annotations on both top and right marginal panels
- alignment of marginal axes with the main scatter plot scales

This makes it easier to visually compare grouped distributions while
keeping statistical inference directly on the marginal panels.


### Example

```r
library(ggplot2)
library(ggExtra)
library(ggsignif)

data(mpg, package = "ggplot2")

ggMarginalSignif(
  data = mpg,
  x = displ,
  y = hwy,
  group = class,
  top_comparisons = list(
    c("2seater", "suv"),
    c("pickup", "suv")
  ),
  top_y_position = c(43, 36),
  right_comparisons = list(
    c("2seater", "suv"),
    c("compact", "suv")
  ),
  right_y_position = c(7.2, 6.4)
)
```

![](man/figures/ggMarginalSignif-example.png)


## Installation

`ggExtra` is available through both CRAN and GitHub.

Install from CRAN:

```
install.packages("ggExtra")
```

Install development version from GitHub:

```
install.packages("devtools")
devtools::install_github("daattali/ggExtra")
```


## Usage

Load the package together with ggplot2:

```
library(ggExtra)
library(ggplot2)
```


## ggMarginal()

`ggMarginal()` is an easy drop-in solution for adding marginal plots
(histograms, density plots, boxplots, violin plots) to ggplot2 scatterplots.

Example:

```
set.seed(30)
df1 <- data.frame(
  x = rnorm(500, 50, 10),
  y = runif(500, 0, 50)
)

p1 <- ggplot(df1, aes(x, y)) +
  geom_point() +
  theme_bw()

ggMarginal(p1)
```


## Other helper functions

The package also includes several small convenience helpers:

- `removeGrid()` – remove grid lines
- `removeGridX()` – remove vertical grid lines
- `removeGridY()` – remove horizontal grid lines
- `rotateTextX()` – rotate x-axis labels
- `plotCount()` – quickly visualize count data


## Visual testing

Visual snapshot tests ensure that `ggMarginal()` produces correct output
across environments. Because graphical rendering differs between systems,
Docker containers are used to provide reproducible test environments.

See the GitHub Actions workflow for details:
.github/workflows/test-ggplot2-versions.yml
