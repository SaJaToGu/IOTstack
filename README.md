# IOT Stack

> **⚠️ Maintenance Status: Unmaintained**
> 
> **This repository has not been updated since August 1, 2020 (over 4 years).**
> The project is no longer actively maintained. The code may contain unaddressed security vulnerabilities, compatibility issues with current Docker versions, or broken dependencies.
> 
> **Use at your own risk.**
> 
> If you are looking for alternatives, consider forking the repository or checking the [original SensorsIot/IOTstack repository](https://github.com/SensorsIot/IOTstack) for potential continuation.

IOTstack is a builder for docker-compose to easily make and maintain IoT stacks on the Raspberry Pi.


## Documentation for the project: 

https://sensorsiot.github.io/IOTstack/


## Video
https://youtu.be/a6mjt8tWUws


## Installation
1. On the (RPi) lite image you will need to install git first

```
sudo apt-get install git -y
```

2. Download the repository with:
```
git clone https://github.com/SensorsIot/IOTstack.git ~/IOTstack
```

Due to some script restraints, this project needs to be stored in ~/IOTstack

3. To enter the directory and run menu for installation options:
```
cd ~/IOTstack && bash ./menu.sh
```

4. Install docker with the menu, restart your system.

5. Run menu again to select your build options, then start docker-compose with
```
docker-compose up -d
```

## Experimental Features
Want to have the latest and greatest features? Switch to the experimental branch:
```
git pull && git checkout experimental
./menu.sh
```

Do note that the experimental branch may be broken, or may break your setup, so ensure you have a good backup, and please report any issues.

## Migrating from the old repo?
```
cd ~/IOTstack/
git remote set-url origin https://github.com/SensorsIot/IOTstack.git
git pull origin master
docker-compose down
./menu.sh
docker-compose up -d
```
