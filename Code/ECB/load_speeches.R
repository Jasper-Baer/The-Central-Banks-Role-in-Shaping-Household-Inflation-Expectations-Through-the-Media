dataset <- read.table(
  file.choose(),
  sep = "|",
  quote = "",
  fill = TRUE,
  header = FALSE,
  encoding = "UTF-8",
  stringsAsFactors = FALSE
)

write.csv(x=dataset, file="D:\\Studium\\PhD\\Single Author\\Data\\ECB\\Speeches\\all_ECB_speeches_repaired.csv")