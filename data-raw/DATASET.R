owd <- setwd(tempdir())

fix_names <- function(name) {

  # Convert to common names in English
  new_name <- countrycode::countryname(name)

  return(new_name)
}

memoise::cache_filesystem(
  download.file(
    url = "https://doi.org/10.1371/journal.pcbi.1005697.s002",
    destfile = "all_datasets.zip"
  )
)

files <- unzip("all_datasets.zip", unzip = "internal")

library(fs)

files <- file_move(files, gsub("locations_", "", files))
files <- file_move(files, getwd())

library(readxl)

locations <- c(
  "work",
  "school",
  "home",
  "all",
  "other"
)

for (l in locations) {

  res <- list()

  file1 <- paste0("MUestimates_", l, "_1.xlsx")
  file2 <- paste0("MUestimates_", l, "_2.xlsx")

  countries1 <- excel_sheets(file1)
  countries2 <- excel_sheets(file2)

  for (c in countries1) {
    df <- as.matrix(read_xlsx(
      file1,
      col_names = FALSE,
      sheet = c,
      skip = 1
    ))
    rownames(df) <- colnames(df) <- sprintf("%02i_%02i", seq(0, 75, 5), seq(5, 80, 5))
    c <- fix_names(c)
    res[[c]] <- df
  }
  for (c in countries2) {
    df <- as.matrix(read_xlsx(
      file2,
      col_names = FALSE,
      sheet = c
    ))
    rownames(df) <- colnames(df) <- sprintf("%02i_%02i", seq(0, 75, 5), seq(5, 80, 5))
    c <- fix_names(c)
    res[[c]] <- df
  }

  saveRDS(res, paste0(owd, "/inst/extdata/", l, ".rds"))

}

setwd(owd)
