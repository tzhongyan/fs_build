# Building FreeSWITCH from source with mod_shout
An edit from original FreeSWITCH Dockerfile, and I need the mod_shout for shit to work

# What it does
- Pulling from tag v1.10 from stable
- Build with `docker build -t REP:TAG .`
- Run with `docker run -d -v $(pwd)/conf:/etc/freeswitch -v $(pwd)/tmp:/tmp REP:TAG` or whatever the Windows equivalent is

Oh ya, make sure your FreeSWITCH configuration is there.

# TODO
- Test run, cause I have only test build
- Remove source after building