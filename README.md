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
- Create Gang
  - Empty <br>
  ![image](https://github.com/user-attachments/assets/a0fcbd6a-3e1b-4e37-9e36-92529bd38cc6)
  - With Details <br>
  ![image](https://github.com/user-attachments/assets/0c83b55c-0357-484b-8640-b9409cfd6014)
- Place Gang Location <br>
![image](https://github.com/user-attachments/assets/16b1fac9-4296-4285-af3a-68b56d2390bd)
- Place Gang Command Center
  -Pre Placement <br>
  ![image](https://github.com/user-attachments/assets/8c6f21e7-4253-40ba-a1dc-61cbcbc4eeea)
  -Post Placement <br>
  ![image](https://github.com/user-attachments/assets/3437358d-22a6-42fd-95f4-96622e2072a2)
### Gang Garage System
- Garage hover <br>
![image](https://github.com/user-attachments/assets/1a1f176a-f706-48a2-afdc-3ce835dbe899)
- No Cars <br>
![image](https://github.com/user-attachments/assets/b247f411-835e-464d-8ba7-d10e59d7283a)
- Hover over X button <br>
![image](https://github.com/user-attachments/assets/426ebdd2-1bde-4f38-976c-1d53390fc85e)
- Car in the garage <br>
![image](https://github.com/user-attachments/assets/3ba9ddee-f034-41a8-946a-3c2ccbfa11b0)
- Hover over Take Out button <br>
![image](https://github.com/user-attachments/assets/a9c7db4b-54b3-4708-845e-7df716f30940)
- Car out of the garage <br>
![image](https://github.com/user-attachments/assets/876623a3-039f-4d6e-8ed6-75efbeb73502)
- Multiple cars in garage <br>
![image](https://github.com/user-attachments/assets/ffc35e7e-b5df-47e7-930b-761f7fc99650)
### Gang Command Center
- Designs <br>
  - Old Designs:
    - Details Section <br>
      ![image](https://github.com/user-attachments/assets/c08f4b08-b862-4027-adfe-2fdb51d46085)
    - Vehicle Section <br>
      ![image](https://github.com/user-attachments/assets/4875c85b-6f06-4111-8d12-fed2fd2d3c87)
  - New Designs:
    - Details <br>
      ![image](https://github.com/user-attachments/assets/5e9c222e-b6ee-4f81-b654-72ac347103e7)

## The system currently plans to have the following features:
### Quality of life:
  #### Already implemented features:
  - When a gang member joins a new gang, they are instantly removed from their old one
  - System is well optimised, with a max of 0.06 ms when actually in use/nearby system, otherwise idles at 0.00/0.01 ms
  - Gang things are colored based on the gang color, such as the map marker, command center hovering icon and garages hovering icon
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
  - Cars of a given gang can be moved between the garages of said gang by simply putting the car in said garage like you normally would a car
  - Easy saving of vehicles by simply pressing **E** over the Garage hovering icon
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

