#https://gist.github.com/b-rodrigues/d427703e76a112847616c864551d96a1
library(rix)

rix(
  r_ver = "4.5.1",
  project_path = getwd(),
  r_pkgs = c(
    "reactable",
    "reactablefmtr@2.0.0",
    "htmltools",
    "dplyr",
    "tidyr",
    "anytime",
    "pointblank",
    "lubridate"
  ),

  ide = "none",
  system_pkgs = c("air-formatter", "quarto"),
  overwrite = TRUE
)
