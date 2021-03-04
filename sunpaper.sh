#!/bin/bash

##CONFIG OPTIONS---------------------------------

# This script also has some testing functions that 
# can be called with option flags. 
# Check sunpaper.sh -h 

#################################################
# BASIC CONFIGURATION
#################################################

# Set your local latitude and longitude for sun calculations
latitude="38.9072N"
longitude="77.0369W"

# Set full path to the wallpaper theme folder
# Theme folder names:
# Apple: The-Beach The-Cliffs The-Lake The-Desert
# Louis Coyle: Lakeside
wallpaperPath="$HOME/sunpaper/images/The-Desert"

# Set how you want your wallpaper displayed
# stretch | center | tile | scale | zoom | fill
wallpaperMode="scale"

# Sunpaper writes some cache files to keep track of 
# persistent variables.
#
# NOTE: call sunpaper.sh -c to clear cache contents. This
# will force a wallpaper reload after configuration changes.
#
# Set a different folder for this file or just leave
# it as the default.
cachePath="$HOME/.cache"


# The rest of these are optional configuration modes
#
#################################################
# DARKMODE
#################################################
# You may use script to trigger a darkmode on your desktop
# or any other actions you want to preform on day / night.
# This feature is disabled by default but you can enable
# it here like:
# darkmode_enable="true"
darkmode_enable="false"

# And if darkmode is enabled, use these two lines
# to set the the external command to run on day / night.
# example: 
# darkmode_run_day="bash /path/to/switch.sh light"
darkmode_run_day=""
darkmode_run_night=""


#################################################
# WAYBAR MODE
#################################################
# Sunpaper has a special mode for use with sway/waybar 
# It displays an icon and sun times report as a tooltip.
# Call it with a flag sunpaper.sh --waybar

# Set the icon display for that here
status_icon=""


#################################################
# PYWAL MODE 
# requires pywal (https://github.com/dylanaraps/pywal)
#################################################
# Sunpaper can call pywal to set a new color scheme
# on each wallpaper image change. 
# pywalmode_enable="true"
pywalmode_enable="false"

# If you like to use pywal with specific options 
# you may set them here. 
#
# NOTE Sunpaper does not use pywal to set the wallpaper 
# images, so those options will be ignored.
#
# Set pywal options that will always be used
# for example: 
#pywal_options="-e --backend colorthief"
pywal_options=""

# Set pywal options that will be used only during
# the DAY or NIGHT for example:
#pywal_options_day="-l"
pywal_options_day=""
pywal_options_night=""

# Some pywal options like themes would be in conflict
# with setting colors by image. If you wish to use 
# pywal theme colors instead, then switch these to false to 
# disable pywal from setting colors by image.
pywal_image_day="true"
pywal_image_night="true"


#################################################
# EXTERNAL CONFIGURATION
#################################################
# Congratulations you've found a super secret undocumented
# experimental feature. If you prefer to have an external 
# configuration file, then simply copy everything above this 
# section and put it in ~/.config/sunpaper/config
#
# Leave everything here in place as it is. Your config values
# will overwrite these defaults.
#
# Just check back here if you you ever update the script for
# any new config options.

##CONFIG OPTIONS END---------------------------- 


#Sunpaper Version History
#2.26 - initial commit
#2.27 - functionize & option flags
#2.28 - new darkmode feature
#3.01 - new waybar feature
#3.03 - pywall integration

version="3.03"

# Check for external config file
CONFIG_FILE=$HOME/.config/sunpaper/config
if [ -f "$CONFIG_FILE" ];then
    . "$CONFIG_FILE"
fi

#Trim any trailing slashes from paths
wallpaperPath=$(echo $wallpaperPath | sed 's:/*$::')
cachePath=$(echo $cachePath | sed 's:/*$::')

#Define cache paths
cacheFileWall="$cachePath/sunpaper_cache.wallpaper"
cacheFileDay="$cachePath/sunpaper_cache.day"
cacheFileNight="$cachePath/sunpaper_cache.night"

set_cache(){

    if [ -f "$cacheFileWall" ]; then
        currentpaper=$( cat < $cacheFileWall );
    else 
        touch $cacheFileWall
        echo "0" > $cacheFileWall
        currentpaper=0
    fi
}

clear_cache(){

    if [ -f "$cacheFileWall" ]; then
        rm $cacheFileWall
        echo "cleared wallpaper cache"
    else 
        echo "no wallpaper cache file found"
    fi

    if [ -f "$cacheFileDay" ]; then
        rm $cacheFileDay
        echo "cleared darkmode day cache"
    else 
        echo "no darkmode day cache found"
    fi

    if [ -f "$cacheFileNight" ]; then
        rm $cacheFileNight
        echo "cleared darkmode night cache"
    else 
        echo "no darkmode night cache found"
    fi
}

get_currenttime(){

    if [ "$time" ]; then
        currenttime=$(date -d "$time" +%s)
    else
        currenttime=$(date +%s)
    fi
}

