## Sunpaper

Sunpaper is a simple bash script to change wallpaper based on your local sunrise and sunset times. It seeks to closely replicate the functionality of the Big Sur Dynamic Desktop Wallpapers. This script works really well as a Sway/i3 Waybar or i3blocks module but it should work on any distro / window manager.

![Screenshot](screenshot.jpg)

## Dependencies

1. [sunwait](https://github.com/risacher/sunwait)
2. [wallutils](https://github.com/xyproto/wallutils)

Depending on your distro these utilities may be available within community repositories.


## Install

1. put sunpaper.sh wherever you want it.
2. make it executable:`chmod +x sunpaper.sh`
3. put the folders from sunpaper/images/ wherever you want them.
4. edit sunpaper.sh to set some configuration options (see below)
5. call sunpaper.sh from waybar or i3blocks or cron etc (see below)

## Configure

Sunpaper takes a few configuration options available by editing the sunpaper.sh file directly:

You'll need to set your latitude and longitude for your current location. If you aren't sure you can get these numbers from places like [latlong.net](https://www.latlong.net/) or even google maps.

Make sure your latitude number ends with N  
`latitude="38.9072N"`

and longitude ends with W  
`longitude="77.0369W"`

You can set what mode your wallpaper is displayed.  
Options include: stretch | center | tile | scale | zoom | fill  
`wallpaperMode="scale"`

And finally you need to set the full path to the location of the sunpaper/images with no ending folder slash:  
`wallpaperPath="$HOME/sunpaper/images/The-Desert"`

## Start it up

This script can be called directly however you'd like. Ideally, it's called from something with an interval of 60 seconds. That's why statusbars are easy choices. But you could also set up a [cronjob to call the script every minute](https://linuxhint.com/run_cron_job_every_minute/)

**As a waybar module**

Add to waybar/config
```
    "custom/sunpaper":{
      "exec": "~/.config/waybar/modules/sunpaper.sh", 
      "interval": 60
      "tooltip": false
    },
```
**As a i3blocks module**

Add to i3blocks/config
```
[sunpaper]
command=/path/to/sunpaper.sh
interval=60
```
