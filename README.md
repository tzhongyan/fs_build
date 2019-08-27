# Building FreeSWITCH from source with additional mods
An edit from original FreeSWITCH Dockerfile, and I need the mod_shout for shit to work
- Edit 20190827: Now I need mod_xml_curl for it to work, and docker command is a bit too verbose. So I have created simple bash file to automate things

# What it does
- Build the freeswitch source in freeswitch folder, of which can be obtained by `git pull --recurse-submodules`. Currently set to branch v1.10
- Build with `docker build -t REP:TAG .`
- Run with `docker run -d -v $(pwd)/conf/:/usr/local/freeswitch/conf/ -v $(pwd)/tmp:/tmp REP:TAG` or whatever the Windows equivalent is

Oh ya, make sure your FreeSWITCH configuration is there.

# TODO
- Test run, cause I have only test build
- Remove source after building