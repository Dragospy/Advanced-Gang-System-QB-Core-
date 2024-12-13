#  Advanced Gang System (QB-Core)
***THIS IS NOT YET READY TO BE USED ON A LIVE SERVER***
- Creator: Dragospy (aka W4TCH3R)
- Framework: QB-Core
## Description

This is an Advanced Gang System for the QB-Core framework (FiveM). <br>
<br> 

It allows for the creation of Gangs anywhere on the map, with advanced garages, and a command center for the gang leader to work with (**Planning to add a turf system as well, with turf wars, just not had time to yet**). <br>

## Dependancy's
- QB-Core
- oxmysql

## Setup
- Drag and Drop the resource in your chosen resource folder (make sure to activate it in server.cfg)
- Drop the sql file in to your db (This will create a Gangs table, and will add an extra column to your players table)
- Disable QB-Gangs, not necessary, but will save resources.
- Add the permission licenses in Config.lua and tweak the default gang settings to your liking.
- Done!

## Preview 
### Gang Creation System
### Gang Garage System
### Gang Command Center

## The system currently plans to have the following features:
### Quality of life:
  #### Already implemented features:
  - When a gang member joins a new gang, they are instantly removed from their old one
  - System is well optimised, with a max of 0.06 ms when actually in use/nearby system, otherwise idles at 0.00/0.01 ms
  #### Not yet implemented features:
  - Gang marker shows up on map with chosen emblem
  - Config file that allows for easy tweaking of permisions/features

### Gang creation system, which allows the creator(Probably the owner or high staff) of the gang to:
  #### Already implemented features:
  - Set the Name of the gang
  - Set the Color of the gang
  - Set the Owner of the gang
  - Set the Location of the gang map marker
  - Set the Location of the gang Command Center

### Advanced Gang Garages:
  #### Already implemented features:
  - Allows placement of garages
  - Cars of a given gang can be moved between the garages of said gang
  - Each car only exists as a single entity, so it can only be take out once at a time, meaning only one gang member can take each car out at a time, this does not however mean that you cannot have multiple of the same car model in the garage at a time, only that each car can only be taken out once before it is returned so that it can be taken out again.
  - Garages save: the Tunning, the Damage and the Fuel of the car, meaning gang members have to be careful with their cars, adding an extra layer of realism to gangs
  - Garages display: the car name, car image, car colour, and the fuel of the car(out of 100)
  #### Not yet implemented features:
  - Allows placement of garages anywhere inside the gang area (within a set radius of the Gang Map Marker, although not yet implemented, it will be in the next update)
  - Server owner can set the max number of garages each gang is allowed to have (**Allows for server monetization**)
  - Server owner can set the max number of vehicles the gang is allowed to have (**Allows for server monetization**)
  - Gangs will not start with default vehicles, instead, gang owners and anyone the gang owner allows, will be able to buy vehicles and place them inside the gang garages, giving gangs another way to spend their money (aka to upgrade their vehicles)

### Gang Command Center:
  *****Currently still in design phase*****
  - Gang leaders can:
   - change the color of the gang
   - change/set the photo background of their gangs interfaces
   - manage members of the gang (remove, add, change rank)
   - deposit and remove funds from the gangs money stash
   - manage gang vehicles and their storage location (garage they're stored in)
   - add new vehicles into the gang garages/remove old ones
   - manage the items in the gang item stashes
   - Add/remove garages (within their max limit)
   - Add/remove item stashes (within their max limit)

### Gang Turf system:
  ****Still in planning phase****

