#!/bin/bash

##CONFIG OPTIONS---------------------------------

# This script also has some testing functions that 
# can be called with option flags. 
# Check sunpaper.sh -h 

# There's also pretty good documentation on the wiki
# https://github.com/hexive/sunpaper/wiki


#################################################
# BASIC CONFIGURATION
#################################################

# Set your local latitude and longitude for sun calculations
latitude="38.9072N"
longitude="77.0369W"

# Set full path to the wallpaper theme folder
# Theme folder names:grep
#
# Blake Watson & Sunpaper: Corporate-Synergy
# Apple: The-Beach The-Cliffs The-Lake The-Desert
# Louis Coyle: Lakeside
# 
wallpaperPath="$HOME/sunpaper/images/Corporate-Synergy"

# Set how you want your wallpaper displayed
# stretch | center | tile | scale | zoom | fill
wallpaperMode="stretch"

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
# Moonphase Mode
#################################################
# Show a wallpaper with the correct moonphase for
# today's date.
#
# This only works with Corporate-Synergy theme so 
# make sure it's already set as your theme choice.
#
# moonphase_enable="true"
moonphase_enable="false"


#################################################
# Live Weather Mode
#################################################
# Show a wallpaper that reflects the current weather
# conditions outside.
#
# This only works with Corporate-Synergy theme so 
# make sure it's already set as your theme choice.
#
# weather_enable="true"
weather_enable="false"

# We're using an API from openweathermap.org
# to get your local conditions. You'll need to sign
# up for a free API Key and set it below:
# https://openweathermap.org/price
#
weather_api_key=""

# Set your openweather city id number here.
# Check on http://openweathermap.org/find
#
weather_city_id="4140963"


#################################################
# Animate transitions with SWWW MODE 
# requires (https://github.com/Horus645/swww)
# and Wayland
#################################################
#
# For smooth low memory animated transitions between 
# images.
#
# This also resolves the gray flash in Sway whenever changing
# wallpaper. (https://github.com/swaywm/sway/issues/3693)
#
# enable this mode here with 
# swww_enable="true"
swww_enable="false"

# swww should already be installed and configured.
# sunpaper will launch the swww daemon if it's not
# already started.

# swww takes two options for animation control of the
# transition between images: frame rate and step (more
# info: https://github.com/Horus645/swww/issues/51)
#
# swww_fps <1 to 255>
# swww_step <1 to 255>
swww_fps="3"
swww_step="3"


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
# darkmode_run_day="/path/to/switch.sh light"
darkmode_run_day=""
darkmode_run_night=""


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
# SWAY / WAYBAR MODE
#################################################
# Sunpaper has a special mode for use with sway/waybar 
# It displays an icon and sun times report as a tooltip.
# Call it within waybar with a flag sunpaper.sh --waybar
#
# See the wiki for more details: 
# https://github.com/hexive/sunpaper/wiki/as-waybar

# Set the icon display for that here
status_icon=""


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
#
#1.0 - initial commit
#1.1 - functionize & option flags
#1.2 - new darkmode feature
#1.3 - new waybar feature
#1.4 - pywall integration
#1.5 - oguri integration (ended with 2.0)
#1.6 - moonphase & weather
#2.0 - swww animations & let it snow

version="2.0"

# Check for external config file
CONFIG_FILE=$HOME/.config/sunpaper/config
if [ -f "$CONFIG_FILE" ];then
    . "$CONFIG_FILE"
else
	# if not found, check if a default exists in /usr/share/sunpaper/ 
    SYSTEM_CONFIG_FILE=/usr/share/sunpaper/config
    if [ -f "$SYSTEM_CONFIG_FILE" ];then
		# and copy it to ~/.config/sunpaper/config if it exists
        mkdir -p $HOME/.config/sunpaper
		cp "$SYSTEM_CONFIG_FILE" "$CONFIG_FILE"
		. "$CONFIG_FILE"
    fi
fi

#Trim any trailing slashes from paths
wallpaperPath=$(echo "$wallpaperPath" | sed 's:/*$::')
cachePath=$(echo "$cachePath" | sed 's:/*$::')

#Define cache paths
cacheFileWall="$cachePath/sunpaper_cache.wallpaper"
cacheFileDay="$cachePath/sunpaper_cache.day"
cacheFileNight="$cachePath/sunpaper_cache.night"
cacheFileWeather="$cachePath/sunpaper_cache.weather"

