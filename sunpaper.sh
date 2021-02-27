#!/bin/bash

##CONFIG OPTIONS---------------------------------

# This version has some testing features that can be called
# with flags. Check sunpaper.sh -h for all the options

#Set your local latitude and longitude for sun calculations
latitude="38.9072N"
longitude="77.0369W"

#Set how you want your wallpaper displayed
#stretch | center | tile | scale | zoom | fill
wallpaperMode="scale"

#Set full path to your local dynamic wallpaper folder
#no ending folder slash /
#wallpaperPath="$HOME/sunpaper/images/The-Beach"
#wallpaperPath="$HOME/sunpaper/images/The-Cliffs"
#wallpaperPath="$HOME/sunpaper/images/The-Lake"
wallpaperPath="$HOME/sunpaper/images/The-Desert"

# Sunpaper writes the current wallpaper to a cachefile
# this keeps the script from updating your wallpaper
# when it doesn't need to.
# You can set a differnt location for this file or just leave
# it as the default.
#
# Note if you are testing configuration changes and want to remove
# this file to force a wallpaper update you can now call sunpaper.sh -c

cacheFile=$HOME/.cache/sunpaper.cache


##CONFIG OPTIONS END----------------------------

set_cache(){

    ## Setup Cache File 
    #TODO: Use $XDG_CACHE_HOME instead? What if it's not set?

    if [ -f "$cacheFile" ]; then
        currentpaper=$( cat < $cacheFile );
    else 
        touch $cacheFile
        echo "0" > $cacheFile
        currentpaper=0
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
    sunriseEarly=$(date -d "$get_sunrise 15 minutes" +"%s");
    sunriseMid=$(date -d "$get_sunrise 30 minutes" +"%s");
    dayLight=$(date -d "$get_sunrise 90 minutes" +"%s");
    twilightEarly=$(date -d "$get_sunset 90 minutes ago" +"%s");
    twilightMid=$(date -d "$get_sunset 30 minutes ago" +"%s");
    twilightLate=$(date -d "$get_sunset 15 minutes ago" +"%s");
    sunset=$(date -d "$get_sunset" +"%s");
}

    ## Wallpaper Display Logic
    #1.jpg - after sunset until sunrise (sunset-sunrise)
    #2.jpg - sunrise for 15 min (sunrise - sunriseEarly)
    #3.jpg - 15 min after sunrise for 15 min (sunriseEarly-sunriseMid)
    #4.jpg - 30 min after sunrise for 1 hour (sunriseMid-dayLight)
    #5.jpg - day light between sunrise and sunset events (dayLight-twilightEarly)
    #6.jpg - 1.5 hours before sunset for 1 hour (twilightEarly-twilightMid)
    #7.jpg - 30 min before sunset for 15 min (twilightMid-twilightLate)
    #8.jpg - 15 min before sunset for 15 min (twilightLate-sunset)

set_paper(){

    if [ "$currenttime" -ge "$sunrise" ] && [ "$currenttime" -lt "$sunriseEarly" ]; then
        
        if [[ $currentpaper != 2 ]]; then
        setwallpaper -m $wallpaperMode $wallpaperPath/2.jpg
        sed -i s/./2/g $HOME/.cache/sunpaper.cache
      fi

    elif [ "$currenttime" -ge "$sunriseEarly" ] && [ "$currenttime" -lt "$sunriseMid" ]; then
      
        if [[ $currentpaper != 3 ]]; then
        setwallpaper -m $wallpaperMode $wallpaperPath/3.jpg
        sed -i s/./3/g $HOME/.cache/sunpaper.cache
      fi

    elif [ "$currenttime" -ge "$sunriseMid" ] && [ "$currenttime" -lt "$dayLight" ]; then
       
        if [[ $currentpaper != 4 ]]; then
        setwallpaper -m $wallpaperMode $wallpaperPath/4.jpg
        sed -i s/./4/g $HOME/.cache/sunpaper.cache
      fi

    elif [ "$currenttime" -ge "$dayLight" ] && [ "$currenttime" -lt "$twilightEarly" ]; then
        
        if [[ $currentpaper != 5 ]]; then
        setwallpaper -m $wallpaperMode $wallpaperPath/5.jpg
        sed -i s/./5/g $HOME/.cache/sunpaper.cache
      fi

    elif [ "$currenttime" -ge "$twilightEarly" ] && [ "$currenttime" -lt "$twilightMid" ]; then
        
        if [[ $currentpaper != 6 ]]; then
        setwallpaper -m $wallpaperMode $wallpaperPath/6.jpg
        sed -i s/./6/g $HOME/.cache/sunpaper.cache
    	fi

    elif [ "$currenttime" -ge "$twilightMid" ] && [ "$currenttime" -lt "$twilightLate" ]; then
       
        if [[ $currentpaper != 7 ]]; then
        setwallpaper -m $wallpaperMode $wallpaperPath/7.jpg
        sed -i s/./7/g $HOME/.cache/sunpaper.cache   
        fi

    elif [ "$currenttime" -ge "$twilightLate" ] && [ "$currenttime" -lt "$sunset" ]; then

    	if [[ $currentpaper != 8 ]]; then
        	setwallpaper -m $wallpaperMode $wallpaperPath/8.jpg
        	sed -i s/./8/g $HOME/.cache/sunpaper.cache
    	fi

    else 
    	if [[ $currentpaper != 1 ]]; then
    	setwallpaper -m $wallpaperMode $wallpaperPath/1.jpg
    	sed -i s/./1/g $HOME/.cache/sunpaper.cache
    	fi
    fi
}

show_suntimes(){

    echo "Current Time: "`date -d "@$currenttime" +"%H:%M"`
    echo ""
    echo "Sunrise: "`date -d "@$sunrise" +"%H:%M"`
    echo "Sunrise Early: "`date -d "@$sunriseEarly" +"%H:%M"`
    echo "Sunrise Middle: "`date -d "@$sunriseMid" +"%H:%M"`
    echo "Daylight: "`date -d "@$dayLight" +"%H:%M"`
    echo "Twilight Early: "`date -d "@$twilightEarly" +"%H:%M"`
    echo "Twilight Middle: "`date -d "@$twilightMid" +"%H:%M"`
    echo "Twilight Late: "`date -d "@$twilightLate" +"%H:%M"`
    echo "Twilight Sunset: "`date -d "@$sunset" +"%H:%M"`
}

clear_cache(){

    FILE=$HOME/.cache/sunpaper.cache
    if [ -f "$FILE" ]; then
        rm $HOME/.cache/sunpaper.cache
    else 
        echo "no cache file found"
    fi

}

show_help(){
cat << EOF  
HELP!

-h, --help,     Display help

-r, --report,   Show times for all wallpaper events

-c, --clear,    Clear the cache file

-t, --time,     Set a curent time for testing must be in HH:MM format (ex 06:12 14:02)

EOF
}


time=
verbose=0

while :; do
    case $1 in
        -h|--help) 
            show_help 
            exit         
        ;;
        -r|--report) 
            get_currenttime
            get_suntimes
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
            echo 'ERROR: "--time" requires 06:10'
            exit
        fi         
        ;;
        *) break
    esac
    shift
done

# Regular Flow
set_cache
get_currenttime
get_suntimes
set_paper
