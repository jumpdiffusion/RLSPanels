# RLSPanels

generate a panel of rectangles with both manually and randomly placed lines for aesthetics.

## Usage
Follow these steps in order
- Install Julia. Recommended to use `juliaup` to install julia.
- Navigate to the `RLSPanels` folder on your terminal.
- start julia there. Tips press `]` key to enter pkg manager mode in julia terminal and `backspace` key to go back to julia terminal from pkg mode.
- run this `activate .`, you might also have to run `instantiate` in `pkg>` mode. Now run `RLSPanels.main()` to generate pattern. You will have to import by running `using RLSPanels` first. It will open a very simple window. Click save button to save json and pdf.
```bash
	               _
   _       _ _(_)_     |  Documentation: https://docs.julialang.org
  (_)     | (_) (_)    |
   _ _   _| |_  __ _   |  Type "?" for help, "]?" for Pkg help.
  | | | | | | |/ _` |  |
  | | |_| | | | (_| |  |  Version 1.12.6 (2026-04-09)
 _/ |\__'_|_|_|\__'_|  |  Official https://julialang.org release
|__/                   |

(@v1.12) pkg> activate .
  Activating project at `~/Library/CloudStorage/GoogleDrive-sivapvarma@gmail.com/My Drive/BTS/MacMini_Downloads/gate_cad_mini/RLSPanels`

(RLSPanels) pkg> st
Project RLSPanels v0.1.0
Status `~/Library/CloudStorage/GoogleDrive-sivapvarma@gmail.com/My Drive/BTS/MacMini_Downloads/gate_cad_mini/RLSPanels/Project.toml`
  [5ae59095] Colors v0.13.1
  [31c24e10] Distributions v0.25.125
  [5789e2e9] FileIO v1.18.0
  [53c48c17] FixedPointNumbers v0.8.5
  [82e4d734] ImageIO v0.6.9
  [682c06a0] JSON v1.5.1
  [ae8d54c2] Luxor v4.5.0
  [510215fc] Observables v0.5.5
  [2db162a6] QML v0.13.0
  [295af30f] Revise v3.14.2
  [db9b398d] Serde v3.7.1
  [fa267f1f] TOML v1.0.3

(RLSPanels) pkg> instantiate

julia> using RLSPanels

julia> RLSPanels.main()
Found 'config.toml'. Loading parameters...
```

- `config.toml` should be very self explanatory, based on our discussions.
- rest of the things we can talk 1-1