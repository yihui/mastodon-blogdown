Sys.setenv(TWITTER_PAT = 'twitter_token.rds')
dir.create('content/post', showWarnings = FALSE)
d = Sys.Date()

p = list.files('content/post/', '^\\d{4,}-\\d{2}-\\d{2}[.]md$')
p = max(as.Date(gsub('.md$', '', p)))
if (length(p) && d <= p && !interactive()) q('no')

if (!file.exists(f <- 'R/keywords.csv')) writeLines('query,since_id', f)
m = read.csv(f, colClasses = 'character')
d = as.character(d)
x = NULL; t = paste('Tweets on', d); n = 0  # markdown text, post title, and favorite count

for (i in seq_len(NROW(m))) {
  q = m[i, 'query']
  s = rtweet::search_tweets(q, include_rts = FALSE, since_id = m[i, 'since_id'])
  if (NROW(s) == 0 || is.na(s$favorite_count[1])) next

  m[i, 'since_id'] = s$status_id[1]  # update since_id for newer results next time
  k = order(s$favorite_count, s$retweet_count, decreasing = TRUE)
  s = s[k, ]
  u = rtweet::users_data(s)[k, ]
  if ((n2 <- s$favorite_count[1]) >= n) {
    n = n2; t = gsub('\\s+', ' ', s$text[1])
  }
  s$text = gsub('\\s*$', '', s$text)
  s$text = gsub('\n\n', '\n>\n', s$text)
  s$text = paste(s$text, sprintf(' [&#8618;](https://twitter.com/xieyihui/status/%s)', s$status_id))
  x = c(
    x, paste('#', q), '',
    paste0('> **', u$name, '** (@', u$screen_name, '; ', s$favorite_count, '/',
           s$retweet_count, '): ', s$text, '\n\n<!-- -->\n\n')
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
