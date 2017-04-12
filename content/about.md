---
title: About This Site
date: 2017-04-12
---

This website is automatically built for my personal interest only. The basic ideas:

- Search Twitter messages through predefined keywords using the R package [**rtweet**](https://mkearney.github.io/rtweet/) on Travis CI on a [daily](https://docs.travis-ci.com/user/cron-jobs/) basis;
- Convert the results to Markdown files and push to Github;
- Build the website using [Hugo](https://gohugo.io) automatically on [Netlify](https://www.netlify.com).

Then I can subscribe to the RSS feed through an RSS reader, and know if anybody was trying to praise me in a corner yesterday.

![Goose smile](https://slides.yihui.name/gif/goose-smile.gif)

You are welcome to fork this project on [Github](https://github.com/yihui/twitter-blogdown), and use it by yourself. Some technical notes in case you want to do that:

- Learn a bit about **rtweet**, especially how to get your own [access token](https://mkearney.github.io/rtweet/articles/auth.html);
- After you save the token to an `.rds` file, say, `twitter_token.rds`, follow the [Travis guide](https://docs.travis-ci.com/user/encrypting-files) to encrypt it and tweak your `.travis.yml` accordingly;
- Tweak the [keywords](](https://github.com/yihui/twitter-blogdown/blob/master/R/keywords.csv)) I defined for myself;
- Define an environment variable `GITHUB_PAT` [on Travis](https://docs.travis-ci.com/user/environment-variables#Defining-Variables-in-Repository-Settings), which is a Github [personal access token](https://help.github.com/articles/creating-a-personal-access-token-for-the-command-line/) that should have write access to your repo, because the Markdown files will need to be pushed to your repo from Travis;
- Connect your Github repo with [Netlify](https://app.netlify.com), so that whenever there are new commits in your repo, Netlify will automatically rebuild your site. The build command can be `hugo_0.19`, and the publish dir is `public`.

Then sit back and relax. Travis and Netlify will do the hard work for you. You may have a good or bad day tomorrow after you read the tweets. Who knows. Social network is a fantasy, filled with isolated and lonely people. You'd better not spend too much time there.

Well, you may ask, "Hey, why did you build this website then?" Good question. I just wanted to learn a bit about the **rtweet** package. I have never tried to scrape data from Twitter before. Since I'm working on **blogdown** recently, I thought it might be a good exercise to build a website automatically.
