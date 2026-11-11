#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUTPUT_DIR="${SCRIPT_DIR}/stl_output"
PREVIEW_DIR="${SCRIPT_DIR}/previews"

mkdir -p "$OUTPUT_DIR"
mkdir -p "$PREVIEW_DIR"

echo "=== Génération des STL Binaires pour ProArt PA602 GPU Mount ==="

echo "1/3 Génération de psu_bracket.stl (Binary STL)..."
openscad --export-format binstl -o "${OUTPUT_DIR}/psu_bracket.stl" -D "part_to_render=1" "${SCRIPT_DIR}/print_plates.scad"

echo "2/3 Génération de riser_tray.stl (Binary STL)..."
openscad --export-format binstl -o "${OUTPUT_DIR}/riser_tray.stl" -D "part_to_render=2" "${SCRIPT_DIR}/print_plates.scad"

echo "3/3 Génération de support_foot.stl (Binary STL)..."
openscad --export-format binstl -o "${OUTPUT_DIR}/support_foot.stl" -D "part_to_render=3" "${SCRIPT_DIR}/print_plates.scad"

echo "=== Génération des rendus d'aperçu PNG ==="
xvfb-run -a openscad -o "${PREVIEW_DIR}/assembly_preview.png" --autocenter --viewall --imgsize=1920,1080 --colorscheme="Tomorrow Night" "${SCRIPT_DIR}/assembly.scad"
xvfb-run -a openscad -o "${PREVIEW_DIR}/psu_bracket_preview.png" --autocenter --viewall --imgsize=1280,720 "${SCRIPT_DIR}/psu_bracket.scad"
xvfb-run -a openscad -o "${PREVIEW_DIR}/riser_tray_preview.png" --autocenter --viewall --imgsize=1280,720 "${SCRIPT_DIR}/riser_tray.scad"

echo "Génération terminée avec succès dans :"
echo " - STLs (Binaires) : ${OUTPUT_DIR}"
echo " - Aperçus : ${PREVIEW_DIR}"
