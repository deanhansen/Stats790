library(jsonlite)
library(tidyverse)
library(spotifyr)
library(purrr)
library(RSQLite)
library(lubridate)
library(ggthemes)

#using json data and spotifyr api to collect whether songs belong or don't in my library
streaming_history_path = "/Users/deanhansen/Development/data/spotify/MyData"
streaming_history_files <- dir(streaming_history_path, pattern = "StreamingHistory*")
streaming_history_json <- streaming_history_files %>% 
  map(~fromJSON(file.path(streaming_history_path,.))) %>%
  list_rbind()
View(streaming_history_json)

end_song_path = "/Users/deanhansen/Development/data/spotify/MyData 2"
end_song_files <- dir(end_song_path, pattern = "endsong_*")
end_song_json <- end_song_files %>% 
  map(~fromJSON(file.path(end_song_path,.))) %>%
  list_rbind()
View(end_song_json)

your_library_path = "/Users/deanhansen/Development/data/spotify/MyData"
your_library_files <- dir(your_library_path, pattern = "YourLibrary*")
your_library_json <- your_library_files %>% 
  map(~fromJSON(file.path(your_library_path,.)))
View(your_library_json)

#write_csv(streaming_history_json, "spotifystreaming_history_json.csv")
#write_csv(end_song_json, "end_song_json.csv")

streaming_history_df <- streaming_history_json %>%
  mutate(s_played = round(msPlayed * 0.001, 0)) %>%
  rename(end_time = endTime, ms_played = msPlayed, artist_name = artistName, track_name = trackName)

end_song_df <- end_song_json %>%
  filter(reason_end %in% c("trackdone", "endplay", "backbtn")) %>%
  filter(is.na(episode_name) == TRUE) %>%
  filter(is.na(spotify_track_uri) == FALSE) %>%
  filter(is.na(skipped) == TRUE | skipped == "FALSE") %>%
  select(-username, -platform, -ip_addr_decrypted, -user_agent_decrypted, -episode_name, -episode_show_name, -shuffle, -skipped, -incognito_mode, -offline, -offline_timestamp) %>%
  mutate(ts = as_date(ts), s_played = round(ms_played * 0.001, 0)) %>%
  rename(artist_name = master_metadata_album_artist_name, 
         track_name = master_metadata_track_name,
         album_name = master_metadata_album_album_name)

your_library_tracks_df <- your_library_json[[1]]$tracks
your_library_tracks_df <- your_library_tracks_df %>%
  mutate(uri = str_replace(pattern = "spotify:track:", string = uri, replacement = ""))

df_end_song_streaming_history <- merge(x = end_song_df, y = streaming_history_df, by = c("artist_name", "track_name"))
View(df_end_song_streaming_history)

map(your_library_tracks_df$uri, get_track_audio_features)

#construct some plots
end_song_df %>%
  group_by(s_played) %>%
  count() %>%
  ggplot(aes(x = s_played, y = n)) +
  geom_point(cex = 0.4)

streaming_history_mean <- mean(streaming_history_df$s_played)

streaming_history_df %>%
  group_by(s_played) %>%
  count() %>%
  filter(s_played > 0) %>%
  ggplot(aes(x = s_played, y = n)) +
  geom_point(cex = 0.4) +
  geom_vline(xintercept = streaming_history_mean, color = "blue") +
  annotate("vline", xintercept = streaming_history_mean)


##########################

end_song_df %>%
  group_by(artist_name, track_name) %>%
  count(track_name) %>%
  arrange(desc(n)) %>% 
  View()

top_artists_df <- end_song_df %>%
  group_by(artist_name) %>%
  count(artist_name) %>%
  rename(songs = n) %>%
  arrange(desc(songs))

ggplot(top_artists_df[1:10,], aes(x = artist_name, songs)) +
  geom_point()

hist(end_song_df$s_played)

ggplot(end_song_df %>% filter(reason_end == "trackdone" & conn_country != "CA"), aes(x = s_played, group = conn_country, color = conn_country)) +
  geom_histogram(bins = 300) +
  scale_y_log10() +
  scale_color_brewer(palette = "Spectral") +
  xlim(c(0, 600)) +
  ylim(c(0, 58)) +
  
  # Themes
  theme_minimal(base_family = "karla") +
  theme(
    plot.title = element_text(family = "karla", size = 16, face = "bold", hjust = .5),
    plot.subtitle = element_text(size = 14, hjust = .5, margin = margin(b = 10)),
    plot.caption = element_text(size = 8, hjust = 0, margin = margin(t = 10)),
    axis.title.x = element_text(size = 12, margin = margin(t = 5)),
    axis.title.y = element_blank(),
    axis.text.x = element_text(size = 11, margin = margin(t = 5)),
    axis.text.y = element_text(size = 11, margin = margin(r = 5)),
    legend.title = element_blank(),
    legend.text = element_text(size = 12, margin = margin(r = 10)),
    panel.background = element_rect(fill = "gray97", color = NA),
    panel.grid.major.x = element_blank(),
    panel.grid.major.y = element_line(linewidth = .5, color = "white"),
    panel.grid.minor.x = element_blank(),
    panel.grid.minor.y = element_blank()
  )

##########################

df_11 <- end_song_df %>% 
  select(ts, s_played) %>% 
  mutate(ts_month = month(ts), ts_year = year(ts), ts_day = day(ts)) %>%
  group_by(ts, ts_month, ts_year, ts_day) %>% 
  reframe(seconds_played = sum(s_played)) %>%
  mutate(month = month.abb[month(ts)])

ggplot(df_11 %>% filter(ts_year > 2018), aes(x = fct_reorder(month, ts_month), y = seconds_played*(1/60), color = fct_reorder(month, ts_month))) +
  labs(color = "Month", x = "Month", y = "Minutes spent streaming music") +
  geom_point(shape = 12) +
  facet_wrap(~ts_year) +
  geom_boxplot()

##########################

df_12 <- df_11 %>% 
  filter(ts_year > 2018) %>% 
  group_by(ts_month, month, ts_day) %>% 
  reframe(seconds_played = mean(seconds_played))

ggplot(df_12, aes(x = ts_day, y = seconds_played*(1/60), color = fct_reorder(month, ts_month))) +
  labs(color = "Month", x = "Day", y = "Minutes spent streaming music") +
  geom_point(shape = 4) +
  geom_smooth() +
  theme_bw() +
  facet_wrap(~fct_reorder(month, ts_month))

###########################
#connect to database
con <- dbConnect(SQLite(), "/Users/deanhansen/Development/data/spotify/spotify.db")

#query the database
df <- dbGetQuery(con, "") %>% 
  as_tibble()
View(df)

