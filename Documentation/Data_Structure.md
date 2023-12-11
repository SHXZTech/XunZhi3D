# Data Structure of SiteSight 
## Overview
The SiteSight dataset is organized into a hierarchical file structure, primarily divided into three main categories: `cameras`, `depth`, and `confidence`. Each category contains a series of files named according to a its timestamp.
```
~/UUID/
│
├── cameras/
│   ├── timestamp1.json
│   ├── timestamp2.json
│   ├── ...
│
├── confidence/
│   ├── timestamp1.png
│   ├── timestamp2.png
│   ├── ...
│
├── depth/
│   ├── timestamp1.png
│   ├── timestamp2.png
│   ├── ...
│
├── rtk/
│   ├── timestamp1.json
│   ├── timestamp2.json
│   ├── ...
│
├── images/
│   ├── timestamp1.jpg
│   ├── timestamp2.jpg
│   ├── ...
│
├── config.json
├── cover.jpg
```


## File Categories

### 1. Cameras (`cameras` Directory)
- **Location**: `/UUID/cameras`
- **File Extension**: `.json`
- **Description**: This directory contains JSON files. Each file represents the intrinsic, extrinsic and exif data of this frame. 


### 2. Depth Maps (`depth` Directory)
- **Location**: ~/UUID/depth`
- **File Fromat**: `.png`, 256 x 192, single channel 32 bit float.
- **Description**: The `depth` directory comprises PNG image files. Each file represents a depth map corresponding to a particular keyframe. Each pixel present the distance of the camera center to the surface.

### 3. Confidence Maps (`confidence` Directory)
- **Location**: `/UUID/confidence`
- **File Format**: `.png` 256 x 192, single channel 8 bit uint image.
- **Description**: The `depth` directory comprises PNG image files. Each file represents a depth map corresponding to a particular keyframe. Each pixel present the confidence of each depth point. 0 = low confidence, 1 = medium confidence, 2 = high confidence.

### Images (`images` Directory)
- **Location**: `/UUID/images`
- **File Format**: `.jpg`, 1920 x 1440, 3 channel 8 bit uint image.
- **Description**: The `images` directory comprises JPG image files. Each file represents a color image corresponding to a particular keyframe. Each pixel present the color of the scene.

### RTK (`rtk` Directory)
- **Location**: `/UUID/rtk`
- **File Format**: `.json`
- **Description**: The `rtk` directory comprises JSON files. Each file represents the RTK data of this frame.

### Config (`config.json` File)
- **Location**: `/UUID/config.json`
- **File Format**: `.json`
- **Description**: The `config.json` file contains the configuration of the project, such as the creation time, owner info, rtk/gps info, frame count, etc.
