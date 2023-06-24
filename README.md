# ff2mpvidious-bash
## **A fork of [ff2mpv-bash](https://github.com/Ckath/ff2mpv-bash), but proxying youtube videos through invidious, with thumbnail notifications.**
You might want to ping the invidious instances (can be found at [invidious' API website](https://api.invidious.io/)) and choose the fastest ones for your location, then replace the ones used in the array at the top of the script, e.g. ``array[0]="https://yt.artemislena.eu"``.  
This script uses ``notify-send`` for notifications.  
## ** Note **  
This script actually requests the video to be proxied through invidious, so no data is ever requested from youtube or google directly.  

However, due to this, sometimes videos fail in the request, take a longer time to load or cache while playing or simply fail,  
perhaps due to the instance rate limiting the requests or failure on their side.  

Which is understandable, since this puts a lot more load on their servers to serve the video directly through them rather then delivering the video from youtube or google urls.  

I'll probably change the script to not request the video to be proxied, since I don't want to put that much load on their servers.  

Although this does have an upside, which is faster loading times (near immediate opening in mpv in my experience);  

faster caching times (most videos fully load seconds after being opened, just like youtube, in my experience);  

and if subtitles are available for the video they will be available for selection, something that fully proxied videos couldn't do.
