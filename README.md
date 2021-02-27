## Sunpaper

Sunpaper is a simple bash script to change wallpaper based on your local sunrise and sunset times. It seeks to closely replicate the functionality of the Big Sur Dynamic Desktop Wallpapers. This script works really well as a Sway/i3 Waybar or i3blocks module but it should work on any linux distro / window manager.

![Screenshot](screenshot.jpg)

## Dependencies

1. [sunwait](https://github.com/risacher/sunwait)
2. [wallutils](https://github.com/xyproto/wallutils)

Depending on your distro these utilities may be available within community repositories.


## Install

`git clone https://github.com/hexive/sunpaper`

1. put sunpaper.sh wherever you want it.
2. make it executable:`chmod +x sunpaper.sh`
3. put the wallpaper folders from sunpaper/images/ wherever you want them.
4. edit sunpaper.sh to set some configuration options (see below)
5. call sunpaper.sh from waybar or i3blocks or cron etc (see below)

## Configure

Sunpaper takes a few configuration options available by editing the sunpaper.sh file directly:

> NOTE: if you change settings, you'll need to also remove the cache file at ~/.config/sunpaper.cache to see the changes before the next time event.

Set your latitude and longitude for your current location. If you aren't sure you can get these numbers from places like [latlong.net](https://www.latlong.net/) or even google maps.

Make sure your latitude number ends with N  
`latitude="38.9072N"`

and longitude ends with W  
`longitude="77.0369W"`

You can set what mode your wallpaper is displayed.  
Options include: stretch | center | tile | scale | zoom | fill  
`wallpaperMode="scale"`

And finally you need to set the full path to the location of the sunpaper/images with no ending folder slash:  
`wallpaperPath="$HOME/sunpaper/images/The-Desert"`

The timing of wallpaper changes is also configurable with human-readable relative time statements, if you can make sense of the bash. By default, most of the day/night is represented with a single wallpaper image, but then there is a flurry of activity within 1.5 hours of both sunrise/sunset.

## Usage

This script can be called directly however you'd like. Ideally, it's called from something with an interval of 60 seconds. That's why statusbars are easy choices, but there are many other options.

**As a waybar module**

Add to waybar/config
```
    "custom/sunpaper":{
      "exec": "/path/to/sunpaper.sh", 
      "interval": 60
      "tooltip": false
    },
```
**As a i3blocks module**

Add to i3blocks.conf
```
[sunpaper]
command=/path/to/sunpaper.sh
interval=60
```
**As a cron job**

[Crontab setup to call a script every minute](https://linuxhint.com/run_cron_job_every_minute/)

**As a systemd service**

Something like this should work in theory. If you try it, you'll probably need full paths in the script and maybe use your WM specific wallpaper cli changing method instead of using setwallpaper. I'll [test this](https://unix.stackexchange.com/questions/198444/run-script-every-30-min-with-systemd) and write it up here if it works.

## Why Sunpaper?

The Big Sur minimal wallpapers are beautiful and I wanted to use them on my linux machines. There are many other timed wallpaper utilities out there, but they all seemed to be using static timetables for the wallpaper changes. I wanted something that could be directly tied to the sunrise/sunset times locally and adapt to changes over the year without any fiddling on my part.

## Known Issues

- Sway - there's a brief gray flash on each wallpaper change. It's a [known issue](https://github.com/swaywm/sway/issues/3693) with swaywm, apparently, there's not an easy fix.
- Sway - if you use [azote](https://github.com/nwg-piotr/azote) at any time to change your wallpaper, Sunpaper won't be able to make any further changes for that session (logout and log back in to continue).

## Disclaimers

Wallpaper images are not mine, they come from Apple Big Sur.
