**# BEM — Simulation of acoustic radiation using the Boundary Element Method**



Implementation in MATLAB of a simulation environment based on the Boundary Element Method (BEM) for the study of the frequency response and directivity of radiating systems (loudspeakers, pistons, arrays), in 2D and 3D.


This project forms part of my Final Year Project in Physics (University of Alicante), supervised by Jaime Ramis Soriano. The full written report is in Spanish.
Functions have Spanish comments, but feel free to translate it is nedeed :)


**## What does it do?**



\- Solves the acoustic pressure field radiated by vibrating surfaces using BEM

\- Calculates directivity in the horizontal and vertical planes

\- Calculates the frequency response at far-field points

\- Includes separate solvers for 2D (Hankel based Green’s function) and 3D (exponential Green’s function) geometries

\- Handles irregular frequencies using the CHIEF method

\- Allows for frequency-adaptive mesh refinement

## Known limitations
- Radiation impedance calculation is validated in 3D. 
  The 2D implementation has known discrepancies and is still under review.


**## Repository structure**



BEM/

├── BEM\_2D/       # 2D solver

├── BEM\_3D/       # 3D solver

├── examples/     # Example results (images)

├── LICENSE

└── README.md



**## Requirements**



\- MATLAB (tested on version R2025b)

\- No additional toolboxes required



**## Flowchart**

![Flowchart](diagrama_bem.png)



**## Licence**



This project is licensed under the \*\*PolyForm Noncommercial Licence 1.0.0\*\*. This means that you are free to use, study and modify the code for non-commercial purposes (study, research, portfolio), but its use for commercial purposes is not permitted without authorisation. Please refer to the \[LICENSE](LICENSE) file for further details.



**## Author**



Eliana Arques — Graduate in Physics (University of Alicante)

\[GitHub](https://github.com/EliArq) · \[LinkedIn](https://linkedin.com/in/eliana-arques)

