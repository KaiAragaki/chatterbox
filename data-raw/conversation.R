times <- c(
  "2024-11-05 11:11:11",
  "2024-11-05 11:11:12",
  "2024-11-05 11:20:01",
  "2024-11-06 12:02:10",
  "2024-11-06 12:02:11",
  "2024-11-06 13:42:11",
  "2024-11-06 17:10:42"
) |>
  as.POSIXlt()

texts <- c(
  "Hey",
  "This is just some example text for this R package, so you can see how it looks and test it and stuff.",
  "Oh that's pretty cool!",
  "In theory, this should support emoji 🌎",
  "I don't know if it'll support images yet though :(",
  "K",
  "Anyway, how's life been?"
)

people <- c("Alice", "Alice", "Bob", "Alice", "Alice", "Bob", "Bob")

conversation <- data.frame(
  time = times,
  text = texts,
  person = people
)

usethis::use_data(conversation, overwrite = TRUE)