set_cache(){

    if [ -f "$cacheFileWall" ]; then
        currentpaper=$( cat < "$cacheFileWall" );
    else 
        touch "$cacheFileWall"
        echo "0" > "$cacheFileWall"
        currentpaper=0
        swww_first="true"
    fi

}

clear_cache(){

	#TODO: -q quiet mode?

    if [ -f "$cacheFileWall" ]; then
        rm "$cacheFileWall"
        echo "cleared wallpaper cache"
    else 
        echo "no wallpaper cache file found"
    fi

    if [ -f "$cacheFileDay" ]; then
        rm "$cacheFileDay"
        echo "cleared darkmode day cache"
    else 
        echo "no darkmode day cache found"
    fi

    if [ -f "$cacheFileNight" ]; then
        rm "$cacheFileNight"
        echo "cleared darkmode night cache"
    else 
        echo "no darkmode night cache found"
    fi

    if [ -f "$cacheFileWeather" ]; then
        rm "$cacheFileWeather"
        echo "cleared weather cache"
    else 
        echo "no weather cache found"
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

    ## Wallpaper Display Logic
    #1.jpg - after sunset until sunrise (sunset-sunrise)
    #2.jpg - sunrise for 15 min (sunrise - sunriseMid)
    #3.jpg - 15 min after sunrise for 15 min (sunriseMid-sunriseLate)
    #4.jpg - 30 min after sunrise for 1 hour (sunriseLate-dayLight)
    #5.jpg - day light between sunrise and sunset events (dayLight-twilightEarly)
    #6.jpg - 1.5 hours before sunset for 1 hour (twilightEarly-twilightMid)
    #7.jpg - 30 min before sunset for 15 min (twilightMid-twilightLate)
    #8.jpg - 15 min before sunset for 15 min (twilightLate-sunset)

}

get_sunpoll(){

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
    echo "Current Time: " $(date -d "@$currenttime" +"%H:%M")
    echo "Current Paper: $currentpaper.jpg"
    [[ "$darkmode_enable" == "true" ]] && echo "Darkmode Status: $sun_poll"
    if [[ "$weather_enable" == "true" ]] && [[ -f "$cacheFileWeather" ]];then
        showWeather=$( cat < "$cacheFileWeather" )
        echo "Weather Status: ${showWeather^^}"
    fi
    echo ""
    echo $(date -d "@$sunrise" +"%H:%M") "- Sunrise (2.jpg)"
    echo $(date -d "@$sunriseMid" +"%H:%M") "- Sunrise Mid (3.jpg)"
    echo $(date -d "@$sunriseLate" +"%H:%M") "- Sunrise Late (4.jpg)"
    echo $(date -d "@$dayLight" +"%H:%M") "- Daylight (5.jpg)"
    echo $(date -d "@$twilightEarly" +"%H:%M") "- Twilight Early (6.jpg)"
    echo $(date -d "@$twilightMid" +"%H:%M") "- Twilight Mid (7.jpg)"
    echo $(date -d "@$twilightLate" +"%H:%M") "- Twilight Late (8.jpg)"
    echo $(date -d "@$sunset" +"%H:%M") "- Sunset (1.jpg)"
}

show_suntimes_waybar(){

    #sunpaper calls itself to get -r report lines
    sunpaper_self=$(realpath "$0")
    output=$(bash "$sunpaper_self" -r)

    tooltip="$(echo "$output" | sed -z 's/\n/\\n/g')"
    tooltip=${tooltip::-2}

    echo "{\"text\":\""$status_icon"\", \"tooltip\":\""$tooltip"\"}"
    exit 0
}

