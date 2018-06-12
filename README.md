# MatlabVrep_Build3dMap
This reporsitory allow people to build a 3d map in Vrep simulation through a matlab program (No RemoteAPI in this version).
The Matlab program takes a "neutralized" text file with map informations. The program will convert the text file to a .stl file, which can be directly imported into Vrep.

To use the program:
1. Start with the "buildmap.m"
2. Edit or create a text file usint the same formate as "transferfiles.txt"
3. Run buildmap.m, it will produce a test.stl file in the same directory
4. Imported test.stl in the Vrep by clicking files->import->Mesh