get_suntimes(){

    # Use sunwait to calculate sunrise/sunset times
    get_sunrise=$(sunwait list civil rise $latitude $longitude);
    get_sunset=$(sunwait list civil set $latitude $longitude);

    # Use human-readable relative time for offset adjustments
    sunrise=$(date -d "$get_sunrise" +"%s");
    sunriseMid=$(date -d "$get_sunrise 15 minutes" +"%s");
    sunriseLate=$(date -d "$get_sunrise 30 minutes" +"%s");
    dayLight=$(date -d "$get_sunrise 90 minutes" +"%s");
    twilightEarly=$(date -d "$get_sunset 90 minutes ago" +"%s");
    twilightMid=$(date -d "$get_sunset 30 minutes ago" +"%s");
    twilightLate=$(date -d "$get_sunset 15 minutes ago" +"%s");
    sunset=$(date -d "$get_sunset" +"%s");

}

get_sunpoll(){

    # this if/else replaces sunwait poll function which unfortunately cannot 
    # be evaulated by different $t_ime so won't work with our --time testing flag
    ### sun_poll=$(sunwait d $d_ay m $m_onth y $y_ear poll civil $latitude $longitude)
    #
    # TODO: allow for darkmode time offsets

    if [ "$currenttime" -ge "$sunrise" ] && [ "$currenttime" -lt "$sunset" ]; then
        sun_poll="DAY"
    else
        sun_poll="NIGHT"
    fi
}

show_suntimes(){

    #echo "--------------"
    echo "Sunpaper: $version"
    echo ""
    echo "Current Time: "`date -d "@$currenttime" +"%H:%M"`
    echo "Current Paper: $currentpaper.jpg"
    [[ "$darkmode_enable" == "true" ]] && echo "Darkmode Status: $sun_poll"
    echo ""
    echo `date -d "@$sunrise" +"%H:%M"` "- Sunrise (2.jpg)"
    echo `date -d "@$sunriseMid" +"%H:%M"` "- Sunrise Mid (3.jpg)"
    echo `date -d "@$sunriseLate" +"%H:%M"` "- Sunrise Late (4.jpg)"
    echo `date -d "@$dayLight" +"%H:%M"` "- Daylight (5.jpg)"
    echo `date -d "@$twilightEarly" +"%H:%M"` "- Twilight Early (6.jpg)"
    echo `date -d "@$twilightMid" +"%H:%M"` "- Twilight Mid (7.jpg)"
    echo `date -d "@$twilightLate" +"%H:%M"` "- Twilight Late (8.jpg)"
    echo `date -d "@$sunset" +"%H:%M"` "- Sunset (1.jpg)"
}

show_suntimes_waybar(){

    #sunpaper calls itself to get -r report lines
    sunpaper_self=`realpath $0`
    output=$(bash $sunpaper_self -r)

    tooltip="$(echo "$output" | sed -z 's/\n/\\n/g')"
    tooltip=${tooltip::-2}

    echo "{\"text\":\""$status_icon"\", \"tooltip\":\""$tooltip"\"}"
    exit 0
}

## Wallpaper Display Logic
#1.jpg - after sunset until sunrise (sunset-sunrise)
#2.jpg - sunrise for 15 min (sunrise - sunriseMid)
#3.jpg - 15 min after sunrise for 15 min (sunriseMid-sunriseLate)
#4.jpg - 30 min after sunrise for 1 hour (sunriseLate-dayLight)
#5.jpg - day light between sunrise and sunset events (dayLight-twilightEarly)
#6.jpg - 1.5 hours before sunset for 1 hour (twilightEarly-twilightMid)
#7.jpg - 30 min before sunset for 15 min (twilightMid-twilightLate)
#8.jpg - 15 min before sunset for 15 min (twilightLate-sunset)

