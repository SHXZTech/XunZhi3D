---

# SiteSight Data Format Documentation

## Overview
The SiteSight format is designed for comprehensive data collection in 3D scene reconstruction, featuring a combination of imaging, depth, and positioning data. The file structure is organized to facilitate detailed scene analysis and modeling.

## File Structure
The SiteSight data set typically includes the following files and directories:

### 1. Image Files
- **`RGB_*.jpeg`**: These are the RGB (color) images captured for each frame. The filename usually contains a timestamp or identifier.

### 2. Depth Files
- **`Depth_*.TIF`**: Depth map images corresponding to the RGB images, providing depth information for each pixel.

### 3. Confidence Maps
- **`Confidence_*.TIF`**: These files may contain confidence data related to the depth measurements.

### 4. Additional Files
- **`cover.jpeg`**: A cover image for the data set, possibly used for quick identification or overview.
- **`rawMesh.usd`**: A file containing a 3D mesh model of the scene.
- **`rawPointCloud.ply`**: Stores a point cloud representation of the scene.
- **`info.json`**: A crucial file containing metadata and detailed information about each frame.

## `info.json` File Structure
This file is central to understanding the data set as it contains detailed metadata for each frame captured.

### General Attributes
- **`name`**: Name of the data set.
- **`owners`**: List of data set owners or creators.
- **`frameCount`**: Total number of frames.
- **`uuid`**: Unique identifier for the data set.
- **`configs`**: Configuration settings used during data capture.

### Configs Section
Contains settings such as:

- **Image capture**
- **Timestamp recording**
- **Camera intrinsic and extrinsic data**
- **Depth and confidence data**
- **GPS and RTK data**
- **Mesh model and point cloud data**

### RTK Data Section
Provides RTK positional data with attributes like `fixStatus`, `longitude`, `latitude`, `height`, `accuracy`, and `timeStamp`.

### Frames Section
Each entry in the `frames` array includes:

- **`confidenceMapName`**: File name of the confidence map.
- **`RTK` and `GPS` Data**: Positioning data for the frame.
- **`timeStamp` and `timeStampGlobal`**: Local and global timestamps.
- **`imageName`**: Corresponding RGB image file name.
- **`extrinsic` and `intrinsic` Data**: Camera positioning and internal parameter data.
- **`depthImageName`**: Associated depth image file name.

#### Camera Parameters
- **Intrinsic Parameters**: 3x3 matrix detailing focal length, optical center, etc.
- **Extrinsic Parameters**: 4x4 matrix indicating the camera's position and orientation.

## Usage
This format is ideal for 3D modeling, surveying, and detailed scene reconstruction. The `info.json` file, in conjunction with the image, depth, and confidence files, provides a comprehensive dataset for advanced 3D analysis.
