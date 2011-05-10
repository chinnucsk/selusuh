#!/bin/bash

curl -X PUT http://127.0.0.1:8091/riak/soldiers/blackadder -d "Captain Edmund Blackadder" -H "Content-type: text/plain" -H 'Link: </riak/soldiers/george>; riaktag="underling", </riak/soldiers/baldrick>; riaktag="scapegoat", </riak/equipment/wit>; riaktag="equip", </riak/equipment/gun>; riaktag="equip", </riak/wit/one-liner>; riaktag="wit", </riak/wit/two-liner>; riaktag="wit"'

curl -X PUT http://127.0.0.1:8092/riak/soldiers/george -d "Lt. George" -H "Content-type: text/plain" -H 'Link: </riak/soldiers/baldrick>; riaktag="underling", </riak/equipment/stick>; riaktag="equip"'

curl -X PUT http://127.0.0.1:8093/riak/soldiers/baldrick -d "Pvt. Baldrick" -H "Content-type: text/plain" -H 'Link: </riak/soldier/blackadder>; riaktag="superior", </riak/soldier/george>; riaktag="superior", </riak/equipment/stick>; riaktag="fear", </riak/equipment/wit>; riaktag="fear"'

curl -X PUT http://127.0.0.1:8091/riak/equipment/wit -d "A sharp tongue" -H "Content-type: text/plain" -H 'Link: </riak/wit/one-liner>; riaktag="entry", </riak/wit/two-liner>; riaktag="entry"'
curl -X PUT http://127.0.0.1:8092/riak/equipment/gun -d "A good ol' service revolver" -H "Content-type: text/plain"
curl -X PUT http://127.0.0.1:8092/riak/equipment/stick -d "Brown and sticky" -H "Content-type: text/plain"

curl -X PUT http://127.0.0.1:8091/riak/wit/one-liner -d "Personally, I thought you were the least convincing female impressionist since Tarzan went through Jane's handbag and ate her lipstick." -H "Content-type: text/plain"
curl -X PUT http://127.0.0.1:8091/riak/wit/two-liner -d "That's not the only thing around here that's \"very small indeed\". Your brain for example, is so minute, Baldrick, that if a hungry cannibal cracked your head open there wouldn't be enough inside to cover a small water-biscuit." -H "Content-type: text/plain"