set_paper(){

if [ "$currenttime" -ge "$sunrise" ] && [ "$currenttime" -lt "$sunriseMid" ]; then
    
    if [[ $currentpaper != 2 ]]; then
        image=2
        setwallpaper -m $wallpaperMode $wallpaperPath/2.jpg
        sed -i s/./2/g $cacheFileWall
        [[ "$pywalmode_enable" == "true" ]] && pywal_construct
    fi

elif [ "$currenttime" -ge "$sunriseMid" ] && [ "$currenttime" -lt "$sunriseLate" ]; then
  
    if [[ $currentpaper != 3 ]]; then
        image=3
        setwallpaper -m $wallpaperMode $wallpaperPath/3.jpg
        sed -i s/./3/g $cacheFileWall
        [[ "$pywalmode_enable" == "true" ]] && pywal_construct
    fi

elif [ "$currenttime" -ge "$sunriseLate" ] && [ "$currenttime" -lt "$dayLight" ]; then
   
    if [[ $currentpaper != 4 ]]; then
        image=4
        setwallpaper -m $wallpaperMode $wallpaperPath/4.jpg
        sed -i s/./4/g $cacheFileWall
        [[ "$pywalmode_enable" == "true" ]] && pywal_construct
    fi

elif [ "$currenttime" -ge "$dayLight" ] && [ "$currenttime" -lt "$twilightEarly" ]; then
    
    if [[ $currentpaper != 5 ]]; then
        image=5
        setwallpaper -m $wallpaperMode $wallpaperPath/5.jpg
        sed -i s/./5/g $cacheFileWall
        [[ "$pywalmode_enable" == "true" ]] && pywal_construct
    fi

elif [ "$currenttime" -ge "$twilightEarly" ] && [ "$currenttime" -lt "$twilightMid" ]; then
    
    if [[ $currentpaper != 6 ]]; then
        image=6
        setwallpaper -m $wallpaperMode $wallpaperPath/6.jpg
        sed -i s/./6/g $cacheFileWall
        [[ "$pywalmode_enable" == "true" ]] && pywal_construct
	fi

elif [ "$currenttime" -ge "$twilightMid" ] && [ "$currenttime" -lt "$twilightLate" ]; then
   
    if [[ $currentpaper != 7 ]]; then
        image=7
        setwallpaper -m $wallpaperMode $wallpaperPath/7.jpg
        sed -i s/./7/g $cacheFileWall  
        [[ "$pywalmode_enable" == "true" ]] && pywal_construct
    fi

elif [ "$currenttime" -ge "$twilightLate" ] && [ "$currenttime" -lt "$sunset" ]; then

	if [[ $currentpaper != 8 ]]; then
        image=8
        setwallpaper -m $wallpaperMode $wallpaperPath/8.jpg
        sed -i s/./8/g $cacheFileWall
        [[ "$pywalmode_enable" == "true" ]] && pywal_construct
	fi

else 
	if [[ $currentpaper != 1 ]]; then
        image=1
    	setwallpaper -m $wallpaperMode $wallpaperPath/1.jpg
    	sed -i s/./1/g $cacheFileWall
        [[ "$pywalmode_enable" == "true" ]] && pywal_construct
    fi
fi
}

show_help(){

cat << EOF  
Sunpaper Option Flags (flags cannot be combined)

-h, --help,     Help! Show the option flags available.

-r, --report,   Report! Show a table of all the time 
                events for the wallpaper today.

-c, --clear,    Clear! Use this to clear the cache file. 
                Call this after any configuration change 
                to force a wallpaper update.

-t, --time,     Time! Want to see what will happen 
                later today? This option will set a custom 
                time so you can see what your wallpaper will 
                look like then. Must be in HH:MM format. 
                (-t 06:12)

-w, --waybar,   Waybar! Use sway/waybar? Call sunpaper.sh with this 
                flag in the waybar config and it will display
                an icon in the bar and show the full sun time report
                as a tooltip.

EOF
}

pywal_construct(){

    get_sunpoll

    if [ "$sun_poll" == "DAY" ];then 

        [ "$pywal_image_day" == "true" ] && pywal_options_image="-i $wallpaperPath/$image.jpg"
        pywal_options_combined="-n -q $pywal_options_image $pywal_options $pywal_options_day"

    elif [ "$sun_poll" == "NIGHT" ];then

        [ "$pywal_image_night" == "true" ] && pywal_options_image="-i $wallpaperPath/$image.jpg"
        pywal_options_combined="-n -q $pywal_options_image $pywal_options $pywal_options_night"

    fi
    echo "$pywal_options_combined"
    wal $pywal_options_combined
}

local_darkmode(){

    get_sunpoll

    if [ "$sun_poll" == "DAY" ] && [ ! -f "$cacheFileDay" ];then
        exec `$darkmode_run_day`
        touch $cacheFileDay
        rm $cacheFileNight 2> /dev/null || true

    elif [ "$sun_poll" == "NIGHT" ] && [ ! -f "$cacheFileNight" ];then
        exec `$darkmode_run_night`
        touch $cacheFileNight
        rm $cacheFileDay 2> /dev/null || true

    fi
}

while :; do
    case $1 in
        -h|--help) 
            show_help 
            exit         
        ;;
        -r|--report) 
	        set_cache
            get_currenttime
            get_suntimes
            get_sunpoll
            show_suntimes  
            exit             
        ;;
        -c|--clear) 
            clear_cache
            exit             
        ;;
        -t|--time)
        if [ "$2" ]; then
            time=$2
            shift
        else
            echo 'ERROR: "--time" requires format of HH:MM'
            exit
        fi         
        ;;
        -w|--waybar) 
            waybarmode_enable="true"
            shift             
        ;;
        *) break
    esac
    shift
done

# Start Calling Functions
get_currenttime
get_suntimes
set_cache
set_paper

if [ "$darkmode_enable" == "true" ]; then
    local_darkmode
fi

if [ "$waybarmode_enable" == "true" ]; then
    show_suntimes_waybar
fi