set_paper(){

    if [ "$currenttime" -ge "$sunrise" ] && [ "$currenttime" -lt "$sunriseMid" ]; then
        
        if [[ $currentpaper != 2 ]]; then
            image=2
            sed -i "s/./$image/g" "$cacheFileWall"
            setpaper_construct
        fi

    elif [ "$currenttime" -ge "$sunriseMid" ] && [ "$currenttime" -lt "$sunriseLate" ]; then
      
        if [[ $currentpaper != 3 ]]; then
            image=3
            sed -i "s/./$image/g" "$cacheFileWall"
            setpaper_construct
        fi

    elif [ "$currenttime" -ge "$sunriseLate" ] && [ "$currenttime" -lt "$dayLight" ]; then
       
        if [[ $currentpaper != 4 ]]; then
            image=4
            sed -i "s/./$image/g" "$cacheFileWall"
            setpaper_construct
        fi

    elif [ "$currenttime" -ge "$dayLight" ] && [ "$currenttime" -lt "$twilightEarly" ]; then
        
        if [[ $currentpaper != 5 ]]; then
            image=5
            sed -i "s/./$image/g" "$cacheFileWall"
            setpaper_construct
        fi

    elif [ "$currenttime" -ge "$twilightEarly" ] && [ "$currenttime" -lt "$twilightMid" ]; then
        
        if [[ $currentpaper != 6 ]]; then
            image=6
            sed -i "s/./$image/g" "$cacheFileWall"
            setpaper_construct
    	fi

    elif [ "$currenttime" -ge "$twilightMid" ] && [ "$currenttime" -lt "$twilightLate" ]; then
       
        if [[ $currentpaper != 7 ]]; then
            image=7
            sed -i "s/./$image/g" "$cacheFileWall"  
            setpaper_construct
        fi

    elif [ "$currenttime" -ge "$twilightLate" ] && [ "$currenttime" -lt "$sunset" ]; then

    	if [[ $currentpaper != 8 ]]; then
            image=8
            sed -i "s/./$image/g" "$cacheFileWall"
            setpaper_construct
    	fi

    else 
    	if [[ $currentpaper != 1 ]]; then
            image=1
        	sed -i "s/./$image/g" "$cacheFileWall"
            setpaper_construct
        fi
    fi
}

setpaper_construct(){

    ################
    # Weather

    if [[ "$weather_enable" == "true" ]] && [[ -f "$wallpaperPath/rain/1.jpg" ]];then 

        #currentWeather should already be set 
        #cloud is both the default weather and not in special directory
        if [[ -z ${currentWeather+x} ]] || [[ "$currentWeather" == "cloud" ]]; then
            #keep defaults
            true

        else
            #update wallpaper path with correct weather directory
            wallpaperPath="$wallpaperPath/$currentWeather"

        fi
    fi


    ################
    # m-o-o-n that spells tom cullen

    if [ "$moonphase_enable" == "true" ] && [[ -f "$wallpaperPath/moons/1-1.jpg" ]];then 

        if [ $image == 1 ] || [ $image == 2 ] || [ $image == 8 ];then

            get_moonphase

            if [[ ("$phase_addendum" == "-1" || "$phase_addendum" == "-5") && ($image == 2 || $image == 8) ]];then
                # if moonphase is new or full use defaults on images 2 & 8
                true
            elif [[ "$phase_addendum" == "-5" ]] && [[ $image == 1 ]];then
                # if moonphase is full use default on image 1
                true
            else
                # update $image used below with new path and moonphase addendum
                image="moons/$image$phase_addendum"
            fi
        fi
    fi


    ################
    # SWWW

    if [ "$swww_enable" == "true" ];then 

        # Check for swww dameon and launch it if it isn't running
        exec_swww

        #TODO: is there a need to make this configurable?
        #output $display_output

        # it takes awhile for that daemon to start so make sure there's success before moving on

        if [ "$swww_first" == "true" ];then 
            # don't animate first load image
            until swww img "$wallpaperPath"/"$image".jpg --transition-step 255 --transition-fps 255 > /dev/null 2>&1; do
                 ((c++)) && ((c==10)) && break
                sleep 1
            done
        else 
        
            until swww img "$wallpaperPath"/"$image".jpg --transition-step "$swww_fps" --transition-fps "$swww_step" > /dev/null 2>&1; do
                 ((c++)) && ((c==10)) && break
                 sleep 1
            done
        fi

    else
        ################
        # Walutil - default

        setwallpaper -m "$wallpaperMode" "$wallpaperPath"/"$image".jpg
    fi

    ################
    # Pywal

    [[ "$pywalmode_enable" == "true" ]] && pywal_construct
}

