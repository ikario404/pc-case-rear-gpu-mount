// =============================================================================
// ProArt PA602 - Support GPU Externe sur vis PSU
// Fichier : riser_tray.scad
// Description : Plateau support pour le riser PCIe, portique d'équerre PCIe
//               avec arche auto-porteuse et berceau anti-affaissement (anti-sag)
// =============================================================================

include <config.scad>;

// Coordonnées Y locales des vis M4 d'assemblage sur les bras PSU
tray_m4_y1 = 22.0;
tray_m4_y2 = 52.0;
tray_m4_x  = psu_plate_width/2 - flange_width/2; // ±73.0 mm

// Position X de la face interne de l'équerre métallique PCIe
bracket_face_x = -riser_hole_spacing_x/2 - 12.5; // -66.5 mm

module riser_tray() {
    tray_w = riser_tray_width;
    tray_d = riser_tray_depth;
    tray_h = riser_tray_thickness;

    // Hauteur du plan de pose de la languette supérieure de l'équerre PCIe
    tower_top_z = tray_h + riser_standoff_h + pcie_bracket_screw_h;
    tower_w     = (tray_w/2) + bracket_face_x; // De -86 à -66.5 = 19.5 mm
    pillar_d    = 12.0;

    difference() {
        union() {
            // 1. Plateau de base principal
            translate([-tray_w/2, 0, 0])
                cube([tray_w, tray_d, tray_h]);

            // 2. Nervures longitudinales de rigidification sous/sur les bords avant et arrière
            translate([-tray_w/2, 0, tray_h])
                cube([tray_w, 4.0, 3.0]);
            translate([-tray_w/2, tray_d - 4.0, tray_h])
                cube([tray_w, 4.0, 3.0]);

            // 3. Entretoises (Standoffs) pour le PCB du riser PCIe
            if (riser_hole_spacing_y == 0) {
                for (x_pos = [-riser_hole_spacing_x/2, riser_hole_spacing_x/2]) {
                    translate([x_pos, riser_Axis_y, tray_h])
                        cylinder(d = riser_screw_d + 6.5, h = riser_standoff_h);
                }
            } else {
                for (x_pos = [-riser_hole_spacing_x/2, riser_hole_spacing_x/2]) {
                    for (y_off = [-riser_hole_spacing_y/2, riser_hole_spacing_y/2]) {
                        translate([x_pos, riser_Axis_y + y_off, tray_h])
                            cylinder(d = riser_screw_d + 6.5, h = riser_standoff_h);
                    }
                }
            }

            // 4. Portique de verrouillage de l'équerre métallique PCIe (côté -X)
            // Conçu en portique ajouré pour laisser libre accès aux ports HDMI/DP et aux vis M4
            translate([-tray_w/2, 0, tray_h]) {
                // Pilier arrière (Y = 0 à 12)
                cube([tower_w, pillar_d, tower_top_z - tray_h]);

                // Pilier avant (Y = tray_d - 12 à tray_d)
                translate([0, tray_d - pillar_d, 0])
                    cube([tower_w, pillar_d, tower_top_z - tray_h]);

                // Traverse supérieure d'appui de la patte 90° de l'équerre PCIe
                translate([0, 0, tower_top_z - tray_h - 10])
                    cube([tower_w, tray_d, 10]);

                // Goussets à 45° sous la traverse supérieure pour impression FDM plus propre
                hull() {
                    translate([0, pillar_d - 1, tower_top_z - tray_h - 24])
                        cube([tower_w, 1, 14]);
                    translate([0, pillar_d + 13, tower_top_z - tray_h - 10])
                        cube([tower_w, 1, 1]);
                }
                hull() {
                    translate([0, tray_d - pillar_d, tower_top_z - tray_h - 24])
                        cube([tower_w, 1, 14]);
                    translate([0, tray_d - pillar_d - 14, tower_top_z - tray_h - 10])
                        cube([tower_w, 1, 1]);
                }

                // Butée latérale externe (à gauche de la patte 90° de l'équerre PCIe)
                translate([0, 0, tower_top_z - tray_h])
                    cube([4.5, tray_d, 4.0]);
            }

            // 5. Berceau d'appui arrière anti-affaissement (anti-sag) côté +X
            // Soutient la tranche inférieure du PCB et du carénage à la hauteur du slot PCIe
            cradle_x = riser_hole_spacing_x/2 + 6.0; // +60.0 mm (entre bossage riser et vis M4)
            cradle_z = riser_standoff_h + 11.0;      // Hauteur de la tranche inférieure du GPU
            translate([cradle_x, riser_Axis_y - 10, tray_h]) {
                // Socle d'appui sous le PCB et la backplate
                cube([8.0, 22.0, cradle_z]);
                // Lèvre arrière de maintien (côté backplate -Y)
                cube([8.0, 4.5, cradle_z + 10.0]);
                // Lèvre avant de maintien (côté radiateur +Y)
                translate([0, 17.5, 0])
                    cube([8.0, 4.5, cradle_z + 10.0]);
            }
        }

        // --- DÉCOUPES ET PERÇAGES ---

        // A. Fente centrale traversante pour le passage de la nappe souple du riser PCIe
        translate([-riser_cable_slot_w/2, riser_Axis_y - riser_cable_slot_d/2, -1])
            cube([riser_cable_slot_w, riser_cable_slot_d, tray_h + 6]);

        // B. Perçages M3 pour visser le PCB du riser + lamages inférieurs
        if (riser_hole_spacing_y == 0) {
            for (x_pos = [-riser_hole_spacing_x/2, riser_hole_spacing_x/2]) {
                translate([x_pos, riser_Axis_y, -1])
                    cylinder(d = riser_screw_d, h = tray_h + riser_standoff_h + 4);
                translate([x_pos, riser_Axis_y, -0.5])
                    cylinder(d = 6.5, h = 3.0);
            }
        } else {
            for (x_pos = [-riser_hole_spacing_x/2, riser_hole_spacing_x/2]) {
                for (y_off = [-riser_hole_spacing_y/2, riser_hole_spacing_y/2]) {
                    translate([x_pos, riser_Axis_y + y_off, -1])
                        cylinder(d = riser_screw_d, h = tray_h + riser_standoff_h + 4);
                    translate([x_pos, riser_Axis_y + y_off, -0.5])
                        cylinder(d = 6.5, h = 3.0);
                }
            }
        }

        // C. Perçages M4 + lamages pour assembler le plateau sur les bras de psu_bracket
        for (side = [-1, 1]) {
            x_pos = side * tray_m4_x;
            for (y_pos = [tray_m4_y1, tray_m4_y2]) {
                translate([x_pos, y_pos, -1])
                    cylinder(d = 4.3, h = tray_h + 6);
                translate([x_pos, y_pos, tray_h - 2.0])
                    cylinder(d = 8.2, h = 6.0);
            }
        }

        // D. Trous de vissage pour la patte supérieure de l'équerre métallique PCIe (vis 6-32 ou M3.5)
        for (slot_idx = [0 : gpu_slots - 1]) {
            slot_y = riser_Axis_y + 4.0 + (slot_idx * pcie_slot_pitch);
            translate([bracket_face_x - 6.0, slot_y, tower_top_z - 12])
                cylinder(d = 3.4, h = 15);
        }

        // E. Rainure inférieure pour loger les languettes basses de l'équerre métallique PCIe
        translate([bracket_face_x - 2.5, pillar_d + 1.0, 1.5])
            cube([3.5, tray_d - 2*pillar_d - 2.0, tray_h + 5.0]);

        // F. Passages pour colliers de serrage (zip-ties) de maintien des câbles
        for (zip_x = [-35, 35]) {
            for (zip_y = [6.0, 34.0]) {
                translate([zip_x - 2.0, zip_y, -1])
                    cube([4.0, 2.5, tray_h + 6]);
            }
        }
    }
}

riser_tray();
