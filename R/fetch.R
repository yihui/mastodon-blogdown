options('rtweet:::config_dir' = normalizePath('~'))
dir.create('content/post', showWarnings = FALSE)
d = Sys.Date()

update.packages(ask = FALSE, checkBuilt = TRUE)
if (!requireNamespace('rtweet', quietly = TRUE)) install.packages('rtweet')

if (!file.exists(f <- 'R/keywords.csv')) writeLines('query,since_id', f)
m = read.csv(f, colClasses = c('character', 'character', 'integer'))
d = as.character(d)
x = NULL; t = paste('Tweets on', d); n = 0  # markdown text, post title, and favorite count
ids = NULL  # ids of tweets that have already been included in the post

for (i in seq_len(NROW(m))) {
  q = m[i, 'query']
  s = rtweet::search_tweets(q, n = 1000, include_rts = FALSE, since_id = m[i, 'since_id'])
  if (NROW(s) == 0 || is.na(s$favorite_count[1])) next
  u = rtweet::users_data(s)
  k = !(s$id_str %in% ids) & (s$favorite_count + s$retweet_count >= m[i, 'threshold']) &
    (unlist(lapply(s$entities, function(x) sum(!is.na(x$hashtags$text)))) < 10)
  s = s[k, ]
  u = u[k, ]
  if (nrow(s) == 0) next
  ids = c(ids, s$id_str)

  m[i, 'since_id'] = s$id_str[1]  # update since_id for newer results next time
  k = order(s$favorite_count, s$retweet_count, decreasing = TRUE)
  s = s[k, ]
  u = u[k, ]
  if ((n2 <- s$favorite_count[1]) >= n) {
    n = n2; t = gsub('\\s+', ' ', s$text[1])
  }
  s$text = gsub('\\s*$', '', s$text)
  s$text = gsub('\n\n', '\n>\n', s$text)
  s$text = paste(s$text, sprintf(' [&#8618;](https://twitter.com/%s/status/%s)', u$screen_name, s$id_str))
  x = c(
    x, paste('#', gsub(' .+', '', q)), '',
    paste0('> **', u$name, '** (@', u$screen_name, '; ', s$favorite_count, '/',
           s$retweet_count, '): ', gsub('\n', '\n> ', s$text), '\n\n<!-- -->\n\n')
  )
  Sys.sleep(1)
}

p = sprintf('content/post/%s.md', d)
if (length(x)) if (file.exists(p)) {
  cat(paste(c('', '', x, ''), collapse = '\n'), file = p, append = TRUE)
} else writeLines(
  c(jsonlite::toJSON(list(title = t, date = d), auto_unbox = TRUE, pretty = TRUE), '', x),
  p
)

write.csv(m[order(m$query), , drop = FALSE], f, row.names = FALSE)