pywal_construct(){

    get_sunpoll

    if [ "$sun_poll" == "DAY" ];then 

        [ "$pywal_image_day" == "true" ] && pywal_options_image="-i $wallpaperPath/$image.jpg"
        pywal_options_combined="-q -n $pywal_options_image $pywal_options $pywal_options_day"

    elif [ "$sun_poll" == "NIGHT" ];then

        [ "$pywal_image_night" == "true" ] && pywal_options_image="-i $wallpaperPath/$image.jpg"
        pywal_options_combined="-q -n $pywal_options_image $pywal_options $pywal_options_night"
    fi
    #TODO: why does this fail?
    #wal "$pywal_options_combined"
    wal $pywal_options_combined
}

local_darkmode(){

    get_sunpoll

    if [ "$sun_poll" == "DAY" ] && [ ! -f "$cacheFileDay" ];then
	#TODO: why does this fail?
	#$("$darkmode_run_day")
	$($darkmode_run_day)
        touch "$cacheFileDay"
        rm "$cacheFileNight" 2> /dev/null || true

    elif [ "$sun_poll" == "NIGHT" ] && [ ! -f "$cacheFileNight" ];then
	$($darkmode_run_night)
        touch "$cacheFileNight"
        rm "$cacheFileDay" 2> /dev/null || true
    fi
}

get_moonphase(){
  
    # adapted from https://github.com/nikospag/bash-moon-phase/blob/master/Moon_old

    lp=2551443 #Lunar period (unix time in seconds)=29.53 days
    now=$(date -u +"%s") #Time now (unix time UTC)
    newmoon=592500 #Known new moon time (unix time). 7 Jan 1970 20:35
    phase=$((($now - $newmoon) % $lp))
    phase_number=$(echo 'scale=0; '${phase}'/86.400' | bc -l)

    #new moon math -- showing new quarter and full moons for aprox 2 days

    if [[ $phase_number -ge 0 ]] && [[ $phase_number -lt 1000 ]];  then phase_addendum="-1"  # new
    elif [[ $phase_number -ge 1000 ]] && [[ $phase_number -lt 6382 ]];  then phase_addendum="-2"  # waxing crescent
    elif [[ $phase_number -ge 6382 ]] && [[ $phase_number -lt 8382 ]];  then phase_addendum="-3"  # first quarter
    elif [[ $phase_number -ge 8382 ]] && [[ $phase_number -lt 13765 ]]; then phase_addendum="-4"  # waxing gibbous
    elif [[ $phase_number -ge 13765 ]] && [[ $phase_number -lt 15765 ]]; then phase_addendum="-5"  # full
    elif [[ $phase_number -ge 15765 ]] && [[ $phase_number -lt 21147 ]]; then phase_addendum="-6"  # waning gibbous
    elif [[ $phase_number -ge 21147 ]] && [[ $phase_number -lt 23147 ]]; then phase_addendum="-7"  # last quarter
    elif [[ $phase_number -ge 23147 ]] && [[ $phase_number -lt 28530 ]]; then phase_addendum="-8"  # waning crescent
    else phase_addendum="-1" # back to new
    fi
}

check_weather() {

    if [ -f "$cacheFileWeather" ]; then

        #how much time has passed since weather cache was last modified?
        lastModificationSeconds=$(date +%s -r $cacheFileWeather)
        currentSeconds=$(date +%s)
        #1200 - 20 min / 300 - 5 min
        compareSeconds=$(($lastModificationSeconds + 300))

        if [[ "$compareSeconds" -lt "$currentSeconds" ]]; then

            #cache was modified more than 20 min ago
            get_weather
            cacheWeather=$( cat < "$cacheFileWeather" );
            
            if [[ "$currentWeather" = "$cacheWeather" ]]; then

                # weather hasn't changed
                touch "$cacheFileWeather"
            
            else
                # weather has changed
                # set new cacheFileWeather
                sed -i "s/.*/$currentWeather/g" "$cacheFileWeather"

                # set new paper 
                image=$currentpaper
                setpaper_construct

            fi
        else
            #cache was not modified more than 20 min ago
            currentWeather=$( cat < "$cacheFileWeather" );

        fi
        
    else 
        #no cache file found
        get_weather

        #set new cache
        touch "$cacheFileWeather"
        echo "$currentWeather" > "$cacheFileWeather"

    fi
}

