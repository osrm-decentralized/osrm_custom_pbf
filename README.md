# osrm_custom_pbf
A ready docker config to deploy OSRM for any place, using custom pbf

## Build

```
docker build -t osrm_custom_pbf .
```

## Run OSRM API

**IMPORTANT:** Create a "data" folder in your working folder where your command prompt is
```
mkdir -p data/
```
This will be your main persistent storage volume, where you can retain the data used by OSRM between runs.


### Running with default area (New Delhi region,India):
```
docker run --rm -it -p 5000:5000 -v $(pwd)/data:/data osrm_custom_pbf
```

For a custom region of your own:
- Select a URL to a PBF (OSM data) file that you want to use, from https://download.geofabrik.de/
- Click on the continent name to go to country level. A few countries may have sub-levels under them.
- Right-click and copy the link for the .osm.pbf you need.

Alternative data sources:
- Or if you want a state / region in India, the author of this repo has made available daily updating PBFs here: https://server.nikhilvj.co.in/dump/ . Note that each PBF has the region's boundary buffered out to 50km to handle edge locations.

We recommend using as small an area as you possibly can, to keep your RAM consumption minimal and your OSRM router fast.


Suppose we're chosen a custom pbf, say, `https://server.nikhilvj.co.in/dump/sikkim.pbf` :


```
docker run \
	--rm -it \
	-p 5000:5000 \
	-v $(pwd)/data:/data \
	-v $(pwd)/profiles:/profiles \
	-e PBFURL='https://server.nikhilvj.co.in/dump/sikkim.pbf' \
	-e PROFILE='/profiles/car-modified.lua'
	osrm_custom_pbf
```

After some compile time (give it 10 mins if your area is big), your OSRM API should be up and available on http://localhost:5000

Each commandline option explained:

- `--rm -it` - runs as an interactive terminal, and upon termination closes the container. Good for development. When deploying, you'll want to replace `--rm it` with `-d` so it runs detached as a background process.
- `-p 5000:5000` - **Port**: maps your system's port number to docker container's internal port number. If you want to deploy on another port say 8800, use: `-p 8800:5000`
- `-v $(pwd)/data:/data` - **Volume**: mounts the data/ folder in your current directory as a persistent storage volume used by the program. You'll see a lot of files collecting there when you run.
- `-v $(pwd)/profiles:/profiles` - mounts the profiles/ folder in this repo (should also be in your current directory) likewise.
- `-e PBFURL='https://server.nikhilvj.co.in/dump/delhi.pbf'` - **ENV**: Instructs the program to download and use this PBF as source data. This is passed in as an environment variable (for the compose/kubernetes folks)
- `-e PROFILE='/profiles/car-modified.lua'` - Similar to above, specifies which profile from the profiles/ folder to use.


## Run OSRM Frontend

Change starting lat-longs in OSRM_CENTER and starting zoom level in OSRM_ZOOM below as applicable:

```
docker run \
	--rm -it \
	-p 9966:9966 \
	-e OSRM_BACKEND='http://localhost:5000' \
	-e OSRM_CENTER='28.6,77.26' \
	-e OSRM_ZOOM='11' \
	osrm/osrm-frontend
```

Once it compiles, you should be able to open the frontend on http://localhost:9966 on your browser.

Each commandline option explained:

- `-p 9966:9966` : Port mapping. Change the left side number if you want to deploy on another port.
- `-e OSRM_BACKEND='http://localhost:5000'` : To tell the frontend where the API is. If you've deployed it on cloud, use the public IP / URL.
- `-e OSRM_CENTER='28.6,77.26'` : Starting lat-long when you open o browser
- `-e OSRM_ZOOM='11'` : Starting zoom level

again, change `--rm -it` to `-d` to detach the container and run it in background instead of on an active terminal (imp when deploying)

To directly deploy the frontend on http:localhost, use the default port 80. So: `-p 80:9966`


## Custom profile

You'll notice a profiles/ folder in our repo - that is mainly containing a customized car profile - car-modified.lua .  
We're using this to Indianize the routing - mainly to specify left hand driving and maybe in future we'll customize it further like changing speeds, turn penalties etc. 

If you want to use another profile in your , then ensure your profile is there in the profiles/ folder, and mention its name in the `-e PROFILE=` parameter in the docker run command. 
