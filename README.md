# leine

<!-- badges: start -->
[![Main](https://github.com/subugoe/leine/workflows/.github/workflows/main.yaml/badge.svg)](https://github.com/subugoe/leine/actions)
[![Codecov test coverage](https://codecov.io/gh/subugoe/leine/branch/master/graph/badge.svg)](https://codecov.io/gh/subugoe/leine?branch=master)
[![CRAN status](https://www.r-pkg.org/badges/version/leine)](https://CRAN.R-project.org/package=leine)
[![Lifecycle: experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)
<!-- badges: end -->

[wikipedia:](https://en.wikipedia.org/wiki/Leine):

> The Leine (German: [ˈlaɪnə]; Old Saxon Lagina) is a river in Thuringia and Lower Saxony, Germany.

[WAG](https://www.sub.uni-goettingen.de/kontakt/abteilungen-a-z/abteilungs-und-gruppendetails/abteilunggruppe/wissen-als-gemeingut/)
runs several big data pipelines used in various data products.

These pipelines, though largely not themselves run in R, are here organised into an R package.

## Design

WAG is a relatively small team of data analysts, serving academic and librarian stakeholders with various data products.

The data engineering of our pipelines has to correspond to these constraints:

- Our most important, and scarce resource is developer time.
- Our most important, and hard target is reproducibility.

### Priorities

From this follows:

1. Cheap compute is good, but **convenience** is better.
    Our workloads are comparatively minor, labor costs are a much bigger driver.
1. Special-purpose tools are good, but **standardising** on fewer tools is better.
    Given our small, and sometimes churning team, we can only support very few tools.
1. Working prototypes are good, but **reproducibility** is better.
    For our academic (as well as librarian) stakeholders, reproduciblity trumps all else.
1. Interactive, one-off results are good, but **automation**, **testing** and **documentation** are better.
    Given churn (and vacation, context-switching, etc.), we must avoid low [bus factors](https://en.wikipedia.org/wiki/Bus_factor).
    Data pipelines, especially, must be designed to be run and be maintainable without the original developer.

### ELT

Our data pipelines follow an extract-load-transform paradigm.
They are centered a "data river" (or data like) hosted on the Google Cloud Platform (GCP).

1. Data river
    1. Data is **extracted** from sources in its *rawest form* into to GCP Cloud Storage (for long-term versioned coldline storage).
    1. Data is then **loaded** into GCP BigQuery.
        If the source data is schemaless or noncompliant, it is loaded *without schema*, with entire unparsed entries as cells.
1. Data warehouse
    1. Data is then **transformed** into a canonical form in GCP BigQuery with a well-defined schema.
1. Data mart
    1. Data is then further transformed according to shared needs of WAGs data products on GCP BigQuery.