get_weather(){
    weather_info=""
    weather_main=""

    weather_url="http://api.openweathermap.org/data/2.5/weather?id=${weather_city_id}&appid=${weather_api_key}&units=Imperial"

    # Allow for weather testing from --sky flag
    if [ "$test_weather" ]; then
        weather_main=$test_weather

    else
        weather_info=$(wget -qO- "$weather_url")
        weather_main=$(echo "$weather_info" | grep -o -e '\"main\":\"[a-zA-Z]*\"' | awk -F ':' '{print $2}' | tr -d '"')
    fi


    if [[ "$weather_main" = "" ]] ; then
            # this probably means the network connection to the API is down
            # TODO: special handling of this case 
            #    -- check every minute until it's reestablished?
            #currentWeather="unknown"

            #if cache value exists use that, else set cloud default
                if [[ -f "$cacheFileWeather" ]];then
                    currentWeather=$( cat < "$cacheFileWeather" )
                else
                    currentWeather="cloud"
                fi
                
    else 

        if [[ "$weather_main" = *Rain* ]] || [[ "${weather_main}" = *Drizzle* ]] || [[ "$weather_main" = *Mist* ]]; then
            currentWeather="rain"

        elif [[ "$weather_main" = *Thunderstorm* ]] || [[ "$weather_main" = *Extreme* ]] || [[ "$weather_main" = *Squall* ]] || [[ "$weather_main" = *Tornado* ]]; then
            currentWeather="storm"

        elif [[ "$weather_main" = *Clear* ]]; then
            currentWeather="clear"

        elif [[ "$weather_main" = *Fog* ]] || [[ "$weather_main" = *Haze* ]] || [[ "$weather_main" = *Smoke* ]] || [[ "$weather_main" = *Dust* ]] || [[ "$weather_main" = *Sand* ]] || [[ "$weather_main" = *Ash* ]]; then
            currentWeather="fog"

        elif [[ "$weather_main" = *Snow* ]] || [[ "$weather_main" = *Sleet* ]] ; then
            currentWeather="snow"

        else
            currentWeather="cloud"

        fi

    fi
}

exec_swww(){

    #Check if swww daemon is already running
    if pgrep -x "swww" > /dev/null ;then
        #do nothing
        true

    else
        nohup swww init > /dev/null 2>&1 &

    fi
}

pkill_daemon(){
    #TODO: does this need to be smarter?
    echo "The Sunpaper daemon has stopped."
    pkill sunpaper.sh > /dev/null 2>&1 &

}

show_help(){

cat << EOF  
Sunpaper Option Flags (cannot be combined)

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

-s, --sky,      Sky! A weather testing flag. Set conditions
                here to see what your wallpaper will look
                like in different weather (weather is normally
                cached for a period of time so you may need to 
                call -c first to see changes)
                Clear | Clouds | Rain | Thunderstorm | Fog  

-w, --waybar,   Waybar! Use sway/waybar? Call sunpaper.sh with this 
                flag in the waybar config and it will display
                an icon in the bar and show the full sun time report
                as a tooltip.

-d, --daemon,   Daemon! Start sunpaper with this flag and it will
                run continuiously in the background.

-k, --kill,     Kill! Use this flag if you'd like to stop the 
                sunpaper daemon.

EOF
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
        -s|--sky) 
        if [ "$2" ]; then
            test_weather=$2
            shift
        else
            exit
        fi               
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
        -d|--daemon) 
            daemon_enable="true"
                ;;
        -k|--kill) 
            pkill_daemon
            exit
        ;;
        *) break
    esac
    shift
done

main(){
    get_currenttime
    get_suntimes
    set_cache

    if [[ "$weather_enable" == "true" ]];then
        check_weather
    fi

    set_paper

    if [ "$darkmode_enable" == "true" ]; then
        local_darkmode
    fi

    if [ "$waybarmode_enable" == "true" ]; then
        show_suntimes_waybar
    fi
}

if [ "$daemon_enable" == "true" ]; then

    #Clear cache for first run 
    clear_cache > /dev/null 2>&1

    #Always call main 
    #to make sure paper is still set for WM logout/login if daemon already exists, etc)
    main

    #TODO: maybe this should be quiet?
    echo "The Sunpaper daemon has started -- use sunpaper.sh -k to stop it."

    #Try to prevent generating duplicate daemons.
    if [[ $(pgrep -c "sunpaper.sh") -gt 1 ]] ;then
        #do nothing
        true
    else
        #Then loop forever
        while :; do
            main &
            sleep 60
        done &
    fi
else
    main
fi
