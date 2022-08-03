# cron-parser-challenge
cron-parser-challenge in Swift  
This is the first command line application for MacOS I've done in swift, so I didn't have time to do many things in the 2 hours ☹️  
I would have liked to have separated the exercise by classes in files and also to have done unit tests.  

## Getting Started
### Requirements 🚧

- Swift 5 

### Setup ⚙

1. Fork this repository or clone the repository or download the latest release
2. Open a terminal in the folder
3. cat config.txt | swift main.swift 16:10

### Project Files 📁
```
main.swift
config.txt
```
### Description 📁

The command line tool is very simple, in the config.txt we have this configuration:
```
30 1 /bin/run_me_daily
45 * /bin/run_me_hourly
* * /bin/run_me_every_minute
* 19 /bin/run_me_sixty_times
```
we enter this command (```cat config.txt | swift main.swift 16:10```) it will return:
```
1:30 tomorrow - /bin/run_me_daily
16:45 today - /bin/run_me_hourly
16:10 today - /bin/run_me_every_minute
19:00 today - /bin/run_me_sixty_times
```
also if we don't set the time parameter, it will use the device time:  
```
cat config.txt | swift main.swift
```
### ScreenShoots
<img width="730" alt="screen" src="https://user-images.githubusercontent.com/11006805/182626550-c8cba4f6-4c14-4077-a905-89bab5bf8b27.png">

