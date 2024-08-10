# Recode Variable Values

The **Recode** feature provides functionality for re-mapping
operations, including binning, log transforms, ratios, and mapping
categoric variables into indicator variables.

A **Binning** function is provided, choosing between Quantile binning,
KMeans binning, and Equal Width binning. For each option the default
number of bins is 4, and we can change this to suit our needs. The
generated variables are prefixed with either BIN_QUn_, BIN_KMn_, and
BIN_EWn_ respectively, with n replaced with the number of bins. Thus,
we can create multiple binnings for any variable.

An example of why we might want to do this is to visualise data. A
mosaic plot, for exapmle, is only useful for categoric data and so we
could turn Sunshine into a categoric by binning. Also binning can be
used to show a box plot against different targets.

Note that quantile binning is the same as equal count binning.

Rattle can create **Indicator Variables**.  Some model builders do not
handle categoric variables. Neural networks and regression are two
examples. A simple approach in this case is to turn the categoric
variable into some numeric form. If the categoric variable is not an
ordered categoric variable, then the usual approach is to turn the
single variable into a collection of so called indicator
variables. For each value of the categoric variable there will be a
new indicator variable which will have the value 1 for any observation
that has this categoric value, and 0 otherwise. The result is a
collection of numeric variables.

Rattle can transform one or more categoric variables into a collection
of indicator variables. Each is prefixed by INDI_ and the remainder is
made up of the name of the categoric variable (e.g., gender) and the
particular value (e.g., female), to give INDI_gender_female.

There is not always a need to transform a categoric variable. Some
model builders, like the regressions in Rattle, will do it for us
automatically.

The **Join Categorics** option provides a convenient way to stratify the
dataset, based on multiple categoric variables. It is a simple
mechanism that creates a new variable from the combination of all of
the values of the two constituent variables selected in the Rattle
interface. The resulting variables are prefixed with JOIN_ and include
the names of both the constituent variables.

A simple example might be to join gender and marital, to give a new
variable, JOIN_marital_gender.

We might also want to join a numeric variable and a categoric
variable, like the typical age and gender stratification. To do this
we first use the Binning option within Remap to categorise the age
variable

A Log transform is available. The generated variable is prefixed with
REMAP_LOG_.

>
