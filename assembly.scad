// =============================================================================
// ProArt PA602 - Support GPU Externe sur vis PSU
// Fichier : assembly.scad
// Description : Assemblage complet avec vue en situation (Châssis, PSU, GPU fantôme)
// =============================================================================

include <config.scad>;
use <psu_bracket.scad>;
use <riser_tray.scad>;
use <support_foot.scad>;

/* [Affichage des composants imprimés] */
show_psu_bracket  = true;
show_riser_tray   = true;
show_support_feet = true;

/* [Affichage des éléments fantômes de référence] */
show_dummy_psu    = true;
show_dummy_gpu    = true;
show_dummy_cables = true;

module dummy_psu_rear() {
    color([0.3, 0.3, 0.35, 0.45]) {
        difference() {
            // Face arrière de l'alimentation (150 x 86 mm)
            translate([-atx_psu_width/2, -2, -atx_psu_height/2])
                cube([atx_psu_width, 2, atx_psu_height]);

            // Emplacement prise secteur C14
            translate([-30, -3, -14])
                cube([32, 4, 24]);

            // Emplacement interrupteur I/O
            translate([15, -3, -10])
                cube([22, 4, 16]);
        }
    }

    // Fiche secteur C13 branchée (dégagée dans le tunnel central)
    if (show_dummy_cables) {
        color([0.15, 0.15, 0.15, 0.85]) {
            translate([-14, 0, -2]) {
                translate([-15, 0, -12])
                    cube([30, 38, 24]); // Corps de la fiche C13
                translate([0, 38, 0])
                    rotate([-90, 0, 0])
                        cylinder(d = 9, h = 45); // Câble secteur
            }
        }
    }
}

module dummy_gpu() {
    // Cotes exactes MSI GeForce RTX 5060 Ti 16G VENTUS 2X OC PLUS (V535-005R) : 227 x 127 x 41 mm (2 slots)
    gpu_length    = 227.0;
    gpu_height    = 127.0;
    gpu_thickness = 41.0;

    bracket_face_x = -riser_hole_spacing_x/2 - 12.5; // -66.5 mm
    pcb_y          = riser_Axis_y;                   // 20.0 mm
    backplate_y    = pcb_y - 5.0;                    // 15.0 mm

    // 1. Connecteur PCIe x16 + Riser PCB
    color([0.1, 0.45, 0.2, 0.85]) {
        translate([-riser_hole_spacing_x/2 - 8, pcb_y - 16, 0])
            cube([riser_hole_spacing_x + 16, 32, 3.0]); // PCB Riser
    }
    color([0.15, 0.15, 0.15, 0.9]) {
        translate([-45, pcb_y - 4.5, 3.0])
            cube([90, 9.0, 8.0]); // Slot PCIe x16
    }

    // 2. Corps du GPU (Backplate en -Y vers le boîtier, Ventilateurs en +Y vers l'extérieur)
    color([0.2, 0.6, 0.85, 0.45]) {
        translate([bracket_face_x + 1.5, backplate_y, 11.0])
            cube([gpu_length, gpu_thickness, gpu_height - 11.0]);
    }

    // 3. Plaque métallique arrière (Backplate) côté boîtier (-Y)
    color([0.25, 0.25, 0.3, 0.75]) {
        translate([bracket_face_x + 1.5, backplate_y - 1.5, 11.0])
            cube([gpu_length, 1.5, gpu_height - 11.0]);
    }

    // 4. Équerre métallique PCIe (côté -X) avec patte supérieure à 90° vers -X
    color([0.78, 0.78, 0.82, 0.9]) {
        // Face verticale avec ports HDMI/DP
        translate([bracket_face_x, pcb_y, -3.0])
            cube([1.5, gpu_thickness - 5.0, pcie_bracket_screw_h + 3.0]);
        // Patte pliée à 90° vers -X (reposant sur le sommet du portique à Z = pcie_bracket_screw_h)
        translate([bracket_face_x - 11.5, pcb_y, pcie_bracket_screw_h])
            cube([13.0, gpu_thickness - 5.0, 1.5]);
    }

    // 5. Ventilateurs stylisés (orientés vers l'extérieur +Y)
    color([0.12, 0.12, 0.12, 0.75]) {
        for (i = [0 : 1]) {
            translate([bracket_face_x + 66 + (i * 95), backplate_y + gpu_thickness, 11.0 + (gpu_height - 11.0)/2])
                rotate([-90, 0, 0])
                    cylinder(d = 88, h = 2.5);
        }
    }

    // 6. Connecteur d'alimentation 12VHPWR / 8-pin sur le dessus (+Z)
    if (show_dummy_cables) {
        color([0.9, 0.75, 0.15, 0.85]) {
            translate([bracket_face_x + gpu_length - 65, backplate_y + gpu_thickness/2, gpu_height + 6]) {
                cube([22, 14, 12], center = true);
                translate([0, -15, 10])
                    rotate([45, 0, 0])
                        cylinder(d = 10, h = 45);
            }
        }
    }
}

module full_assembly() {
    m4_bolt_x = psu_plate_width/2 - flange_width/2;

    // 1. Face arrière PSU de référence (Y = 0)
    if (show_dummy_psu) {
        dummy_psu_rear();
    }

    // 2. Pièce 1 : Support vissé sur l'alimentation (Bleu acier)
    if (show_psu_bracket) {
        color([0.18, 0.48, 0.70])
            psu_bracket();
    }

    // 3. Pièce 2 : Plateau Riser PCIe posé sur les semelles supérieures (Gris anthracite)
    if (show_riser_tray) {
        color([0.32, 0.35, 0.40])
            translate([0, standoff_depth, riser_elevation_from_psu_center])
                riser_tray();
    }

    // 4. Pièce 3 : Pieds d'appui sous les semelles inférieures (Noir carbone)
    if (show_support_feet && enable_support_foot) {
        color([0.18, 0.18, 0.20]) {
            for (side = [-1, 1]) {
                translate([side * m4_bolt_x, standoff_depth + 13, -psu_plate_height/2 - support_foot_height])
                    support_foot(support_foot_height);
            }
        }
    }

    // 5. GPU fantôme installé sur ses entretoises
    if (show_dummy_gpu) {
        translate([0, standoff_depth, riser_elevation_from_psu_center + riser_tray_thickness + riser_standoff_h])
            dummy_gpu();
    }
}

full_assembly();
